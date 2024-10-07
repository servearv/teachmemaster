" EXPLAIN VIM COMMAND
function! ExplainVimCommand(command)
  " Construct the JSON payload with stream set to false
  let json_payload = '{"model": "llama3.2", "prompt": "Explain the following Vim command. Your response should be factually correct, concise and as informative as possible. Keep the response very short.: ' . a:command . '", "stream": false}'

  " Define the output file where the response will be saved
  let output_file = "/tmp/llama_explanation.json"

  " Use curl to make the API request and save the output to a file
  let curl_command = 'curl -X POST http://127.0.0.1:11435/api/generate -H "Content-Type: application/json" -d ' . shellescape(json_payload) . ' -o ' . output_file

  " Execute the curl command in the shell
  call system(curl_command)

  " Use jq to extract the 'response' field from the JSON and save it to a cleaned file
  let clean_output_file = "/tmp/llama_explanation_clean.txt"
  call system('jq -r ".response" ' . output_file . ' > ' . clean_output_file)

  " Check if the cleaned output file exists and is not empty
  if filereadable(clean_output_file)
    " Read the cleaned output file and display it in a new buffer
    execute 'edit' clean_output_file
  else
    echo "Failed to generate explanation."
  endif

  " Optionally, set textwidth for better readability
  setlocal textwidth=80
  setlocal wrap
endfunction

command! -nargs=1 Whats call ExplainVimCommand(<q-args>)

