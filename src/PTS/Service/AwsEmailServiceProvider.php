<?php
namespace PTS\Service;

use Aws\Common\Aws;
use Silex\Application;
use Silex\ServiceProviderInterface;

/**
 * Support for sending email via AWS SimpleEmailService.
 *
 * @uses ServiceProviderInterface
 * @version .1
 * @author Joshua Bradley <joshua_bradley@fws.gov>
 */

class AwsEmailServiceProvider implements ServiceProviderInterface {
    public function register(Application $app) {
        $app['ses.sendmail'] = $app->protect(function($mail, $account = false) use ($app) {
//echo $mail;
            // Get the Amazon SES client
            $ses = $app['aws']->get('Ses');
            return $ses->sendRawEmail(array(
                'Source' => $account ? $account : $app['session']->get('email'),
                //'Destinations' => array('string', ... ),
                // RawMessage is required
                'RawMessage' => array(
                    // Data is required
                    'Data' => base64_encode($mail),
                ),
            ));
        });
    }

    public function boot(Application $app) {
    }

}
?>