#!/bin/bash
# Enhanced file finder script with fzf integration
# Save to /usr/local/bin/f and make executable with: chmod +x /usr/local/bin/f

# Process arguments
depth=""
num_regex='^[0-9]+$'
extensions=()
copy_to_clipboard=true
max_depth=""
show_tree=true
show_content=true
max_files=100
use_fzf=false

# Terminal colors (for display only, not included in clipboard)
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Check for fzf
if command -v fzf >/dev/null 2>&1; then
  fzf_available=true
else
  fzf_available=false
fi

# Check if pbcopy/xclip are available
if command -v pbcopy >/dev/null 2>&1; then
  copy_cmd="pbcopy"
elif command -v xclip >/dev/null 2>&1; then
  copy_cmd="xclip -selection clipboard"
else
  copy_to_clipboard=false
fi

# Process arguments
for arg in "$@"; do
  if [[ $arg =~ $num_regex ]]; then
    # If argument is a number, set max depth
    max_depth="$arg"
    depth="-maxdepth $arg"
  elif [[ $arg == "--no-copy" || $arg == "-n" ]]; then
    # Flag to disable clipboard copy
    copy_to_clipboard=false
  elif [[ $arg == "--no-tree" || $arg == "-nt" ]]; then
    # Flag to disable tree view
    show_tree=false
  elif [[ $arg == "--no-content" || $arg == "-nc" ]]; then
    # Flag to disable content preview
    show_content=false
  elif [[ $arg == "--fzf" || $arg == "-f" ]]; then
    # Flag to use fzf for interactive selection
    if [ "$fzf_available" = true ]; then
      use_fzf=true
    else
      echo -e "${RED}fzf is not installed. Please install it with 'brew install fzf' or 'apt-get install fzf'.${NC}"
      exit 1
    fi
  else
    # Otherwise, it's a file extension pattern
    case "$arg" in
      "ts")
        extensions+=("*.ts*")
        ;;
      "js")
        extensions+=("*.js*")
        ;;
      "go")
        extensions+=("*.go" "*.mod")
        ;;
      "py")
        extensions+=("*.py")
        ;;
      "md")
        extensions+=("*.md")
        ;;
      "sh")
        extensions+=("*.sh" "*.bash" "*.zsh")
        ;;
      "c")
        extensions+=("*.c" "*.h")
        ;;
      "cpp")
        extensions+=("*.cpp" "*.hpp" "*.cc" "*.hh")
        ;;
      "java")
        extensions+=("*.java")
        ;;
      "rust"|"rs")
        extensions+=("*.rs")
        ;;
      "html")
        extensions+=("*.html" "*.htm")
        ;;
      "css")
        extensions+=("*.css" "*.scss" "*.sass" "*.less")
        ;;
      "json")
        extensions+=("*.json")
        ;;
      "yaml"|"yml")
        extensions+=("*.yaml" "*.yml")
        ;;
      "xml")
        extensions+=("*.xml")
        ;;
      "rb")
        extensions+=("*.rb")
        ;;
      "php")
        extensions+=("*.php")
        ;;
      "sql")
        extensions+=("*.sql")
        ;;
      *)
        # Custom extension
        extensions+=("*.$arg")
        ;;
    esac
  fi
done

# Get current directory name
DIR_NAME=$(basename "$(pwd)")

# Build find command and description
if [ ${#extensions[@]} -eq 0 ]; then
  # No extensions specified, find all files
  find_cmd="find . $depth -type f -not -path \"*/\\.*\" -not -path \"*/node_modules/*\""
  file_desc="all files"
else
  # Find files with specified extensions
  find_cmd="find . $depth -type f \\( "
  file_desc=""
  first=true
  
  for ext in "${extensions[@]}"; do
    if [ "$first" = true ]; then
      find_cmd="$find_cmd -name \"$ext\""
      file_desc="$ext"
      first=false
    else
      find_cmd="$find_cmd -o -name \"$ext\""
      file_desc="$file_desc, $ext"
    fi
  done
  
  find_cmd="$find_cmd \\) -not -path \"*/\\.*\" -not -path \"*/node_modules/*\""
fi

# Execute find command and store results
files=$(eval "$find_cmd")
file_list=($(echo "$files" | sort))
file_count=${#file_list[@]}

# Interactive mode with fzf if requested
if [ "$use_fzf" = true ] && [ $file_count -gt 0 ]; then
  # Using fzf to select files interactively
  selected_files=$(echo "$files" | fzf -m --preview 'cat {}')
  if [ -n "$selected_files" ]; then
    file_list=($(echo "$selected_files" | sort))
    file_count=${#file_list[@]}
  else
    echo "No files selected. Exiting."
    exit 0
  fi
fi

# Prepare directory tree
tree_output=""
if [ "$show_tree" = true ] && command -v tree >/dev/null 2>&1; then
  # Determine tree depth parameter
  tree_depth=""
  if [ -n "$max_depth" ]; then
    tree_depth="-L $max_depth"
  else
    tree_depth="-L 3"  # Default to showing 3 levels
  fi
  
  tree_output=$(tree -a $tree_depth -I "node_modules|.git" | strip_ansi)
fi

# Function to strip ANSI escape codes
strip_ansi() {
  sed 's/\x1b\[[0-9;]*[mGKH]//g'
}

# Initialize output - keep clipboard and terminal output completely separate
clipboard_output=""
terminal_output=""

# Add header
header="=== File Analysis for \"$DIR_NAME\" directory ===
Found $file_count $file_desc"
if [ -n "$max_depth" ]; then
  header+=" (max depth: $max_depth)"
else
  header+=" (all subdirectories)"
fi

# Plain text for clipboard
clipboard_output+="$header"$'\n\n'

# Colored text for terminal
terminal_output+="${CYAN}${BOLD}$header${NC}"$'\n\n'

# Add directory structure at the top
if [ -n "$tree_output" ]; then
  clipboard_output+="Directory Structure:"$'\n'"$tree_output"$'\n\n'
  terminal_output+="${YELLOW}${BOLD}Directory Structure:${NC}"$'\n'"$tree_output"$'\n\n'
fi

# Add file contents
if [ "$show_content" = true ] && [ $file_count -le $max_files ]; then
  clipboard_output+="Detailed File Analysis:"$'\n'"\"\"\""$'\n\n'
  terminal_output+="${YELLOW}${BOLD}Detailed File Analysis:${NC}"$'\n'"${BLUE}\"\"\"${NC}"$'\n\n'
  
  # Count total line count for repeating directory structure
  total_lines=0
  tree_line_count=0
  if [ -n "$tree_output" ]; then
    tree_line_count=$(echo -e "$tree_output" | wc -l)
    tree_line_count=$((tree_line_count + 2)) # Add header lines
  fi
  
  for file in "${file_list[@]}"; do
    file_path=$(dirname "$(realpath "$file")")
    file_name=$(basename "$file")
    
    # Calculate file content line count
    file_line_count=0
    if [ -f "$file" ]; then
      file_line_count=$(wc -l < "$file")
      file_line_count=$((file_line_count + 4)) # Add header and newline
    fi
    
    # If reaching 1000 lines, add directory structure again for reference
    if [ $total_lines -gt 0 ] && [ $((total_lines % 1000)) -lt $file_line_count ] && [ -n "$tree_output" ]; then
      clipboard_output+=$'\n'"=== Directory Structure (for reference) ==="$'\n'"$tree_output"$'\n\n'
      terminal_output+=$'\n'"${YELLOW}${BOLD}=== Directory Structure (for reference) ===${NC}"$'\n'"$tree_output"$'\n\n'
    fi
    
    # Prepare file content
    file_header="=== Path: $file_path"$'\n'"=== File: $file_name"$'\n\n'
    
    if [ -f "$file" ]; then
      # Add file content if file exists and is readable
      if [ -r "$file" ]; then
        file_content=$(cat "$file")
      else
        file_content="[File not readable]"
      fi
    else
      file_content="[Not a file]"
    fi
    
    # Add to clipboard output (plain text)
    clipboard_output+="$file_header$file_content"$'\n\n'
    
    # Add to terminal output (with colors)
    terminal_output+="${CYAN}$file_header$file_content${NC}"$'\n\n'
    
    total_lines=$((total_lines + file_line_count))
  done
  
  clipboard_output+="\"\"\""$'\n\n'
  terminal_output+="${BLUE}\"\"\"${NC}"$'\n\n'
fi

# Add summary
summary="=== Analysis Summary ==="$'\n'"Directory: $DIR_NAME"$'\n'"Total Files Found: $file_count"

clipboard_output+="$summary"$'\n'
terminal_output+="${PURPLE}${BOLD}$summary${NC}"$'\n'

# Add directory structure at the bottom for reference
if [ -n "$tree_output" ]; then
  clipboard_output+=$'\n'"Directory Structure (Final Reference):"$'\n'"$tree_output"$'\n'
  terminal_output+=$'\n'"${YELLOW}${BOLD}Directory Structure (Final Reference):${NC}"$'\n'"$tree_output"$'\n'
fi

# Print the output with colors in terminal
echo -e "$terminal_output"

# Copy to clipboard if enabled (without color codes)
if [ "$copy_to_clipboard" = true ]; then
  # Strip any remaining ANSI codes from clipboard output
  clean_output=$(printf "%s" "$clipboard_output" | strip_ansi)
  
  if [ "$copy_cmd" = "pbcopy" ]; then
    printf "%s" "$clean_output" | pbcopy
    echo -e "${GREEN}Results copied to clipboard with pbcopy.${NC}"
  elif [ "$copy_cmd" = "xclip -selection clipboard" ]; then
    printf "%s" "$clean_output" | xclip -selection clipboard
    echo -e "${GREEN}Results copied to clipboard with xclip.${NC}"
  else
    echo -e "${RED}Warning: pbcopy/xclip not found - couldn't copy to clipboard${NC}"
  fi
fi