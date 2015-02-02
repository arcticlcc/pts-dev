<?php
namespace PTS\Console;

use Knp\Command\Command;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Output\OutputInterface;

class BatchNotice extends \Knp\Command\Command {
    protected function configure() {
        $this
            ->setName("notice:batch")
            ->setDescription("Send a batch of notice(s) for deliverable(s).")
            ->addArgument(
                'daysdue',
                InputArgument::REQUIRED,
                'The number of days due(+/-). This determines which deliverables to generate notices for. Days in the future are indicated using a minus(-).'
            )
            ->addArgument(
                'sender',
                InputArgument::REQUIRED,
                'The email account to send from.'
            )
            ->addOption(
                'override',
                null,
                InputOption::VALUE_NONE,
                'If set, will ignore the automatic setting for the notice.'
            )
            ->addOption(
                'schema',
                's',
                InputOption::VALUE_REQUIRED,
                'Which schema to use? "dev" is the default.',
                'dev'
            );

    }

    protected function execute(InputInterface $input, OutputInterface $output) {

        $sender = $input->getArgument('sender');

        $app = $this->getSilexApplication();

        $schema = $input->getOption('schema');
        $app['idiorm']->setPath($schema);

        if ($days = $input->getArgument('daysdue')) {
            $app['monolog']->addInfo("Querying for deliverables due in $days day(s).");
        }

        $table = $app['idiorm']->getTable('deliverablereminder');
        //if override is not set, respect the reminder setting
        if (!$input->getOption('override')) {
            $table->where('reminder', TRUE);
        }
        $table->where('dayspastdue', $days)
            ->where_raw('(deliverablestatusid < ? OR deliverablestatusid IS NULL)', array(10));

        $objects = $table->find_many();
        $notices = array();

        if($objects) {
            $app['monolog']->addInfo('Found ' . count($objects) . " deliverables due in $days day(s).");
            $dataset = array();

            foreach ($objects as $object) {
                $data = $object->as_array();
                //cc admin if a financial report
                $data['ccadmin']  = in_array($data['deliverabletypeid'], [6,25]) ? TRUE : FALSE;
                $template = $data['ccadmin'] ? 'financial' : 'notice';
                $data['staff'] = $sender;
                $notices[$data['deliverableid']] = $app['renderNotice']($data, $template);
                //index the data objects by id
                $dataset[$data['deliverableid']] = $data;
            }
            $resp = $app['sendMail']($notices, $sender);

            foreach ($resp as $id => $m) {
                $status = $m['success'] ? '<info>SUCCESS</info>' : '<error>FAILED</error>';
                $pid = (explode( '-', $id));
                $message = "$status: Send message for deliverable with id = {$pid[1]} \n";
                $app['monolog']->addInfo($message);
                //record notices for successful responses
                if($m['success']) $app['recordNotice']($dataset[$pid[1]]);
            }
        }else {
            $message = "No deliverables found due in $days day(s).";
            $app['monolog']->addInfo($message);
        }
    }

}
?>