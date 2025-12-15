package org.gradle.wrapper;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Properties;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

/**
 * Minimal Gradle wrapper replacement that downloads the configured distribution
 * and executes it. This is a lightweight stand-in for the standard wrapper that
 * is suitable for offline generation environments.
 */
public class GradleWrapperMain {
    public static void main(String[] args) throws Exception {
        File wrapperDir = locateWrapperDir();
        Properties properties = loadProperties(wrapperDir);
        String distributionUrl = properties.getProperty("distributionUrl");
        if (distributionUrl == null) {
            throw new IllegalStateException("distributionUrl is not defined in gradle-wrapper.properties");
        }

        Path gradleHome = prepareDistribution(properties, distributionUrl, wrapperDir.getParentFile());
        File gradleScript = gradleHome.resolve("bin/gradle").toFile();
        if (!gradleScript.canExecute()) {
            gradleScript.setExecutable(true);
        }

        ProcessBuilder builder = new ProcessBuilder();
        builder.command(gradleScript.getAbsolutePath());
        builder.command().addAll(java.util.Arrays.asList(args));
        builder.inheritIO();
        Process process = builder.start();
        int exitCode = process.waitFor();
        if (exitCode != 0) {
            System.exit(exitCode);
        }
    }

    private static File locateWrapperDir() throws Exception {
        File jarFile = new File(GradleWrapperMain.class.getProtectionDomain()
                .getCodeSource()
                .getLocation()
                .toURI());
        return jarFile.getParentFile();
    }

    private static Properties loadProperties(File wrapperDir) throws IOException {
        Properties properties = new Properties();
        try (FileInputStream fis = new FileInputStream(new File(wrapperDir, "gradle-wrapper.properties"))) {
            properties.load(fis);
        }
        return properties;
    }

    private static Path prepareDistribution(Properties properties, String distributionUrl, File projectDir)
            throws Exception {
        String distributionBase = properties.getProperty("distributionBase", "GRADLE_USER_HOME");
        String distributionPath = properties.getProperty("distributionPath", "wrapper/dists");
        String zipStoreBase = properties.getProperty("zipStoreBase", distributionBase);
        String zipStorePath = properties.getProperty("zipStorePath", distributionPath);

        Path baseDir = resolveBaseDir(distributionBase, projectDir);
        Path distributionDir = baseDir.resolve(distributionPath);
        String archiveName = distributionUrl.substring(distributionUrl.lastIndexOf('/') + 1);
        Path zipStoreDir = resolveBaseDir(zipStoreBase, projectDir).resolve(zipStorePath);
        Files.createDirectories(zipStoreDir);

        Path downloadedZip = zipStoreDir.resolve(archiveName);
        if (!Files.exists(downloadedZip)) {
            download(distributionUrl, downloadedZip);
        }

        String extractedName = archiveName.replace(".zip", "");
        String gradleFolder = extractedName.replace("-bin", "").replace("-all", "");
        Path extractedDir = distributionDir.resolve(extractedName).resolve(gradleFolder);
        if (!Files.exists(extractedDir)) {
            unzip(downloadedZip, distributionDir.resolve(extractedName));
        }
        return extractedDir;
    }

    private static Path resolveBaseDir(String base, File projectDir) {
        if ("PROJECT".equals(base)) {
            return projectDir.toPath();
        }
        String gradleUserHome = System.getenv("GRADLE_USER_HOME");
        if (gradleUserHome == null || gradleUserHome.isEmpty()) {
            gradleUserHome = System.getProperty("user.home") + File.separator + ".gradle";
        }
        return Paths.get(gradleUserHome);
    }

    private static void download(String url, Path target) throws Exception {
        System.out.println("Downloading Gradle from " + url);
        Files.createDirectories(target.getParent());
        HttpURLConnection connection = (HttpURLConnection) new URL(url).openConnection();
        connection.setInstanceFollowRedirects(true);
        try (BufferedInputStream in = new BufferedInputStream(connection.getInputStream());
             FileOutputStream fos = new FileOutputStream(target.toFile());
             BufferedOutputStream out = new BufferedOutputStream(fos)) {
            byte[] buffer = new byte[8192];
            int read;
            while ((read = in.read(buffer)) != -1) {
                out.write(buffer, 0, read);
            }
        }
    }

    private static void unzip(Path zipFile, Path targetDir) throws IOException {
        System.out.println("Extracting Gradle to " + targetDir);
        Files.createDirectories(targetDir);
        try (ZipInputStream zis = new ZipInputStream(new BufferedInputStream(new FileInputStream(zipFile.toFile())))) {
            ZipEntry entry;
            while ((entry = zis.getNextEntry()) != null) {
                Path entryPath = targetDir.resolve(entry.getName());
                if (entry.isDirectory()) {
                    Files.createDirectories(entryPath);
                } else {
                    Files.createDirectories(entryPath.getParent());
                    try (BufferedOutputStream bos = new BufferedOutputStream(new FileOutputStream(entryPath.toFile()))) {
                        byte[] buffer = new byte[8192];
                        int read;
                        while ((read = zis.read(buffer)) != -1) {
                            bos.write(buffer, 0, read);
                        }
                    }
                }
                zis.closeEntry();
            }
        }
    }
}
