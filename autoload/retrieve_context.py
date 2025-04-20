# save this as retrieve_context.py
import sys
import json
from annoy import AnnoyIndex
from sentence_transformers import SentenceTransformer

def load_annoy_index(model_path="annoy_index.ann"):
    model = SentenceTransformer('paraphrase-MiniLM-L3-v2')
    f = model.get_sentence_embedding_dimension()
    index = AnnoyIndex(f, 'angular')
    index.load(model_path)
    return model, index

def retrieve_context(query, model, index, documents, top_k=5):
    query_vector = model.encode(query)
    indices = index.get_nns_by_vector(query_vector, top_k)
    return [documents[i] for i in indices]

if __name__ == "__main__":
    if len(sys.argv) != 5:
        print("Usage: python3 retrieve_context.py <query> <top_k> <documents_file> <output_file>")
        sys.exit(1)

    query = sys.argv[1]
    top_k = int(sys.argv[2])
    documents_file = sys.argv[3]
    output_file = sys.argv[4]

    # Load documents from the provided JSON file
    with open(documents_file, 'r') as f:
        documents = json.load(f)

    # Load the model and Annoy index
    model, index = load_annoy_index()

    # Retrieve the context
    context = retrieve_context(query, model, index, documents, top_k)

    # Write the context to the output file
    with open(output_file, 'w') as f:
        f.write("\n\n".join(context))

