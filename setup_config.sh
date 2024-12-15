###################################################
# Configuration settings for setup.zsh
#
# Define the packages, applications, and shell configurations you want for your macOS setup.
###################################################

# Homebrew packages to install
PACKAGES=(
    docker-completion           # Command-line completion for Docker commands in zsh
    docker-compose              # Tool for defining and running multi-container Docker applications
    gcc                         # GNU Compiler Collection, essential for compiling code from source
    gh                          # GitHub CLI for managing GitHub resources from the terminal
    git                         # Version control system for tracking code changes
    graphviz                    # Tool for creating visual representations of graphs and networks
    java                        # Java Development Kit for running Java applications
    make                        # Utility for building and managing code projects
    nvm                         # Node Version Manager for installing and managing multiple Node.js versions
    poetry                      # Python dependency management and packaging tool
    pyenv                       # Python Version Manager for managing multiple Python versions
    r                           # R programming language and software environment for statistical computing
    rbenv                       # Ruby Version Manager for managing multiple Ruby versions
    ruby-build                  # Add-on for rbenv that provides ruby installation scripts
    sphinx-doc                  # Documentation generator, primarily for Python projects
    speedtest-cli               # Command-line interface for testing internet speed
    stripe/stripe-cli/stripe    # Stripe CLI for managing Stripe resources from the terminal
    tree                        # Directory listing tool that displays folder structure as a tree
    unar                        # Utility for extracting RAR archives and other compressed files
    watchman                    # Tool for watching files and recording changes, often used in development
    wget                        # Network utility to retrieve files from the web
    zsh                         # Z shell, an extended Bourne shell with features for interactive use
    zsh-completions             # Additional completions for Z shell commands
)

# Cask apps to install
APPS=(
    db-browser-for-sqlite  # GUI browser for SQLite databases, useful for database management
    docker                 # Container platform for building, running, and managing containerized applications
    glance                 # A quick system monitor for macOS, displays resource usage
    github                 # GitHub desktop application for managing GitHub repositories
    google-chrome          # Popular web browser by Google
    google-drive           # Google Drive desktop client for file storage and synchronization
    iina                   # Modern macOS media player with a sleek interface and powerful features
    jupyter-notebook-ql    # QuickLook extension for previewing Jupyter notebooks in Finder
    logi-options+          # Logitech application for configuring Logitech peripherals
    mark-text              # Markdown editor with a simple and intuitive interface
    miniconda              # Distribution of Python and packages for data science and machine learning
    notion                 # All-in-one workspace for notes, tasks, and projects
    obsidian               # Markdown-based knowledge base and note-taking app
    qlmarkdown             # QuickLook plugin for previewing Markdown files in Finder
    quicklook-csv          # QuickLook plugin for previewing CSV files in Finder
    responsively           # Browser tailored for responsive web development
    slack                  # Collaboration and communication tool, popular for team chat
    spotify                # Music streaming app with a vast library of songs
    visual-studio-code     # Source code editor with support for debugging, syntax highlighting, and more
    webpquicklook          # QuickLook plugin for previewing WebP images in Finder
    zotero                 # Reference manager for managing and organizing research sources

    # Font casks
    font-sf-pro                          # San Francisco Pro font family by Apple
    font-sf-compact                      # San Francisco Compact font family by Apple
    font-sf-mono                         # San Francisco Mono font family by Apple
    font-new-york                        # New York serif font family by Apple
    font-fira-code                       # Monospaced font with programming ligatures
    font-montserrat                      # Versatile sans-serif font
    font-fontawesome                     # Iconic font and CSS toolkit
    font-awesome-terminal-fonts          # Awesome terminal fonts with icons
    font-academicons                     # Font for academic-related icons
    font-devicons                        # Font for development-related icons
    font-foundation-icons                # Foundation's icon font
    font-material-design-icons-webfont   # Material Design Icons in web font format
    font-material-icons                  # Google's Material Icons font
    font-mynaui-icons                    # Icon font for Mynaui projects
    font-simple-line-icons               # Minimal and elegant icon font
)

# PATH exports and other shell configurations
SHELL_CONFIGS=(
    # Initialize Homebrew and set HOMEBREW_PREFIX
    'if [ -x /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x /usr/local/bin/brew ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi'
    'export HOMEBREW_PREFIX="$(brew --prefix)"'                                # Define Homebrew prefix path for easier reference

    # Ensure Homebrew bin is in PATH
    'export PATH="$HOMEBREW_PREFIX/bin:$PATH"'

    # Add GNU Make tools to PATH
    'export PATH="$HOMEBREW_PREFIX/opt/make/libexec/gnubin:$PATH"'

    # Initialize pyenv
    'export PYENV_ROOT="$HOME/.pyenv"'
    'export PATH="$PYENV_ROOT/bin:$PATH"'
    'if command -v pyenv 1>/dev/null 2>&1; then
        eval "$(pyenv init --path)"
        eval "$(pyenv init -)"
    fi'

    # Initialize rbenv
    'export PATH="$HOME/.rbenv/bin:$PATH"'
    'if command -v rbenv 1>/dev/null 2>&1; then
        eval "$(rbenv init - zsh)"
    fi'

    # Set up NVM
    'export NVM_DIR="$HOME/.nvm"'
    '[ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ] && . "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"'

    # Add other necessary paths
    'export PATH="$HOMEBREW_PREFIX/opt/sphinx-doc/bin:$PATH"'
    'export PATH="$HOMEBREW_PREFIX/opt/openjdk/bin:$PATH"'
    'export PATH="$HOMEBREW_PREFIX/opt/curl/bin:$PATH"'
    'export PATH="$HOMEBREW_PREFIX/opt/qt@5/bin:$PATH"'

    # Compiler flags
    'export CPPFLAGS="-I$HOMEBREW_PREFIX/opt/openjdk/include -I$HOMEBREW_PREFIX/opt/curl/include -I$HOMEBREW_PREFIX/opt/qt@5/include"'
    'export LDFLAGS="-L$HOMEBREW_PREFIX/opt/curl/lib -L$HOMEBREW_PREFIX/opt/qt@5/lib"'
    'export PKG_CONFIG_PATH="$HOMEBREW_PREFIX/opt/curl/lib/pkgconfig:$HOMEBREW_PREFIX/opt/qt@5/lib/pkgconfig"'

    # Add custom Zsh function path
    'fpath+=~/.zfunc'

    # Aliases
    'alias c="clear"'

    # Source Powerlevel10k theme
    'if [ -f "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k/powerlevel10k.zsh-theme" ]; then
        source "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k/powerlevel10k.zsh-theme"
    else
        echo "Powerlevel10k theme not found at ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k/powerlevel10k.zsh-theme"
    fi'

    # Load Powerlevel10k configuration if it exists
    '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh'
)