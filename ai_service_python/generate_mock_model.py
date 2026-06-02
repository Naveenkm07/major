import os
import json
import tensorflow as tf

LABELS = [
    "healthy",
    "bacterial_blight",
    "leaf_spot",
    "rust",
    "powdery_mildew",
    "late_blight",
    "aphids",
    "stem_borer"
]

def main():
    os.makedirs("app/ml_models", exist_ok=True)

    # 1. Save Labels
    labels_path = "app/ml_models/disease_labels.json"
    with open(labels_path, "w") as f:
        json.dump(LABELS, f, indent=4)
    print(f"Saved labels to {labels_path}")

    # 2. Build MobileNetV2 architecture with untrained weights
    print("Building MobileNetV2 dummy architecture...")
    base_model = tf.keras.applications.MobileNetV2(
        input_shape=(224, 224, 3),
        include_top=False,
        weights=None # Use random initialization since it's a mock
    )
    
    # 3. Add classification head
    x = tf.keras.layers.GlobalAveragePooling2D()(base_model.output)
    x = tf.keras.layers.Dense(128, activation='relu')(x)
    output = tf.keras.layers.Dense(len(LABELS), activation='softmax')(x)
    
    model = tf.keras.Model(inputs=base_model.input, outputs=output)
    
    # 4. Compile model
    model.compile(
        optimizer='adam',
        loss='categorical_crossentropy',
        metrics=['accuracy']
    )
    
    # 5. Save model
    model_path = "app/ml_models/crop_disease_model.h5"
    model.save(model_path)
    print(f"Saved dummy MobileNetV2 to {model_path}")

if __name__ == "__main__":
    main()
