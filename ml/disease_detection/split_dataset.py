import os
import hashlib
import shutil
import random
from pathlib import Path
from collections import defaultdict
from sklearn.model_selection import train_test_split

def hash_file(filepath):
    hasher = hashlib.md5()
    with open(filepath, 'rb') as f:
        buf = f.read()
        hasher.update(buf)
    return hasher.hexdigest()

def main():
    source_dir = Path("Z:/major/images")
    output_dir = Path("Z:/major/dataset_split")
    
    if not source_dir.exists():
        print(f"Error: Source directory {source_dir} not found.")
        return
        
    print("Hashing files to detect duplicates...")
    hashes = {}
    duplicates = []
    unique_files = defaultdict(list)
    
    class_counts = defaultdict(int)
    
    for img_path in sorted(source_dir.rglob("*")):
        if img_path.is_file() and img_path.suffix.lower() in ['.jpg', '.jpeg', '.png']:
            class_name = img_path.parent.name
            file_hash = hash_file(img_path)
            if file_hash in hashes:
                duplicates.append((img_path, hashes[file_hash]))
            else:
                hashes[file_hash] = img_path
                unique_files[class_name].append(img_path)
                class_counts[class_name] += 1
                    
    print(f"Total duplicates found: {len(duplicates)}")
    
    # Stratified Split
    print("\nSplitting dataset...")
    train_files, val_files, test_files = {}, {}, {}
    
    for class_name, files in unique_files.items():
        if len(files) < 10:
            print(f"WARNING: Class '{class_name}' has only {len(files)} samples. This is insufficient for reliable 70/15/15 splits. Putting all in train.")
            train_files[class_name] = files
            val_files[class_name] = []
            test_files[class_name] = []
            continue
            
        # 70/15/15 split
        train_split, temp_split = train_test_split(files, test_size=0.3, random_state=42)
        val_split, test_split = train_test_split(temp_split, test_size=0.5, random_state=42)
        
        train_files[class_name] = train_split
        val_files[class_name] = val_split
        test_files[class_name] = test_split
        
    # Copy files
    if output_dir.exists():
        shutil.rmtree(output_dir)
        
    for split_name, split_dict in [("train", train_files), ("val", val_files), ("test", test_files)]:
        split_dir = output_dir / split_name
        for class_name, files in split_dict.items():
            if not files: continue
            class_dir = split_dir / class_name
            class_dir.mkdir(parents=True, exist_ok=True)
            for f in files:
                shutil.copy(f, class_dir / f.name)
                
    # Report
    report = ["# Dataset Split Report\n"]
    report.append("| Class | Total | Train | Validation | Test |")
    report.append("|---|---|---|---|---|")
    
    total_train = total_val = total_test = total_overall = 0
    
    for class_name in sorted(unique_files.keys()):
        tr = len(train_files[class_name])
        va = len(val_files.get(class_name, []))
        te = len(test_files.get(class_name, []))
        tot = tr + va + te
        
        total_train += tr
        total_val += va
        total_test += te
        total_overall += tot
        
        report.append(f"| {class_name} | {tot} | {tr} | {va} | {te} |")
        
    report.append(f"| **TOTAL** | **{total_overall}** | **{total_train}** | **{total_val}** | **{total_test}** |")
    
    with open("Z:/major/docs/dataset_split_report.md", "w") as f:
        f.write("\n".join(report))
        
    print("\nSplit completed successfully.")
    print("Report saved to Z:/major/docs/dataset_split_report.md")

if __name__ == "__main__":
    main()
