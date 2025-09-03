
import csv
import os
import random
import string
import argparse

def random_string(length=10):
    """Generate a random string of fixed length."""
    return ''.join(random.choices(string.ascii_letters + string.digits, k=length))

def generate_csv(file_path, target_size_mb):
    """Generate a CSV file of approximately target_size_mb MB."""
    target_size_bytes = target_size_mb * 1024 * 1024
    written_bytes = 0

    with open(file_path, 'w', newline='') as csvfile:
        writer = csv.writer(csvfile)
        
        # Write header
        header = ["id", "name", "value1", "value2", "value3"]
        writer.writerow(header)
        written_bytes += len(",".join(header)) + 2  # rough estimate

        row_id = 1
        while written_bytes < target_size_bytes:
            row = [
                row_id,
                random_string(12),
                random.randint(1000, 9999),
                random.uniform(10.5, 999.9),
                random.choice(["A", "B", "C", "D", "E"])
            ]
            row_str = ",".join(map(str, row)) + "\n"
            csvfile.write(row_str)
            written_bytes += len(row_str)
            row_id += 1

    print(f"✅ Generated {file_path} (~{os.path.getsize(file_path) / (1024*1024):.2f} MB)")

def main():
    parser = argparse.ArgumentParser(description="Generate large CSV files for testing.")
    parser.add_argument("--num-files", type=int, default=10, help="Number of CSV files to generate")
    parser.add_argument("--size-mb", type=int, default=50, help="Approximate size of each CSV file in MB")
    parser.add_argument("--output-dir", type=str, default="./data", help="Output directory for CSV files")
    args = parser.parse_args()

    os.makedirs(args.output_dir, exist_ok=True)

    for i in range(1, args.num_files + 1):
        file_path = os.path.join(args.output_dir, f"sample{i}.csv")
        generate_csv(file_path, args.size_mb)

if __name__ == "__main__":
    main()
