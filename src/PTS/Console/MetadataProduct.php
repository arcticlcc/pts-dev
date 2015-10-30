<?php
namespace PTS\Console;

use Knp\Command\Command;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Output\OutputInterface;

class MetadataProduct extends \Knp\Command\Command {
    protected function configure() {
        $this
            ->setName("metadata:product")
            ->setDescription("Generate metadata for a product.")
            ->addArgument(
                'productid',
                InputArgument::REQUIRED,
                'The productid (primary key).'
            )
            ->addOption(
                'format',
                'f',
                InputOption::VALUE_REQUIRED,
                'Which format? html, xml, json',
                'json'
            )
            ->addOption(
                'schema',
                's',
                InputOption::VALUE_REQUIRED,
                'Which schema to use? "dev" is the default.',
                'dev'
            )
            ->addOption(
                'pretty-print',
                'p',
                InputOption::VALUE_NONE,
                'If set, will pretty print json.'
            );

    }

    protected function execute(InputInterface $input, OutputInterface $output) {

        $id = $input->getArgument('productid');
        $format = $input->getOption('format');
        $pretty = $input->getOption('pretty-print');

        $app = $this->getSilexApplication();

        $schema = $input->getOption('schema');
        $app['idiorm']->setPath($schema);

        $app['monolog']->addInfo("Querying for productid($id).");

            try{
                $json = $app['adiwg']->renderProduct($app['adiwg']->getProduct($id, TRUE));

                switch ($format) {
                    case 'xml':
                        $out = $app['adiwg']->translate($json);
                        break;
                    case 'html':
                        $out = $app['adiwg']->translate($json, 'html');
                        break;
                    case 'json':
                    default:
                       $out = $pretty ? json_encode(json_decode($json), JSON_PRETTY_PRINT) : $json;
                }
                $output->writeln($out);

            } catch (\Exception $exc) {
                $app['monolog']->addError($exc->getMessage());

                $output->writeln($exc->getMessage());
            }

    }

}
?>