<?php

namespace PTS\Service;

use Silex\Application;
use Silex\ServiceProviderInterface;

//use Google\Client;
//use Google\Service\Calendar;

//require_once 'Google/Client.php';
//require_once 'Google/Service/Calendar.php';

use Symfony\Component\HttpFoundation\Response;

class GoogleServiceProvider implements ServiceProviderInterface {

    public function register(Application $app) {

        $app['gcal'] = $app->protect(function($batch = false) use ($app) {
            $client = new \Google_Client();
            // Replace this with your application name.
            $client->setApplicationName("PTS Calendar Service");
            // Replace this with the service you are using.
            $service = new \Google_Service_Calendar($client);

            $token = $app['session']->get('service_token');
            if ($token) {
              $client->setAccessToken($token);
            }
            // This file location should point to the private key file.
            $key = file_get_contents($app['google']['key']);
            $cred = new \Google_Auth_AssertionCredentials(
              // Replace this with the email address from the client.
              $app['google']['service_account'],
              // Replace this with the scopes you are requesting.
              array(
                'https://www.googleapis.com/auth/calendar',
                'https://www.googleapis.com/auth/gmail.compose'
              ),
              $key
            );

            //$cred->sub = "jbradley@arcticlcc.org";

            $client->setAssertionCredentials($cred);

            if($client->getAuth()->isAccessTokenExpired()) {
              $client->getAuth()->refreshTokenWithAssertion($cred);
            }

            $app['session']->set('service_token',$client->getAccessToken());

            if ($batch) {
                $client->setUseBatch(TRUE);
                $batch = new \Google_Http_Batch($client);
                return array('batch'=>$batch,'service'=>$service);
            }

            return $service;
        });

        $app['eventData'] = $app->protect(function(\ORM $values) use ($app) {
            $event = array(
                'id' => bin2hex($app['session']->get('schema') . '-' . $values->deliverableid),
                'date' => $values->duedate,
                'summary' => $values->title,
                'desc' => "Project: $values->projectcode\nDescription: $values->description"
            );

            return $event;
         });

        $app['createEvent'] = $app->protect(function(array $data) use ($app) {
            $event = new \Google_Service_Calendar_Event();
            $event->setId($data['id']);
            $event->setSummary($data['summary']);
            $event->setDescription($data['desc']);
            //$event->setLocation('Somewhere');
            $start = new \Google_Service_Calendar_EventDateTime();
            $start->setDate($data['date']);
            $event->setStart($start);
            $end = new \Google_Service_Calendar_EventDateTime();
            $end->setDate($data['date']);
            $event->setEnd($end);
            $event->setStatus('confirmed');
            //attendees
            $att = array(
                array('email' => 'joshua_bradley@fws.gov', 'responseStatus' => 'accepted') ,
                //array('email' => 'suzanne_worker@fws.gov', 'responseStatus' => 'accepted')
            );
            //$event->setAttendees($att);

            return $event;
         });


        $app['insertEvent'] = $app->protect(function($event, $calId) use ($app) {
            $cal = $app['gcal']();
            //$calId = 'arcticlcc.org_abfo22c9ei4quuf4n50cs5qnlg@group.calendar.google.com';

            return $createdEvent = $cal->events->insert($calId, $event);

            //echo $createdEvent->getId();


            //$result = $cal->events->listEvents($calId);
            //print json_encode($result->getItems());

            /*$colors = $cal->colors->get();

            // Print available calendarListEntry colors.
            foreach ($colors->getCalendar() as $key => $color) {
              print "colorId : {$key}\n";
              print "  Background: {$color->getBackground()}\n";
              print "  Foreground: {$color->getForeground()}\n";
            }
            // Print available event colors.
            foreach ($colors->getEvent() as $key => $color) {
              print "colorId : {$key}\n";
              print "  Background: {$color->getBackground()}\n";
              print "  Foreground: {$color->getForeground()}\n";
            }*/
        });

        $app['updateEvent'] = $app->protect(function($event, $calId, $notice = false) use ($app) {
            $cal = $app['gcal']();
            $old = $cal->events->get($calId, $event->getId());
            $opt_params = array(
              'sendNotifications' => $notice
            );

            $event->setSequence($old->getSequence() + 1);
            //$calId = 'arcticlcc.org_abfo22c9ei4quuf4n50cs5qnlg@group.calendar.google.com';
            return $cal->events->update($calId, $event->getId(), $event, $opt_params);
        });

        $app['deleteEvent'] = $app->protect(function($eventId, $calId) use ($app) {
            $cal = $app['gcal']();
            //$calId = 'arcticlcc.org_abfo22c9ei4quuf4n50cs5qnlg@group.calendar.google.com';

            return $cal->events->delete($calId, $eventId);
        });

        $app['sendMail'] = $app->protect(function($email, $account = false) use ($app) {
            $client = new \Google_Client();
            $batch = false;

            if (is_array($email)) {
                $client->setUseBatch(TRUE);
                $batch = new \Google_Http_Batch($client);
            }
            // Replace this with your application name.
            $client->setApplicationName("PTS Calendar Service");
            $client->setClientId($app['google']['serviceid']);
            // Replace this with the service you are using.
            $mail = new \Google_Service_Gmail($client);

            $token = $app['session']->get('gmail_token');
            if ($token) {
              $client->setAccessToken($token);
            }
            // This file location should point to the private key file.
            $key = file_get_contents($app['google']['key']);
            $cred = new \Google_Auth_AssertionCredentials(
              // Replace this with the email address from the client.
              $app['google']['service_account'],
              // Replace this with the scopes you are requesting.
              array(
                'https://mail.google.com/'
              ),
              $key
            );

            //gmail account to use
            $cred->sub = $account ? $account : $app['session']->get('email');

            $client->setAssertionCredentials($cred);
            if($client->getAuth()->isAccessTokenExpired()) {
              $client->getAuth()->refreshTokenWithAssertion($cred);
            }

            $app['session']->set('service_token1',$client->getAccessToken());

            if($batch) {
                foreach ($email as $k => $e) {
                    $message = new \Google_Service_Gmail_Message();
                    $message->setRaw(\Google_Utils::urlSafeB64Encode($e));
                    $action = $mail->users_messages->send('me', $message);
                    $batch->add($action, $k);
                }

                $b = $batch->execute();

                $result = array();

                foreach ($b as $k => $r) {
                    $result[$k] = array();
                    if(method_exists($r,'getErrors')) {
                        $result[$k]['success'] = FALSE;
                        $result[$k]['errors'] = $r->getErrors();
                    } else {
                        $result[$k]['success'] = TRUE;
                    }
                }

                return $result;
            } else {
                $message = new \Google_Service_Gmail_Message();
                $message->setRaw(\Google_Utils::urlSafeB64Encode($email));

                return $mail->users_messages->send('me', $message);
            }
        });

        $app['gcalSync'] = $app->protect(function($data, $calId) use ($app) {
            ini_set('max_execution_time', 300);
            $service = $app['gcal']();
            $optParams = array('showDeleted' => TRUE);
            $events = $service->events->listEvents($calId, $optParams);
            $gcal = $app['gcal'](TRUE);
            $cal = $gcal['service'];
            $batch = $gcal['batch'];
            $update = array();

            //index data by eventid to make look-ups more efficient
            foreach ($data as $d) {
                $dataIdx[bin2hex($app['session']->get('schema') . '-' . $d->deliverableid)] = $d;
            }

            while(true) {
              foreach ($events->getItems() as $event) {
                $eid = $event->getId();
                if(isset($dataIdx[$eid])) {
                    //update
                    $update[$eid] = $event->getSequence() + 1;
                } else {
                    //delete
                    $del = $cal->events->delete($calId, $eid);
                    $batch->add($del, $eid);
                }
              }
              $pageToken = $events->getNextPageToken();
              if ($pageToken) {
                $optParams['pageToken'] = $pageToken;
                $events = $service->events->listEvents($calId, $optParams);
              } else {
                break;
              }
            }

            foreach ($dataIdx as $values) {
                //action, insert or update
                $eventData = $app['eventData']($values);

                $createdEvent = $app['createEvent']($eventData);

                if(isset($update[$createdEvent->getId()])) {
                    $createdEvent->setSequence($update[$createdEvent->getId()]);
                    $action = $cal->events->update($calId, $createdEvent->getId(), $createdEvent);
                } else {
                    $action = $cal->events->insert($calId, $createdEvent);
                }
                $batch->add($action, $createdEvent->getId());
            }

            $b = $batch->execute();

            $result['errors'] = array();

            foreach ($b as $r) {
                if(method_exists($r,'getErrors')) {
                    $result['errors'][] = $r->getErrors();
                }
            }

            return $result;

        });
    }

    public function boot(Application $app) {
    }

}

?>
