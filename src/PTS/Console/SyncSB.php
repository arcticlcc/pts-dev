<?php
namespace PTS\Console;

use Knp\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Filesystem\Exception\IOExceptionInterface;
use GuzzleHttp\Client;
use GuzzleHttp\Exception\RequestException;

class SyncSB extends \Knp\Command\Command
{
    protected function configure()
    {
        $this
            ->setName("sb:sync")
            ->setDescription("Fetch and update ScienceBase identifiers.")
            ->addOption(
                'schema',
                's',
                InputOption::VALUE_REQUIRED,
                'Which schema to update? "dev" is the default.',
                'dev'
            );
    }

    protected function execute(InputInterface $input, OutputInterface $output)
    {
        $app = $this->getSilexApplication();
        $schema = $input->getOption('schema');
        $app['idiorm']->setPath($schema);

        try {
            $sciencebaseid = $app['idiorm']->getTable('groupschema')
              ->find_one($schema)
              ->sciencebaseid;

            if (!$sciencebaseid) {
                throw new \Exception("No sciencebaseid found for $schema schema.");
            }
        } catch (\Exception $e) {
            $output->writeln('<error>An error occurred while changing to directory: ' .
            $e->getContext()['path']) . '</error>';
            $app['monolog']->addError($e->getMessage());
        }

        $output->writeln("Querying ScienceBase using id $sciencebaseid...\n");
        $app['monolog']->info("Querying ScienceBase using id $sciencebaseid...\n");

        try {
            $client = new Client();
            $url = "https://www.sciencebase.gov/catalog/items?ancestors={$sciencebaseid}&max=1700&format=json&fields=id,identifiers,browseType,files";
            $res = $client->request('GET', $url);
            //echo $res->getStatusCode();
          // "200"
          //dump($res->getHeader('content-type'));
          // 'application/json; charset=utf8'

          // {"type":"User".
        } catch (RequestException   $e) {
            $body = $e->getResponse() ? $e->getResponse()->getBody() : '';

            // $output->writeln('<error>An error occurred while querying ScienceBase: ' .
            // $body . '</error>');
            $app['monolog']->addError($e->getMessage());
            exit;
        }

        $data = json_decode($res->getBody());

        if ($data->total === 0) {
            $message = "No items found for id $sciencebaseid ({$url}).";
            //$output->writeln("<warning>{$message}</warning>");
            $app['monolog']->addWarning($message);
            return;
        }

        $output->writeln($data->total . ' items found.');
        $app['monolog']->info($data->total . ' items found.');

        $map = [];

        foreach ($data->items as $value) {
            if (property_exists($value, 'identifiers')) {
                $uuid = null;
                foreach ($value->identifiers as $ident) {
                    if ($ident->scheme == 'urn:uuid') {
                        $uuid = $ident->key;
                        break;
                    }
                }

                if ($uuid) {
                    $map[$uuid] = array('id' => $value->id, 'data' => array());

                    if (property_exists($value, 'files')) {
                        $file = null;
                        foreach ($value->files as $file) {
                            if ($file->name == 'md_metadata.json') {
                                $map[$uuid]['json'] = $file;
                                continue ;
                            }
                            if ($file->name == 'metadata.xml') {
                                $map[$uuid]['xml'] = $file;
                                continue ;
                            }

                            $map[$uuid]['data'][] = $file;
                        }
                    }
                    //get shapefiles
                    if (property_exists($value, 'facets')) {
                        $file = null;
                        foreach ($value->facets as $facet) {
                            if ($facet->className == 'gov.sciencebase.catalog.item.facet.ShapefileFacet') {
                                $file = (object) array(
                                  'downloadUri' => "https://www.sciencebase.gov/catalog/file/get/{$value->id}?facet={$facet->name}",
                                  'name' => "{$facet->name}_Shapefile.zip"
                                );
                                $map[$uuid]['data'][] = $file;
                            }
                        }
                    }
                }
            }
        }

        foreach ($map as $uuid => $item) {
            $sbid = $item['id'];
            $project = $app['idiorm']->getTable('project')
            ->where('uuid', $uuid)
            ->find_one();

            if ($project) {
                $project->set('sciencebaseid', $sbid)->save();
                continue;
            }

            $product = $app['idiorm']->getTable('product')
              ->where('uuid', $uuid)
              ->find_one();

            if ($product) {
                $product->set('sciencebaseid', $sbid)->save();

                if(isset($item['data'])) {
                  foreach ($item['data'] as $file) {
                    $this->insertLink($product->productid, $file, 1, "File stored on ScienceBase.");
                  }
                }
                if(isset($item['xml'])) {
                  $this->insertLink($product->productid, $item['xml'], 6, "ISO 19115-2 Metadata stored on ScienceBase.");
                }
                continue;
            }
            $app['monolog']->addWarning("No project or product found with uuid {$uuid} and sbid {$sbid}.");
        }
        $output->writeln('Sync complete.');
        $app['monolog']->info('Sync complete.');
    }

    protected function insertLink($id, $file, $func = 2, $desc="ScienceBase item") {
        $app = $this->getSilexApplication();
        $link = $app['idiorm']->getTable('onlineresource');
        $exists = $link->where(array(
                'productid' => $id,
                'uri' => $file->downloadUri
            ))->find_one();

        if(!$exists){
          $named=$app['idiorm']->getTable('onlineresource')->where(array(
                  'productid' => $id,
                  'title' => $file->name
              ))->find_one();

            if(!$named) {
              $link->create();
              $link->set('productid', $id);
              $link->set('onlinefunctionid', $func);
              $link->set('uri', $file->downloadUri);
              $link->set('title', $file->name);
              $link->set('description', $desc);
              $link->save();

              return;
            }

          $named->set('uri', $file->downloadUri)->save();
        }

    }
}
