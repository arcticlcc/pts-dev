<?php
namespace PTS\Console;

use Knp\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Filesystem\Filesystem;
use Symfony\Component\Filesystem\Exception\IOExceptionInterface;
use Symfony\Component\Finder\Finder;
use Composer\Semver\Semver;

class SchemaUpdate extends \Knp\Command\Command {
    protected function configure() {
        $this
            ->setName("schema:update")
            ->setDescription("Compile and apply updated to the PTS schema(s).")
            ->addOption(
                'schema',
                's',
                InputOption::VALUE_REQUIRED,
                'Which schema to output? "all" is the default, pass "none" to skip.',
                'all'
            )
            ->addOption(
                'no-system',
                'x',
                InputOption::VALUE_NONE,
                'If set, will skip system schema updates.'
            );
    }

    protected function execute(InputInterface $input, OutputInterface $output) {

        $app = $this->getSilexApplication();
        $schema = $input->getOption('schema');
        $system = $input->getOption('no-system');
        $fs = new Filesystem();
        $empty_path = "SET search_path TO '';\n";

        try {
            $path =  dirname ( __FILE__ ) . '/../../../schema/';
            chdir($path);
            $versions = Semver::rsort(glob('*.*.*', GLOB_ONLYDIR));
            $path .= $versions[0];
        } catch (\Exception $e) {
            $output->writeln('<error>An error occurred while changing to directory: ' .
            $e->getContext()['path']) . '</error>';
            $app['monolog']->addError($e->getMessage());
        }

        $output->writeln("Begin;\n");

        if(!$system) {
            try {
              $finder = new Finder();
              $finder->files()->in($path . '/system')->name('*.sql' )->sortByName();
                $output->writeln("---- System ----\n\n");
                $output->writeln($empty_path);
                foreach ($finder as $file) {
                    $contents = $file->getContents();
                    $output->writeln("---- File: {$file->getBasename()} ----\n\n");
                    $output->writeln($contents);
                    $output->writeln($empty_path);
                }
            } catch (\Exception $e) {
                $output->writeln(
                '<error>An error occurred while processing the system files.</error>');
                $app['monolog']->addError($e->getMessage());
            }
        }

        $app_schemas = $app['dbOptions.schemas'];
        $app_schemas['dev'] = FALSE;

        if($schema !== 'none') {
            $schemas = $schema === 'all' ? array_keys($app_schemas, true) : [$schema];

            try {
              $finder = new Finder();
              $finder->files()->in($path . '/dev')->name('*.sql' )->sortByName();
              $contents = '';
                foreach ($finder as $file) {
                    $path = "SET search_path TO dev, public;\n\n";
                    $contents .= "---- File: {$file->getBasename()} ----\n\n";
                    $contents .= $path;
                    $contents .= $file->getContents();
                }
                //write out dev
                if($schema === 'all' || $schema === 'dev') {
                    $output->writeln("---- Schema: dev ----\n\n");
                    $output->writeln($contents);
                }
                //loop other schemas
                foreach ($schemas as $s) {
                    $s_path = "SET search_path TO $s, public;\n\n";
                    $s_contents = preg_replace("/".$path."/", $s_path, $contents);
                    $s_contents = preg_replace("/dev\./", $s . '.', $s_contents);
                    //write out schema
                    $output->writeln("---- Schema: $s ----\n\n");
                    $output->writeln($s_contents);
                }
            } catch (\Exception $e) {
                $output->writeln(
                '<error>An error occurred while processing the schema files.</error>');
                $app['monolog']->addError($e->getMessage());
            }
        }
    }
}
?>