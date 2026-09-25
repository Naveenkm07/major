import sys
try:
    from docx import Document
except ImportError:
    print("python-docx is not installed.")
    sys.exit(1)

def replace_text_in_docx(doc_path, old_text, new_text):
    doc = Document(doc_path)
    replaced_count = 0
    
    # Replace in paragraphs
    for p in doc.paragraphs:
        if old_text in p.text:
            p.text = p.text.replace(old_text, new_text)
            replaced_count += 1
            
    # Replace in tables
    for table in doc.tables:
        for row in table.rows:
            for cell in row.cells:
                for p in cell.paragraphs:
                    if old_text in p.text:
                        p.text = p.text.replace(old_text, new_text)
                        replaced_count += 1
                        
    if replaced_count > 0:
        doc.save(doc_path)
        print(f"Success! Replaced '{old_text}' with '{new_text}' {replaced_count} times in the document.")
    else:
        print(f"Notice: '{old_text}' was not found in the document.")

if __name__ == "__main__":
    docx_file = r"Z:\major\check_docx\KrushikaDhara_IEEE_PUBLISH_READY.docx"
    replace_text_in_docx(docx_file, "Java backend", "Node.js backend")
