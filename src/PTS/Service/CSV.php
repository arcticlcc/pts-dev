<?php

namespace PTS\Service;

use Symfony\Component\HttpFoundation\Response;


/**
 * A quick and dirty service to render a Csv response.
 *
 * @version .1
 * @author Joshua Bradley <joshua_bradley@fws.gov>
 */

class CSV
{

    public $data;
    private $statusCode;
    private $success;
    private $msg;
    private $total;
    private $title;

    public function __construct(array $data = null, $statusCode = 200, $success=true, $msg = false,$total = null)
    {
        $this->data = $data;
        $this->statusCode = $statusCode;
        $this->success = $success;
        $this->msg = $msg;
        $this->total = $total;
    }

    public function setAll(array $data = null, $statusCode = 200, $success=true, $msg = false, $total = null)
    {
        $this->data = $data;
        $this->statusCode = $statusCode;
        $this->success = $success;
        $this->msg = $msg;
        $this->total = $total;
        return $this;

    }

    public function setData($data)
    {
        $this->data = $data;
        return $this;
    }

    public function setStatusCode($code)
    {
        $this->statusCode = $code;
        return $this;
    }

    public function setTotal($total)
    {
        $this->total = $total;
        return $this;
    }

    public function setTitle($title)
    {
        $this->title = $title;
        return $this;
    }

    public function setMessage($message)
    {
        $this->msg = $message;
        return $this;
    }

    public function getCSV ($data) {
        $data = $data ? $data : $this->data;
        $zout = null;
        $path = dirname(__FILE__) . '/../../../web/pts/dl/pts-' . $this->title . '-'. date("mdY") .'-';

        //try {
            if ($data) {
                $out = $path . hash('crc32b',microtime(true)) . '.csv';
                while (file_exists($out)) {
                    $out = $path . hash('crc32b',microtime(true)) . '.csv';
                }
            //echo $out; exit;
                //get first row and assign csv column titles
                if(!($row = $data[0])) {
                    trigger_error("Caught Exception: No data returned.", E_USER_ERROR);
                }
                $csvHead = array(
                              'attribution'=>'This data file was created using the Project Tracking System on ' . date("D M j G:i:s T Y"),
                          );
                $csvSpacer = array(
                              'blank'=>''
                          );
                $csvCol = array_keys($row);
            //print_r($rkeys);
                //open file
                if (!$fp = fopen($out, 'w')) {
                    throw new \Exception("CANNOT OPEN $out");
                }
                fputcsv($fp, $csvHead);
                /*if($searchVal || $params['bbox']) {
                    fputcsv($fp, $csvSpacer);
                }
                if($searchVal) {
                    fputcsv($fp, array("Search Option", "Value"));
                    foreach ($searchVal as $k => $v) {
                        $v ? fputcsv($fp, array($k,$v)) : null;
                    }
                }
                if ($params['bbox']) {
                    $params['bbox'] ? fputcsv($fp, array('Map Bounds',$params['bbox'])) : null;
                }*/
                fputcsv($fp, $csvSpacer);
                fputcsv($fp, $csvCol);

                foreach($data as $csvRow) {
                    fputcsv($fp, $csvRow);
                }
                fclose($fp);
                //check filesize and zipup if > 1MB
                if (filesize($out) > 1048576) {
                    $zout = substr($out, 0, -3) . 'zip';
                    $zip = new ZipArchive();
                    if ($zip->open($zout, ZIPARCHIVE::CREATE)!==TRUE) {
                        throw new \Exception("cannot open <$zout>\n");
                    }
                    $zip->addFile($out,'pts.csv');
                    $zip->close();
                    $out = $zout;
                }
                $size = $this->formatBytes(filesize($zout) ?: filesize($out),0);
               // if($rawData) {
                    return array(
                        'file' => basename($out),
                        'zip' => (isset($zout) ? 1 : 0),
                        'size' => $size
                    );
                //}//else{
                //    echo '{"url":"../dl/' . basename($out) . '","zip":' . (isset($zout) ? 1 : 0) . ',"size":"' . $size . '"}';
                //}
            }else {
                throw new \Exception("No data returned.");
            }
        //}

        /*catch (\Exception $e) {
            trigger_error("Caught Exception: " . $e->getMessage(), E_USER_ERROR);
        }*/
    }

    public function getSuccess () {
        return $this->success;
    }

    public function getResponse($plain = false) {
        if(!$plain) {
            $this->json = array(
                'success' => $this->success,
            );

            if($this->data) {
                $this->json['data'] = $this->getCSV($this->data);
            }else{
                $this->json['data'] = array();
            }

            if($this->msg) {
                $this->json['message'] = $this->msg;
            }elseif(!$this->success) {
                $this->json['message'] = 'Error.';
            }

        }elseif($this->data) {
                $this->json = $this->data;
        }

        return new Response(json_encode($this->json), $this->statusCode, array(
            'Content-type' => 'application/json'
        ));
    }

    public function formatBytes($bytes, $precision = 2) {
        $units = array('B', 'KB', 'MB', 'GB', 'TB');

        $bytes = max($bytes, 0);
        $pow = floor(($bytes ? log($bytes) : 0) / log(1024));
        $pow = min($pow, count($units) - 1);

        // Uncomment one of the following alternatives
        $bytes /= pow(1024, $pow);
        // $bytes /= (1 << (10 * $pow));

        return round($bytes, $precision) . ' ' . $units[$pow];
    }
}

?>
