"""
Final comprehensive DOCX patch:
- Removes ALL "Java/Spring Boot" references → Node.js/Express
- Removes remaining YOLOv8 references → MobileNetV3-Small  
- Fixes model filename reference
- Fixes image input size 416x416 → 224x224
"""
import sys
from docx import Document

def fix_run_text(paragraph, replacements):
    """Replace text across runs within a paragraph, preserving formatting."""
    # First do full-text check
    full = paragraph.text
    for old, new in replacements.items():
        if old in full:
            # Try to replace within individual runs first
            for run in paragraph.runs:
                if old in run.text:
                    run.text = run.text.replace(old, new)
            # If still present (split across runs), rebuild via first run
            if old in paragraph.text:
                for run in paragraph.runs:
                    run.text = ''
                paragraph.runs[0].text = paragraph.text.replace(old, new) if paragraph.runs else paragraph.text

def apply_replacements(doc_path, replacements):
    doc = Document(doc_path)
    count = 0
    
    for para in doc.paragraphs:
        for old, new in replacements.items():
            if old in para.text:
                for run in para.runs:
                    if old in run.text:
                        run.text = run.text.replace(old, new)
                        count += 1

    for table in doc.tables:
        for row in table.rows:
            for cell in row.cells:
                for para in cell.paragraphs:
                    for old, new in replacements.items():
                        if old in para.text:
                            for run in para.runs:
                                if old in run.text:
                                    run.text = run.text.replace(old, new)
                                    count += 1

    doc.save(doc_path)
    print(f"Done. Made {count} run-level replacements.")
    return count

replacements = {
    # Java/Spring Boot → Node.js
    "Java backend": "Node.js backend",
    "Java/Spring Boot backend": "Node.js/Express backend",
    "Java / Spring Boot": "Node.js / Express",
    "Java 21 on Spring Boot 3.2": "Node.js 20 (LTS) with Express 4.18",
    "Spring Boot 3.2": "Express 4.18",
    "Spring Boot": "Node.js/Express",
    "annotation-driven @Scheduled jobs and non-blocking WebClient": "cron-based scheduled jobs and non-blocking async/await HTTP calls",
    "Java backend so that any one of them": "Node.js backend so that any one of them",
    "lightweight Java backend": "lightweight Node.js/Express backend",
    "Java/Spring Boot": "Node.js/Express",
    "LangChain4J 0.29": "LangChain.js 0.2",
    "Apache Tika 2.9": "PyMuPDF / pdfplumber",
    # Fix inconsistent model name references
    "MobileNetV3-Small / YOLOv8 TFLite interpreter": "MobileNetV3-Small TFLite interpreter",
    "quantised MobileNetV3-Small / YOLOv8": "quantised MobileNetV3-Small",
    "INT8-quantised YOLOv8 model": "INT8-quantised MobileNetV3-Small model",
    "YOLOv8 (INT8 Quantized)": "MobileNetV3-Small (INT8 Quantized)",
    "frozen YOLOv8 weights": "frozen MobileNetV3-Small weights",
    "new YOLO `.tflite`": "new MobileNetV3 `.tflite`",
    "yolov8_int8.tflite": "mobilenet_v3_int8.tflite",
    # Fix image size
    "resized to 416×416": "resized to 224×224",
    "416×416 resize": "224×224 resize",
    "416\u00d7416": "224\u00d7224",
}

docx_path = r"Z:\major\check_docx\KrushikaDhara_IEEE_PUBLISH_READY.docx"
apply_replacements(docx_path, replacements)
print("DOCX patched successfully.")
