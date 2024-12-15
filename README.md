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

## 🔍 Package Index

<details>
<summary><b>Complete List of Available Packages (A-Z)</b></summary>

| Package                                | Type | Description                     | Environment  |
| -------------------------------------- | ---- | ------------------------------- | ------------ |
| `academicons`                        | Font | Academic and scholarly icons    | Fonts        |
| `db-browser-for-sqlite`              | App  | SQLite database management      | Data Science |
| `devicons`                           | Font | Development-related icons       | Fonts        |
| `docker`                             | CLI  | Container runtime               | Docker       |
| `docker-completion`                  | CLI  | Docker command completions      | Docker       |
| `docker-compose`                     | CLI  | Multi-container orchestration   | Docker       |
| `fira-code`                          | Font | Programming font with ligatures | Fonts        |
| `font-academicons`                   | Font | Academic icons                  | Fonts        |
| `font-awesome-terminal-fonts`        | Font | Terminal-optimized icons        | Fonts        |
| `font-devicons`                      | Font | Developer icon font             | Fonts        |
| `font-fira-code`                     | Font | Programming ligatures           | Fonts        |
| `font-fontawesome`                   | Font | Popular icon library            | Fonts        |
| `font-foundation-icons`              | Font | Foundation framework icons      | Fonts        |
| `font-material-design-icons-webfont` | Font | Material Design web icons       | Fonts        |
| `font-material-icons`                | Font | Google's Material icons         | Fonts        |
| `font-montserrat`                    | Font | Modern sans-serif typeface      | Fonts        |
| `font-mynaui-icons`                  | Font | Myna UI icon set                | Fonts        |
| `font-new-york`                      | Font | Apple's serif typeface          | Fonts        |
| `font-sf-compact`                    | Font | Apple's compact system font     | Fonts        |
| `font-sf-mono`                       | Font | Apple's monospace font          | Fonts        |
| `font-sf-pro`                        | Font | Apple's system font             | Fonts        |
| `font-simple-line-icons`             | Font | Simple line icon set            | Fonts        |
| `gcc`                                | CLI  | GNU Compiler Collection         | Core         |
| `gh`                                 | CLI  | GitHub command-line tool        | Core         |
| `git`                                | CLI  | Version control system          | Core         |
| `github`                             | App  | GitHub desktop client           | Core         |
| `glance`                             | App  | Quick file preview utility      | System       |
| `google-chrome`                      | App  | Web browser                     | Web          |
| `google-drive`                       | App  | Cloud storage client            | System       |
| `graphviz`                           | CLI  | Graph visualization             | Java         |
| `iina`                               | App  | Media player                    | Media        |
| `java`                               | CLI  | Java Development Kit            | Java         |
| `jupyter-notebook-ql`                | App  | Notebook preview integration    | Python       |
| `logi-options+`                      | App  | Logitech device manager         | System       |
| `make`                               | CLI  | Build automation tool           | Core         |
| `mark-text`                          | App  | Markdown editor                 | Writing      |
| `miniconda`                          | CLI  | Python distribution             | Python       |
| `notion`                             | App  | Note-taking application         | Writing      |
| `nvm`                                | CLI  | Node version manager            | Node         |
| `obsidian`                           | App  | Knowledge base system           | Writing      |
| `poetry`                             | CLI  | Python dependency manager       | Python       |
| `pyenv`                              | CLI  | Python version manager          | Python       |
| `qlmarkdown`                         | App  | Markdown preview                | Web          |
| `quicklook-csv`                      | App  | CSV file preview                | Web          |
| `r`                                  | CLI  | Statistical computing           | R            |
| `rbenv`                              | CLI  | Ruby version manager            | Ruby         |
| `responsively`                       | App  | Responsive design testing       | Web          |
| `ruby-build`                         | CLI  | Ruby installation manager       | Ruby         |
| `slack`                              | App  | Team communication              | System       |
| `speedtest-cli`                      | CLI  | Network speed testing           | System       |
| `sphinx-doc`                         | CLI  | Documentation generator         | Python       |
| `spotify`                            | App  | Music streaming                 | Media        |
| `tree`                               | CLI  | Directory structure viewer      | Core         |
| `unar`                               | CLI  | Archive extraction              | System       |
| `visual-studio-code`                 | App  | Code editor                     | Core         |
| `watchman`                           | CLI  | File watching service           | Node         |
| `webpquicklook`                      | App  | WebP image preview              | Web          |
| `wget`                               | CLI  | File retrieval utility          | Core         |
| `zotero`                             | App  | Reference management            | Writing      |
| `zsh`                                | CLI  | Z shell                         | Core         |
| `zsh-completions`                    | CLI  | Shell completions               | Core         |

</details>

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
   git clone https://github.com/wyattowalsh/setup.git
   cd setup
   ```
2. **Make Executable**

   ```bash
   chmod +x setup.zsh
   ```
3. **Configure Environments**
   Edit `setup.yaml` to enable or disable environments:

   ```yaml
   environments:
     python:
       enabled: true  # Set to false to disable
       packages:
         - pyenv
         - poetry
         # Add more packages...
     node:
       enabled: false  # Set to true to enable
       packages:
         - nvm
         - watchman
         # Add more packages...
   ```
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

| Option                | Description                      | Example            |
| --------------------- | -------------------------------- | ------------------ |
| `-v, --verbose`     | Show detailed output             | `./setup.zsh -v` |
| `-d, --dry-run`     | Preview changes without applying | `./setup.zsh -d` |
| `-s, --skip-update` | Skip updating existing packages  | `./setup.zsh -s` |
| `-h, --help`        | Show help message                | `./setup.zsh -h` |

## 📦 Project Structure

```
📁 mac_setup/
├── 📄 README.md              # Documentation
├── 📄 setup.zsh             # Main setup script
├── 📄 setup.yaml            # Environment configuration
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
