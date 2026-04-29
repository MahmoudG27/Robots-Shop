package com.mg.robotshop.shipping;

import java.sql.Connection;
import java.sql.SQLException;
import javax.sql.DataSource;

import org.springframework.jdbc.datasource.AbstractDataSource;
import org.springframework.retry.annotation.Retryable;
import org.springframework.retry.annotation.Backoff;

class RetryableDataSource extends AbstractDataSource {
    private DataSource delegate;

    public RetryableDataSource(DataSource delegate) {
        this.delegate = delegate;
    }

    @Override
    @Retryable(maxAttempts = 3, backoff = @Backoff(delay = 2000))
    public Connection getConnection() throws SQLException {
        return delegate.getConnection();
    }

    @Override
    @Retryable(maxAttempts = 3, backoff = @Backoff(delay = 2000))
    public Connection getConnection(String username, String password) throws SQLException {
        return delegate.getConnection(username, password);
    }
}