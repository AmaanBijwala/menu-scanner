package com.menuscanner.util;

import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPool;
import redis.clients.jedis.JedisPoolConfig;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

/**
 * Redis cache for public menu JSON.
 * Uses JedisPool (thread-safe); never share a raw Jedis instance across threads.
 *
 * Cache key:  "menu:{restaurantId}"
 * TTL:        1 hour (MENU_CACHE_TTL_SECONDS)
 * Invalidate: on every menu INSERT / UPDATE / DELETE via MenuCRUDServlet
 */
public final class RedisCache {

    private static final int MENU_CACHE_TTL_SECONDS = 3_600; // 1 hour
    private static final JedisPool pool;

    static {
        try (InputStream is = RedisCache.class
                .getClassLoader()
                .getResourceAsStream("application.properties")) {

            if (is == null) throw new IOException("application.properties not found");

            Properties props = new Properties();
            props.load(is);

            String host = props.getProperty("redis.host", "localhost");
            int    port = Integer.parseInt(props.getProperty("redis.port", "6379"));

            JedisPoolConfig cfg = new JedisPoolConfig();
            cfg.setMaxTotal(16);
            cfg.setMaxIdle(8);
            cfg.setMinIdle(2);
            cfg.setTestOnBorrow(true);

            pool = new JedisPool(cfg, host, port, 2_000);

        } catch (IOException e) {
            throw new ExceptionInInitializerError("Redis init failed: " + e.getMessage());
        }
    }

    public static String getMenu(long restaurantId) {
        try (Jedis jedis = pool.getResource()) {
            return jedis.get("menu:" + restaurantId);
        }
    }

    public static void setMenu(long restaurantId, String json) {
        try (Jedis jedis = pool.getResource()) {
            jedis.setex("menu:" + restaurantId, MENU_CACHE_TTL_SECONDS, json);
        }
    }

    /** Call this after any INSERT / UPDATE / DELETE on menu_items. */
    public static void invalidateMenu(long restaurantId) {
        try (Jedis jedis = pool.getResource()) {
            jedis.del("menu:" + restaurantId);
        }
    }

    private RedisCache() {}
}
