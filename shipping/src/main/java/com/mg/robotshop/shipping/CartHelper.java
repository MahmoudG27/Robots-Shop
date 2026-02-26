package com.mg.robotshop.shipping;

import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.client.config.RequestConfig;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.BufferedReader;
import java.io.InputStreamReader;

public class CartHelper {

    private static final Logger logger = LoggerFactory.getLogger(CartHelper.class);
    private final String baseUrl;

    public CartHelper(String baseUrl) {
        this.baseUrl = baseUrl;
    }

    public String addToCart(String id, String data) {
        StringBuilder buffer = new StringBuilder();

        RequestConfig config = RequestConfig.custom()
                .setConnectTimeout(5000)
                .setSocketTimeout(5000)
                .build();

        try (CloseableHttpClient client = HttpClients.custom()
                .setDefaultRequestConfig(config)
                .build()) {

            HttpPost post = new HttpPost(baseUrl + id);
            post.setEntity(new StringEntity(data));
            post.setHeader("Content-Type", "application/json");

            try (CloseableHttpResponse res = client.execute(post)) {
                if (res.getStatusLine().getStatusCode() == 200) {
                    BufferedReader reader =
                            new BufferedReader(new InputStreamReader(res.getEntity().getContent()));
                    reader.lines().forEach(buffer::append);
                } else {
                    logger.warn("Cart service returned {}", res.getStatusLine().getStatusCode());
                }
            }
        } catch (Exception e) {
            logger.error("Error calling cart service", e);
        }

        return buffer.toString();
    }
}