<?php

namespace MG\RobotShop\Ratings\Metrics;

use Prometheus\CollectorRegistry;
use Prometheus\Storage\Redis;

class MetricsRegistry
{
    public static function create(): CollectorRegistry
    {
        $adapter = new Redis([
            'host' => getenv('REDIS_HOST') ?: 'redis',
            'port' => 6379,
            'timeout' => 0.1,
            'read_timeout' => 10,
            'persistent_connections' => false,
        ]);

        return new CollectorRegistry($adapter);
    }
}
