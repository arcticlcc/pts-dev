<?php

namespace PTS\Service;

use Silex\Application;
use Silex\ServiceProviderInterface;
use Sabre\VObject;

/**
 * A quick and dirty service provider to render and send notices using the Google API.
 *
 * @uses ServiceProviderInterface
 * @uses GoogleServiceProvider
 * @version .1
 * @author Joshua Bradley <joshua_bradley@fws.gov>
 */

class NoticeServiceProvider implements ServiceProviderInterface
{
    public function register(Application $app)
    {
        $app['renderNotice'] = $app->protect(function (array $data, $template = 'notice') use ($app) {

            $due = (new \DateTime($data['duedate']));
            $duedate = $due->format('M jS, Y');

            //staff e-mail defaults to session
            $staff = isset($data['staff']) ? $data['staff'] : $app['session']->get('email');

            $body = $app['twig']->render("notices/{$template}.twig", array(
                'projectcode' => $data['projectcode'],
                'project' => $data['project'],
                'deliverable' => $data['title'],
                'pi' => $data['contact'],
                'agreementnumber' => $data['agreementnumber'],
                'projectofficer' => $data['projectofficer'],
                'duedate' => $duedate,
                'tense' => $due->diff(new \DateTime())->format('%r%a') > 0 ? 'was' : 'is',
                'staff' => $staff,
                'type' => $data['type'],
                'days' => $data['dayspastdue'],
                'start' => $data['startdate'],
                'end' => $data['enddate'],
            ));

            $cc = array(
                  //'jbradley@arcticlcc.org',
                );
            $cc[] = $staff;
            $cc = array_merge($cc, explode(',', $data['ccemail']));

            if(isset($data['ccadmin']) && $data['ccadmin']) {
                $cc = array_merge($cc, explode(',', $data['adminemail']));
            }

            $subject = sprintf('Reminder: %s for %s (%s) due %s', $data['title'], $data['agreementnumber'], $data['projectcode'], $duedate);

            $vcalendar = new VObject\Component\VCalendar();

            $vcalendar->add('VEVENT', [
                'SUMMARY' => 'Due: ' . $data['title'],
                'DTSTART' => $due->modify("+12 hours"),
                //'DTEND' => $due,
                'ORGANIZER' => $staff,
                'DESCRIPTION' => $subject
            ]);

            //Build the attachment
            $attachment = \Swift_Attachment::newInstance()
                ->setFilename('event.ics')
                ->setContentType('text/calendar')
                ->setBody($vcalendar->serialize());

            $email = \Swift_Message::newInstance()
                // Give the message a subject
                ->setSubject($subject)

                // Set the From address with an associative array
                // Note: Google API ignores these settings
                //->setFrom(array($staff => 'LCC Staff'))
                //->setSender(array($staff => 'LCC Staff'))
                ->setFrom(array('jbradley@arcticlcc.org' => 'Bradley'))
                ->setSender(array('jbradley@arcticlcc.org' => 'Josh'))

                // Set the To addresses with an associative array
                /*->setTo(
                    array_merge(
                        array(
                            'joshua_bradley@fws.gov'
                        ),
                        explode(',', $data['email'])
                    )
                )*/
                ->setTo(
                    array('jbradley@arcticlcc.org'=>'Josh')
                )
                // Set the To addresses with an associative array
                //->setCc($cc)

                // Give it a body
                ->setBody($body, 'text/html')

                // And optionally an alternative body
                //->addPart('<b>Here is <i>the</i> message itself</b>', 'text/html');

                // Attach it to the message
                ->attach($attachment);

            $msgId = $email->getHeaders()->get('Message-ID');

            $msgId->setId(time() . '.' . uniqid('pts') . '@arcticlcc.org');
            $email = $email->toString();
//var_dump($email);exit;
            return $email;
        });

        $app['recordNotice'] = $app->protect(function (array $data, $comment = NULL, \DateTime $date = NULL) use ($app) {
            $fdate = is_null($date) ? (new \DateTime())->format('Y-m-d') : $date->format('Y-m-d');
            $map = $app['notice.typeMap'];

            $rec = [
                'modificationid' => $data['modificationid'],
                'deliverableid' => $data['deliverableid'],
                'noticeid' => isset($map[$data['dayspastdue']]) ? $map[$data['dayspastdue']] : 0,
                'recipientid' => $data['contactid'],
                'contactid' => isset($data['senderid']) ? $data['senderid'] : 0, //default to system contact
                'datesent' => $fdate,
                'comment' => $comment ? $comment : 'This reminder was auto-generated.',
            ];

            $object = $app['idiorm']->getTable('deliverablenotice')->create();

            foreach ($rec as $key => $value) {
                $object->set($key, $value);
            }

            return $object->save();
        });

        $app['notice.typeMap'] = [
            -30 => 1, // "Thirty(30) day notice"
            1 =>2, // "First Overdue Notice"
            10 =>3, // "Second Overdue Notice"
            29 =>4, // "Final Overdue Notice"
            -14 =>5, // "Fourteen(14) day notice"
            -2 =>6, // "Two(2) day notice"
        ];

        $app['notice.getTemplateId'] = $app->protect(function ($id) {
            $map = [
                6 => 'financial',
                25 => 'performance'
            ];

            return isset($map[$id]) ? $map[$id] : 'notice';
        });
    }

    public function boot(Application $app) {
    }
}

?>
