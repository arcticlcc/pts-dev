<?php
namespace PTS\Console;

use Knp\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class MyCommand extends \Knp\Command\Command {
    protected function configure() {
        $this->setName("testcmd")->setDescription("A test command!");
    }

    protected function execute(InputInterface $input, OutputInterface $output) {
        $output->writeln("It works!");
    }

}
?>