# 🖥️ Environment-Based macOS Setup Scripts

> [!NOTE]
> A flexible macOS setup automation suite that organizes tools and applications into logical environment groups. Built on [Homebrew](https://brew.sh/), enhanced with [Oh My Zsh](https://ohmyz.sh/) and [Powerlevel10k](https://github.com/romkatv/powerlevel10k).

<div align="center">

[![macOS](https://img.shields.io/badge/macOS-000000?style=for-the-badge&logo=apple&logoColor=white)](https://www.apple.com/macos/)
[![Homebrew](https://img.shields.io/badge/Homebrew-FBB040?style=for-the-badge&logo=homebrew&logoColor=black)](https://brew.sh/)
[![Shell Script](https://img.shields.io/badge/shell_script-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white)](https://www.zsh.org/)
[![Tests](https://github.com/wyattowalsh/setup/actions/workflows/test.yml/badge.svg)](https://github.com/wyattowalsh/setup/actions/workflows/test.yml)

</div>

---

## 🎯 Environment Groups

> [!TIP]
> Each environment group is a self-contained set of tools and applications. Enable only what you need to keep your system lean and focused.

<details>
<summary><b>Core Development Tools</b></summary>

Essential tools for any development workflow:
- \`gcc\` - GNU Compiler Collection
- \`git\` - Version control system
- \`gh\` - GitHub CLI
- \`make\` - Build automation tool
- \`tree\` - Directory structure viewer
- \`wget\` - File retrieval utility
- \`zsh\` - Z shell
- \`zsh-completions\` - Additional completions for Zsh
- \`visual-studio-code\` - Code editor
- \`github\` - GitHub desktop client

</details>

<details>
<summary><b>Language Environments</b></summary>

### Python Environment
- \`pyenv\` - Python version management
- \`poetry\` - Dependency management
- \`miniconda\` - Data science distribution
- \`jupyter-notebook-ql\` - Notebook previews
- \`sphinx-doc\` - Documentation generator

### Java Environment
- \`java\` - JDK installation
- \`graphviz\` - Graph visualization

### Ruby Environment
- \`rbenv\` - Ruby version management
- \`ruby-build\` - Ruby installation

### Node.js Environment
- \`nvm\` - Node version management
- \`watchman\` - File watching service

</details>

<details>
<summary><b>Specialized Environments</b></summary>

### Docker Environment
- \`docker\` - Container runtime
- \`docker-compose\` - Multi-container orchestration
- \`docker-completion\` - Shell completions

### R Statistical Environment
- \`r\` - R language and environment

### Web Development
- \`google-chrome\` - Web browser
- \`responsively\` - Responsive design testing
- \`quicklook-csv\` - CSV file previews
- \`qlmarkdown\` - Markdown previews
- \`webpquicklook\` - WebP image previews

### Data Science
- \`db-browser-for-sqlite\` - Database management
- \`jupyter-notebook-ql\` - Notebook integration

</details>

<details>
<summary><b>Support Tools</b></summary>

### Writing & Documentation
- \`mark-text\` - Markdown editor
- \`notion\` - Note-taking and collaboration
- \`obsidian\` - Knowledge base
- \`zotero\` - Reference management

### Media
- \`iina\` - Media player
- \`spotify\` - Music streaming

### System Utilities
- \`glance\` - Quick file preview
- \`google-drive\` - Cloud storage
- \`logi-options+\` - Logitech device manager
- \`slack\` - Team communication
- \`speedtest-cli\` - Network speed test
- \`unar\` - Archive extraction

</details>

<details>
<summary><b>Font Collection</b></summary>

### System Fonts
- \`font-sf-pro\` - San Francisco Pro
- \`font-sf-compact\` - San Francisco Compact
- \`font-sf-mono\` - San Francisco Mono
- \`font-new-york\` - New York serif

### Development Fonts
- \`font-fira-code\` - Programming ligatures
- \`font-montserrat\` - Modern sans-serif

### Icon Fonts
- \`font-fontawesome\` - FontAwesome icons
- \`font-awesome-terminal-fonts\` - Terminal icons
- \`font-academicons\` - Academic icons
- \`font-devicons\` - Development icons
- \`font-foundation-icons\` - Foundation icons
- \`font-material-design-icons-webfont\` - Material Design web font
- \`font-material-icons\` - Material Design icons
- \`font-mynaui-icons\` - Myna UI icons
- \`font-simple-line-icons\` - Simple line icons

</details>

## 🚀 Quick Start

> [!IMPORTANT]
> Before running the script, make sure you have administrative privileges on your Mac.

1. **Clone and Navigate**
   \`\`\`bash
   git clone https://gist.github.com/03cb9559dc981a69d410e3ff5ee085fb.git mac_setup
   cd mac_setup
   \`\`\`

2. **Make Executable**
   \`\`\`bash
   chmod +x setup.zsh
   \`\`\`

3. **Customize (Optional)**
   \`\`\`bash
   # Edit setup_config.sh to enable/disable environments
   vim setup_config.sh
   \`\`\`

4. **Run Setup**
   \`\`\`bash
   # View available environments
   ./setup.zsh -l
   
   # Enable specific environments
   ./setup.zsh -e python -e node
   
   # Run with all enabled environments
   ./setup.zsh
   \`\`\`

> [!WARNING]
> The script will require sudo access for some operations. Always review scripts before running them with elevated privileges.

## 🎛️ Command Line Options

| Option | Description |
|--------|-------------|
| \`-l\` | List all available environment groups |
| \`-e GROUP\` | Enable a specific environment group |
| \`-x GROUP\` | Disable a specific environment group |
| \`-v\` | Enable verbose output |
| \`-d\` | Dry run (show what would be installed) |
| \`-s\` | Skip updating existing packages |
| \`-h\` | Show help message |

## 📦 File Structure

\`\`\`
📁 mac_setup/
├── 📄 README.md              # Documentation
├── 📄 setup.zsh             # Main setup script
├── 📄 setup_config.sh       # Environment configuration
├── 📄 setup_functions.sh    # Core functions
└── 📁 tests/                # Test suite
    ├── 📄 run_tests.sh      # Test runner
    ├── 📄 test_helper.sh    # Testing utilities
    ├── 📁 unit/            # Unit tests
    ├── 📁 integration/     # Integration tests
    └── 📁 system/          # System tests
\`\`\`

## 🧪 Testing

The project includes a comprehensive test suite covering unit, integration, and system tests. Tests are automatically run on every push to the main branch using GitHub Actions.

### Running Tests Locally

\`\`\`bash
# Run all tests
./tests/run_tests.sh

# Run specific test suites
./tests/unit/setup_functions_test.sh
./tests/integration/setup_integration_test.sh
./tests/system/setup_system_test.sh
\`\`\`

### Test Coverage

- **Unit Tests**: Test individual functions and utilities
- **Integration Tests**: Test interactions between components
- **System Tests**: Test end-to-end functionality
- **CI/CD**: Automated testing on macOS latest

## 🔄 One-Line Installation

> [!CAUTION]
> This will remove any existing mac_setup directory before installation.

\`\`\`bash
cd && rm -rf mac_setup && git clone https://gist.github.com/03cb9559dc981a69d410e3ff5ee085fb.git mac_setup && cd mac_setup && chmod +x setup.zsh && ./setup.zsh -v
\`\`\`

## 🤝 Contributing

Feel free to submit issues and enhancement requests! Follow these steps:

1. Fork the repository
2. Create your feature branch
3. Add tests for any new functionality
4. Ensure all tests pass locally
5. Commit your changes
6. Push to the branch
7. Create a Pull Request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

<div align="center">
Made with ❤️ for the macOS development community
</div>