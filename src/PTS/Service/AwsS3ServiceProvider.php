<?php
namespace PTS\Service;

use Aws\Common\Aws;
use Guzzle\Service\Exception\CommandTransferException;
use Silex\Application;
use Silex\ServiceProviderInterface;

/**
 * Support for sending files to AWS S3 bucket.
 *
 * @uses ServiceProviderInterface
 * @version .1
 * @author Joshua Bradley <joshua_bradley@fws.gov>
 */

class AwsS3ServiceProvider implements ServiceProviderInterface {
    public function register(Application $app) {
        $app['s3.upload'] = $app -> protect(function($file, $bucket, $key , $compress = FALSE) use ($app) {

            // Get the Amazon S3 client
            $s3 = $app['aws'] -> get('s3');
            //return $results;

            if ($compress) {
                // Name of compressed gz file
                $gzfile = "$file.gz";

                // Open the gz file (w9 is the highest compression)
                $fp = gzopen ($gzfile, 'w9');

                // Compress the file
                gzwrite ($fp, file_get_contents($file));

                //close the file after compression is done
                gzclose($fp);

                $file = $gzfile;
            }

            // Upload an object to Amazon S3
            // $result = $s3->putObject(array(
            //     'Bucket' => $bucket,
            //     'Key'    => $key,
            //     'Body'   => fopen($file, 'r+')
            // ));

            $result = $s3->upload($bucket, $key, fopen($file, 'r+'));

            if ($compress) {
                unlink($file);
            }

            return $result;
        });
    }

    public function boot(Application $app) {
    }

}
?>
