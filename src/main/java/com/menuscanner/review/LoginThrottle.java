package com.menuscanner.review;

import java.util.Iterator;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Slows down password guessing on the owner login: after {@link #MAX_FAILURES} wrong
 * passwords from the same IP within {@link #WINDOW_MS}, further attempts are refused
 * until the window passes. In memory only — a restart clears it, which is fine here.
 */
public final class LoginThrottle {

    private static final int  MAX_FAILURES = 8;
    private static final long WINDOW_MS    = 15 * 60 * 1000L;

    private record Entry(int failures, long windowStart) {}

    private static final Map<String, Entry> FAILURES = new ConcurrentHashMap<>();

    public static boolean isBlocked(String ip) {
        Entry e = FAILURES.get(ip);
        return e != null && e.failures() >= MAX_FAILURES
            && System.currentTimeMillis() - e.windowStart() < WINDOW_MS;
    }

    public static void recordFailure(String ip) {
        long now = System.currentTimeMillis();
        FAILURES.compute(ip, (k, e) -> e == null || now - e.windowStart() >= WINDOW_MS
                ? new Entry(1, now) : new Entry(e.failures() + 1, e.windowStart()));
        if (FAILURES.size() > 10_000) prune(now);
    }

    public static void recordSuccess(String ip) { FAILURES.remove(ip); }

    private static void prune(long now) {
        for (Iterator<Entry> it = FAILURES.values().iterator(); it.hasNext(); ) {
            if (now - it.next().windowStart() >= WINDOW_MS) it.remove();
        }
    }

    private LoginThrottle() {}
}
