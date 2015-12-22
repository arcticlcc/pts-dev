<?php
namespace PTS\Console;

use Knp\Command\Command;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Output\OutputInterface;
use PTS\Service\ADIwg;

class MetadataSync extends \Knp\Command\Command {
    protected function configure() {
        $this
            ->setName("metadata:sync")
            ->setDescription("Sync the metadata publication database.")
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
        $adiwg = new ADIwg($app);

        try {
            if(!isset($app['dbOptions'][$schema])) {
                Throw new \Exception("No SQLite config found for $schema schema.");
            }

            $app['idiorm']->setPath($schema);
            $build = $adiwg->buildMetaDB(FALSE, $schema);
            $conn = $build ? $build : $app['dbs'][$schema];
//dump($conn);

            foreach (['project','product'] as $table) {
                //delete existing records
                $conn->delete($table, array('groupid' => $schema));
                $query = $app['idiorm']->getTable($table)
                    ->where('exportmetadata', TRUE);
                $items = $query->find_many();

                if($items) {
                    $method = 'save' . ucfirst($table);
                    $getId = "{$table}id";
                    $app['monolog']->addInfo('Found ' . count($items) .
                        " $table records for $schema schema.");
                    foreach ($items as $item) {
                        $adiwg->$method($item->$getId, $schema);
                    }
                    $output->writeln('Sync completed.');
                }else {
                    $message = "No {$table}(s) found for $schema.";
                    $app['monolog']->addInfo($message);
                }
            }
        } catch (\Exception $exc) {
            $app['monolog']->addError($exc->getMessage());
        }
    }

}
?>