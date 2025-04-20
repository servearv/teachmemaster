function! QueryLlamaWithRAG() abort
  " Prompt the user for the query
  let l:query = 'How do I exit Vim?'

  " Prompt the user for the output file path
  let l:output_file = '/tmp/output.json'

  " Define the path to the Python script, the documents file, and the context output file
  let l:python_script = 'retrieve_context.py''
  let l:documents_file = 'documents.json'
  let l:context_file = '/tmp/context.txt'
  
  " Define the number of top documents to retrieve for context
  let l:top_k = 5

  " Run the Python script to get the context
  let l:context_command = 'python3 ' . l:python_script . ' ' . shellescape(l:query) . ' ' . l:top_k . ' ' . l:documents_file . ' ' . l:context_file
  let l:context_output = system(l:context_command)

  " Check if the Python script execution was successful
  if v:shell_error != 0
    echohl ErrorMsg
    echo "Error: Failed to retrieve context."
    echohl None
    return
  endif

  " Read the context from the context file
  let l:context = join(readfile(l:context_file), "\n\n")

  " Prepare the JSON payload for the API request
  let l:json_payload = '{"prompt": "Context:\n' . l:context . '\n\nQuestion: ' . l:query . '\nAnswer:"}'

  " Construct the curl command
  let l:curl_command = 'curl -X POST ' . g:teachmemaster_base_url . '/api/generate ' .
        \ '-H "Content-Type: application/json" ' .
        \ '-d ' . shellescape(l:json_payload) . ' -o ' . l:output_file

  " Run the curl command
  let l:response = system(l:curl_command)

  " Check if the curl command was successful
  if v:shell_error != 0
    echohl ErrorMsg
    echo "Error: Failed to query ollama server. See output in " . l:output_file
    echohl None
  else
    echo "Query successful. See response in " . l:output_file
  endif
endfunction

