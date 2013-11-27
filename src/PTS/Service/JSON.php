<?php

namespace PTS\Service;

use Symfony\Component\HttpFoundation\Response;

/**
 * A quick and dirty service to render a JSON response.
 *
 * @version .1
 * @author Joshua Bradley <joshua_bradley@fws.gov>
 */

class JSON
{

    public $data;
    private $statusCode;
    private $success;
    private $msg;
    private $total;

    public function __construct(array $data = null, array $metadata = null, $statusCode = 200, $success=true, $msg = false,$total = null)
    {
        $this->data = $data;
        $this->metadata = $metadata;
        $this->statusCode = $statusCode;
        $this->success = $success;
        $this->msg = $msg;
        $this->total = $total;
    }

    public function setAll(array $data = null, $statusCode = 200, $success=true, $msg = false, $total = null, array $metadata = null)
    {
        $this->data = $data;
        $this->metadata = $metadata;
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

    public function setMetadata($metadata)
    {
        $this->metadata = $metadata;
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

    public function setMessage($message)
    {
        $this->msg = $message;
        return $this;
    }

    public function getJSON () {
        return json_encode($this->data);
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
                $this->json['data'] = $this->data;
            }else{
                $this->json['data'] = array();
            }

            if($this->metadata) {
                $this->json['metaData'] = $this->metadata;
            }

            if(!is_null($this->total)) {
                $this->json['total'] = $this->total;
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
}

?>
