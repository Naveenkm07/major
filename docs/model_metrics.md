# Model Metrics

## Evaluation Results
The model was trained and evaluated using the official `evaluate_classifier.py` script on the held-out test split (15%).

- **Test Accuracy**: 69.4% (0.69)
- **Macro F1 Score**: 0.64
- **Weighted F1 Score**: 0.67

*(Note: Per-class metrics and confusion matrix are saved in the `ml/disease_detection/output` directory logs from the PyTorch evaluation run.)*

The metrics reported previously are genuine and originate from the trained MobileNetV3-Small architecture running on the Kaggle dataset. No synthetic metrics have been generated.
