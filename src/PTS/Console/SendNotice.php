<?php
namespace PTS\Console;

use Knp\Command\Command;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Output\OutputInterface;

class SendNotice extends \Knp\Command\Command {
    protected function configure() {
        $this
            ->setName("notice:send")
            ->setDescription("Send a notice for a deliverable.")
            ->addArgument(
                'deliverableId',
                InputArgument::REQUIRED,
                'The id of the deliverable to send a notice for.'
            )
            ->addArgument(
                'sender',
                InputArgument::REQUIRED,
                'The email account to send from.'
            )
            ->addOption(
                'schema',
                's',
                InputOption::VALUE_REQUIRED,
                'Which schema to use? "dev" is the default.',
                'dev'
            )
            ->addOption(
                'override',
                null,
                InputOption::VALUE_NONE,
                'If set, will ignore the automatic setting for the notice.'
            )
            ->addOption(
                'template',
                't',
                InputOption::VALUE_REQUIRED,
                'Which template to use? notice(default), financial, performance',
                'notice'
            );

    }

    protected function execute(InputInterface $input, OutputInterface $output) {

        $template = $input->getOption('template');
        $sender = $input->getArgument('sender');

        $app = $this->getSilexApplication();

        $schema = $input->getOption('schema');
        $app['idiorm']->setPath($schema);

        if ($id = $input->getArgument('deliverableId')) {
            $app['monolog']->addInfo("Querying for deliverable with id = $id");
        }

        $table = $app['idiorm']->getTable('deliverablereminder');
        //if override is not set, respect the reminder setting
        if (!$input->getOption('override')) {
            $table->where('reminder', TRUE);
        }
        $object = $table->find_one($id);

        if($object) {
            $data = $object->as_array();
            //cc admin if a financial report
            $data['ccadmin']  = in_array($data['deliverabletypeid'], [6,25]) ? TRUE : FALSE;
            $data['staff'] = $sender;

            $notice = $app['renderNotice']($data, $template);

            $resp = $app['ses.sendmail']([$notice], $sender);

            if(isset($resp['failed'])) {
                $message = "<error>FAILED to send message for $id: " . $resp['failed'][0]['Error']['Message'] . '</error>';
                $app['monolog']->addError($message);
            } else {
                $app['recordNotice']($data);
                $message = "Sent message for $id with id = " . $resp['succeeded'][0]['MessageId'];
                $app['monolog']->addInfo($message);
            }
        }else {
            $message = "No deliverable found with id of $id.";
            $app['monolog']->addWarning($message);
        }
    }

}
?>
