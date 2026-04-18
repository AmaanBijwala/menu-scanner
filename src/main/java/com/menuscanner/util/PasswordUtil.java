package com.menuscanner.util;

import org.mindrot.jbcrypt.BCrypt;

public final class PasswordUtil {

    /** BCrypt work factor — increase to 13–14 if server hardware allows. */
    private static final int ROUNDS = 12;

    public static String hash(String plainText) {
        return BCrypt.hashpw(plainText, BCrypt.gensalt(ROUNDS));
    }

    public static boolean verify(String plainText, String hashed) {
        return BCrypt.checkpw(plainText, hashed);
    }

    private PasswordUtil() {}
}
