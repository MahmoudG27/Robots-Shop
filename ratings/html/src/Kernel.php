<?php

declare(strict_types=1);

namespace MG\RobotShop\Ratings;

use MG\RobotShop\Ratings\Controller\HealthController;
use MG\RobotShop\Ratings\Controller\RatingsApiController;
use MG\RobotShop\Ratings\Service\CatalogueService;
use MG\RobotShop\Ratings\Service\HealthCheckService;
use MG\RobotShop\Ratings\Service\RatingsService;
use Monolog\Formatter\LineFormatter;
use Symfony\Bundle\FrameworkBundle\FrameworkBundle;
use Symfony\Bundle\FrameworkBundle\Kernel\MicroKernelTrait;
use Symfony\Bundle\MonologBundle\MonologBundle;
use Symfony\Component\Config\Loader\LoaderInterface;
use Symfony\Component\DependencyInjection\ContainerBuilder;
use Symfony\Component\DependencyInjection\Reference;
use Symfony\Component\EventDispatcher\EventSubscriberInterface;
use Symfony\Component\HttpKernel\Event\ResponseEvent;
use Symfony\Component\HttpKernel\Kernel as BaseKernel;
use Symfony\Component\HttpKernel\KernelEvents;
use Symfony\Component\Routing\RouteCollectionBuilder;

class Kernel extends BaseKernel implements EventSubscriberInterface
{
    use MicroKernelTrait;

    public function registerBundles()
    {
        return [
            new FrameworkBundle(),
            new MonologBundle(),
        ];
    }

    /**
     * {@inheritdoc}
     */
    public static function getSubscribedEvents()
    {
        return [
            KernelEvents::RESPONSE => 'corsResponseFilter',
        ];
    }

    public function corsResponseFilter(ResponseEvent $event)
    {
        $response = $event->getResponse();

        $response->headers->add([
            'Access-Control-Allow-Origin' => '*',
            'Access-Control-Allow-Methods' => '*',
        ]);
    }

    protected function configureContainer(ContainerBuilder $c, LoaderInterface $loader): void
    {
        $c->loadFromExtension('framework', [
            'secret' => 'S0ME_SECRET',
        ]);

        $c->loadFromExtension('monolog', [
            'handlers' => [
                'stdout' => [
                    'type' => 'stream',
                    'level' => 'info',
                    'path' => 'php://stdout',
                    'channels' => ['!request'],
                ],
            ],
        ]);

        $mysqlHost = getenv('MYSQL_HOST') ?: 'mysql';
        $mysqlPort = getenv('MYSQL_PORT') ?: '3306';
        $mysqlDb   = getenv('MYSQL_DB') ?: 'ratings';
        $mysqlUser = getenv('MYSQL_USER') ?: 'ratings';
        $mysqlPass = getenv('MYSQL_PASSWORD') ?: 'ratings';

        $dsn = sprintf(
            'mysql:host=%s;port=%s;dbname=%s;charset=utf8mb4',
            $mysqlHost,
            $mysqlPort,
            $mysqlDb
        );

        $c->setParameter('pdo_dsn', $dsn);
        $c->setParameter('pdo_user', $mysqlUser);
        $c->setParameter('pdo_password', $mysqlPass);
        $c->setParameter('catalogueUrl', getenv('CATALOGUE_URL') ?: 'http://catalogue:8080');
        $c->setParameter('logger.name', 'RatingsAPI');


        $c->register(Database::class)
            ->addArgument($c->getParameter('pdo_dsn'))
            ->addArgument($c->getParameter('pdo_user'))
            ->addArgument($c->getParameter('pdo_password'))
            ->addMethodCall('setLogger', [new Reference('logger')])
            ->setAutowired(true);

        $c->register(CatalogueService::class)
            ->addArgument($c->getParameter('catalogueUrl'))
            ->addMethodCall('setLogger', [new Reference('logger')])
            ->setAutowired(true);

        $c->register(HealthCheckService::class)
            ->addArgument(new Reference('database.connection'))
            ->addMethodCall('setLogger', [new Reference('logger')])
            ->setAutowired(true);

        $c->register('database.connection', \PDO::class)
            ->setFactory([new Reference(Database::class), 'getConnection']);

        $c->setAlias(\PDO::class, 'database.connection');

        $c->register(RatingsService::class)
            ->addMethodCall('setLogger', [new Reference('logger')])
            ->setAutowired(true);

        $c->register(HealthController::class)
            ->addMethodCall('setLogger', [new Reference('logger')])
            ->addTag('controller.service_arguments')
            ->setAutowired(true);

        $c->register(RatingsApiController::class)
            ->addMethodCall('setLogger', [new Reference('logger')])
            ->addTag('controller.service_arguments')
            ->setAutowired(true);
    }

    protected function configureRoutes(RouteCollectionBuilder $routes)
    {
        $routes->import(__DIR__.'/Controller/', '/', 'annotation');
    }
}
