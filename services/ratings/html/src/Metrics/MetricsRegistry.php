<?php

namespace MG\RobotShop\Ratings\Metrics;

use Prometheus\CollectorRegistry;
use Prometheus\Storage\Redis;

class MetricsRegistry
{
    private static $registry;

    public static function getRegistry(): CollectorRegistry
    {
        if (!self::$registry) {
            $adapter = new Redis([
                'host' => getenv('REDIS_HOST') ?: 'redis',
                'port' => getenv('REDIS_PORT') ?: 6379,
                'timeout' => 0.1,
                'read_timeout' => 10,
                'persistent_connections' => false,
            ]);

            self::$registry = new CollectorRegistry($adapter);
        }

        return self::$registry;
    }
}