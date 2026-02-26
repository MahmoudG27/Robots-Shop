<?php

namespace MG\RobotShop\Ratings\Controller;

use Prometheus\RenderTextFormat;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;
use MG\RobotShop\Ratings\Metrics\MetricsRegistry;

class MetricsController
{
    /**
     * @Route("/metrics", methods={"GET"})
     */
    public function metrics(): Response
    {
        $registry = MetricsRegistry::create();

        $renderer = new RenderTextFormat();
        $result = $renderer->render($registry->getMetricFamilySamples());

        return new Response(
            $result,
            200,
            ['Content-Type' => RenderTextFormat::MIME_TYPE]
        );
    }
}