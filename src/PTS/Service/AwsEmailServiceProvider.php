<?php
namespace PTS\Service;

use Aws\Common\Aws;
use Guzzle\Service\Exception\CommandTransferException;
use Silex\Application;
use Silex\ServiceProviderInterface;

/**
 * Support for sending "raw" email via AWS SimpleEmailService.
 *
 * @uses ServiceProviderInterface
 * @version .1
 * @author Joshua Bradley <joshua_bradley@fws.gov>
 */

class AwsEmailServiceProvider implements ServiceProviderInterface {
    public function register(Application $app) {
        $app['ses.sendmail'] = $app->protect(function(array $emails, $account = false) use ($app) {
            // Get the Amazon SES client
            $ses = $app['aws']->get('Ses');
            //Chunk 'em up to respect SES limit
            $emails_chunked = array_chunk($emails, $app['ses.limit'], true);
            $results = array();

            foreach ($emails_chunked as $e) {
                $commands = array();

                foreach ($e as $key => $email) {
                    $commands[] = $ses->getCommand('SendRawEmail', array(
                        'Source' => $account ? $account : $app['session']->get('email'),
                        //'Destinations' => array('string', ... ),
                        // RawMessage is required
                        'RawMessage' => array(
                            // Data is required
                            'Data' => base64_encode($email),
                        ),
                        'key.id' => $key,
                    ));
                }

                try {
                    $succeeded = $ses->execute($commands);
                } catch (CommandTransferException $e) {
                    $succeeded = $e->getSuccessfulCommands();
                    // Loop over the failed commands
                    foreach ($e->getFailedCommands() as $failedCommand) {
                        $results['failed'][$failedCommand['key.id']] = $failedCommand->getResult();
                    }
                }

                // Loop over the successful commands, which have now all been executed
                foreach ($succeeded as $command) {
                    $results['succeeded'][$command['key.id']] = $command->getResult();
                }

                //pause 1 second
                sleep(1);
            }

            return $results;
        });
    }

    public function boot(Application $app) {
    }

}
?>
