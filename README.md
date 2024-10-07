# teachmemaster

## Overview
**teachmemaster** is a Vim plugin that provides detailed explanations of Vim commands using a local `llama3.2` model server. With this plugin, users can easily understand complex Vim commands through explanations formatted as full sentences, paragraphs, or lists, directly within their Vim environment.

## Features
- Accepts any Vim command as input and generates a detailed explanation.
- Uses `curl` to send a request to the `llama3.2` model API with `stream` set to `false` for a single, coherent response.
- Displays the explanation in a new buffer with proper formatting, making it easy to read and understand.
- Automatically wraps the text for improved readability.

## Prerequisites
- `jq`: A lightweight command-line JSON processor.
  - Install `jq` using:
    - macOS: `brew install jq`
    - Linux: `sudo apt-get install jq`
- A running instance of the `llama3.2` model server.
  - The server should be accessible at `http://127.0.0.1:11435` and must support the `/api/generate` endpoint with `stream` set to `false`.

## Installation
### Using Vim Plug
Add the following line to your `.vimrc` or `init.vim` file:
```vim
Plug 'servearv/teachmemaster'

