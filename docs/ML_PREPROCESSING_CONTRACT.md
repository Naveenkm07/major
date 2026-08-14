# ML Preprocessing Contract

To ensure the Flutter application accurately predicts diseases, the Flutter TFLite input tensor preparation **MUST** exactly match the preprocessing steps utilized during PyTorch model training.

## Training Preprocessing (PyTorch)
- **Image Size**: Resized to exactly `224x224` pixels.
- **Color Format**: `RGB`.
- **Data Type**: `float32`.
- **Normalization Strategy**: 
  - Image pixels are scaled to `[0, 1]` initially.
  - Mean normalization: `[0.485, 0.456, 0.406]` (Standard ImageNet means).
  - Standard Deviation scaling: `[0.229, 0.224, 0.225]` (Standard ImageNet stds).
- **Tensor Format**: PyTorch utilizes `[1, C, H, W]` internally (`[1, 3, 224, 224]`).

## Inference Preprocessing (Flutter)
- **Tensor Format**: TFLite conversion inherently transposes the PyTorch NCHW format to standard TFLite NHWC (`[1, 224, 224, 3]`). Flutter must feed data as NHWC.
- **Data Type**: If the final TFLite model is INT8, Flutter must supply an `INT8` or `UINT8` tensor based exactly on the final converter parameters. 
- **Image Size**: The `CameraImage` / `XFile` must be scaled down to `224x224`.
- **Color Format**: YUV420 from Android camera must be manually converted to RGB.

**WARNING**: Any deviation from this contract (e.g. failing to apply the ImageNet mean/std normalization before TFLite INT8 quantization scaling) will severely degrade the model's performance in production.
