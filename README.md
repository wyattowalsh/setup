# 🖥️ macOS Setup

> [!NOTE]
> A robust macOS setup automation system that organizes development tools and applications into logical package groups. Built with [Homebrew](https://brew.sh/), enhanced with [Oh My Zsh](https://ohmyz.sh/) and [Powerlevel10k](https://github.com/romkatv/powerlevel10k).

<div align="center">

[![macOS](https://img.shields.io/badge/macOS-000000?style=for-the-badge&logo=apple&logoColor=white)](https://www.apple.com/macos/)
[![Homebrew](https://img.shields.io/badge/Homebrew-FBB040?style=for-the-badge&logo=homebrew&logoColor=black)](https://brew.sh/)
[![Shell Script](https://img.shields.io/badge/shell_script-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white)](https://www.zsh.org/)

</div>

---

## ✨ Features

- 🎯 **Package Groups**: Logically organized packages for targeted installation
- 🚀 **Parallel Installation**: Optimized package installation using available CPU cores
- 🔄 **Smart Retry Logic**: Automatic retry for failed operations with exponential backoff
- 🎨 **Rich CLI Interface**: Beautiful progress indicators and detailed status reporting
- 🛡️ **System Validation**: Comprehensive checks for compatibility and requirements
- 🔌 **Simple Configuration**: YAML-based configuration for easy customization

## 🔍 System Requirements

> [!IMPORTANT]
> The script performs these checks automatically before installation.

- macOS 11.0 (Big Sur) or later
- 4GB RAM minimum
- 20GB free disk space
- Administrative privileges
- Internet connection

## 🎯 Installation

1. **Clone Repository**
   ```bash
   git clone https://github.com/wyattowalsh/setup.git
   cd setup
   ```

2. **Make Executable**
   ```bash
   chmod +x setup.zsh
   ```

3. **Configure Package Groups**
   Edit `setup.yaml` to include only the package groups you want to install:

   ```yaml
   groups:
     core:
       description: Core development tools
       packages:
         - git
         - gh
         - make
         # Add or remove packages...

     python:
       description: Python development environment
       packages:
         - pyenv
         - poetry
         # Add or remove packages...
   ```

   > [!TIP]
   > - To disable a group: Remove or comment out its entire section
   > - To enable a group: Include its section with description and packages
   > - To customize: Add or remove packages within any group

4. **Run Setup**
   ```bash
   # Run with default settings
   ./setup.zsh

   # Run with verbose output
   ./setup.zsh -v

   # Preview changes without applying
   ./setup.zsh -d
   ```

## 🎛️ Command Line Options

| Option | Description | Example |
|--------|-------------|---------|
| `-v, --verbose` | Show detailed output | `./setup.zsh -v` |
| `-d, --dry-run` | Preview changes without applying | `./setup.zsh -d` |
| `-s, --skip-update` | Skip updating existing packages | `./setup.zsh -s` |
| `-h, --help` | Show help message | `./setup.zsh -h` |

## 📦 Project Structure

```
📁 setup/
├── 📄 README.md              # Documentation
├── 📄 setup.zsh             # Main setup script
├── 📄 setup.yaml            # Package configuration
└── 📁 lib/                  # Library modules
    ├── 📄 logging.zsh       # Logging utilities
    ├── 📄 config.zsh        # Config management
    ├── 📄 system.zsh        # System checks
    └── 📄 install.zsh       # Package installation
```

## 🔄 Quick Installation

> [!CAUTION]
> This command removes any existing setup directory before installation.

```bash
cd && rm -rf setup && git clone https://github.com/wyattowalsh/setup.git && cd setup && chmod +x setup.zsh && ./setup.zsh -v
```

## 🤝 Contributing

Feel free to submit issues and enhancement requests! Follow these steps:

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

<div align="center">
Made with ❤️ for the macOS development community
</div>
