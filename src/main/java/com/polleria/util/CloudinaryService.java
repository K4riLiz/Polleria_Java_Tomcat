package com.polleria.util;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import java.util.Map;

public class CloudinaryService {

    private static Cloudinary cloudinary;

    private static Cloudinary getInstance() {
        if (cloudinary == null) {
            cloudinary = new Cloudinary(ObjectUtils.asMap(
                "cloud_name", "ddtnuqqs7",
                "api_key", "923397728892225",
                "api_secret", "LKOCda_aevFdb27NL-Ck2jRhZNE"
            ));
        }
        return cloudinary;
    }

    // Sube una imagen y devuelve la URL pública
    public static String subirImagen(byte[] datosImagen) throws Exception {
        Map uploadResult = getInstance().uploader().upload(datosImagen, ObjectUtils.asMap(
                "folder", "polleria/productos",
                "transformation", new com.cloudinary.Transformation()
                        .width(800)
                        .quality("auto")
                        .fetchFormat("auto")
        ));
        return (String) uploadResult.get("secure_url");
    }
}