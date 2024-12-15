<h1 style="font-size: 2.5rem; font-weight: 750; color: #4b5563; padding-bottom: 0; margin-bottom: 0.5rem;"> 🖥️ Configurable macOS Setup Scripts</h1>
<span style="font-size: 1.15rem; font-weight: 750; color: #4b5563; background-color: #f3f4f6;">Easily automate macOS environment setup with essential tools, applications, and Zsh customizations.</span>
<hr style="border: 0; border-top: 1px solid #e5e7eb; margin-top: 0.5rem; margin-bottom: 1rem;">

<p style="font-size: 1.2em; color: #4b5563;">
    Designed to streamline macOS setup, this script suite leverages <a href="https://brew.sh/" style="color: #10B981; font-weight: bold;">Homebrew</a> for efficient package management, enhances Zsh with <a href="https://ohmyz.sh/" style="color: #10B981; font-weight: bold;">Oh My Zsh</a> and <a href="https://github.com/romkatv/powerlevel10k" style="color: #10B981; font-weight: bold;">Powerlevel10k</a>, and customizes your development environment. Using <code>setup_config.sh</code>, you can effortlessly tailor the installation, benefit from detailed logging, and apply robust error handling for a smooth, reliable setup.
</p>

---

<details>
    <summary style="font-weight: 750; font-size: clamp(1.5rem, 2vw, 2rem);"> ⚙ Default Setup Configuration ⤵️</summary>
    <br>

### 📜 Configuration Guide

- **`PACKAGES`**: Define Homebrew formulae to install.
- **`APPS`**: Add cask applications.
- **`SHELL_CONFIGS`**: Customize your shell with exports, aliases, or other Zsh configurations.

### 📦 Homebrew Packages

| **Package**                                           | **Description**                                                                                   |
|-------------------------------------------------------|---------------------------------------------------------------------------------------------------|
| <a href="https://formulae.brew.sh/formula/docker-completion" style="color: #10B981; font-weight: bold;">docker-completion</a> | Command-line completion for Docker commands in zsh                       |
| <a href="https://docs.docker.com/compose/" style="color: #10B981; font-weight: bold;">docker-compose</a>   | Tool for defining and running multi-container Docker applications           |
| <a href="https://gcc.gnu.org/" style="color: #10B981; font-weight: bold;">gcc</a>         | GNU Compiler Collection, essential for compiling code from source        |
| <a href="https://cli.github.com/" style="color: #10B981; font-weight: bold;">gh</a>       | GitHub CLI for managing GitHub resources from the terminal                 |
| <a href="https://git-scm.com/" style="color: #10B981; font-weight: bold;">git</a>         | Version control system for tracking code changes                            |
| <a href="https://graphviz.org/" style="color: #10B981; font-weight: bold;">graphviz</a>   | Tool for creating visual representations of graphs and networks           |
| <a href="https://www.oracle.com/java/" style="color: #10B981; font-weight: bold;">java</a> | Java Development Kit for running Java applications                          |
| <a href="https://www.gnu.org/software/make/" style="color: #10B981; font-weight: bold;">make</a>       | Utility for building and managing code projects                            |
| <a href="https://github.com/nvm-sh/nvm" style="color: #10B981; font-weight: bold;">nvm</a>         | Node Version Manager for installing and managing multiple Node.js versions |
| <a href="https://python-poetry.org/" style="color: #10B981; font-weight: bold;">poetry</a>   | Python dependency management and packaging tool                            |
| <a href="https://github.com/pyenv/pyenv" style="color: #10B981; font-weight: bold;">pyenv</a>   | Python Version Manager for managing multiple Python versions               |
| <a href="https://github.com/rbenv/rbenv" style="color: #10B981; font-weight: bold;">rbenv</a>   | Ruby Version Manager for managing multiple Ruby versions                    |
| <a href="https://github.com/rbenv/ruby-build" style="color: #10B981; font-weight: bold;">ruby-build</a> | Add-on for rbenv that provides Ruby installation scripts                   |
| <a href="https://www.sphinx-doc.org/" style="color: #10B981; font-weight: bold;">sphinx-doc</a>   | Documentation generator, primarily for Python projects                    |
| <a href="https://www.speedtest.net/apps/cli" style="color: #10B981; font-weight: bold;">speedtest-cli</a> | Command-line interface for testing internet speed                          |
| <a href="http://mama.indstate.edu/users/ice/tree/" style="color: #10B981; font-weight: bold;">tree</a>   | Directory listing tool that displays folder structure as a tree           |
| <a href="https://theunarchiver.com/command-line" style="color: #10B981; font-weight: bold;">unar</a>   | Utility for extracting RAR archives and other compressed files             |
| <a href="https://facebook.github.io/watchman/" style="color: #10B981; font-weight: bold;">watchman</a>   | Tool for watching files and recording changes, often used in development |
| <a href="https://www.gnu.org/software/wget/" style="color: #10B981; font-weight: bold;">wget</a> | Network utility to retrieve files from the web                             |
| <a href="https://www.zsh.org/" style="color: #10B981; font-weight: bold;">zsh</a>           | Z shell, an extended Bourne shell with features for interactive use      |
| <a href="https://github.com/zsh-users/zsh-completions" style="color: #10B981; font-weight: bold;">zsh-completions</a> | Additional completions for Z shell commands                               |

### 🖥 Homebrew Cask Applications

| **App**                                       | **Description**                                                                                   |
|-----------------------------------------------|---------------------------------------------------------------------------------------------------|
| <a href="https://sqlitebrowser.org/" style="color: #10B981; font-weight: bold;">db-browser-for-sqlite</a> | GUI browser for SQLite databases, useful for database management         |
| <a href="https://www.docker.com/" style="color: #10B981; font-weight: bold;">docker</a>                   | Container platform for building, running, and managing containerized apps |
| <a href="https://github.com/samuelmeuli/glance" style="color: #10B981; font-weight: bold;">glance</a>     | A quick system monitor for macOS, displays resource usage                 |
| <a href="https://desktop.github.com/" style="color: #10B981; font-weight: bold;">github desktop</a>       | GitHub desktop application for managing GitHub repositories               |
| <a href="https://www.google.com/chrome/" style="color: #10B981; font-weight: bold;">google-chrome</a>     | Popular web browser by Google                                             |
| <a href="https://www.google.com/drive/download/" style="color: #10B981; font-weight: bold;">google-drive</a> | Google Drive desktop client for file storage and synchronization           |
| <a href="https://iina.io/" style="color: #10B981; font-weight: bold;">iina</a>                           | Modern macOS media player with sleek interface and powerful features      |
| <a href="https://github.com/achille-roussel/jupyter-notebook-ql" style="color: #10B981; font-weight: bold;">jupyter-notebook-ql</a> | QuickLook extension for previewing Jupyter notebooks in Finder             |
| <a href="https://www.logitech.com/en-us/software/logi-options.html" style="color: #10B981; font-weight: bold;">logi-options-plus</a> | Logitech application for configuring peripherals                           |
| <a href="https://github.com/marktext/marktext" style="color: #10B981; font-weight: bold;">mark-text</a>   | Markdown editor with a simple and intuitive interface                      |
| <a href="https://docs.conda.io/en/latest/miniconda.html" style="color: #10B981; font-weight: bold;">miniconda</a> | Distribution of Python and packages for data science and machine learning |
| <a href="https://www.notion.so/desktop" style="color: #10B981; font-weight: bold;">notion</a>             | All-in-one workspace for notes, tasks, and projects                        |
| <a href="https://obsidian.md/" style="color: #10B981; font-weight: bold;">obsidian</a>                   | Markdown-based knowledge base and note-taking app                          |
| <a href="https://github.com/toland/qlmarkdown" style="color: #10B981; font-weight: bold;">qlmarkdown</a> | QuickLook plugin for previewing Markdown files in Finder                  |
| <a href="https://github.com/p2/quicklook-csv" style="color: #10B981; font-weight: bold;">quicklook-csv</a> | QuickLook plugin for previewing CSV files in Finder                       |
| <a href="https://responsively.app/" style="color: #10B981; font-weight: bold;">responsively</a>           | Browser tailored for responsive web development                            |
| <a href="https://slack.com/downloads" style="color: #10B981; font-weight: bold;">slack</a>               | Collaboration and communication tool, popular for team chat                |
| <a href="https://www.spotify.com/download" style="color: #10B981; font-weight: bold;">spotify</a>         | Music streaming app with a vast library of songs                           |
| <a href="https://code.visualstudio.com/" style="color: #10B981; font-weight: bold;">visual-studio-code</a> | Source code editor with support for debugging, syntax highlighting, etc.   |
| <a href="https://github.com/emin/WebPQuickLook" style="color: #10B981; font-weight: bold;">webpquicklook</a> | QuickLook plugin for previewing WebP images in Finder                     |
| <a href="https://www.zotero.org/" style="color: #10B981; font-weight: bold;">zotero</a>                   | Reference manager for managing and organizing research sources             |

### 🧰 Default Shell Configurations (`SHELL_CONFIGS`)

These default configurations include useful `PATH` exports, aliases, and environment setups to streamline your terminal experience:

- **Aliases**:
    - `brew`: An override to avoid pyenv interference, ensuring Homebrew runs independently.
    - `c`: Clears the terminal screen for quick readability.
  
- **Path Exports**:
    - `HOMEBREW_PREFIX`, `PYENV_ROOT`, and `NVM_DIR` are set up to simplify access to installed tools.
    - Custom directories for Homebrew packages like `make`, `sphinx-doc`, `curl`, and `qt@5` are added to `PATH`.
  
- **Other Environment Configurations**:
    - `rbenv` and `pyenv` are initialized if available, managing Ruby and Python versions for flexibility across projects.
    - `Powerlevel10k` theme for Zsh is sourced and set up, providing a powerful visual prompt with additional customization options.

</details>

> [!TIP]  
> To add or remove tools, simply update the `PACKAGES` and `APPS` arrays in `setup_config.sh`.

---

## 📋 File Structure Overview

```plaintext
📁 mac_setup/
├── README.md                   # Documentation
├── setup.zsh                   # Main setup script
├── setup_config.sh             # Configurable package/app/shell settings
└── setup_functions.sh          # Core functions, error handling, logging
```

---

## 🚀 Quick Start

1. **Clone the Repository**:

   ```bash
   git clone https://gist.github.com/03cb9559dc981a69d410e3ff5ee085fb.git mac_setup
   cd mac_setup
   ```

2. **Customize Your Setup**:
    - Edit `setup_config.sh` to add or remove packages, apps, or shell configurations.
    - Review the default settings and adjust them to your needs.

3. **Make the Script Executable and Run It**:

   ```bash
   chmod +x setup.zsh
   ```

4. **Run the Setup Script**:
   - **Default setup**:
     ```zsh
     ./setup.zsh
     ```
   - **Verbose output**:
     ```zsh
     ./setup.zsh -v
     ```
   - **Dry run** (simulates setup without changes):
     ```zsh
     ./setup.zsh -d
     ```

---

In one huge command:
```zsh
cd && rm -rf mac_setup && git clone https://gist.github.com/03cb9559dc981a69d410e3ff5ee085fb.git mac_setup && cd mac_setup && chmod +x setup.zsh && ./setup.zsh -v
```