package com.polleria.util;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import java.util.Map;

public class CloudinaryService {

    private static Cloudinary cloudinary;

    private static Cloudinary getInstance() {
        if (cloudinary == null) {
            cloudinary = new Cloudinary(ObjectUtils.asMap(
                "cloud_name", ConfigLoader.get("cloudinary.cloud_name"),
                "api_key",    ConfigLoader.get("cloudinary.api_key"),
                "api_secret", ConfigLoader.get("cloudinary.api_secret")
            ));
        }
        return cloudinary;
    }

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