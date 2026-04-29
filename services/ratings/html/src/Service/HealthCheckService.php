<?php

declare(strict_types=1);

namespace MG\RobotShop\Ratings\Service;

use PDO;
use Psr\Log\LoggerAwareInterface;
use Psr\Log\LoggerAwareTrait;

class HealthCheckService implements LoggerAwareInterface
{
    use LoggerAwareTrait;

    /**
     * @var PDO
     */
    private $pdo;

    public function __construct(PDO $pdo)
    {
        $this->pdo = $pdo;
    }

    public function checkConnectivity(): bool
    {
        try {
            $stmt = $this->pdo->query('SELECT 1');
            return $stmt !== false;
        } catch (\Exception $e) {
            $this->logger->error('DB health check failed: ' . $e->getMessage());
            return false;
        }
    }
}
