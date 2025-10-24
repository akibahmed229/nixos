# The Complete Linux & Bash Command-Line Guide

Master the Linux command line from first principles to advanced automation. This comprehensive guide organizes commands by **what you want to accomplish**, making it your go-to reference whether you're taking your first steps or optimizing complex workflows.

## 🧭 Table of Contents

1. [Foundations: Understanding the Command Line](#1-foundations-understanding-the-command-line)
2. [Navigation: Finding Your Way Around](#2-navigation-finding-your-way-around)
3. [File Operations: Creating, Moving, and Deleting](#3-file-operations-creating-moving-and-deleting)
4. [Reading and Viewing Files](#4-reading-and-viewing-files)
5. [Searching: Finding Files and Text](#5-searching-finding-files-and-text)
6. [Advanced Text Processing: Power Tools](#6-advanced-text-processing-power-tools)
7. [Users, Permissions, and Access Control](#7-users-permissions-and-access-control)
8. [Process and System Management](#8-process-and-system-management)
9. [Networking Essentials](#9-networking-essentials)
10. [Archives and Compression](#10-archives-and-compression)
11. [Bash Scripting: Automating Tasks](#11-bash-scripting-automating-tasks)
12. [Input/Output Redirection](#12-inputoutput-redirection)
13. [Advanced Techniques and Power User Features](#13-advanced-techniques-and-power-user-features)
14. [Troubleshooting and Debugging](#14-troubleshooting-and-debugging)

---

## 1. Foundations: Understanding the Command Line

### The Anatomy of a Command

Every Linux command follows a predictable pattern that, once understood, unlocks the entire system:

```bash
command -options arguments
```

- **`command`**: The program or tool you're invoking (like `ls` to list files)
- **`-options`**: Modifiers that change behavior, also called _flags_ or _switches_ (like `-l` for "long format")
- **`arguments`**: What you want the command to operate on (like `/home/user`)

**Example breakdown:**

```bash
ls -la /var/log
│  │  └─ argument (which directory)
│  └──── options (long format + all files)
└─────── command (list contents)
```

### The Pipe: Your Most Powerful Tool

The pipe operator `|` is the cornerstone of command-line productivity. It channels the output of one command directly into the input of another, letting you chain simple tools into sophisticated operations.

```bash
cat server.log | grep "ERROR" | wc -l
```

**What happens here:**

1. `cat` outputs the entire log file
2. `|` feeds that output to `grep`
3. `grep` filters for lines containing "ERROR"
4. `|` feeds those filtered lines to `wc`
5. `wc -l` counts how many lines remain

**Think of pipes as assembly lines**: each command does one thing well, then passes its work to the next station.

### Essential Survival Skills

#### Getting Help When You're Stuck

```bash
man command_name
```

The `man` (manual) command is your built-in encyclopedia. Every standard command has a manual page explaining its purpose, options, and usage. Navigate with arrow keys, search with `/search_term`, and quit with `q`.

**⚠️ Common Mistake**: Forgetting that `man` exists and searching online first. While web searches are valuable, `man` pages are authoritative, always available offline, and specific to your system's version.

**Quick reference alternatives:**

- `command --help` or `command -h`: Brief usage summary (faster than `man`)
- `apropos keyword`: Search all manual pages for a keyword

#### Tab Completion: Stop Typing So Much

Press `Tab` at any point while typing a command, filename, or path. The shell will:

- Complete the word if there's only one match
- Show you all possibilities if there are multiple matches
- Save you from typos and help you discover available options

**Pro tip**: Double-tap `Tab` twice quickly to see all possible completions without typing anything.

#### Quoting Rules That Matter

Quotes aren't stylistic—they fundamentally change how the shell interprets your input:

**Double quotes `"`**: The shell expands variables and substitutions

```bash
echo "Hello, $USER"  # Outputs: Hello, akib
echo "Current dir: $(pwd)"  # Outputs: Current dir: /home/akib
```

**Single quotes `'`**: Everything is literal—no expansions occur

```bash
echo 'Hello, $USER'  # Outputs: Hello, $USER
echo 'Cost: $50'  # Outputs: Cost: $50
```

**When to use which:**

- Use double quotes by default for strings containing variables
- Use single quotes when you want literal text (like in `sed` or `awk` patterns)
- Use no quotes for simple, single-word arguments

#### The `sudo` Privilege System

Linux protects critical system operations by requiring administrator privileges. Rather than logging in as the dangerous "root" user, use `sudo` to execute individual commands with elevated rights:

```bash
sudo apt update  # Update package lists (requires admin)
sudo reboot      # Restart the system
```

**How it works**: `sudo` (**S**uper**u**ser **Do**) temporarily grants your command root privileges. You'll be prompted for your password the first time, then you have a grace period (typically 15 minutes) before it asks again.

**⚠️ Warning**: With great power comes great responsibility. `sudo` can break your system if misused. Always double-check commands that start with `sudo`.

---

## 2. Navigation: Finding Your Way Around

### Understanding Where You Are

The Linux filesystem is a tree structure. Unlike Windows with its separate drives (C:, D:), everything branches from a single root `/`.

```bash
pwd
```

**P**rint **W**orking **D**irectory shows your current location:

```
/home/akib/projects/website
```

**Best practice**: Run `pwd` when you're disoriented. It's free and instant.

### Seeing What's Around You

```bash
ls
```

The **l**i**s**t command shows directory contents, but it's far more powerful with options:

```bash
ls -la
```

This is the command you'll use 90% of the time:

- `-l`: **L**ong format showing permissions, owner, size, date
- `-a`: Show **a**ll files, including hidden ones (starting with `.`)

**Output anatomy:**

```
drwxr-xr-x  5 akib akib  4096 Oct 24 10:30 Documents
-rw-r--r--  1 akib akib  2048 Oct 23 15:42 notes.txt
│││││││││  │ │    │     │    │         └─ filename
│││││││││  │ │    │     │    └─────────── modification date
│││││││││  │ │    │     └──────────────── size in bytes
│││││││││  │ │    └────────────────────── group
│││││││││  │ └─────────────────────────── owner
│││││││││  └───────────────────────────── number of links
││││││││└───────────────────────────────── permissions (others)
│││││││└────────────────────────────────── permissions (group)
││││││└─────────────────────────────────── permissions (owner)
│││││└──────────────────────────────────── execute/search
││││└───────────────────────────────────── write
│││└────────────────────────────────────── read
││└─────────────────────────────────────── file type (d=directory, -=file)
```

**Useful variations:**

- `ls -lh`: **H**uman-readable sizes (2.1M instead of 2048576)
- `ls -lt`: Sort by **t**ime (newest first)
- `ls -lS`: Sort by **S**ize (largest first)
- `ls -lR`: **R**ecursive (show subdirectories too)

### Moving Between Directories

```bash
cd directory_name
```

**C**hange **D**irectory is your navigation command. It understands both absolute and relative paths:

**Absolute paths** start from root `/`:

```bash
cd /var/log  # Go directly to /var/log from anywhere
```

**Relative paths** start from your current location:

```bash
cd Documents          # Go into Documents subdirectory
cd ../Downloads       # Go up one level, then into Downloads
cd ../../shared/data  # Go up two levels, then down a different branch
```

**Special shortcuts:**

```bash
cd          # Go to your home directory (/home/username)
cd ~        # Same as above (~ means "home")
cd -        # Return to previous directory (like "back" button)
cd ..       # Go up one directory level
cd ../..    # Go up two levels
```

**⚠️ Common Mistake**: Forgetting that `cd` without arguments takes you home. If you accidentally run `cd` and lose your place, use `cd -` to get back.

### Advanced Navigation: The Directory Stack

For power users who jump between multiple locations:

```bash
pushd /var/log        # Save current location, jump to /var/log
pushd ~/projects      # Save /var/log, jump to ~/projects
dirs                  # View the stack
popd                  # Return to /var/log
popd                  # Return to original location
```

**Why use this?** When you're working across multiple directory trees (e.g., comparing logs in `/var/log` with configs in `/etc` while editing code in `~/projects`), the directory stack is faster than repeatedly typing full paths.

### Clearing the Clutter

```bash
clear
```

Clears your terminal screen without affecting your work. Useful when output has become overwhelming.

**Keyboard shortcut**: `Ctrl+L` does the same thing (faster than typing).

---

## 3. File Operations: Creating, Moving, and Deleting

### Creating Files

```bash
touch filename.txt
```

Creates an empty file or updates the timestamp on an existing file. While `touch` seems simple, it's essential for:

- Creating placeholder files
- Resetting modification times
- Testing write permissions in a directory

**Why the name "touch"?** It "touches" the file, updating its access time without modifying contents.

### Creating Directories

```bash
mkdir new_folder
```

**M**a**k**e **Dir**ectory creates a new folder. But the real power comes with options:

```bash
mkdir -p path/to/deeply/nested/folder
```

The `-p` (parents) flag creates all intermediate directories automatically. Without it, you'd need to create each level separately:

```bash
# Without -p (tedious):
mkdir path
mkdir path/to
mkdir path/to/deeply
mkdir path/to/deeply/nested
mkdir path/to/deeply/nested/folder

# With -p (elegant):
mkdir -p path/to/deeply/nested/folder
```

**Best practice**: Always use `-p` unless you specifically want an error when parent directories don't exist.

### Copying Files and Directories

```bash
cp source.txt destination.txt
```

**C**o**p**y creates a duplicate of a file:

```bash
# Copy and rename:
cp report.txt report_backup.txt

# Copy to another directory (keeping same name):
cp report.txt ~/Documents/

# Copy to another directory with new name:
cp report.txt ~/Documents/final_report.txt
```

**For directories, use `-r` (recursive):**

```bash
cp -r project/ project_backup/
```

Without `-r`, you'll get an error: `cp: -r not specified; omitting directory 'project/'`

**Useful options:**

- `-i`: **I**nteractive—prompt before overwriting
- `-v`: **V**erbose—show what's being copied
- `-u`: **U**pdate—only copy if source is newer than destination
- `-a`: **A**rchive mode—preserves permissions, timestamps, and structure (ideal for backups)

**Pro tip**: Combine flags for safety and visibility:

```bash
cp -riv source/ destination/
```

### Moving and Renaming

```bash
mv old_name.txt new_name.txt
```

**M**o**v**e serves double duty:

**Renaming** (destination in same directory):

```bash
mv draft.txt final.txt
```

**Moving** (destination in different directory):

```bash
mv final.txt ~/Documents/
```

**Moving and renaming simultaneously:**

```bash
mv draft.txt ~/Documents/final.txt
```

**Moving directories** (no `-r` flag needed):

```bash
mv old_folder/ new_location/
```

**⚠️ Warning**: Unlike `cp`, `mv` doesn't have a built-in way to prevent overwriting. Use `-i` for safety:

```bash
mv -i source.txt destination.txt  # Prompts if destination exists
```

### Deleting Files

```bash
rm filename.txt
```

**R**e**m**ove permanently deletes files. There is no "Recycle Bin" or "Trash" on the command line—once removed, files are gone.

**⚠️ CRITICAL WARNING**: The most dangerous command in Linux is:

```bash
sudo rm -rf /
```

**NEVER RUN THIS.** It recursively (`-r`) and forcefully (`-f`) deletes **everything** on your system, including the operating system itself.

**Safe deletion practices:**

```bash
# Delete a single file:
rm old_file.txt

# Delete with confirmation:
rm -i file.txt  # Prompts before deleting

# Delete multiple files:
rm file1.txt file2.txt file3.txt

# Delete directories (requires -r):
rm -r old_folder/

# Force deletion without prompts (use cautiously):
rm -rf temporary_folder/
```

**Protecting yourself:**

1. Always double-check the path before using `-r`
2. Use `ls` first to verify what you're about to delete
3. Never use `-rf` together unless you're certain
4. Consider aliasing `rm` to `rm -i` in your `.bashrc` for an automatic safety net

**Alternative for empty directories:**

```bash
rmdir empty_folder/
```

This only works on empty directories, providing a safety check against accidental deletion.

### Creating Links

```bash
ln -s /path/to/original /path/to/link
```

**L**i**n**ks are like shortcuts or references. The `-s` creates a **s**ymbolic (soft) link—the most commonly used type.

**Symbolic links** point to a file path:

```bash
ln -s /var/www/html/index.php ~/index_link.php
```

Now you can edit `~/index_link.php` and the changes affect the original file in `/var/www/html/`.

**Real-world use cases:**

- Creating shortcuts to deeply nested files
- Maintaining multiple versions (link to the current version)
- Organizing files without duplicating them
- Cross-referencing configurations

**Viewing links:**

```bash
ls -l
# Output: lrwxrwxrwx ... index_link.php -> /var/www/html/index.php
#         ^
#         'l' indicates it's a link
```

**Hard links** (without `-s`) create a direct reference to file data:

```bash
ln original.txt hardlink.txt
```

Hard links are less common because they have limitations (can't span filesystems, can't link directories).

### Identifying File Types

```bash
file mysterious_file
```

Determines what type of file something is, regardless of its extension (or lack thereof):

```bash
$ file script
script: POSIX shell script, ASCII text executable

$ file image.jpg
image.jpg: JPEG image data, JFIF standard 1.01

$ file compiled_program
compiled_program: ELF 64-bit LSB executable, x86-64
```

**Why this matters**: Unix doesn't rely on file extensions like Windows does. A file named `document` could be a text file, an image, or a program. The `file` command examines the actual content to tell you what it is.

### Verifying File Integrity

```bash
md5sum filename
sha256sum filename
```

These commands generate cryptographic "fingerprints" (checksums) of files:

```bash
$ sha256sum ubuntu-22.04.iso
b8f31413336b9393ad5d8ef0282717b2ab19f007df2e9ed5196c13d8f9153c8b  ubuntu-22.04.iso
```

**Use cases:**

- Verify downloaded files haven't been corrupted or tampered with
- Check if two files are identical without comparing them byte-by-byte
- Detect changes in files (checksums change if even one bit changes)

**Verification workflow:**

```bash
# Download a file and its checksum:
wget https://example.com/file.zip
wget https://example.com/file.zip.sha256

# Verify:
sha256sum -c file.zip.sha256
# Output: file.zip: OK  (means it matches)
```

---

## 4. Reading and Viewing Files

### Quick Output: cat

```bash
cat filename.txt
```

**Con**cat**enate** dumps the entire contents of a file to your screen instantly. Perfect for short files or when you need to pipe content to another command.

**Multiple files:**

```bash
cat file1.txt file2.txt file3.txt  # Shows all files in sequence
```

**Combining files:**

```bash
cat part1.txt part2.txt > complete.txt
```

**⚠️ Common Mistake**: Using `cat` on large files. If you accidentally run `cat` on a gigabyte-sized log file, your terminal will freeze while it tries to display millions of lines. Use `less` instead.

**Quick tips:**

- `cat -n`: Number all lines
- `cat -A`: Show all special characters (tabs, line endings, etc.)

### Interactive Viewing: less

```bash
less large_file.log
```

A powerful pager for viewing files of any size. Unlike `cat`, it doesn't load the entire file into memory—you can view gigabyte-sized files instantly.

**Essential controls:**

- `Spacebar` or `PageDown`: Next page
- `b` or `PageUp`: Previous page
- `g`: Jump to beginning
- `G`: Jump to end
- `/search_term`: Search forward
- `?search_term`: Search backward
- `n`: Next search result
- `N`: Previous search result
- `q`: Quit

**Why "less" is more:**
The name is a play on an older program called `more`. The joke: "less is more than more," meaning `less` has more features than `more`.

**Pro tips:**

```bash
less +F file.log  # Start in "follow" mode (like tail -f)
# Press Ctrl+C to stop following, then navigate normally
```

### First and Last Lines

```bash
head filename.txt  # First 10 lines
tail filename.txt  # Last 10 lines
```

**Custom line counts:**

```bash
head -n 50 access.log  # First 50 lines
tail -n 100 error.log  # Last 100 lines
```

**The killer feature: tail -f**

```bash
tail -f /var/log/syslog
```

The `-f` (follow) flag watches a file in real-time, displaying new lines as they're added. This is indispensable for:

- Monitoring live log files
- Watching build processes
- Debugging applications in real-time

**Stop following:** Press `Ctrl+C`

**Pro tip**: Follow multiple files simultaneously:

```bash
tail -f /var/log/nginx/access.log /var/log/nginx/error.log
```

### Reverse Text: rev

```bash
rev filename.txt
```

Reverses each line character-by-character:

```
Input:  Hello World
Output: dlroW olleH
```

**Practical use?** Honestly, it's rarely used except for:

- Fun text manipulation
- Certain data processing tasks
- Reversing accidentally reversed text

### The Universal Editor: vi/vim

```bash
vi filename.txt
```

Vi (and its improved version, Vim) is the most universally available text editor—present on virtually every Unix-like system. Even if it seems arcane at first, knowing vi basics is essential for system administration.

**Bare minimum survival guide:**

1. **Opening:** `vi filename`
2. **Modes:**
   - **Normal mode** (default): For navigation and commands
   - **Insert mode**: For typing text (press `i` to enter)
   - **Command mode**: For saving/quitting (press `:` to enter)

3. **Basic workflow:**
   - Press `i` to start inserting text
   - Type your content
   - Press `Esc` to return to Normal mode
   - Type `:wq` and press `Enter` to **w**rite and **q**uit

4. **Emergency exit:**
   - If you're stuck: Press `Esc` several times, then type `:q!` and press `Enter`
   - `:q!` quits without saving (overriding any warnings)

**Why learn vi?**

- It's the only editor guaranteed to be present on remote servers
- It's powerful once you overcome the initial learning curve
- Many modern IDEs offer vim keybindings because they're efficient

**Alternatives if vi isn't your thing:**

- `nano`: Simpler, more intuitive for beginners
- `emacs`: Powerful but requires installation on some systems

---

## 5. Searching: Finding Files and Text

### Searching Inside Files: grep

```bash
grep "search_term" filename.txt
```

**G**lobal **R**egular **E**xpression **P**rint is your text search workhorse. It scans files line-by-line and outputs matching lines.

**Basic examples:**

```bash
# Find error messages in a log:
grep "ERROR" application.log

# Case-insensitive search:
grep -i "warning" system.log  # Matches WARNING, Warning, warning

# Show line numbers:
grep -n "TODO" script.sh
# Output: 42:# TODO: Fix this later

# Invert match (show lines that DON'T match):
grep -v "DEBUG" app.log  # Hide debug messages

# Count matches:
grep -c "success" results.txt
# Output: 127
```

**Recursive search through directories:**

```bash
grep -r "config_value" /etc/
```

This searches through all files in `/etc/` and its subdirectories—incredibly powerful for finding where a setting is defined.

**Advanced options:**

- `-A 3`: Show 3 lines **A**fter each match (context)
- `-B 3`: Show 3 lines **B**efore each match
- `-C 3`: Show 3 lines of **C**ontext (both before and after)
- `-E`: Use extended regular expressions (more powerful patterns)
- `-w`: Match whole **w**ords only
- `-x`: Match whole lines only (e**x**act)

**Real-world power move:**

```bash
grep -rn "import pandas" ~/projects/ --include="*.py"
```

Find all Python files in your projects that import pandas, showing line numbers.

**⚠️ Common Pitfall**: Forgetting that grep returns an exit code. This matters in scripts:

```bash
if grep -q "error" log.txt; then
    echo "Errors found!"
fi
```

The `-q` (quiet) flag suppresses output—we only care about the exit code.

### Searching for Files: find

```bash
find /starting/path -name "pattern"
```

While `grep` searches **inside** files, `find` searches **for** files themselves based on name, size, type, permissions, modification time, and more.

**Search by name:**

```bash
# Find all .log files:
find /var/log -name "*.log"

# Case-insensitive name search:
find /home -iname "*.JPG"  # Matches .jpg, .JPG, .Jpg, etc.
```

**Search by type:**

```bash
find /etc -type f  # Only files
find /tmp -type d  # Only directories
find /dev -type l  # Only symbolic links
```

**Search by time:**

```bash
# Modified in last 7 days:
find . -mtime -7

# Modified more than 30 days ago:
find . -mtime +30

# Modified exactly 5 days ago:
find . -mtime 5

# Accessed in last 24 hours:
find /var/log -atime -1
```

**Search by size:**

```bash
# Files larger than 100MB:
find /home -size +100M

# Files smaller than 1KB:
find . -size -1k

# Files between 10MB and 50MB:
find . -size +10M -size -50M
```

**Combining criteria (AND logic is default):**

```bash
# Large log files modified recently:
find /var/log -name "*.log" -size +10M -mtime -7
```

**Executing commands on found files:**

```bash
# Delete all .tmp files:
find /tmp -name "*.tmp" -delete

# Change permissions on all scripts:
find ~/scripts -name "*.sh" -exec chmod +x {} \;

# More efficient with xargs (see Section 6):
find . -name "*.txt" -print0 | xargs -0 wc -l
```

**⚠️ Warning**: `find` with `-delete` or `-exec rm` is powerful and dangerous. Always test without the destructive action first:

```bash
# Test first:
find /tmp -name "*.tmp"
# If output looks right:
find /tmp -name "*.tmp" -delete
```

**Pro tip—excluding directories:**

```bash
# Search but ignore node_modules:
find . -name "*.js" -not -path "*/node_modules/*"
```

### Fast File Locating: locate

```bash
locate filename
```

Blazing fast filename search that works across your entire system. How? It searches a pre-built database instead of scanning the filesystem in real-time.

**Advantages over find:**

- Incredibly fast (sub-second searches across millions of files)
- Simple syntax

**Disadvantages:**

- Database may be outdated (usually updated daily)
- Only searches by filename (no size, time, or content filtering)

**Updating the database:**

```bash
sudo updatedb
```

Run this after creating or deleting many files if you need `locate` to find them immediately.

**Case-insensitive search:**

```bash
locate -i document.pdf
```

**Limiting results:**

```bash
locate -n 20 readme  # Show only first 20 matches
```

**When to use locate vs. find:**

- Use `locate` when you vaguely remember a filename and need quick results
- Use `find` when you need precise criteria (size, date, type) or the database might be stale

### Finding Commands: apropos

```bash
apropos "search term"
```

Searches through man page descriptions to find relevant commands:

```bash
$ apropos "copy files"
cp (1)                   - copy files and directories
cpio (1)                 - copy files to and from archives
rsync (1)                - fast, versatile, remote file-copying tool
```

**Use case**: "I need to do X, but I don't know which command..." Just ask `apropos`.

**Exact keyword match:**

```bash
apropos -e networking
```

### Comparing Files

#### Line-by-line comparison: diff

```bash
diff file1.txt file2.txt
```

Shows exactly what changed between two files:

```
3c3
< This is the old line
---
> This is the new line
7d6
< This line was deleted
```

**Unified format (more readable):**

```bash
diff -u file1.txt file2.txt
```

**Side-by-side comparison:**

```bash
diff -y file1.txt file2.txt
```

**Comparing directories:**

```bash
diff -r directory1/ directory2/
```

**Practical use**: Code reviews, configuration audits, troubleshooting changes.

#### Byte-by-byte comparison: cmp

```bash
cmp file1.bin file2.bin
```

Unlike `diff` (which compares text line-by-line), `cmp` compares files byte-by-byte. Essential for binary files like images, videos, or compiled programs.

**Silent check (just the exit code):**

```bash
cmp -s file1 file2 && echo "Files are identical"
```

#### Comparing sorted files: comm

```bash
comm file1.txt file2.txt
```

Requires both files to be sorted. Outputs three columns:

1. Lines only in file1
2. Lines only in file2
3. Lines in both files

**Suppress columns:**

```bash
comm -12 file1.txt file2.txt  # Show only lines in both (intersection)
comm -23 file1.txt file2.txt  # Show only lines unique to file1
```

---

## 6. Advanced Text Processing: Power Tools

These commands transform raw text into structured information. They're the secret sauce behind command-line productivity.

### Stream Editor: sed

```bash
sed 's/old/new/' filename.txt
```

**S**tream **Ed**itor performs find-and-replace and other transformations as text flows through it.

**Basic substitution:**

```bash
# Replace first occurrence per line:
sed 's/cat/dog/' pets.txt

# Replace all occurrences (g for global):
sed 's/cat/dog/g' pets.txt

# Replace and save to new file:
sed 's/cat/dog/g' pets.txt > updated_pets.txt

# Edit file in-place:
sed -i 's/cat/dog/g' pets.txt
```

**⚠️ Warning**: `-i` modifies the original file. Use `-i.bak` to create a backup:

```bash
sed -i.bak 's/cat/dog/g' pets.txt  # Creates pets.txt.bak
```

**Delete lines:**

```bash
# Delete line 5:
sed '5d' file.txt

# Delete lines 10-20:
sed '10,20d' file.txt

# Delete lines matching a pattern:
sed '/^#/d' script.sh  # Remove comment lines
sed '/^$/d' file.txt   # Remove blank lines
```

**Print specific lines:**

```bash
# Print line 42:
sed -n '42p' large_file.txt

# Print lines 10-20:
sed -n '10,20p' file.txt
```

**Multiple operations:**

```bash
sed -e 's/cat/dog/g' -e 's/red/blue/g' file.txt
```

**Real-world example—configuration file update:**

```bash
# Change database host in config:
sed -i 's/DB_HOST=localhost/DB_HOST=db.example.com/g' config.env
```

### Pattern Scanner: awk

```bash
awk '{print $1}' file.txt
```

AWK is a complete programming language designed for text processing. Its superpower: effortlessly handling column-based data.

**Understanding AWK's model:**

- AWK processes text line-by-line
- Each line is split into fields (columns)
- `$1` is the first field, `$2` is the second, etc.
- `$0` is the entire line

**Basic field extraction:**

```bash
# Print first column:
ls -l | awk '{print $9}'  # Filenames only

# Print multiple columns:
ls -l | awk '{print $9, $5}'  # Filename and size

# Reorder columns:
echo "John Doe 30" | awk '{print $3, $1, $2}'
# Output: 30 John Doe
```

**Custom field separators:**

```bash
# Default separator is whitespace, but you can change it:
awk -F':' '{print $1}' /etc/passwd  # Print all usernames

# Using comma as separator:
awk -F',' '{print $2}' data.csv
```

**Conditional processing:**

```bash
# Print lines where column 3 is greater than 100:
awk '$3 > 100' data.txt

# Print lines matching a pattern:
awk '/ERROR/ {print $1, $4}' log.txt

# Combine conditions:
awk '$3 > 100 && $5 == "active"' data.txt
```

**Mathematical operations:**

```bash
# Sum all numbers in column 2:
awk '{sum += $2} END {print sum}' numbers.txt

# Average:
awk '{sum += $1; count++} END {print sum/count}' data.txt

# Count lines:
awk 'END {print NR}' file.txt  # NR = Number of Records (lines)
```

**Real-world examples:**

Analyze access logs:

```bash
# Count requests per IP:
awk '{print $1}' access.log | sort | uniq -c | sort -nr | head

# Total bandwidth transferred (column 10 is bytes):
awk '{sum += $10} END {print sum/1024/1024 " MB"}' access.log
```

Parse CSV data:

```bash
# Extract email addresses from CSV:
awk -F',' '{print $3}' contacts.csv

# Filter high-value transactions:
awk -F',' '$4 > 1000 {print $1, $2, $4}' transactions.csv
```

**Pro tip**: AWK can replace many pipes:

```bash
# Instead of: cat file | grep pattern | awk '{print $2}'
# Just use:
awk '/pattern/ {print $2}' file
```

### Simple Column Cutter: cut

```bash
cut -d',' -f1 data.csv
```

A simpler alternative to AWK for basic column extraction:

**Extract specific fields:**

```bash
# Field 1 (default delimiter is tab):
cut -f1 file.txt

# Fields 1 and 3:
cut -f1,3 file.txt

# Field range:
cut -f2-5 file.txt

# Custom delimiter:
cut -d':' -f1 /etc/passwd  # Extract usernames
cut -d',' -f2,4 data.csv   # Extract columns 2 and 4 from CSV
```

**Character-based extraction:**

```bash
# First 10 characters of each line:
cut -c1-10 file.txt

# Characters 5 through 15:
cut -c5-15 file.txt

# Everything from character 20 onward:
cut -c20- file.txt
```

**When to use cut vs. awk:**

- Use `cut` for simple, single-delimiter column extraction
- Use `awk` for complex conditions, calculations, or multiple delimiters

### Sorting Lines: sort

```bash
sort filename.txt
```

Arranges lines alphabetically or numerically:

**Basic sorting:**

```bash
# Alphabetical (default):
sort names.txt

# Reverse order:
sort -r names.txt

# Numeric sort (critical for numbers):
sort -n numbers.txt
```

**Why `-n` matters:**

```bash
# Without -n (alphabetical):
echo -e "1\n10\n2\n20" | sort
# Output: 1, 10, 2, 20 (wrong!)

# With -n (numeric):
echo -e "1\n10\n2\n20" | sort -n
# Output: 1, 2, 10, 20 (correct!)
```

**Sort by specific column:**

```bash
# Sort by second column, numerically:
sort -k2 -n data.txt

# Sort by third column, reverse:
sort -k3 -r data.txt

# Multiple sort keys:
sort -k1,1 -k2n data.txt  # Sort by column 1, then by column 2 numerically
```

**Advanced options:**

```bash
# Ignore leading blanks:
sort -b file.txt

# Case-insensitive:
sort -f names.txt

# Human-readable numbers (understands K, M, G):
du -h * | sort -h

# Random shuffle:
sort -R file.txt

# Unique sort (remove duplicates while sorting):
sort -u file.txt
```

**Real-world example—find largest directories:**

```bash
du -sh * | sort -h | tail -10
```

### Remove Duplicate Lines: uniq

```bash
uniq file.txt
```

Removes **adjacent** duplicate lines—this is crucial to understand.

**⚠️ Critical Pitfall**: `uniq` only removes duplicates that are next to each other:

```bash
# This WON'T work as expected:
echo -e "apple\nbanana\napple" | uniq
# Output: apple, banana, apple (duplicate remains!)

# This WILL work:
echo -e "apple\nbanana\napple" | sort | uniq
# Output: apple, banana
```

**Best practice**: Always pipe through `sort` first:

```bash
sort file.txt | uniq
```

**Count occurrences:**

```bash
sort file.txt | uniq -c
# Output:
#   3 apple
#   1 banana
#   2 cherry
```

**Show only duplicates:**

```bash
sort file.txt | uniq -d
```

**Show only unique lines (no duplicates):**

```bash
sort file.txt | uniq -u
```

**Real-world examples:**

Count unique visitors in access log:

```bash
awk '{print $1}' access.log | sort | uniq | wc -l
```

Find most common error messages:

```bash
grep ERROR app.log | sort | uniq -c | sort -nr | head -10
```

### Character Translation: tr

```bash
tr 'abc' 'xyz'
```

**Tr**anslates or deletes characters—works on standard input only:

**Character substitution:**

```bash
# Convert lowercase to uppercase:
echo "hello world" | tr 'a-z' 'A-Z'
# Output: HELLO WORLD

# Convert uppercase to lowercase:
echo "HELLO WORLD" | tr 'A-Z' 'a-z'
# Output: hello world

# ROT13 encoding:
echo "Hello" | tr 'A-Za-z' 'N-ZA-Mn-za-m'
```

**Delete characters:**

```bash
# Remove all digits:
echo "Phone: 555-1234" | tr -d '0-9'
# Output: Phone: -

# Remove all spaces:
echo "too  many   spaces" | tr -d ' '
# Output: toomanyspaces

# Remove newlines:
cat multiline.txt | tr -d '\n'
```

**Squeeze repeated characters:**

```bash
# Collapse multiple spaces to single space:
echo "too    many     spaces" | tr -s ' '
# Output: too many spaces

# Remove duplicate letters:
echo "bookkeeper" | tr -s 'a-z'
# Output: bokeper
```

**Complement (invert the set):**

```bash
# Keep only alphanumeric characters:
echo "Hello, World! 123" | tr -cd 'A-Za-z0-9'
# Output: HelloWorld123

# Remove everything except newlines (one word per line):
cat file.txt | tr -cs 'A-Za-z' '\n'
```

**Real-world uses:**

Convert DOS line endings to Unix:

```bash
tr -d '\r' < dos_file.txt > unix_file.txt
```

Generate random passwords:

```bash
tr -dc 'A-Za-z0-9!@#$%' < /dev/urandom | head -c 20
```

### Word, Line, and Byte Counting: wc

```bash
wc filename.txt
```

**W**ord **C**ount provides statistics about text:

**Default output:**

```bash
$ wc document.txt
  45  312 2048 document.txt
  │   │   │    └─ filename
  │   │   └────── bytes
  │   └────────── words
  └────────────── lines
```

**Specific counts:**

```bash
wc -l file.txt  # Lines only (most common)
wc -w file.txt  # Words only
wc -c file.txt  # Bytes only
wc -m file.txt  # Characters (may differ from bytes with Unicode)
wc -L file.txt  # Length of longest line
```

**Multiple files:**

```bash
$ wc -l *.txt
  100 file1.txt
  200 file2.txt
  150 file3.txt
  450 total
```

**Real-world examples:**

Count files in directory:

```bash
ls | wc -l
```

Count lines of code in project:

```bash
find . -name "*.py" -exec cat {} \; | wc -l
```

Monitor log growth rate:

```bash
# Before:
wc -l app.log
# ... wait some time ...
# After:
wc -l app.log  # Compare the numbers
```

Count occurrences of a pattern:

```bash
grep -r "TODO" src/ | wc -l
```

### Pipe Splitter: tee

```bash
command | tee output.txt
```

Splits a pipeline: sends output to **both** a file and the screen (or next command).

**Basic usage:**

```bash
# See output AND save it:
ls -la | tee file_list.txt

# Long-running command—monitor and save:
./build_script.sh | tee build.log
```

**Append instead of overwrite:**

```bash
echo "New entry" | tee -a log.txt
```

**Multiple outputs:**

```bash
echo "Important" | tee file1.txt file2.txt file3.txt
```

**Combining with sudo:**

```bash
# This WON'T work (sudo doesn't apply to redirection):
sudo echo "nameserver 8.8.8.8" > /etc/resolv.conf

# This WILL work:
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf

# Append with sudo:
echo "option timeout:1" | sudo tee -a /etc/resolv.conf
```

**Real-world pattern—save and continue processing:**

```bash
# Save intermediate results while continuing pipeline:
cat data.txt | tee raw_data.txt | grep "ERROR" | tee errors.txt | wc -l
```

**Pro tip—silent output:**

```bash
# Save to file without screen output:
command | tee file.txt > /dev/null
```

### Argument Builder: xargs

```bash
command1 | xargs command2
```

Converts input into arguments for another command. This solves a fundamental problem: many commands don't read from standard input—they need arguments.

**The problem xargs solves:**

```bash
# This doesn't work (rm doesn't read filenames from stdin):
find . -name "*.tmp" | rm

# This works:
find . -name "*.tmp" | xargs rm
```

**Basic usage:**

```bash
# Delete files returned by find:
find . -name "*.log" | xargs rm

# Create directories:
echo "dir1 dir2 dir3" | xargs mkdir

# Download multiple URLs:
cat urls.txt | xargs wget
```

**Handling spaces and special characters:**

```bash
# UNSAFE (breaks with spaces in filenames):
find . -name "*.txt" | xargs rm

# SAFE (use null delimiter):
find . -name "*.txt" -print0 | xargs -0 rm
```

The `-print0` and `-0` combination uses null bytes (`\0`) as delimiters instead of spaces, making it safe for filenames with spaces, quotes, or other special characters.

**Control execution:**

```bash
# Run command once per item (-n 1):
echo "file1 file2 file3" | xargs -n 1 echo "Processing:"
# Output:
# Processing: file1
# Processing: file2
# Processing: file3

# Parallel execution (-P):
find . -name "*.jpg" | xargs -P 4 -I {} convert {} {}.optimized.jpg
# Processes 4 images simultaneously
```

**Interactive prompting:**

```bash
# Confirm before each execution:
find . -name "*.tmp" | xargs -p rm
# Prompts: rm ./file1.tmp?...
```

**Replace string:**

```bash
# Use {} as placeholder:
find . -name "*.txt" | xargs -I {} cp {} {}.backup

# Custom placeholder:
cat hostnames.txt | xargs -I HOST ssh HOST "df -h"
```

**Real-world examples:**

Batch rename files:

```bash
ls *.jpeg | xargs -I {} bash -c 'mv {} $(echo {} | sed s/jpeg/jpg/)'
```

Check which servers are up:

```bash
cat servers.txt | xargs -I {} -P 10 ping -c 1 {}
```

Find and replace across multiple files:

```bash
grep -l "old_term" *.txt | xargs sed -i 's/old_term/new_term/g'
```

Compress large files in parallel:

```bash
find . -name "*.log" -size +100M -print0 | xargs -0 -P 4 gzip
```

---

## 7. Users, Permissions, and Access Control

Linux is a multi-user system with robust permission controls. Understanding these concepts is essential for both security and day-to-day operations.

### Identifying Yourself

```bash
whoami
```

Shows your current username:

```bash
$ whoami
akib
```

**When it matters**: After using `su` to switch users, or in scripts where you need to check who's running the code.

### Detailed User Information

```bash
id
```

Displays your user ID (UID), group ID (GID), and all group memberships:

```bash
$ id
uid=1000(akib) gid=1000(akib) groups=1000(akib),27(sudo),998(docker)
```

**What this tells you:**

- `uid=1000(akib)`: Your user ID is 1000, username is "akib"
- `gid=1000(akib)`: Your primary group ID is 1000, group name is "akib"
- `groups=...`: You're also in the "sudo" and "docker" groups

**Why it matters**: Group membership determines what you can access. Being in the "sudo" group means you can run admin commands. Being in the "docker" group means you can run Docker containers without sudo.

**Check another user:**

```bash
id username
```

### List Group Memberships

```bash
groups
```

Simpler than `id`—just lists group names:

```bash
$ groups
akib sudo docker www-data
```

**Check another user's groups:**

```bash
groups username
```

### Execute as Administrator: sudo

```bash
sudo command
```

**S**uper**u**ser **Do** lets you run individual commands with root privileges:

```bash
# Install software:
sudo apt install nginx

# Edit system files:
sudo nano /etc/hosts

# Restart services:
sudo systemctl restart apache2

# View protected files:
sudo cat /var/log/auth.log
```

**How it works:**

1. You enter your password (not root's password)
2. System checks if you're in the `sudo` group
3. Command runs with root privileges
4. Your password is cached for ~15 minutes

**Running multiple commands:**

```bash
# Start a root shell:
sudo -i  # Login shell (loads root's environment)
sudo -s  # Shell (preserves your environment)

# Run specific shell as root:
sudo bash
```

**Run as different user:**

```bash
sudo -u username command
```

**Preserve environment variables:**

```bash
sudo -E command  # Keeps your environment
```

**Best practices:**

- Only use `sudo` when necessary
- Never run untrusted scripts with `sudo`
- Review what a command does before adding `sudo`
- Use `sudo -i` for multiple admin tasks, then `exit` when done

**⚠️ Security Warning**: The phrase "with great power comes great responsibility" was practically invented for `sudo`. One mistyped command can destroy your system.

### Switch Users: su

```bash
su username
```

**S**ubstitute **U**ser switches your entire session to another account:

```bash
# Become root:
su
# or
su root

# Become another user:
su - john  # The dash loads john's environment
```

**Difference from sudo:**

- `su` requires the **target user's** password
- `sudo` requires **your** password
- `su` switches your entire session
- `sudo` runs one command

**Why `sudo` is preferred:**

- More auditable (logs show who did what)
- More granular (can limit what commands users can run)
- Doesn't require sharing the root password
- Automatically times out

**Return to original user:**

```bash
exit
```

### Understanding File Permissions

Every file and directory has permissions that control who can read, write, or execute it.

**Viewing permissions:**

```bash
$ ls -l script.sh
-rwxr-xr-- 1 akib developers 2048 Oct 24 10:30 script.sh
│││││││││
│││││││││
│││││││└┴─ Other users: r-- (read only)
││││││└──── Group: r-x (read and execute)
│││││└───── Owner: rwx (read, write, execute)
││││└────── ACLs indicator
│││└─────── Number of hard links
││└──────── File type: - (regular file)
│└───────── Also applies to: d (directory), l (link)
```

**Permission breakdown:**

- **r** (read): View file contents / List directory contents
- **w** (write): Modify file / Create/delete files in directory
- **x** (execute): Run file as program / Enter directory

**Three permission sets:**

1. **Owner** (user who created the file)
2. **Group** (users in the file's group)
3. **Others** (everyone else)

### Changing Permissions: chmod

```bash
chmod permissions file
```

**Symbolic method (human-readable):**

```bash
# Add execute permission for owner:
chmod u+x script.sh

# Remove write permission for others:
chmod o-w document.txt

# Add read permission for group:
chmod g+r data.txt

# Set exact permissions:
chmod u=rwx,g=rx,o=r file.txt

# Multiple changes:
chmod u+x,g+x,o-w script.sh
```

**Symbols:**

- `u` = user (owner)
- `g` = group
- `o` = others
- `a` = all (user, group, and others)

**Operators:**

- `+` = add permission
- `-` = remove permission
- `=` = set exact permission

**Octal method (numeric):**

Each permission set is represented by a three-digit octal number:

```
r = 4
w = 2
x = 1
```

Add them up:

- `7` (4+2+1) = rwx
- `6` (4+2) = rw-
- `5` (4+1) = r-x
- `4` = r--
- `0` = ---

**Common patterns:**

```bash
# rwxr-xr-x (755): Owner full, others read/execute
chmod 755 script.sh

# rw-r--r-- (644): Owner read/write, others read-only
chmod 644 document.txt

# rwx------ (700): Only owner can access
chmod 700 private_script.sh

# rw-rw-r-- (664): Owner and group can edit, others read
chmod 664 shared_doc.txt
```

**Recursive (apply to all files in directory):**

```bash
chmod -R 755 /var/www/html/
```

**Real-world examples:**

Make script executable:

```bash
chmod +x deploy.sh
./deploy.sh  # Now you can run it
```

Secure SSH keys:

```bash
chmod 600 ~/.ssh/id_rsa  # Private keys must be owner-only
chmod 644 ~/.ssh/id_rsa.pub  # Public keys can be readable
```

Fix web server permissions:

```bash
# Directories: 755 (browsable)
find /var/www -type d -exec chmod 755 {} \;
# Files: 644 (readable)
find /var/www -type f -exec chmod 644 {} \;
```

### Changing Ownership: chown

```bash
chown owner:group file
```

Changes who owns a file:

```bash
# Change owner only:
sudo chown john file.txt

# Change owner and group:
sudo chown john:developers file.txt

# Change group only:
sudo chown :developers file.txt
# or use chgrp:
sudo chgrp developers file.txt

# Recursive:
sudo chown -R www-data:www-data /var/www/html/
```

**Why you need sudo**: Only root can change file ownership (security feature).

**Real-world use case:**
After extracting files as root, change ownership to regular user:

```bash
sudo tar -xzf archive.tar.gz
sudo chown -R $USER:$USER extracted_folder/
```

**Fix web application permissions:**

```bash
# Web server needs to own web files:
sudo chown -R www-data:www-data /var/www/myapp/

# But you need to edit them:
sudo usermod -aG www-data $USER  # Add yourself to www-data group
```

### Changing Your Password

```bash
passwd
```

Prompts you to change your password:

```bash
$ passwd
Changing password for akib.
Current password:
New password:
Retype new password:
passwd: password updated successfully
```

**Change another user's password (as root):**

```bash
sudo passwd username
```

**Password requirements:**

- Usually minimum 8 characters
- Mix of letters, numbers, symbols
- Not based on dictionary words
- Different from previous passwords

**Best practices:**

- Use a password manager
- Use strong, unique passwords for each system
- Enable two-factor authentication when available
- Change passwords periodically, especially after security incidents

---

## 8. Process and System Management

Understanding and controlling what your system is doing.

### Viewing Processes: ps

```bash
ps
```

**P**rocess **S**tatus shows currently running processes:

**Basic output:**

```bash
$ ps
  PID TTY          TIME CMD
 1234 pts/0    00:00:00 bash
 5678 pts/0    00:00:00 ps
```

**Show all processes:**

```bash
ps aux  # BSD style (no dash)
ps -ef  # Unix style (with dash)
```

Both show similar information—choose whichever you prefer.

**Understanding `ps aux` output:**

```bash
USER  PID %CPU %MEM    VSZ   RSS TTY   STAT START   TIME COMMAND
akib  1234  0.5  2.1 123456 12345 pts/0 S    10:30   0:05 python app.py
│     │     │    │     │      │    │    │    │       │    └─ command
│     │     │    │     │      │    │    │    │       └────── CPU time used
│     │     │    │     │      │    │    │    └────────────── start time
│     │     │    │     │      │    │    └─────────────────── state
│     │     │    │     │      │    └──────────────────────── terminal
│     │     │    │     │      └───────────────────────────── resident memory (KB)
│     │     │    │     └──────────────────────────────────── virtual memory (KB)
│     │     │    └────────────────────────────────────────── % of RAM
│     │     └─────────────────────────────────────────────── % of CPU
│     └───────────────────────────────────────────────────── process ID
└─────────────────────────────────────────────────────────── user
```

**Process states:**

- `R`: Running
- `S`: Sleeping (waiting for an event)
- `D`: Uninterruptible sleep (usually I/O)
- `Z`: Zombie (finished but not cleaned up)
- `T`: Stopped (paused)

**Find specific processes:**

```bash
ps aux | grep python
ps aux | grep -i apache
```

**Show process tree (parent-child relationships):**

```bash
ps auxf  # Forest view
pstree   # Dedicated tree view
```

**Sort by CPU usage:**

```bash
ps aux --sort=-%cpu | head
```

**Sort by memory usage:**

```bash
ps aux --sort=-%mem | head
```

### Real-Time Process Monitoring: top and htop

```bash
top
```

Interactive, real-time view of system processes:

**Essential `top` commands:**

- `q`: Quit
- `k`: Kill a process (prompts for PID)
- `M`: Sort by memory usage
- `P`: Sort by CPU usage
- `1`: Show individual CPU cores
- `h`: Help
- `u`: Filter by username
- `Spacebar`: Refresh immediately

**Understanding the top display:**

```
top - 14:32:01 up 5 days, 2:17, 3 users, load average: 0.45, 0.62, 0.58
Tasks: 187 total, 1 running, 186 sleeping, 0 stopped, 0 zombie
%Cpu(s): 12.3 us, 3.1 sy, 0.0 ni, 84.1 id, 0.5 wa, 0.0 hi, 0.0 si, 0.0 st
MiB Mem:  15842.5 total, 2341.2 free, 8234.7 used, 5266.6 buff/cache
MiB Swap:  2048.0 total, 2048.0 free, 0.0 used. 6892.4 avail Mem
```

**Load average explained:**

- Three numbers: 1-minute, 5-minute, 15-minute averages
- Represents number of processes waiting for CPU time
- On a 4-core system, load of 4.0 means fully utilized
- Load > number of cores = system is overloaded

**Better alternative: htop**

```bash
htop
```

A more user-friendly version with:

- Color-coded display
- Mouse support
- Easier process killing
- Tree view by default
- Better visual representation of CPU and memory

**Install htop:**

```bash
sudo apt install htop  # Debian/Ubuntu
sudo yum install htop  # Red Hat/CentOS
```

**⚠️ Common Mistake**: Panicking when you see high CPU usage in `top`. Check if it's legitimate activity before killing processes.

### Terminating Processes: kill

```bash
kill PID
```

Sends signals to processes—usually to terminate them:

**Basic usage:**

```bash
# Graceful termination (SIGTERM):
kill 1234

# Force kill (SIGKILL):
kill -9 1234
```

**Signal types:**

- `SIGTERM` (15, default): "Please terminate gracefully"
  - Allows process to clean up (save files, close connections)
  - Can be ignored by the process
- `SIGKILL` (9): "Die immediately"
  - Cannot be ignored or caught
  - No cleanup—data loss possible
  - Use as last resort

**Other useful signals:**

```bash
kill -HUP 1234   # Hang up (often makes daemons reload config)
kill -STOP 1234  # Pause process
kill -CONT 1234  # Resume paused process
```

**Kill by name:**

```bash
killall process_name  # Kill all processes with this name
pkill pattern         # Kill processes matching pattern
```

**Examples:**

```bash
# Kill all Python processes:
killall python3

# Kill all processes owned by user:
pkill -u username

# Kill frozen Firefox:
killall -9 firefox
```

**Finding the PID:**

```bash
# Method 1:
ps aux | grep program_name

# Method 2:
pgrep program_name

# Method 3:
pidof program_name
```

**⚠️ Warning**: Always try regular `kill` before `kill -9`. Forcing termination can lead to:

- Lost unsaved work
- Corrupted files
- Orphaned processes
- Resource leaks

### Job Control: bg, fg, jobs

When you start a program from the terminal, it's a "foreground job" that takes over your prompt. Job control lets you manage multiple programs.

**Suspend current job:**
Press `Ctrl+Z` to pause the foreground job:

```bash
$ python long_script.py
^Z
[1]+  Stopped                 python long_script.py
```

**List jobs:**

```bash
$ jobs
[1]+  Stopped                 python long_script.py
[2]-  Running                 npm start &
```

**Resume in foreground:**

```bash
fg %1  # Resume job 1 in foreground
```

**Resume in background:**

```bash
bg %1  # Job 1 continues running, but you get your prompt back
```

**Start job in background immediately:**

```bash
long_running_command &  # Ampersand runs it in background
```

**Real-world workflow:**

```bash
# Start editing a file:
vim document.txt

# Realize you need to check something:
# Press Ctrl+Z to suspend vim

# Run other commands:
ls -la
cat other_file.txt

# Go back to editing:
fg

# Or start a long task while editing:
bg  # Continue vim in background (if it supports it)
```

**⚠️ Limitation**: Background jobs still output to the terminal. For true detachment, use `nohup` or terminal multiplexers.

### Run After Logout: nohup

```bash
nohup command &
```

**No** **H**ang **Up** makes a process immune to logout—essential for long-running tasks on remote servers:

```bash
# Start a long backup:
nohup ./backup_script.sh &

# Start a development server:
nohup npm start &

# Output goes to nohup.out by default:
tail -f nohup.out
```

**Redirect output:**

```bash
nohup ./script.sh > output.log 2>&1 &
```

**Explanation:**

- `nohup`: Ignore hangup signals
- `> output.log`: Redirect stdout
- `2>&1`: Redirect stderr to same place as stdout
- `&`: Run in background

**Check if it's running:**

```bash
ps aux | grep script.sh
```

**Better alternative for remote work**: Use `tmux` or `screen` (see Advanced Techniques section).

### Disk Space: df

```bash
df -h
```

**D**isk **F**ree shows available disk space per filesystem:

```bash
$ df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1        50G   35G   13G  74% /
/dev/sdb1       500G  350G  125G  74% /home
tmpfs           7.8G  1.2M  7.8G   1% /dev/shm
```

**What it shows:**

- `Filesystem`: Device or partition
- `Size`: Total capacity
- `Used`: Space consumed
- `Avail`: Space remaining
- `Use%`: Percentage full
- `Mounted on`: Where it's accessible in the directory tree

**⚠️ Warning**: When a disk hits 100%, things break:

- Can't save files
- Logs can't write (applications fail)
- System becomes unstable

**Quick checks:**

```bash
df -h /          # Check root partition
df -h /home      # Check home partition
df -h --total    # Show grand total
```

**Find largest filesystems:**

```bash
df -h | sort -h -k3  # Sort by usage
```

### Directory Sizes: du

```bash
du -sh directory/
```

**D**isk **U**sage shows how much space files and directories consume:

```bash
# Summary of directory:
du -sh ~/Downloads/
# Output: 2.3G    /home/akib/Downloads/

# Summarize each subdirectory:
du -sh ~/Documents/*
# Output:
# 150M    /home/akib/Documents/Work
# 3.2G    /home/akib/Documents/Projects
# 45M     /home/akib/Documents/Personal

# Show all files and directories (recursive):
du -h ~/Projects/
```

**Options:**

- `-s`: **S**ummary (don't show subdirectories)
- `-h`: **H**uman-readable sizes
- `-c`: Show grand total
- `--max-depth=N`: Limit recursion depth

**Find disk hogs:**

```bash
# Top 10 largest directories:
du -sh /* | sort -h | tail -10

# Or more accurate:
du -h --max-depth=1 / | sort -h | tail -10
```

**Find large files:**

```bash
find / -type f -size +100M -exec du -h {} \; | sort -h
```

**Real-world troubleshooting:**

```bash
# "Disk full" alert—find the culprit:
du -sh /* | sort -h | tail -5
# Drill down into the largest directory:
du -sh /var/* | sort -h | tail -5
# Continue until you find the problem:
du -sh /var/log/* | sort -h | tail -5
```

### System Information: uname

```bash
uname -a
```

Shows kernel and system information:

```bash
$ uname -a
Linux myserver 5.15.0-56-generic #62-Ubuntu SMP Thu Nov 24 13:31:22 UTC 2022 x86_64 x86_64 x86_64 GNU/Linux
```

**Individual components:**

```bash
uname -s  # Kernel name: Linux
uname -n  # Network name: myserver
uname -r  # Kernel release: 5.15.0-56-generic
uname -v  # Kernel version: #62-Ubuntu SMP Thu Nov 24...
uname -m  # Machine hardware: x86_64
uname -o  # Operating system: GNU/Linux
```

**Practical use:**

```bash
# Check if you're on 64-bit:
uname -m
# x86_64 = 64-bit, i686 = 32-bit

# Get kernel version for bug reports:
uname -r
```

### Hostname

```bash
hostname
```

Shows or sets the system's network name:

```bash
$ hostname
myserver.example.com

# Show just the short name:
$ hostname -s
myserver

# Show IP addresses:
$ hostname -I
192.168.1.100 10.0.0.50
```

**Change hostname (temporary):**

```bash
sudo hostname newname
```

**Change hostname (permanent):**

```bash
# Ubuntu/Debian:
sudo hostnamectl set-hostname newname

# Older systems:
sudo nano /etc/hostname  # Edit file
sudo nano /etc/hosts     # Update 127.0.1.1 entry
```

### System Shutdown and Reboot

```bash
reboot
shutdown
```

Control system power state (requires `sudo`):

**Reboot immediately:**

```bash
sudo reboot
```

**Shutdown immediately:**

```bash
sudo shutdown -h now
```

**Shutdown with delay:**

```bash
sudo shutdown -h +10  # Shutdown in 10 minutes
sudo shutdown -h 23:00  # Shutdown at 11 PM
```

**Reboot with delay:**

```bash
sudo shutdown -r +5  # Reboot in 5 minutes
```

**Cancel scheduled shutdown:**

```bash
sudo shutdown -c
```

**Broadcast message to users:**

```bash
sudo shutdown -h +10 "System maintenance in 10 minutes"
```

**Alternative commands:**

```bash
sudo poweroff  # Immediate shutdown
sudo halt      # Stop the system (older method)
sudo init 0    # Shutdown (runlevel 0)
sudo init 6    # Reboot (runlevel 6)
```

---

## 9. Networking Essentials

### Testing Connectivity: ping

```bash
ping hostname
```

Checks if you can reach a remote host:

```bash
$ ping google.com
PING google.com (142.250.185.46) 56(84) bytes of data.
64 bytes from lga34s34-in-f14.1e100.net (142.250.185.46): icmp_seq=1 ttl=117 time=12.3 ms
64 bytes from lga34s34-in-f14.1e100.net (142.250.185.46): icmp_seq=2 ttl=117 time=11.8 ms
```

**Understanding output:**

- `64 bytes`: Packet size
- `icmp_seq`: Packet sequence number
- `ttl`: Time To Live (hops remaining)
- `time`: Round-trip latency in milliseconds

**Stop pinging:**
Press `Ctrl+C` to stop. You'll see statistics:

```
--- google.com ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3005ms
rtt min/avg/max/mdev = 11.532/12.015/12.847/0.518 ms
```

**Useful options:**

```bash
# Send specific number of pings:
ping -c 4 google.com

# Set interval (1 second default):
ping -i 0.5 example.com  # Ping every 0.5 seconds

# Flood ping (requires root):
sudo ping -f 192.168.1.1  # As fast as possible (testing)

# Set packet size:
ping -s 1000 example.com  # 1000-byte packets
```

**Troubleshooting scenarios:**

No response:

```bash
$ ping 192.168.1.50
PING 192.168.1.50 (192.168.1.50) 56(84) bytes of data.
^C
--- 192.168.1.50 ping statistics ---
5 packets transmitted, 0 received, 100% packet loss
```

**Causes**: Host down, network unreachable, firewall blocking ICMP

High latency:

```bash
time=523 ms  # Should be <50ms for LAN, <100ms for internet
```

**Causes**: Network congestion, bad connection, routing issues

Packet loss:

```bash
10 packets transmitted, 7 received, 30% packet loss
```

**Causes**: Weak WiFi, network congestion, failing hardware

### Remote Access: ssh

```bash
ssh user@hostname
```

**S**ecure **Sh**ell connects you to remote Linux systems securely:

**Basic connection:**

```bash
ssh akib@192.168.1.100
ssh admin@server.example.com
```

**Custom port:**

```bash
ssh -p 2222 user@hostname
```

**Execute single command:**

```bash
ssh user@server "df -h"
ssh user@server "systemctl status nginx"
```

**X11 forwarding (run GUI apps remotely):**

```bash
ssh -X user@server
# Then run GUI programs—they display on your local screen
```

**Verbose output (troubleshooting):**

```bash
ssh -v user@server   # Verbose
ssh -vvv user@server # Very verbose
```

**SSH config file** (`~/.ssh/config`):
Make connections easier:

```
Host myserver
    HostName server.example.com
    User akib
    Port 22
    IdentityFile ~/.ssh/id_rsa

Host prod
    HostName 203.0.113.50
    User admin
    Port 2222
```

Now just type:

```bash
ssh myserver
ssh prod
```

**Key-based authentication** (covered in Advanced Techniques):

- More secure than passwords
- No password typing required
- Essential for automation

**⚠️ Security Best Practices:**

- Never use root account directly (use sudo instead)
- Disable password authentication (use keys only)
- Use non-standard ports
- Enable fail2ban to block brute-force attacks
- Keep SSH updated

### File Synchronization: rsync

```bash
rsync source destination
```

**R**emote **Sync** is the Swiss Army knife of file copying—efficient, powerful, and network-aware:

**Basic local copy:**

```bash
rsync -av source/ destination/
```

**Essential options:**

- `-a`: **A**rchive mode (preserves permissions, timestamps, symbolic links)
- `-v`: **V**erbose (show files being transferred)
- `-z`: Compress during transfer
- `-h`: **H**uman-readable sizes
- `-P`: Show **P**rogress + keep partial files

**Best practice combination:**

```bash
rsync -avzP source/ destination/
```

**Remote copying:**

```bash
# Upload to remote server:
rsync -avz /local/path/ user@server:/remote/path/

# Download from remote server:
rsync -avz user@server:/remote/path/ /local/path/
```

**Important trailing slash behavior:**

```bash
# With trailing slash—copy CONTENTS:
rsync -av source/ destination/
# Result: destination contains files from source

# Without trailing slash—copy DIRECTORY:
rsync -av source destination/
# Result: destination/source/ contains the files
```

**Delete files in destination not in source:**

```bash
rsync -av --delete source/ destination/
```

**Dry run (preview what would happen):**

```bash
rsync -avn --delete source/ destination/
# -n = dry run (no changes made)
```

**Exclude files:**

```bash
# Exclude pattern:
rsync -av --exclude '*.tmp' source/ dest/

# Multiple excludes:
rsync -av --exclude '*.log' --exclude 'node_modules/' source/ dest/

# Exclude file list:
rsync -av --exclude-from='exclude-list.txt' source/ dest/
```

**Resume interrupted transfers:**

```bash
rsync -avP source/ dest/  # -P enables partial file resumption
```

**Real-world examples:**

Backup entire home directory:

```bash
rsync -avzP --delete ~/  /mnt/backup/home/
```

Mirror website to remote server:

```bash
rsync -avz --delete /var/www/html/ user@webserver:/var/www/html/
```

Sync with bandwidth limit:

```bash
rsync -avz --bwlimit=1000 large-files/ user@server:/path/
# Limit to 1000 KB/s
```

**Why rsync beats scp:**

- Only transfers changed parts of files (delta transfer)
- Can resume interrupted transfers
- More options for filtering and control
- Better for large transfers or slow connections

### Network Information: ip

```bash
ip addr show
```

Modern tool for viewing and configuring network interfaces (replaces older `ifconfig`):

**Show all network interfaces:**

```bash
$ ip addr show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN
    inet 127.0.0.1/8 scope host lo
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP
    inet 192.168.1.100/24 brd 192.168.1.255 scope global eth0
```

**Abbreviated versions:**

```bash
ip a         # Short for 'ip addr show'
ip addr      # Same thing
ip link show # Show link-layer information
ip link      # Abbreviated
```

**Show specific interface:**

```bash
ip addr show eth0
ip addr show wlan0
```

**Show routing table:**

```bash
ip route show
# or
ip r
```

**Show statistics:**

```bash
ip -s link  # Interface statistics (packets, errors)
```

**Common tasks:**

Add IP address (temporary):

```bash
sudo ip addr add 192.168.1.50/24 dev eth0
```

Remove IP address:

```bash
sudo ip addr del 192.168.1.50/24 dev eth0
```

Bring interface up/down:

```bash
sudo ip link set eth0 up
sudo ip link set eth0 down
```

**⚠️ Note**: Changes with `ip` are temporary—they're lost on reboot. Permanent changes require editing network configuration files (location varies by distribution).

### Downloading Files: wget and curl

Both download files from the web, but with different philosophies:

#### wget: The Downloader

```bash
wget URL
```

Designed specifically for downloading files:

**Basic download:**

```bash
wget https://example.com/file.zip
```

**Save with custom name:**

```bash
wget -O custom_name.zip https://example.com/file.zip
```

**Resume interrupted download:**

```bash
wget -c https://example.com/large_file.iso
```

**Download multiple files:**

```bash
wget -i urls.txt  # File containing list of URLs
```

**Background download:**

```bash
wget -b https://example.com/file.zip
tail -f wget-log  # Monitor progress
```

**Recursive download (mirror site):**

```bash
wget -r -np -k https://example.com/docs/
# -r = recursive
# -np = no parent (don't go up in directory structure)
# -k = convert links for local viewing
```

**Limit download speed:**

```bash
wget --limit-rate=200k https://example.com/file.zip
```

**Authentication:**

```bash
wget --user=username --password=pass https://example.com/file.zip
```

#### curl: The Swiss Army Knife

```bash
curl URL
```

More versatile—can handle uploads, APIs, and complex protocols:

**Basic download (outputs to stdout):**

```bash
curl https://example.com/file.txt
```

**Save to file:**

```bash
curl -o filename.txt https://example.com/file.txt
# or preserve remote filename:
curl -O https://example.com/file.txt
```

**Follow redirects:**

```bash
curl -L https://example.com/redirect
```

**Show progress:**

```bash
curl -# -O https://example.com/file.zip  # Progress bar
```

**API requests:**

```bash
# GET request:
curl https://api.example.com/users

# POST request with data:
curl -X POST -d "name=John&email=john@example.com" https://api.example.com/users

# JSON POST:
curl -X POST -H "Content-Type: application/json" \
     -d '{"name":"John","email":"john@example.com"}' \
     https://api.example.com/users

# With authentication:
curl -u username:password https://api.example.com/data
```

**Headers:**

```bash
# Show response headers:
curl -i https://example.com

# Show only headers:
curl -I https://example.com

# Custom headers:
curl -H "Authorization: Bearer TOKEN" https://api.example.com/data
```

**Upload files:**

```bash
curl -F "file=@document.pdf" https://example.com/upload
```

**When to use which:**

- **wget**: Downloading files, mirroring websites, resume capability
- **curl**: API testing, complex requests, headers, uploads

---

## 10. Archives and Compression

### The Tape Archive: tar

```bash
tar options archive.tar files
```

Originally designed for **T**ape **Ar**chives, `tar` bundles multiple files into a single file (without compression):

**Essential operations:**

**Create archive:**

```bash
tar -cvf archive.tar file1 file2 directory/
# -c = create
# -v = verbose
# -f = filename
```

**Extract archive:**

```bash
tar -xvf archive.tar
# -x = extract
```

**List contents:**

```bash
tar -tvf archive.tar
# -t = list
```

**Compressed archives:**

Most tar archives are also compressed. The flag indicates compression type:

**Gzip (.tar.gz or .tgz):**

```bash
# Create:
tar -czvf archive.tar.gz directory/
# -z = gzip compression

# Extract:
tar -xzvf archive.tar.gz

# Extract to specific directory:
tar -xzvf archive.tar.gz -C /target/directory/
```

**Bzip2 (.tar.bz2):**

```bash
# Create (better compression, slower):
tar -cjvf archive.tar.bz2 directory/
# -j = bzip2 compression

# Extract:
tar -xjvf archive.tar.bz2
```

**XZ (.tar.xz):**

```bash
# Create (best compression, slowest):
tar -cJvf archive.tar.xz directory/
# -J = xz compression

# Extract:
tar -xJvf archive.tar.xz
```

**Advanced options:**

**Exclude files:**

```bash
tar -czvf backup.tar.gz --exclude='*.tmp' --exclude='node_modules' ~/project/
```

**Extract specific files:**

```bash
tar -xzvf archive.tar.gz path/to/specific/file
```

**Preserve permissions:**

```bash
tar -cpzvf archive.tar.gz directory/
# -p = preserve permissions
```

**Append to existing archive:**

```bash
tar -rvf archive.tar newfile.txt
# -r = append
```

**Update archive (only newer files):**

```bash
tar -uvf archive.tar directory/
# -u = update
```

**Mnemonic for remembering flags:**

- **Create**: **C**reate **Z**ipped **F**ile → `-czf`
- **Extract**: e**X**tract **Z**ipped **F**ile → `-xzf`
- **List**: **T**able of **V**erbose **F**iles → `-tvf`

**Real-world examples:**

Backup home directory:

```bash
tar -czvf home-backup-$(date +%Y%m%d).tar.gz ~/
```

Backup with progress indicator:

```bash
tar -czvf backup.tar.gz directory/ --checkpoint=1000 --checkpoint-action=dot
```

Remote backup over SSH:

```bash
tar -czvf - directory/ | ssh user@server "cat > backup.tar.gz"
```

Extract while preserving everything:

```bash
sudo tar -xzvpf backup.tar.gz -C /
# -p = preserve permissions
# -C / = extract to root
```

### Compression Tools

#### gzip/gunzip

```bash
gzip file.txt  # Compresses to file.txt.gz (deletes original)
gunzip file.txt.gz  # Decompresses (deletes .gz)
```

**Keep original:**

```bash
gzip -k file.txt
gunzip -k file.txt.gz
```

**Compression levels:**

```bash
gzip -1 file.txt  # Fastest, least compression
gzip -9 file.txt  # Slowest, best compression
```

**View compressed file without extracting:**

```bash
zcat file.txt.gz    # View contents
zless file.txt.gz   # View with pager
zgrep pattern file.txt.gz  # Search compressed file
```

#### bzip2/bunzip2

```bash
bzip2 file.txt  # Better compression than gzip
bunzip2 file.txt.bz2
```

Similar options to gzip (`-k` to keep, `-1` to `-9` for levels).

**View compressed:**

```bash
bzcat file.txt.bz2
bzless file.txt.bz2
```

#### zip/unzip

```bash
zip archive.zip file1 file2 directory/
unzip archive.zip
```

ZIP format (compatible with Windows):

**Create archive:**

```bash
# Files:
zip archive.zip file1.txt file2.txt

# Directories (recursive):
zip -r archive.zip directory/

# With compression level:
zip -9 -r archive.zip directory/  # Maximum compression
```

**Extract archive:**

```bash
# Current directory:
unzip archive.zip

# Specific directory:
unzip archive.zip -d /target/directory/

# List contents without extracting:
unzip -l archive.zip

# Extract specific file:
unzip archive.zip path/to/file.txt
```

**Update existing archive:**

```bash
zip -u archive.zip newfile.txt
```

**Delete from archive:**

```bash
zip -d archive.zip file-to-remove.txt
```

**Password protection:**

```bash
zip -e -r secure.zip directory/  # Prompts for password
unzip secure.zip  # Prompts for password
```

---

## 11. Bash Scripting: Automating Tasks

Bash isn't just an interactive shell—it's a complete programming language for automation.

### Script Basics

**Create a script:**

```bash
#!/bin/bash
# This is a comment

echo "Hello, World!"
```

**Make it executable:**

```bash
chmod +x script.sh
```

**Run it:**

```bash
./script.sh
```

**The shebang:** `#!/bin/bash` tells the system which interpreter to use.

### Variables

**Assignment:**

```bash
name="John"
count=42
path="/home/user"
```

**⚠️ Critical:** No spaces around `=`

```bash
name="John"   # Correct
name = "John" # Wrong! This runs 'name' as a command
```

**Using variables:**

```bash
echo "Hello, $name"
echo "Count is: $count"
echo "Path: ${path}/documents"  # Curly braces when needed
```

**Command substitution:**

```bash
current_date=$(date +%Y-%m-%d)
file_count=$(ls | wc -l)
user=$(whoami)

echo "Today is $current_date"
echo "You are $user"
```

**Reading user input:**

```bash
echo "Enter your name:"
read name
echo "Hello, $name!"

# Read with prompt:
read -p "Enter your age: " age

# Silent input (passwords):
read -sp "Enter password: " password
```

**Environment variables:**

```bash
echo $HOME     # /home/username
echo $USER     # username
echo $PATH     # Executable search path
echo $PWD      # Present working directory
echo $SHELL    # Current shell
```

### Special Parameters

```bash
$0  # Script name
$1  # First argument
$2  # Second argument
$9  # Ninth argument
${10}  # Tenth argument (braces required for >9)

$@  # All arguments as separate strings
$*  # All arguments as single string
$#  # Number of arguments
$$  # Current process ID
$?  # Exit code of last command
```

**Example script:**

```bash
#!/bin/bash
echo "Script name: $0"
echo "First argument: $1"
echo "All arguments: $@"
echo "Number of arguments: $#"
```

**Usage:**

```bash
$ ./script.sh apple banana cherry
Script name: ./script.sh
First argument: apple
All arguments: apple banana cherry
Number of arguments: 3
```

### Exit Codes

Every command returns an exit code:

- `0` = Success
- Non-zero = Error

```bash
# Check last command's exit code:
ls /existing/directory
echo $?  # Output: 0

ls /nonexistent/directory
echo $?  # Output: 2 (error code)
```

**Using in scripts:**

```bash
#!/bin/bash

if cp source.txt dest.txt; then
    echo "Copy successful"
else
    echo "Copy failed"
    exit 1  # Exit script with error code
fi
```

### String Manipulation

```bash
text="Hello World"

# Length:
echo ${#text}  # 11

# Substring (position:length):
echo ${text:0:5}  # Hello
echo ${text:6}    # World

# Replace first occurrence:
echo ${text/World/Universe}  # Hello Universe

# Replace all occurrences:
fruit="apple apple apple"
echo ${fruit//apple/orange}  # orange orange orange

# Remove prefix:
path="/home/user/document.txt"
echo ${path#*/}  # home/user/document.txt (shortest match)
echo ${path##*/}  # document.txt (longest match - basename)

# Remove suffix:
file="document.txt.backup"
echo ${file%.*}  # document.txt (shortest match)
echo ${file%%.*}  # document (longest match)

# Uppercase/Lowercase:
text="Hello"
echo ${text^^}  # HELLO
echo ${text,,}  # hello
```

### Conditional Statements

```bash
if [[ condition ]]; then
    # commands
elif [[ another_condition ]]; then
    # commands
else
    # commands
fi
```

**File tests:**

```bash
if [[ -e "/path/to/file" ]]; then
    echo "File exists"
fi

if [[ -f "document.txt" ]]; then
    echo "It's a regular file"
fi

if [[ -d "/home/user" ]]; then
    echo "It's a directory"
fi

if [[ -r "file.txt" ]]; then
    echo "File is readable"
fi

if [[ -w "file.txt" ]]; then
    echo "File is writable"
fi

if [[ -x "script.sh" ]]; then
    echo "File is executable"
fi

if [[ -s "file.txt" ]]; then
    echo "File is not empty"
fi
```

**String comparisons:**

```bash
if [[ "$USER" == "akib" ]]; then
    echo "Welcome, Akib"
fi

if [[ "$name" != "admin" ]]; then
    echo "Not admin"
fi

if [[ -z "$variable" ]]; then
    echo "Variable is empty"
fi

if [[ -n "$variable" ]]; then
    echo "Variable is not empty"
fi
```

**Numeric comparisons:**

```bash
if [[ $count -eq 10 ]]; then
    echo "Count is 10"
fi

if [[ $age -gt 18 ]]; then
    echo "Adult"
fi

if [[ $num -lt 100 ]]; then
    echo "Less than 100"
fi

if [[ $value -ge 50 ]]; then
    echo "50 or more"
fi

if [[ $score -le 100 ]]; then
    echo "100 or less"
fi

if [[ $result -ne 0 ]]; then
    echo "Non-zero result"
fi
```

**Logical operators:**

```bash
# AND:
if [[ $age -gt 18 && $age -lt 65 ]]; then
    echo "Working age"
fi

# OR:
if [[ "$user" == "admin" || "$user" == "root" ]]; then
    echo "Privileged user"
fi

# NOT:
if [[ ! -f "config.txt" ]]; then
    echo "Config file missing"
fi
```

### Loops

#### For Loop

```bash
# Iterate over list:
for item in apple banana cherry; do
    echo "Fruit: $item"
done

# Iterate over files:
for file in *.txt; do
    echo "Processing $file"
    # Do something with $file
done

# Iterate over command output:
for user in $(cat users.txt); do
    echo "Creating account for $user"
done

# C-style loop:
for ((i=1; i<=10; i++)); do
    echo "Number: $i"
done

# Range:
for i in {1..10}; do
    echo $i
done

# Range with step:
for i in {0..100..10}; do
    echo $i  # 0, 10, 20, ..., 100
done
```

#### While Loop

```bash
# Basic while:
count=1
while [[ $count -le 5 ]]; do
    echo "Count: $count"
    ((count++))
done

# Read file line by line:
while read -r line; do
    echo "Line: $line"
done < input.txt

# Infinite loop:
while true; do
    echo "Running..."
    sleep 1
done

# Until loop (opposite of while):
count=1
until [[ $count -gt 5 ]]; do
    echo "Count: $count"
    ((count++))
done
```

### Functions

```bash
# Define function:
function greet() {
    echo "Hello, $1!"
}

# Or without 'function' keyword:
greet() {
    echo "Hello, $1!"
}

# Call function:
greet "World"  # Output: Hello, World!

# With return value:
add() {
    local result=$(($1 + $2))
    echo $result
}

sum=$(add 5 3)
echo "Sum: $sum"  # Sum: 8

# With explicit return code:
check_file() {
    if [[ -f "$1" ]]; then
        return 0  # Success
    else
        return 1  # Failure
    fi
}

if check_file "document.txt"; then
    echo "File exists"
fi
```

### Arrays

```bash
# Create array:
fruits=("apple" "banana" "cherry")

# Access elements:
echo ${fruits[0]}  # apple
echo ${fruits[1]}  # banana

# All elements:
echo ${fruits[@]}  # apple banana cherry

# Array length:
echo ${#fruits[@]}  # 3

# Add element:
fruits+=("date")

# Loop through array:
for fruit in "${fruits[@]}"; do
    echo $fruit
done

# Associative arrays (like dictionaries):
declare -A person
person[name]="John"
person[age]=30
person[city]="New York"

echo ${person[name]}  # John

# Loop through keys:
for key in "${!person[@]}"; do
    echo "$key: ${person[$key]}"
done
```

### Practical Script Examples

**Backup script:**

```bash
#!/bin/bash

# Configuration
SOURCE="/home/user/documents"
DEST="/backup"
DATE=$(date +%Y%m%d_%H%M%S)
ARCHIVE="backup_$DATE.tar.gz"

# Create backup
echo "Starting backup..."
tar -czf "$DEST/$ARCHIVE" "$SOURCE"

if [[ $? -eq 0 ]]; then
    echo "Backup successful: $ARCHIVE"
else
    echo "Backup failed!"
    exit 1
fi

# Delete backups older than 30 days
find "$DEST" -name "backup_*.tar.gz" -mtime +30 -delete
echo "Cleanup complete"
```

**Log analyzer:**

```bash
#!/bin/bash

LOG_FILE="/var/log/apache2/access.log"

echo "=== Top 10 IP Addresses ==="
awk '{print $1}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -10

echo ""
echo "=== Top 10 Requested Pages ==="
awk '{print $7}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -10

echo ""
echo "=== HTTP Status Codes ==="
awk '{print $9}' "$LOG_FILE" | sort | uniq -c | sort -nr
```

**System monitoring:**

```bash
#!/bin/bash

# Check if disk usage exceeds 80%
USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')

if [[ $USAGE -gt 80 ]]; then
    echo "WARNING: Disk usage is ${USAGE}%"
    # Send email, SMS, etc.
fi

# Check if service is running
if ! systemctl is-active --quiet nginx; then
    echo "ERROR: Nginx is not running"
    sudo systemctl start nginx
fi
```

---

## 12. Input/Output Redirection

Control where commands read input and send output.

### Output Redirection

**Redirect stdout:**

```bash
ls -la > file_list.txt        # Overwrite
ls -la >> file_list.txt       # Append
```

**Redirect stderr:**

```bash
command 2> errors.log         # Only errors
command 2>> errors.log        # Append errors
```

**Redirect both stdout and stderr:**

```bash
command &> output.log         # Both to same file
command > output.log 2>&1     # Traditional syntax
command 2>&1 | tee output.log # Both to file and screen
```

**Discard output:**

```bash
command > /dev/null           # Discard stdout
command 2> /dev/null          # Discard stderr
command &> /dev/null          # Discard both
```

**Understanding file descriptors:**

- `0` = stdin (standard input)
- `1` = stdout (standard output)
- `2` = stderr (standard error)

**Swap stdout and stderr:**

```bash
command 3>&1 1>&2 2>&3
```

### Input Redirection

```bash
# Feed file as input:
sort < unsorted.txt

# Here document (multi-line input):
cat << EOF > output.txt
Line 1
Line 2
Line 3
EOF

# Here string:
grep "pattern" <<< "text to search"
```

### Practical Examples

**Separate output and errors:**

```bash
./script.sh > output.log 2> errors.log
```

**Log everything:**

```bash
./script.sh &> full.log
```

**Show and log:**

```bash
./script.sh 2>&1 | tee output.log
```

**Silent execution:**

```bash
cron_job.sh &> /dev/null
```

---

## 13. Advanced Techniques and Power User Features

### SSH Key-Based Authentication

Eliminate passwords and enhance security:

**1. Generate key pair (on local machine):**

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

Or RSA for older systems:

```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

Press Enter to accept defaults. Optionally set a passphrase.

**2. Copy public key to server:**

```bash
ssh-copy-id user@server.com
```

Or manually:

```bash
cat ~/.ssh/id_ed25519.pub | ssh user@server "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```

**3. Test:**

```bash
ssh user@server.com  # No password required!
```

**Security hardening:**

Edit `/etc/ssh/sshd_config` on server:

```bash
PasswordAuthentication no
PermitRootLogin no
PubkeyAuthentication yes
```

Restart SSH:

```bash
sudo systemctl restart sshd
```

### Terminal Multiplexers: tmux and screen

Run persistent sessions that survive disconnections.

#### tmux Basics

**Start session:**

```bash
tmux
tmux new -s session_name
```

**Detach from session:**
Press `Ctrl+B`, then `D`

**List sessions:**

```bash
tmux ls
```

**Attach to session:**

```bash
tmux attach
tmux attach -t session_name
```

**Essential tmux commands** (prefix with `Ctrl+B`):

- `C`: Create new window
- `N`: Next window
- `P`: Previous window
- `0-9`: Switch to window by number
- `%`: Split pane vertically
- `"`: Split pane horizontally
- Arrow keys: Navigate between panes
- `D`: Detach from session
- `X`: Kill current pane
- `&`: Kill current window
- `?`: Show all keybindings

**Workflow example:**

```bash
# SSH into server:
ssh user@server.com

# Start tmux:
tmux new -s deployment

# Run long process:
./deploy_application.sh

# Detach: Ctrl+B, then D
# Log out: exit

# Later, reconnect:
ssh user@server.com
tmux attach -t deployment
# Your process is still running!
```

#### screen Basics

**Start session:**

```bash
screen
screen -S session_name
```

**Detach from session:**
Press `Ctrl+A`, then `D`

**List sessions:**

```bash
screen -ls
```

**Attach to session:**

```bash
screen -r
screen -r session_name
```

**Essential screen commands** (prefix with `Ctrl+A`):

- `C`: Create new window
- `N`: Next window
- `P`: Previous window
- `0-9`: Switch to window by number
- `S`: Split horizontally
- `|`: Split vertically (requires configuration)
- `Tab`: Switch between splits
- `D`: Detach
- `K`: Kill current window
- `?`: Help

**Why use multiplexers:**

- Run long processes on remote servers without keeping SSH connected
- Organize multiple terminal windows in one interface
- Share sessions with other users (pair programming)
- Recover from network interruptions

### Advanced Find Techniques

**Find and execute complex operations:**

```bash
# Find files older than 30 days and compress them:
find /var/log -name "*.log" -mtime +30 -exec gzip {} \;

# Find large files and show them sorted:
find / -type f -size +100M -exec ls -lh {} \; | sort -k5 -h

# Find and move files:
find . -name "*.tmp" -exec mv {} /tmp/ \;

# Find with multiple conditions:
find . -type f \( -name "*.log" -o -name "*.txt" \) -size +1M

# Find and confirm before deleting:
find . -name "*.bak" -ok rm {} \;

# Find files modified today:
find . -type f -mtime 0

# Find files by permissions:
find . -type f -perm 777  # Exactly 777
find . -type f -perm -644  # At least 644

# Find empty files and directories:
find . -empty

# Find by owner:
find /home -user john

# Find and change permissions:
find . -type f -name "*.sh" -exec chmod +x {} \;
```

**Advanced xargs patterns:**

```bash
# Process in batches:
find . -name "*.jpg" -print0 | xargs -0 -n 10 -P 4 process_images.sh

# Build complex commands:
find . -name "*.log" | xargs -I {} sh -c 'echo "Processing {}"; gzip {}'

# Handle special characters safely:
find . -name "* *" -print0 | xargs -0 rename

# Parallel processing:
find . -name "*.txt" -print0 | xargs -0 -P 8 -I {} sh -c 'wc -l {} | tee -a count.log'
```

### Process Management Deep Dive

**Advanced process inspection:**

```bash
# Show process tree:
pstree -p  # With PIDs
pstree -u  # With usernames

# Find process by name:
pgrep -f "python app.py"

# Kill by name (careful!):
pkill -f "python app.py"

# Show threads:
ps -T -p PID

# Real-time process monitoring with filtering:
watch -n 1 'ps aux | grep python'

# CPU-consuming processes:
ps aux --sort=-%cpu | head -10

# Memory-consuming processes:
ps aux --sort=-%mem | head -10

# Process with specific state:
ps aux | awk '$8 ~ /^Z/ {print}'  # Zombie processes
```

**Nice and renice (process priority):**

```bash
# Start with lower priority:
nice -n 10 ./cpu_intensive_task.sh

# Change priority of running process:
renice -n 5 -p PID

# Priority levels: -20 (highest) to 19 (lowest)
# Default: 0
```

**Process signals:**

```bash
kill -l  # List all signals

# Common signals:
kill -TERM PID  # Graceful termination (default)
kill -KILL PID  # Force kill (same as kill -9)
kill -HUP PID   # Hangup (reload config)
kill -STOP PID  # Pause
kill -CONT PID  # Resume
kill -USR1 PID  # User-defined signal 1
kill -USR2 PID  # User-defined signal 2
```

### Advanced Text Processing Patterns

**Complex awk programs:**

```bash
# Print lines with specific field value:
awk '$3 > 100 && $5 == "active"' data.txt

# Calculate and format:
awk '{sum += $2} END {printf "Total: $%.2f\n", sum}' prices.txt

# Field manipulation:
awk '{print $2, $1}' file.txt | column -t  # Swap and align

# Multiple patterns:
awk '/ERROR/ {errors++} /WARNING/ {warnings++} END {print "Errors:", errors, "Warnings:", warnings}' log.txt

# Process CSV with headers:
awk -F',' 'NR==1 {for(i=1;i<=NF;i++) header[i]=$i} NR>1 {print header[1]": "$1, header[2]": "$2}' data.csv
```

**Sed scripting:**

```bash
# Multiple substitutions:
sed -e 's/old1/new1/g' -e 's/old2/new2/g' file.txt

# Conditional replacement:
sed '/pattern/s/old/new/g' file.txt

# Delete range of lines:
sed '10,20d' file.txt

# Insert line before pattern:
sed '/pattern/i\New line here' file.txt

# Append line after pattern:
sed '/pattern/a\New line here' file.txt

# Change entire line:
sed '/pattern/c\Replacement line' file.txt

# Multiple commands from file:
sed -f commands.sed input.txt
```

**Combining tools for complex parsing:**

```bash
# Extract URLs from HTML:
grep -oP 'href="\K[^"]+' page.html | sort -u

# Parse JSON (with jq):
curl -s https://api.example.com/data | jq '.items[] | select(.status=="active") | .name'

# Parse log timestamps:
awk '{print $4}' access.log | cut -d: -f1 | sort | uniq -c

# Extract email addresses:
grep -oE '\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b' file.txt
```

### Command History Tricks

**Search history:**

```bash
history | grep command  # Search history
Ctrl+R                  # Reverse search (interactive)
!!                      # Repeat last command
!n                      # Run command number n
!-n                     # Run nth command from end
!string                 # Run most recent command starting with string
!?string                # Run most recent command containing string
^old^new                # Replace text in last command
```

**History expansion:**

```bash
# Reuse arguments:
!$      # Last argument of previous command
!*      # All arguments of previous command
!^      # First argument of previous command

# Example:
ls /var/log/nginx/
cd !$   # Changes to /var/log/nginx/
```

**Configure history:**

```bash
# Add to ~/.bashrc:
export HISTSIZE=10000          # Commands in memory
export HISTFILESIZE=20000      # Commands in file
export HISTTIMEFORMAT="%F %T " # Add timestamps
export HISTCONTROL=ignoredups  # Ignore duplicates
export HISTIGNORE="ls:cd:pwd"  # Ignore specific commands

# Share history across terminals:
shopt -s histappend
PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
```

### Bash Aliases and Functions

**Create aliases** (add to `~/.bashrc`):

```bash
# Navigation shortcuts:
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Safety nets:
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Common commands:
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'

# Git shortcuts:
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'

# System info:
alias ports='netstat -tulanp'
alias meminfo='free -m -l -t'
alias psg='ps aux | grep -v grep | grep -i -e VSZ -e'

# Safety:
alias mkdir='mkdir -pv'

# Reload bash config:
alias reload='source ~/.bashrc'
```

**Create functions** (more powerful than aliases):

```bash
# Extract any archive:
extract() {
    if [ -f $1 ]; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar x $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)           echo "'$1' cannot be extracted" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Create and enter directory:
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Quick backup:
backup() {
    cp "$1" "$1.backup-$(date +%Y%m%d-%H%M%S)"
}

# Find and replace in files:
replace() {
    grep -rl "$1" . | xargs sed -i "s/$1/$2/g"
}

# Show PATH one per line:
path() {
    echo "$PATH" | tr ':' '\n'
}
```

### Performance Optimization

**Benchmark commands:**

```bash
# Time command execution:
time command

# More detailed:
/usr/bin/time -v command

# Benchmark alternatives:
hyperfine "command1" "command2"  # Install separately
```

**Monitor system performance:**

```bash
# I/O statistics:
iostat -x 1

# Disk activity:
iotop

# Network bandwidth:
iftop
nload

# System calls:
strace -c command

# Open files by process:
lsof -p PID

# System load:
uptime
w
```

**Disk performance:**

```bash
# Test write speed:
dd if=/dev/zero of=testfile bs=1M count=1000

# Test read speed:
dd if=testfile of=/dev/null bs=1M

# Clear cache before testing:
sudo sh -c "sync; echo 3 > /proc/sys/vm/drop_caches"

# Measure disk I/O:
sudo hdparm -Tt /dev/sda
```

### Security Best Practices

**File security:**

```bash
# Find files with dangerous permissions:
find / -type f -perm -002 2>/dev/null  # World-writable files
find / -type f -perm -4000 2>/dev/null  # SUID files

# Secure SSH directory:
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
chmod 644 ~/.ssh/authorized_keys
chmod 644 ~/.ssh/known_hosts

# Remove world permissions:
chmod o-rwx file

# Set restrictive umask:
umask 077  # New files: 600, directories: 700
```

**Monitor security:**

```bash
# Check for failed login attempts:
sudo grep "Failed password" /var/log/auth.log

# Show recent logins:
last

# Show currently logged-in users:
w
who

# Check for listening ports:
sudo netstat -tulpn
sudo ss -tulpn

# Review sudo usage:
sudo grep sudo /var/log/auth.log
```

**Secure file deletion:**

```bash
# Overwrite before deletion:
shred -vfz -n 3 sensitive_file.txt

# Wipe free space (use carefully):
# sfill -l /path/to/mount
```

### Systemd Service Management

**Control services:**

```bash
# Start/stop/restart:
sudo systemctl start nginx
sudo systemctl stop nginx
sudo systemctl restart nginx
sudo systemctl reload nginx  # Reload config without restart

# Enable/disable (start on boot):
sudo systemctl enable nginx
sudo systemctl disable nginx

# Check status:
sudo systemctl status nginx
sudo systemctl is-active nginx
sudo systemctl is-enabled nginx

# List all services:
systemctl list-units --type=service
systemctl list-units --type=service --state=running

# View logs:
sudo journalctl -u nginx
sudo journalctl -u nginx -f  # Follow
sudo journalctl -u nginx --since "1 hour ago"
sudo journalctl -u nginx --since "2024-10-01" --until "2024-10-24"

# Failed services:
systemctl --failed
```

**Create custom service:**

```bash
# Create /etc/systemd/system/myapp.service:
[Unit]
Description=My Application
After=network.target

[Service]
Type=simple
User=myuser
WorkingDirectory=/opt/myapp
ExecStart=/opt/myapp/run.sh
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target

# Enable and start:
sudo systemctl daemon-reload
sudo systemctl enable myapp
sudo systemctl start myapp
```

### Cron Job Automation

**Edit crontab:**

```bash
crontab -e      # Edit your crontab
crontab -l      # List your crontab
crontab -r      # Remove your crontab
sudo crontab -u username -e  # Edit another user's crontab
```

**Crontab syntax:**

```
# ┌───────────── minute (0-59)
# │ ┌───────────── hour (0-23)
# │ │ ┌───────────── day of month (1-31)
# │ │ │ ┌───────────── month (1-12)
# │ │ │ │ ┌───────────── day of week (0-6, Sunday=0)
# │ │ │ │ │
# │ │ │ │ │
# * * * * * command to execute
```

**Common patterns:**

```bash
# Every minute:
* * * * * /path/to/script.sh

# Every 5 minutes:
*/5 * * * * /path/to/script.sh

# Every hour:
0 * * * * /path/to/script.sh

# Daily at 2:30 AM:
30 2 * * * /path/to/script.sh

# Every Sunday at midnight:
0 0 * * 0 /path/to/script.sh

# First day of month:
0 0 1 * * /path/to/script.sh

# Weekdays at 6 AM:
0 6 * * 1-5 /path/to/script.sh

# Multiple times:
0 6,12,18 * * * /path/to/script.sh

# At system reboot:
@reboot /path/to/script.sh

# Special shortcuts:
@yearly     # 0 0 1 1 *
@monthly    # 0 0 1 * *
@weekly     # 0 0 * * 0
@daily      # 0 0 * * *
@hourly     # 0 * * * *
```

**Best practices for cron:**

```bash
# Use absolute paths:
0 2 * * * /usr/bin/python3 /home/user/backup.py

# Redirect output:
0 2 * * * /path/to/script.sh > /var/log/script.log 2>&1

# Set environment variables:
PATH=/usr/local/bin:/usr/bin:/bin
SHELL=/bin/bash

0 2 * * * /path/to/script.sh

# Email results (if mail configured):
MAILTO=admin@example.com
0 2 * * * /path/to/script.sh
```

### Regular Expressions Power

**Grep with regex:**

```bash
# Basic patterns:
grep '^Start' file.txt       # Lines starting with "Start"
grep 'end$' file.txt         # Lines ending with "end"
grep '^$' file.txt           # Empty lines
grep '[0-9]' file.txt        # Lines with digits
grep '[A-Z]' file.txt        # Lines with uppercase
grep '[aeiou]' file.txt      # Lines with vowels

# Extended regex (-E):
grep -E 'cat|dog' file.txt   # cat OR dog
grep -E 'colou?r' file.txt   # color or colour
grep -E '[0-9]+' file.txt    # One or more digits
grep -E '[0-9]{3}' file.txt  # Exactly 3 digits
grep -E '[0-9]{2,4}' file.txt # 2 to 4 digits

# Perl regex (-P):
grep -P '\d+' file.txt       # Digits (\d)
grep -P '\w+' file.txt       # Word characters (\w)
grep -P '\s+' file.txt       # Whitespace (\s)
grep -P '(?=.*\d)(?=.*[a-z])' # Lookahead assertions

# Email addresses:
grep -E '\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b' file.txt

# IP addresses:
grep -E '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' file.txt

# URLs:
grep -E 'https?://[^\s]+' file.txt
```

### Command Line Efficiency Tips

**Keyboard shortcuts:**

```bash
Ctrl+A      # Move to beginning of line
Ctrl+E      # Move to end of line
Ctrl+U      # Delete from cursor to beginning
Ctrl+K      # Delete from cursor to end
Ctrl+W      # Delete word before cursor
Alt+D       # Delete word after cursor
Ctrl+L      # Clear screen (like 'clear')
Ctrl+R      # Reverse search history
Ctrl+G      # Escape from reverse search
Ctrl+C      # Cancel current command
Ctrl+Z      # Suspend current command
Ctrl+D      # Exit shell (or send EOF)
!!          # Repeat last command
sudo !!     # Repeat last command with sudo
```

**Quick edits:**

```bash
# Fix typo in previous command:
^typo^correction

# Example:
$ grpe error log.txt
^grpe^grep
# Runs: grep error log.txt
```

**Brace expansion:**

```bash
# Create multiple files:
touch file{1..10}.txt
# Creates: file1.txt, file2.txt, ..., file10.txt

# Create directory structure:
mkdir -p project/{src,bin,lib,doc}

# Copy with backup:
cp file.txt{,.bak}
# Same as: cp file.txt file.txt.bak

# Multiple extensions:
rm file.{txt,log,bak}
```

**Command substitution:**

```bash
# Use command output in another command:
echo "Today is $(date)"
mv file.txt file.$(date +%Y%m%d).txt

# Nested:
echo "Files: $(ls $(pwd))"
```

---

## 14. Troubleshooting and Debugging

### Common Problems and Solutions

**"Command not found":**

```bash
# Check if command exists:
which command_name
type command_name

# Check PATH:
echo $PATH

# Find where command is:
find / -name command_name 2>/dev/null

# Add to PATH temporarily:
export PATH=$PATH:/new/directory

# Add to PATH permanently (add to ~/.bashrc):
export PATH=$PATH:/new/directory
```

**"Permission denied":**

```bash
# Check permissions:
ls -l file

# Make executable:
chmod +x script.sh

# Check ownership:
ls -l file

# Change ownership:
sudo chown user:group file

# Run with sudo:
sudo command
```

**"No space left on device":**

```bash
# Check disk space:
df -h

# Find large directories:
du -sh /* | sort -h

# Find large files:
find / -type f -size +100M -exec ls -lh {} \;

# Clear package cache (Ubuntu/Debian):
sudo apt clean

# Clear systemd journal:
sudo journalctl --vacuum-time=7d
```

**"Too many open files":**

```bash
# Check current limit:
ulimit -n

# Increase limit (temporary):
ulimit -n 4096

# Check what's using files:
lsof | wc -l
lsof -u username

# Permanent fix (edit /etc/security/limits.conf):
* soft nofile 4096
* hard nofile 8192
```

**Process won't die:**

```bash
# Try graceful kill:
kill PID

# Wait a bit, then force:
kill -9 PID

# If still alive, check:
ps aux | grep PID

# May be zombie (can't be killed, wait for parent):
ps aux | awk '$8 ~ /^Z/'
```

### Debugging Scripts

**Enable debugging:**

```bash
#!/bin/bash -x  # Print each command before executing

# Or:
set -x  # Turn on debugging
# ... commands ...
set +x  # Turn off debugging

# Strict mode (recommended):
set -euo pipefail
# -e: Exit on error
# -u: Exit on undefined variable
# -o pipefail: Pipeline fails if any command fails
```

**Debug output:**

```bash
# Add debug messages:
echo "DEBUG: variable value is $var" >&2

# Function for debug messages:
debug() {
    if [[ "${DEBUG:-0}" == "1" ]]; then
        echo "DEBUG: $*" >&2
    fi
}

# Usage:
DEBUG=1 ./script.sh
```

**Check syntax without running:**

```bash
bash -n script.sh  # Check for syntax errors
```

---

## Conclusion

You now have a comprehensive guide to the Linux command line and Bash scripting, covering everything from basic navigation to advanced automation. The key to mastery is practice:

1. **Start simple**: Use basic commands daily until they become second nature
2. **Build gradually**: Add more complex techniques as you encounter real problems
3. **Automate repetitively**: Turn repetitive tasks into scripts
4. **Read documentation**: Use `man` pages and `--help` extensively
5. **Experiment safely**: Use test environments or directories for practice

Remember: the command line is a skill that compounds over time. Every technique you learn builds upon the last, and soon you'll find yourself crafting elegant one-liners that would have seemed impossible when you started.

**Continue learning:**

- Explore your system's man pages
- Read other users' scripts on GitHub
- Join Linux communities and forums
- Challenge yourself with command-line puzzles
- Build your own tools and utilities

The command line isn't just a tool—it's a superpower that makes you more productive, efficient, and capable. Master it, and you'll wonder how you ever worked without it.
