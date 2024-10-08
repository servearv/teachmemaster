" Store the list of buffers created by TeachMe and AskFollowUp
let g:teachmemaster_buffers = []

function! TeachMe(command)
  " Construct the JSON payload with stream set to false
  let json_payload = '{"model": "llama2", "prompt": "Explain the following Vim command. Keep the explanation very very short and informative and easy to read.: ' . a:command . '", "stream": false}'

  " Define the output file where the response will be saved
  let output_file = "/tmp/llama_explanation.json"

  " Use curl to make the API request and save the output to a file
  let curl_command = 'curl -X POST http://127.0.0.1:11435/api/generate -H "Content-Type: application/json" -d ' . shellescape(json_payload) . ' -o ' . output_file

  " Execute the curl command in the shell
  call system(curl_command)

  " Use jq to extract the 'response' field from the JSON and save it to a cleaned file
  let clean_output_file = "/tmp/llama_explanation_clean.txt"
  call system('jq -r ".response" ' . output_file . ' > ' . clean_output_file)

  " Save the current 'splitright' setting
  let l:original_splitright = &splitright
  set splitright
  " Check if the cleaned output file exists and is not empty
  if filereadable(clean_output_file)
    " Open the cleaned output file in a vertical split and add the buffer to the list
    execute 'vsplit' clean_output_file
    let g:teachmemaster_buffers += [bufnr('%')]
  else
    echo "Failed to generate explanation."
  endif

  " Optionally, set textwidth for better readability
  setlocal textwidth=80
  setlocal wrap
  
  " Restore the original 'splitright' setting
  let &splitright = l:original_splitright

  " Store the command for potential follow-up questions
  let g:last_teachme_command = a:command
endfunction

function! AskFollowUp(question)
  " Retrieve the last command that was explained
  if !exists("g:last_teachme_command")
    echo "No previous command to ask a follow-up about."
    return
  endif

  " Construct the JSON payload with the follow-up question
  let json_payload = '{"model": "llama3.2", "prompt": "Following up on the explanation of the command ' . g:last_teachme_command . ': ' . a:question . '", "stream": false}'

  " Define the output file where the response will be saved
  let output_file = "/tmp/llama_followup.json"

  " Use curl to make the API request and save the output to a file
  let curl_command = 'curl -X POST http://127.0.0.1:11435/api/generate -H "Content-Type: application/json" -d ' . shellescape(json_payload) . ' -o ' . output_file

  " Execute the curl command in the shell
  call system(curl_command)

  " Use jq to extract the 'response' field from the JSON and save it to a cleaned file
  let clean_output_file = "/tmp/llama_followup_clean.txt"
  call system('jq -r ".response" ' . output_file . ' > ' . clean_output_file)

  " Save the current 'splitright' setting
  let l:original_splitright = &splitright
  set splitright

  " Check if /tmp/llama_explanation_clean.txt exists.
  if filereadable('/tmp/llama_explanation_clean.txt')
	" Check if the cleaned output file exists and is not empty
	if filereadable(clean_output_file)
		" Open the cleaned output file in a vertical split and add the buffer to the list
		execute 'edit' clean_output_file
		let g:teachmemaster_buffers += [bufnr('%')]
	else
		echo "Failed to generate follow-up response."
	endif
  else
	" Check if the cleaned output file exists and is not empty
	if filereadable(clean_output_file)
		" Open the cleaned output file in a vertical split and add the buffer to the list
		execute 'vsplit' clean_output_file
		let g:teachmemaster_buffers += [bufnr('%')]
	else
		echo "Failed to generate follow-up response."
	endif
  endif

  " Restore the original 'splitright' setting
  let &splitright = l:original_splitright

  " Optionally, set textwidth for better readability
  setlocal textwidth=80
  setlocal wrap
endfunction

function! CloseTeachMeBuffers()
  " Loop through the list of stored buffer numbers and close them
  for buf in g:teachmemaster_buffers
    if bufloaded(buf)
      execute 'bdelete' buf
    endif
  endfor
  " Clear the buffer list after closing
  let g:teachmemaster_buffers = []
  " Delete the text files once the buffers are codes
  if filereadable('/tmp/llama_explanation_clean.txt')
	call delete('/tmp/llama_explanation_clean.txt')
  endif
  if filereadable('/tmp/llama_followup_clean.txt')
	call delete('/tmp/llama_followup_clean.txt')
  endif 
  if filereadable('/tmp/llama_followup.json')
	call delete('/tmp/llama_followup.json')
  endif
  if filereadable('/tmp/llama_explanation.json')
	call delete('/tmp/llama_explanation.json')
  endif

endfunction

" Command to invoke the TeachMe function from Vim's command line
command! -nargs=1 TeachMe call TeachMe(<q-args>)
command! -nargs=1 AskFollowUp call AskFollowUp(<q-args>)
command! -nargs=0 BD call CloseTeachMeBuffers()
