import os
import json

def convert_txt_to_json(txt_directory, output_json_file):
    # List to store the content of each text file
    documents = []

    # Iterate through all files in the given directory
    for filename in os.listdir(txt_directory):
        if filename.endswith(".txt"):
            # Read the content of each .txt file
            with open(os.path.join(txt_directory, filename), 'r', encoding='utf-8') as file:
                content = file.read().strip()  # Strip any leading/trailing whitespace
                documents.append(content)
            print(f"Processed: {filename}")

    # Write the list of documents to a JSON file
    with open(output_json_file, 'w', encoding='utf-8') as json_file:
        json.dump(documents, json_file, ensure_ascii=False, indent=2)
    print(f"All files have been processed. JSON saved to {output_json_file}")

# Example usage
if __name__ == "__main__":
    txt_directory = "/Users/atharva/model/data"  # Replace with the path to your txt files directory
    output_json_file = "documents.json"  # The output JSON file path
    convert_txt_to_json(txt_directory, output_json_file)

