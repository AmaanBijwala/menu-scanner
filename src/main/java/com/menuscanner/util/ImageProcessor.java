package com.menuscanner.util;

import net.coobird.thumbnailator.Thumbnails;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;

/**
 * Resizes and saves uploaded images using Thumbnailator.
 * Output is always JPEG regardless of input format.
 */
public final class ImageProcessor {

    private static final int   MAX_WIDTH  = 800;
    private static final int   MAX_HEIGHT = 600;
    private static final float QUALITY    = 0.85f;

    /**
     * Reads from inputStream, resizes to fit within MAX_WIDTH x MAX_HEIGHT
     * (preserving aspect ratio), and writes a JPEG to targetFile.
     * Parent directories are created if they don't exist.
     */
    public static void saveResized(InputStream inputStream, File targetFile) throws IOException {
        targetFile.getParentFile().mkdirs();
        Thumbnails.of(inputStream)
                .size(MAX_WIDTH, MAX_HEIGHT)
                .keepAspectRatio(true)
                .outputFormat("jpg")
                .outputQuality(QUALITY)
                .toFile(targetFile);
    }

    private ImageProcessor() {}
}
