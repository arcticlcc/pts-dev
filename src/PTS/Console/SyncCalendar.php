<?php
namespace PTS\Console;

use Knp\Command\Command;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Output\OutputInterface;

class SyncCalendar extends \Knp\Command\Command {
    protected function configure() {
        $this
            ->setName("calendar:sync")
            ->setDescription("Sync the Google Calendar for the schema.")
            ->addOption(
                'schema',
                's',
                InputOption::VALUE_REQUIRED,
                'Which schema to use? "dev" is the default.',
                'dev'
            );

    }

    protected function execute(InputInterface $input, OutputInterface $output) {

        $app = $this->getSilexApplication();
        $schema = $input->getOption('schema');

        try {
            $app['idiorm']->setPath($schema);
            $calendar = $app['idiorm']->getTable('groupschema')
                ->find_one($schema)
                ->deliverablecalendarid;

            if(!$calendar) {
                Throw new \Exception("No calendar found for $schema schema.");
            }

            $table = $app['idiorm']->getTable('deliverablecalendar');
            $events = $table->find_many();

            if($events) {
                $app['monolog']->addInfo('Found ' . count($events) .
                    " events for $schema schema with calendar: $calendar..");
                $result = $app['gcalSync']($events, $calendar, $schema);
                $app['monolog']->addInfo(print_r($result, TRUE));
                $output->writeln('Sync completed with ' .count($result['errors']) . ' error(s)');
            }else {
                $message = "No events found for $schema schema with calendar: $calendar.";
                $app['monolog']->addInfo($message);
            }

        } catch (\Exception $exc) {
            $app['monolog']->addError("{$exc->getMessage()}, line {$exc->getLine()} in {$exc->getFile()}");
        }
    }

}
?>