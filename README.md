# Scott's AI World DevContainer

A fully-featured development container pre-configured with AI tools, development utilities, and convenient shell binaries to enhance your development experience with AI-assisted coding.

## Getting Started

### Prerequisites

- Docker installed and running
- VS Code with the "Dev Containers" extension

### Initial Setup

1. **Clone the Repository**
   ```bash
   git clone https://github.com/smpnet74/devcontainer.git
   cd devcontainer
   ```

2. **Open in VS Code Container**
   - Open the cloned folder in VS Code
   - Press `F1` and select "Dev Containers: Reopen in Container"
   - Wait for the container to build and start (this may take a few minutes on first run)
   - The `aimenu` binary will be automatically downloaded and installed

3. **You're Ready!**
   - Once the container is running, you can start using aimenu and all the development tools

## What's Included

### Dockerfile Installation

The Dockerfile includes essential development tools and dependencies:

- **Pixi** - Cross-platform package manager and environment manager
- **Starship** - Modern shell prompt
- **Common Utilities** - Essential command-line tools for development

### Container Startup (postCreateCommand)

When the devcontainer starts up, it automatically:

- Downloads and installs the **aimenu** binary to the container root directory
- The binary is ready to use immediately after the container launches

### aimenu-Installed Environment (ai-dev-pixi)

When you use aimenu to install CLI tools, it automatically sets up a pixi environment with:

- **Node.js 22** - JavaScript runtime (installed once, reused for all tools)
- **Python 3.12** - Python runtime (installed once, reused for all tools)
- **uv** - Universal Python package installer

This isolated environment keeps dependencies organized and prevents conflicts with system packages.

## Using aimenu

The `aimenu` tool provides an interactive menu to install additional AI-focused CLI tools and utilities.

### Running aimenu

Once inside the devcontainer, simply run:

```bash
./aimenu
```

This launches an interactive menu where you can select and install:

### Available CLI Tools

- **Amp by Sourcegraph** - AI-powered code assistance
- **Codex by OpenAI** - OpenAI's code generation tool
- **Droid by Factory AI** - Factory AI coding assistant
- **Gemini CLI by Google** - Google's Gemini AI tool
- **Kimi by MoonshotAI** - MoonshotAI's Kimi CLI
- **Kiro CLI by AWS** - AWS's Kiro CLI tool
- **OpenCode CLI** - OpenCode code assistant
- **OpenHands** - Open-source AI agent for coding
- **Qodo CLI** - Qodo code assistant
- **Qoder by Qwen** - Qwen's Qoder CLI

### Available VS Code Extensions

- **Augment Code** - Augment code completion extension
- **Cline** - Claude AI integration for VS Code
- **Kilo Code** - Kilo Code extension
- **Roo Code** - Roo Cline extension
- **Zencoder** - Zencoder extension

### Available Special Tools

These are tools commonly used in prompts to aid AI CLI tools and are used by various MCP servers:

- **bat** - Better `cat` with syntax highlighting
- **exa/eza** - Modern `ls` replacement
- **fd** - Better `find` alternative
- **gh** - GitHub CLI
- **helm** - Kubernetes package manager
- **jq** - JSON processor
- **lazygit** - Git TUI
- **ripgrep** - Fast search tool (rg)
- **yq** - YAML processor

All selected tools are installed in a dedicated pixi environment (`ai-dev-pixi`) which keeps dependencies isolated and organized.

## Working with VS Code and GitHub

### Opening the Workspace

Once you're inside the devcontainer, you can work with all projects through VS Code:

1. In VS Code, use **File → Open Workspace from File**
2. Navigate to and select `devcontainer.code-workspace`
3. This loads the entire workspace with GitHub integration enabled

The workspace configuration allows you to:
- Access the GitHub icon in VS Code for repository management
- Work across multiple projects simultaneously
- Maintain consistent development environment settings

## Local Development and Building

### For Dockerfile Changes

If you make changes to the Dockerfile, you'll need to rebuild and push the custom devcontainer image:

#### build.sh

Builds the devcontainer image locally:

```bash
./build.sh
```

This creates a new Docker image based on your updated Dockerfile.

#### push.sh

Pushes the newly built image to Docker Hub:

```bash
./push.sh
```

**Note:** Make sure you have Docker access configured before running push.sh.

### Typical Workflow

1. Make changes to `Dockerfile`
2. Run `./build.sh` to build the image locally
3. Test the new image in your devcontainer
4. Run `./push.sh` to push the image to Docker Hub (for sharing with others)
5. Update the image reference in `.devcontainer/devcontainer.json` if the version changed

## Quick Start

1. Open this devcontainer in VS Code
2. Wait for the container to fully initialize (aimenu will be installed automatically)
3. Run `./aimenu` to see the interactive menu
4. Select the AI tools and utilities you want to install
5. Tools will be installed in the isolated pixi environment
6. After installation, source your shell configuration to activate aliases:
   ```bash
   source ~/.zshrc
   ```
7. Use the installed tools via their aliases or direct commands

## Architecture Notes

- **Pixi Environment**: All CLI tools are installed in `~/.local/share/pixi/envs/ai-dev-pixi` to keep your system clean
- **Shell Aliases**: Tool aliases are automatically added to `~/.zshrc` for convenient access
- **Isolation**: The pixi environment isolates tool dependencies, preventing conflicts with system packages

## Troubleshooting

If `aimenu` doesn't run immediately after container startup:
- The download may still be in progress; wait a few moments
- You can manually run the install script:
  ```bash
  INSTALL_DIR=. curl -fsSL https://raw.githubusercontent.com/smpnet74/ai-menu/main/scripts/install.sh | bash
  ```

For issues with installed tools:
- Ensure you've sourced your shell configuration: `source ~/.zshrc`
- Check that the pixi environment is active: `pixi shell`

## Support

For issues or feature requests related to aimenu, visit:
https://github.com/smpnet74/ai-menu
