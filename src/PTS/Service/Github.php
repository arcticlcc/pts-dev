<?php

namespace PTS\Service;

/**
 * GitHub API interface.
 *
 * @version .1
 * @author Joshua Bradley <joshua_bradley@fws.gov>
 */

class Github {

    private $app;

    public function __construct($app) {
        $this->app = $app;
        $this->client = $this->client();
    }

    public function client() {
      $client = new \Github\Client();
      //$client->authenticate($this->app['github_config']['user'], $this->app['github_config']['token'], \Github\Client::AUTH_HTTP_TOKEN);
      return $client;
    }

}
