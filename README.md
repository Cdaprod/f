# f - Enhanced File Finder Script

A powerful command-line tool for quickly finding, analyzing, and organizing file contents in any directory. Perfect for developers who need to rapidly understand project structure and file contents.

Pipe this **f** command with `pbcopy` or `xclip` for the ultimate workflow on terminal friendly mobile devices such as **Shellfish iOS**

## Features

- 🔍 **Smart file discovery** with extension-based filtering
- 📋 **Automatic clipboard copying** of results
- 🌳 **Directory tree visualization** using `tree` command
- 🎯 **Interactive file selection** with `fzf` integration
- 📝 **Complete file content analysis** with proper formatting
- 🎨 **Colorized terminal output** for better readability
- ⚡ **Depth control** for large directory structures
- 🔧 **Flexible configuration** with command-line flags

## Installation

### Quick Install

```bash
# Download and install
curl -o /usr/local/bin/f https://raw.githubusercontent.com/Cdaprod/f/main/f
chmod +x /usr/local/bin/f
```

### Manual Install

1. Download the script
1. Copy to `/usr/local/bin/f`
1. Make executable: `chmod +x /usr/local/bin/f`

### Prerequisites

- `bash` (standard on most Unix systems)
- `find` command
- `tree` (optional, for directory visualization)
- `fzf` (optional, for interactive file selection)
- `pbcopy` (macOS) or `xclip` (Linux) for clipboard functionality

## Usage

### Basic Usage

```bash
# Analyze all files in current directory
f

# Find JavaScript files only
f js

# Find TypeScript files with max depth of 2
f ts 2

# Find Python files without copying to clipboard
f py --no-copy
```

### Shorthand Depth with Repeated `f`

Link the script under multiple `f` names to set a default search depth. The
number of `f` characters in the command determines how many directory levels to
scan:

```bash
# One level deep (equivalent to `f 1`)
f

# Two levels deep
ff

# Three levels deep
fff
```

Create symlinks for the variants you need:

```bash
ln -s /usr/local/bin/f /usr/local/bin/ff
ln -s /usr/local/bin/f /usr/local/bin/fff
```

### File Type Shortcuts

The script includes built-in shortcuts for common file types:

|Shortcut    |File Extensions                      |
|------------|-------------------------------------|
|`js`        |`*.js*`                              |
|`ts`        |`*.ts*`                              |
|`py`        |`*.py`                               |
|`go`        |`*.go`, `*.mod`                      |
|`md`        |`*.md`                               |
|`sh`        |`*.sh`, `*.bash`, `*.zsh`            |
|`c`         |`*.c`, `*.h`                         |
|`cpp`       |`*.cpp`, `*.hpp`, `*.cc`, `*.hh`     |
|`java`      |`*.java`                             |
|`rust`/`rs` |`*.rs`                               |
|`html`      |`*.html`, `*.htm`                    |
|`css`       |`*.css`, `*.scss`, `*.sass`, `*.less`|
|`json`      |`*.json`                             |
|`yaml`/`yml`|`*.yaml`, `*.yml`                    |
|`xml`       |`*.xml`                              |
|`rb`        |`*.rb`                               |
|`php`       |`*.php`                              |
|`sql`       |`*.sql`                              |

### Command Line Options

|Option        |Alias|Description                           |
|--------------|-----|--------------------------------------|
|`--no-copy`   |`-n` |Disable clipboard copying             |
|`--no-tree`   |`-nt`|Disable directory tree view           |
|`--no-content`|`-nc`|Disable file content preview          |
|`--fzf`       |`-f` |Use fzf for interactive file selection|
|`[number]`    |     |Set maximum directory depth           |

### Examples

```bash
# Basic file analysis
f

# Find all JavaScript files in current directory and subdirectories
f js

# Find Python files with maximum depth of 3 levels
f py 3

# Find TypeScript files without tree view
f ts --no-tree

# Interactive file selection with fzf
f --fzf

# Find custom extension files
f tsx

# Multiple options
f js 2 --no-copy --fzf
```

## Output Format

The script generates a comprehensive analysis including:

1. **Header** - Directory name and file count summary
1. **Directory Structure** - Tree view of the directory (if `tree` is available)
1. **File Contents** - Complete contents of each file with clear separators
1. **Summary** - Final statistics

### Sample Output

```
=== File Analysis for "my-project" directory ===
Found 15 *.js* files (max depth: 2)

Directory Structure:
.
├── src/
│   ├── components/
│   │   ├── Button.js
│   │   └── Modal.js
│   └── utils/
│       └── helpers.js
└── package.json

Detailed File Analysis:
"""

=== Path: ./src/components
=== File: Button.js

import React from 'react';

const Button = ({ children, onClick }) => {
  return (
    <button onClick={onClick}>
      {children}
    </button>
  );
};

export default Button;

=== Path: ./src/components
=== File: Modal.js

// Modal component code...

"""

=== Analysis Summary ===
Directory: my-project
Total Files Found: 15
```

## Advanced Features

### Interactive Mode with fzf

When using the `--fzf` flag, you can:

- Select specific files interactively
- Use fuzzy search to find files
- Multi-select files with `Tab`
- Preview file contents before selection

### Large Directory Handling

- Files are limited to 100 by default for performance
- Directory structure is repeated every 1000 lines for reference
- Automatic exclusion of `.git` and `node_modules` directories

### Clipboard Integration

- Automatically copies results to clipboard (macOS: `pbcopy`, Linux: `xclip`)
- Clean output without ANSI color codes
- Disable with `--no-copy` flag

## Configuration

The script automatically detects available tools:

- `tree` for directory visualization
- `fzf` for interactive selection
- `pbcopy`/`xclip` for clipboard functionality

Missing tools are gracefully handled with appropriate fallbacks.

## Troubleshooting

### Common Issues

**"fzf is not installed" error:**

```bash
# macOS
brew install fzf

# Ubuntu/Debian
sudo apt-get install fzf

# Or use without fzf
f js --no-fzf
```

**"pbcopy/xclip not found" warning:**

```bash
# Linux - install xclip
sudo apt-get install xclip

# Or disable clipboard
f js --no-copy
```

**Too many files found:**

```bash
# Limit depth
f js 2

# Or disable content preview
f js --no-content
```

## Contributing

1. Fork the repository
1. Create a feature branch
1. Make your changes
1. Test thoroughly
1. Submit a pull request

## License

MIT License - feel free to use, modify, and distribute.

## Changelog

### v1.0.0

- Initial release
- Basic file finding and content analysis
- Clipboard integration
- Tree view support
- Extension shortcuts
- fzf integration
- Colorized output