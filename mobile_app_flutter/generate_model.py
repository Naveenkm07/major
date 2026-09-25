import tensorflow as tf

def create_and_export_model():
    print("Creating MobileNetV3 Small model...")
    # 5 classes for crop diseases
    base_model = tf.keras.applications.MobileNetV3Small(
        input_shape=(224, 224, 3),
        include_top=False,
        weights='imagenet'
    )
    
    x = tf.keras.layers.GlobalAveragePooling2D()(base_model.output)
    output = tf.keras.layers.Dense(5, activation='softmax')(x)
    
    model = tf.keras.Model(inputs=base_model.input, outputs=output)
    
    print("Converting to TFLite...")
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    
    # We can use default optimization to make it smaller
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    
    tflite_model = converter.convert()
    
    output_path = r"Z:\major\mobile_app_flutter\assets\models\plant_disease_model.tflite"
    with open(output_path, "wb") as f:
        f.write(tflite_model)
        
    print(f"Model saved to {output_path} (Size: {len(tflite_model)/1024/1024:.2f} MB)")
    
    # Write labels
    labels_path = r"Z:\major\mobile_app_flutter\assets\models\disease_labels.txt"
    labels = ["Healthy_Crop", "Leaf_Blight", "Rust_Disease", "Powdery_Mildew", "Pest_Damage"]
    with open(labels_path, "w") as f:
        f.write("\n".join(labels))
    print("Labels saved.")

if __name__ == "__main__":
    create_and_export_model()
