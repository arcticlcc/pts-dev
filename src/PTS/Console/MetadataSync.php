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
            ->addArgument(
                'schemas',
                InputArgument::IS_ARRAY | InputArgument::REQUIRED,
                'Which schema(s) to sync?'
            )
            ->addOption(
                'upload',
                'u',
                InputOption::VALUE_NONE,
                'If set, will upload to S3.'
            );
    }

    protected function execute(InputInterface $input, OutputInterface $output) {

        $app = $this->getSilexApplication();
        $schemas = $input->getArgument('schemas');
        $adiwg = new ADIwg($app);

        foreach ($schemas as $schema) {
            try {
                if(!isset($app['dbOptions'][$schema])) {
                    Throw new \Exception("No SQLite config found for $schema schema.");
                }

                $app['idiorm']->setPath($schema);
                $build = $adiwg->buildMetaDB(FALSE, $schema);
                $conn = $build ? $build : $app['dbs'][$schema];
                $conn->exec('PRAGMA journal_mode=WAL;');

                foreach (['project', 'product'] as $table) {
                    $conn->transactional(function($conn) use ($schema, $app, $adiwg, $output, $table) {
                        //delete existing records
                        $conn->delete($table, array('groupid' => $schema));
                        $query = $app['idiorm']->getTable($table)
                            ->where('exportmetadata', TRUE);
                        $items = $query->find_many();

                        if($items) {
                            $method = 'save' . ucfirst($table);
                            $getId = "{$table}id";
                            $output->writeln('Found ' . count($items) .
                                " $table records for $schema schema.");
                            foreach ($items as $item) {
                                $adiwg->$method($item->$getId, $schema, $conn);
                            }
                            $output->writeln("Sync completed for $schema::$table.");
                        }else {
                            $message = "No {$table}(s) found for $schema.";
                            $app['monolog']->addInfo($message);
                            $output->writeln($message);
                        }
                    });
                }
            } catch (\Exception $exc) {
                $app['monolog']->addError($exc->getMessage());
                die;
            }
        }

        $conn->exec('VACUUM;');

        try {
            if($input->getOption('upload')) {
                $s3Path = $conn->getParams()['path'];
                $s3Key = basename($s3Path);
                $result = $app['s3.upload']($s3Path, 'metadata.arcticlcc.org', "/sqlite/{$s3Key}.gz", TRUE);
                $message = "Uploaded to {$result['ObjectURL']}";
                $app['monolog']->addInfo($message);
                $output->writeln($message);
            }
        } catch (\Exception $exc) {
            $app['monolog']->addError($exc->getMessage());
        }
    }

}
?>