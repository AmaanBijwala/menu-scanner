package com.menuscanner.dao;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Properties;

/**
 * Singleton HikariCP connection pool.
 * Initialized once on class load from application.properties.
 */
public class DBConnection {

    private static final HikariDataSource dataSource;

    static {
        try (InputStream is = DBConnection.class
                .getClassLoader()
                .getResourceAsStream("application.properties")) {

            if (is == null) throw new IOException("application.properties not found on classpath");

            Properties props = new Properties();
            props.load(is);

            HikariConfig config = new HikariConfig();
            config.setDriverClassName("org.postgresql.Driver");
            config.setJdbcUrl(props.getProperty("db.url"));
            config.setUsername(props.getProperty("db.username"));
            config.setPassword(props.getProperty("db.password"));
            config.setMaximumPoolSize(Integer.parseInt(props.getProperty("db.pool.maxSize", "10")));
            config.setMinimumIdle(2);
            config.setConnectionTimeout(30_000);
            config.setIdleTimeout(600_000);
            config.setMaxLifetime(1_800_000);

            dataSource = new HikariDataSource(config);

        } catch (IOException e) {
            throw new ExceptionInInitializerError("DB init failed: " + e.getMessage());
        }
    }

    /** Returns a connection from the pool. Caller MUST close it (use try-with-resources). */
    public static Connection getConnection() throws SQLException {
        return dataSource.getConnection();
    }

    private DBConnection() {}
}
