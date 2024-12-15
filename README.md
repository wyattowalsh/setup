# 🖥️ macOS Setup

> [!NOTE]
> A robust macOS setup automation system that organizes development tools and applications into logical environment groups. Built with [Homebrew](https://brew.sh/), enhanced with [Oh My Zsh](https://ohmyz.sh/) and [Powerlevel10k](https://github.com/romkatv/powerlevel10k).

<div align="center">

[![macOS](https://img.shields.io/badge/macOS-000000?style=for-the-badge&logo=apple&logoColor=white)](https://www.apple.com/macos/)
[![Homebrew](https://img.shields.io/badge/Homebrew-FBB040?style=for-the-badge&logo=homebrew&logoColor=black)](https://brew.sh/)
[![Shell Script](https://img.shields.io/badge/shell_script-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white)](https://www.zsh.org/)

</div>

---

## ✨ Features

- 🎯 **Environment-Based Setup**: Modular environment groups for targeted installation
- 🚀 **Parallel Installation**: Optimized package installation using available CPU cores
- 🔄 **Smart Retry Logic**: Automatic retry for failed operations with exponential backoff
- 🎨 **Rich CLI Interface**: Beautiful progress indicators and detailed status reporting
- 🛡️ **System Validation**: Comprehensive checks for compatibility and requirements
- 🔌 **Extensible Design**: YAML-based configuration for easy customization

## 🔍 System Requirements

> [!IMPORTANT]
> The script performs these checks automatically before installation.

- macOS 11.0 (Big Sur) or later
- 4GB RAM minimum
- 20GB free disk space
- Administrative privileges
- Internet connection

## 🎯 Environment Groups

> [!TIP]
> Each environment is self-contained. Enable only what you need for a lean system.

<details>
<summary><b>Core Development Tools</b></summary>

Essential tools for any development workflow:
- `gcc` - GNU Compiler Collection
- `git` - Version control system
- `gh` - GitHub CLI
- `make` - Build automation tool
- `tree` - Directory structure viewer
- `wget` - File retrieval utility
- `zsh` - Z shell
- `zsh-completions` - Additional completions for Zsh
- `visual-studio-code` - Code editor
- `github` - GitHub desktop client

</details>

<details>
<summary><b>Language Environments</b></summary>

### Python Environment
- `pyenv` - Python version management
- `poetry` - Dependency management
- `miniconda` - Data science distribution
- `jupyter-notebook-ql` - Notebook previews
- `sphinx-doc` - Documentation generator

### Java Environment
- `java` - JDK installation
- `graphviz` - Graph visualization

### Ruby Environment
- `rbenv` - Ruby version management
- `ruby-build` - Ruby installation

### Node.js Environment
- `nvm` - Node version management
- `watchman` - File watching service

</details>

<details>
<summary><b>Specialized Environments</b></summary>

### Docker Environment
- `docker` - Container runtime
- `docker-compose` - Multi-container orchestration
- `docker-completion` - Shell completions

### R Statistical Environment
- `r` - R language and environment

### Web Development
- `google-chrome` - Web browser
- `responsively` - Responsive design testing
- `quicklook-csv` - CSV file previews
- `qlmarkdown` - Markdown previews
- `webpquicklook` - WebP image previews

### Data Science
- `db-browser-for-sqlite` - Database management
- `jupyter-notebook-ql` - Notebook integration

</details>

<details>
<summary><b>Support Tools</b></summary>

### Writing & Documentation
- `mark-text` - Markdown editor
- `notion` - Note-taking and collaboration
- `obsidian` - Knowledge base
- `zotero` - Reference management

### Media
- `iina` - Media player
- `spotify` - Music streaming

### System Utilities
- `glance` - Quick file preview
- `google-drive` - Cloud storage
- `logi-options+` - Logitech device manager
- `slack` - Team communication
- `speedtest-cli` - Network speed test
- `unar` - Archive extraction

</details>

<details>
<summary><b>Font Collection</b></summary>

### System Fonts
- `font-sf-pro` - San Francisco Pro
- `font-sf-compact` - San Francisco Compact
- `font-sf-mono` - San Francisco Mono
- `font-new-york` - New York serif

### Development Fonts
- `font-fira-code` - Programming ligatures
- `font-montserrat` - Modern sans-serif

### Icon Fonts
- `font-fontawesome` - FontAwesome icons
- `font-awesome-terminal-fonts` - Terminal icons
- `font-academicons` - Academic icons
- `font-devicons` - Development icons
- `font-foundation-icons` - Foundation icons
- `font-material-design-icons-webfont` - Material Design web font
- `font-material-icons` - Material Design icons
- `font-mynaui-icons` - Myna UI icons
- `font-simple-line-icons` - Simple line icons

</details>

## 🚀 Installation

> [!IMPORTANT]
> The script requires administrative privileges for certain operations.

1. **Clone Repository**
   ```bash
   git clone https://gist.github.com/03cb9559dc981a69d410e3ff5ee085fb.git mac_setup
   cd mac_setup
   ```

2. **Make Executable**
   ```bash
   chmod +x setup.zsh
   ```

3. **Configure Environments**
   ```yaml
   # Edit setup.yaml to enable/disable environments
   groups:
     python:
       enabled: true
       description: Python development environment
       packages:
         - pyenv
         - poetry
         # Add more packages...
   ```

4. **Run Setup**
   ```bash
   # View available environments
   ./setup.zsh -l
   
   # Enable specific environments
   ./setup.zsh -e python -e node
   
   # Run with all enabled environments
   ./setup.zsh -v
   ```

## 🎛️ Command Line Options

| Option | Description | Example |
|--------|-------------|---------|
| `-l, --list` | List available environments | `./setup.zsh -l` |
| `-e, --enable GROUP` | Enable specific environment | `./setup.zsh -e python` |
| `-x, --disable GROUP` | Disable specific environment | `./setup.zsh -x ruby` |
| `-v, --verbose` | Show detailed output | `./setup.zsh -v` |
| `-d, --dry-run` | Preview changes without applying | `./setup.zsh -d` |
| `-s, --skip-update` | Skip updating existing packages | `./setup.zsh -s` |
| `-h, --help` | Show help message | `./setup.zsh -h` |

## 📦 Project Structure

```
📁 mac_setup/
├── 📄 README.md              # Documentation
├── 📄 setup.zsh             # Main setup script
├── 📄 setup.yaml            # Environment configuration
├── 📄 setup_config.sh       # Configuration loader
├── 📄 setup_functions.sh    # Core functions
└── 📁 lib/                  # Library modules
    ├── 📄 logging.zsh       # Logging utilities
    ├── 📄 config.zsh        # Config management
    ├── 📄 system.zsh        # System checks
    └── 📄 install.zsh       # Package installation
```

## 🔄 Quick Installation

> [!CAUTION]
> This command removes any existing mac_setup directory before installation.

```bash
cd && rm -rf mac_setup && git clone https://gist.github.com/03cb9559dc981a69d410e3ff5ee085fb.git mac_setup && cd mac_setup && chmod +x setup.zsh && ./setup.zsh -v
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