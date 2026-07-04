package com.polleria.util;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

public class ConfigLoader {

    private static Properties props;

    private static Properties getProps() {
        if (props == null) {
            props = new Properties();
            try (InputStream is = ConfigLoader.class.getClassLoader()
                    .getResourceAsStream("config.properties")) {
                if (is == null) {
                    throw new RuntimeException("No se encontró config.properties");
                }
                props.load(is);
            } catch (IOException e) {
                throw new RuntimeException("Error al cargar config.properties", e);
            }
        }
        return props;
    }

    public static String get(String key) {
        return getProps().getProperty(key);
    }
}
