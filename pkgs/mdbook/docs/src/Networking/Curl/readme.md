# curl Cheat Sheet

> **Quick**: Practical, consultant-style reference for using `curl` — from basic GETs to file uploads, API interactions, cookies, scripting tips and advanced flags. Friendly tone, focused on getting you productive fast.

---

## Table of contents

1. [What is curl?](#what-is-curl)
2. [Quick examples — Web browsing & headers](#quick-examples---web-browsing--headers)
3. [Downloading files](#downloading-files)
4. [GET requests](#get-requests)
5. [POST requests & forms](#post-requests--forms)
6. [API interaction & headers](#api-interaction--headers)
7. [File uploads with `--form` / `-F`](#file-uploads-with--form--f)
8. [Cookies and sessions](#cookies-and-sessions)
9. [Scripting with curl](#scripting-with-curl)
10. [Advanced & debugging flags](#advanced--debugging-flags)
11. [Partial downloads & ranges](#partial-downloads--ranges)
12. [Helpful one-line examples](#helpful-one-line-examples)
13. [Etiquette & safety note](#etiquette--safety-note)

---

## What is curl?

`curl` (client URL) is a command-line tool for transferring data with URL syntax. It supports many protocols (HTTP/S, FTP, SCP, SMTP, IMAP, POP3, etc.) and is ideal for quick checks, automation, scripting, API calls, and sometimes creative (or mischievous) automation.

Use it when you need protocol-level control from the terminal.

---

## Quick examples — Web browsing & headers

| Command                                             | Description                                              |
| --------------------------------------------------- | -------------------------------------------------------- |
| `curl http://example.com`                           | Print HTML body of `http://example.com` to stdout        |
| `curl --list-only "http://example.com/dir/"` (`-l`) | List directory contents (if server allows)               |
| `curl --location URL` (`-L`)                        | Follow 3xx redirects                                     |
| `curl --head URL` (`-I`)                            | Fetch HTTP response headers only                         |
| `curl --head --show-error URL`                      | Headers and errors (helpful for down/unresponsive hosts) |

---

## Downloading files

| Command                                                    | Notes                                                                 |
| ---------------------------------------------------------- | --------------------------------------------------------------------- |
| `curl --output hello.html http://example.com` (`-o`)       | Save output to `hello.html`                                           |
| `curl --remote-name URL` (`-O`)                            | Save file using remote filename                                       |
| `curl --remote-name URL --output newname`                  | Download then rename locally                                          |
| `curl --remote-name --continue-at - URL`                   | Resume partial download (if server supports ranges)                   |
| `curl "https://site/{a,b,c}.html" --output "file_#1.html"` | Download multiple variants using brace expansion and `#` placeholders |

**Batch download pattern** (extract links then download):

```bash
curl -L http://example.com/list/ | grep '\.mp4' | cut -d '"' -f 8 | while read i; do curl http://example.com/${i} -O; done
```

(Adjust `grep`/`cut` to the page structure.)

---

## GET requests

| Command                                                                   | Description                                               |
| ------------------------------------------------------------------------- | --------------------------------------------------------- |
| `curl --request GET "http://example.com"` (`-X GET`)                      | Explicit GET request (usually optional)                   |
| `curl -s -w '%{remote_ip} %{time_total} %{http_code}\n' -o /dev/null URL` | Silent mode with custom output: IP, total time, HTTP code |

Example: fetch a JSON API (may require headers or tokens):

```bash
curl -X GET 'https://api.example.com/items?filter=all' -H 'Accept: application/json'
```

---

## POST requests & forms

| Command                                                               | Description                               |
| --------------------------------------------------------------------- | ----------------------------------------- |
| `curl --request POST URL -d 'key=value'` (`-X POST -d`)               | Send URL-encoded data in the request body |
| `curl -H 'Content-Type: application/json' --data-raw '{"k":"v"}' URL` | Send raw JSON payload (set content-type)  |

Examples with MongoDB Data API (illustrative):

```bash
# Insert document
curl --request POST 'https://data.mongodb-api/.../insertOne' \
  --header 'Content-Type: application/json' \
  --header 'api-key: YOUR_KEY' \
  --data-raw '{"dataSource":"Cluster0","database":"db","collection":"c","document":{ "name":"Alice" }}'

# Find one
curl --request POST 'https://data.mongodb-api/.../findOne' \
  --header 'Content-Type: application/json' \
  --header 'api-key: YOUR_KEY' \
  --data-raw '{"filter":{"name":"Alice"}}'
```

---

## API interaction & headers

| Command                                 | Description                                                      |
| --------------------------------------- | ---------------------------------------------------------------- |
| `-H` / `--header`                       | Add custom HTTP header (Auth tokens, Content-Type, Accept, etc.) |
| `curl --header "Auth-Token:$TOKEN" URL` | Pass bearer or custom tokens in headers                          |
| `curl --user username:password URL`     | Basic auth (`-u username:password`)                              |

Examples:

```bash
curl -H 'Authorization: Bearer $TOKEN' -H 'Accept: application/json' https://api.example.com/me
curl -u 'user:password' 'https://example.com/protected'
```

---

## File uploads with `--form` / `-F`

Use `-F` to emulate HTML form file uploads (multipart/form-data).

| Command                                              | Description                                        |
| ---------------------------------------------------- | -------------------------------------------------- |
| `curl --form "file=@/path/to/file" URL`              | Upload file (use `@` for relative or `@/abs/path`) |
| `curl --form "field=value" --form "file=@/path" URL` | Mix fields and files in one request                |

Notes:

- If the file is in the current directory, you can use `@filename`.
- If you supply an absolute path, omit the `@` and pass `field=/full/path`.

Examples:

```bash
curl -F "email=test@me.com" -F "submit=Submit" 'https://docs.google.com/forms/d/e/FORM_ID/formResponse' > output.html
curl -F "entry.123456789=@/Users/me/pic.jpg" 'https://example.com/upload' > response.html
```

---

## Cookies and sessions

| Command                                          | Description                                                  |
| ------------------------------------------------ | ------------------------------------------------------------ |
| `curl --cookie "name=val;name2=val2" URL` (`-b`) | Send cookie(s) inline                                        |
| `curl --cookie cookies.txt URL`                  | Load cookies from file (`cookies.txt` with `k=v;...` format) |
| `curl --cookie-jar mycookies.txt URL` (`-c`)     | Save cookies received into `mycookies.txt`                   |
| `curl --dump-header headers.txt URL` (`-D`)      | Dump response headers (includes Set-Cookie)                  |

Cookie file format (simple):

```
key1=value1;key2=value2
```

---

## Scripting with curl

`curl` is a natural fit for bash automation. Example script patterns:

- Reusable function wrapper for API calls (add auth header once)
- Download + checksum verification loop
- Rate-limited loops for polite scraping (`sleep` between requests)

Example: simple reusable function

```bash
api_get(){
  local endpoint="$1"
  curl -s -H "Authorization: Bearer $API_KEY" "https://api.example.com/${endpoint}"
}

api_get "items"
```

---

## Advanced & debugging flags

| Flag                 | Purpose                                                                                  |
| -------------------- | ---------------------------------------------------------------------------------------- |
| `-h`                 | Show help                                                                                |
| `--version`          | Show curl version and features                                                           |
| `-v`                 | Verbose (request/response)                                                               |
| `--trace filename`   | Detailed trace of operations and data                                                    |
| `-s`                 | Silent mode (no progress meter)                                                          |
| `-S`                 | Show error when used with `-s`                                                           |
| `-L`                 | Follow redirects                                                                         |
| `--connect-timeout`  | Seconds to wait for TCP connect                                                          |
| `-m` / `--max-time`  | Max operation time in seconds                                                            |
| `-w` / `--write-out` | Print variables after completion (`%{http_code}`, `%{time_total}`, `%{remote_ip}`, etc.) |

Examples:

```bash
curl -v https://example.com
curl --trace trace.txt https://twitter.com/
curl -s -w '%{remote_ip} %{time_total} %{http_code}\n' -o /dev/null http://ankush.io
curl -L 'https://short.url' --connect-timeout 0.1
```

---

## Partial downloads & ranges

Use `-r` to request byte ranges from HTTP/FTP responses (helpful for resuming or grabbing file snippets).

| Command                              | Notes                                       |
| ------------------------------------ | ------------------------------------------- |
| `curl -r 0-99 http://example.com`    | First 100 bytes                             |
| `curl -r -500 http://example.com`    | Last 500 bytes                              |
| `curl -r 0-99 ftp://ftp.example.com` | Ranges on FTP (explicit start/end required) |

---

## Helpful one-line examples

```bash
# Show headers only
curl -I https://example.com

# Save response to file quietly
curl -sL https://example.com -o page.html

# POST JSON and pretty-print reply (using jq)
curl -s -H "Content-Type: application/json" -d '{"name":"A"}' https://api.example.com/insert | jq

# Upload file with field name "file"
curl -F "file=@./image.jpg" https://api.example.com/upload

# Send cookies from file and save response headers
curl -b cookies.txt -D headers.txt https://example.com

# Send URL-encoded form field
curl -d "field1=value1&field2=value2" -X POST https://form-endpoint
```

---

## Request example (SMS via textbelt — use responsibly)

```bash
curl -X POST https://textbelt.com/text \
  --data-urlencode phone='+[E.164 number]' \
  --data-urlencode message='Please delete this message.' \
  -d key=textbelt
```

Response example: `{"success":true,...}` (service-dependent)

---

## Etiquette & safety note

- Only target servers or forms you own or have explicit permission to test. Abuse (flooding, unauthorized automation, fraud) is illegal and unethical.
- Prefer `--connect-timeout` and rate-limiting in scripts to avoid hammering servers.
- Keep secrets out of command history — use environment variables or `--netrc` where appropriate.
