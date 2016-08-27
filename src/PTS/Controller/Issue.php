<?php

namespace PTS\Controller;

use Silex\Application;
use Silex\ControllerProviderInterface;
use Symfony\Component\HttpFoundation\Request;

/**
 * Controller for userinfo.
 *
 * @uses ControllerProviderInterface
 *
 * @version .1
 *
 * @author Joshua Bradley <joshua_bradley@fws.gov>
 */
class Issue implements ControllerProviderInterface
{
    public function connect(Application $app)
    {
        $controllers = $app['controllers_factory'];

        $controllers->get('github/issue', function (Application $app) {
            try {
                $result = $app['github']
                    ->client->api('issue')
                    ->all('arcticlcc', $app['github_config']['repo'], array('state' => 'open'));
                foreach ($result as $key => $issue) {
                    $result[$key]['html'] = $app['markdown']->transform($issue['body']);
                }

                $app['json']->setData($result);
            } catch (Exception $exc) {
                $this->app['monolog']->addError($exc->getMessage());

                $this->app['json']->setAll(null, 409, false, $exc->getMessage());
            }

            return $app['json']->getResponse();
        });

        $controllers->post('github/issue', function (Application $app, Request $request) {
            $values = json_decode($request->getContent());

            try {
                if(!$values || !isset($values->title) || !isset($values->body)) {
                  throw new \Exception("Error Processing JSON");
                }

                $result = $app['github']
                    ->client->api('issue')
                    ->create('arcticlcc', $app['github_config']['repo'], array(
                      'title' => $values->title,
                      'body' => $values->body . " \nSubmitted by: " . $app['session']->get('user')['openid'],
                      'assignees' => [$app['github_config']['user']]
                    ));

                $app['json']->setData($result);
            } catch (Exception $exc) {
                $this->app['monolog']->addError($exc->getMessage());

                $this->app['json']->setAll(null, 409, false, $exc->getMessage());
            }

            return $app['json']->getResponse();
        });

        return $controllers;
    }
}
