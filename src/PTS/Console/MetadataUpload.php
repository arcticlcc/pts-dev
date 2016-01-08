<?php
namespace PTS\Console;

use Knp\Command\Command;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Output\OutputInterface;

class MetadataUpload extends \Knp\Command\Command {
    protected function configure() {
        $this
            ->setName("metadata:upload")
            ->setDescription("Upload the metadata publication database to S3.")
            ->addArgument(
                'file',
                InputArgument::REQUIRED,
                'The file to upload.'
            )
            ->addArgument(
                'bucket',
                InputArgument::REQUIRED,
                'S3 bucket.'
            )
            ->addOption(
                'key',
                'k',
                InputOption::VALUE_REQUIRED,
                'The destination path to use. Defaults to the name of the uploaded file.',
                FALSE
            )
            ->addOption(
                'compress',
                'c',
                InputOption::VALUE_NONE,
                'Compress the file using gz?'
            )
            ->addOption(
                'time',
                't',
                InputOption::VALUE_OPTIONAL,
                'Time in seconds. If provided, file modification must have occurred within this
                    interval.'
            );
    }

    protected function execute(InputInterface $input, OutputInterface $output) {

        $app = $this->getSilexApplication();
        $file = $input->getArgument('file');
        $bucket = $input->getArgument('bucket');
        $key = $input->getOption('key') ? $input->getOption('key') : basename($file);
        $compress = $input->getOption('compress');
        $time = $input->getOption('time');
        $inv = time()-filemtime($file);

        try {
            if (!file_exists($file)) {
                Throw new \Exception("Could not find file $file.");
            }
            
            if(!$time || ($time > $inv)) {
                $result = $app['s3.upload']($file, $bucket, $key, $compress);
                $message = "Uploaded to {$result['ObjectURL']}";
                $app['monolog']->addInfo($message);
                $output->writeln($message);
            } else {
                $output->writeln("File $file is older than $time seconds ($inv).");
            }
        } catch (\Exception $exc) {
            $app['monolog']->addError($exc->getMessage());
        }
    }

}
?>