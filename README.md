# Scott's AI World DevContainer

A fully-featured development container pre-configured with Pixi and Starship, two of my favorite tools.  Additional the devcontainer downloads the latest release of ./aimenu, a CLI tool I created to install AI tools, development utilities, and convenient shell binaries to enhance your development experience with AI-assisted coding.

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
   - Once the container is running, you can start using aimenu to install all the various AI development tools.

## What's Included

### Dockerfile Installation

The Dockerfile includes essential development tools and dependencies:

- **Pixi** - Cross-platform package manager and environment manager
- **Starship** - Modern shell prompt with fzf integration for fast history access.
- **Common Utilities** - AWS CLI, Terraform, and Claude CLI are part of the container image.  All other tools need to be installed into the devcontainer via aimenu.  I preinstalled AWS CLI, Terraform, and Claude because I use these tools most often.

### Container Startup (postCreateCommand)

When the devcontainer starts up, it automatically:

- Downloads and installs the latest **aimenu** binary to the container root directory
- The binary is ready to use immediately after the container launches

### aimenu-Installed Environment (ai-dev-pixi directory)

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
- **Plandex** - AI coding assistant
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

## Using MCP Servers with Pixi Environment

Since all CLI tools are installed in an isolated pixi environment, you need to configure MCP (Model Context Protocol) servers to use the correct paths to the pixi environment's binaries. This allows your AI tools and IDE extensions to access the installed tools through MCP servers.

### Understanding the Pixi Environment Path

When you install CLI tools using aimenu, they are installed in a pixi environment at:
```
/workspaces/devcontainer/ai-dev-pixi/.pixi/envs/default/bin/
```

### Configuring MCP Servers

MCP servers need to be configured in your AI tool's configuration file (typically in `~/.config/<tool>/config.json` or similar). The key is to use the full path to the pixi environment's `npx` or other binaries.

#### Example MCP Server Configuration

Here's an example of how to configure MCP servers for use with the pixi environment:

```json
{
  "mcpServers": {
    "playwright": {
      "command": "/workspaces/devcontainer/ai-dev-pixi/.pixi/envs/default/bin/npx",
      "args": [
        "-y",
        "@playwright/mcp@0.0.38",
        "--browser",
        "firefox"
      ],
      "disabled": false,
      "alwaysAllow": []
    },
    "context7": {
      "command": "/workspaces/devcontainer/ai-dev-pixi/.pixi/envs/default/bin/npx",
      "args": [
        "-y",
        "@upstash/context7-mcp"
      ],
      "env": {
        "DEFAULT_MINIMUM_TOKENS": ""
      }
    },
    "filesystem": {
      "command": "/workspaces/devcontainer/ai-dev-pixi/.pixi/envs/default/bin/npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/workspaces/devcontainer"
      ]
    }
  }
}
```

### Key Configuration Points

1. **Command Path**: Always use the full path to the pixi environment's `npx`:
   ```
   /workspaces/devcontainer/ai-dev-pixi/.pixi/envs/default/bin/npx
   ```

2. **Arguments**: Include `-y` flag to automatically accept prompts when installing MCP packages

3. **Environment Variables**: You can pass environment variables through the `env` field if needed

4. **Disabled Flag**: Set `"disabled": false` to enable the server, or `true` to disable it

### Using with Different Tools

#### Augment Code (VSCode Extension)
Add MCP server configurations to your VSCode settings:
```json
{
  "augment.mcpServers": {
    "playwright": {
      "command": "/workspaces/devcontainer/ai-dev-pixi/.pixi/envs/default/bin/npx",
      "args": ["-y", "@playwright/mcp@0.0.38", "--browser", "firefox"]
    }
  }
}
```

#### Claude (Desktop App)
Add configurations to `~/.config/Claude/claude_desktop_config.json`:
```json
{
  "mcpServers": {
    "filesystem": {
      "command": "/workspaces/devcontainer/ai-dev-pixi/.pixi/envs/default/bin/npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/workspaces/devcontainer"]
    }
  }
}
```

### Finding Available MCP Servers

Popular MCP servers available via npm include:
- `@modelcontextprotocol/server-filesystem` - File system access
- `@playwright/mcp` - Browser automation
- `@upstash/context7-mcp` - Context management
- `@modelcontextprotocol/server-git` - Git operations
- `@modelcontextprotocol/server-postgres` - PostgreSQL database access

You can search for more MCP servers on npm by searching for "mcp" or visiting the [Model Context Protocol documentation](https://modelcontextprotocol.io).

## Cleaning Up and Reinstalling Tools

### Removing Installed Tools

If you want to remove all installed CLI tools and start fresh with a different selection, simply delete the `ai-dev-pixi` directory:

```bash
rm -rf /workspaces/devcontainer/ai-dev-pixi
```

After deleting the directory, you can run `./aimenu` again to reinstall any tools you want:

```bash
./aimenu
```

This will create a fresh `ai-dev-pixi` environment and allow you to select which tools to install.

### Removing Shell Aliases

When you delete the `ai-dev-pixi` directory, the shell aliases in `~/.zshrc` will still reference the deleted environment. To clean these up, you can manually remove the alias lines from `~/.zshrc`:

```bash
# Open your shell configuration file
nano ~/.zshrc
# or
vim ~/.zshrc
```

Look for lines that reference the old `ai-dev-pixi` path and delete them. They typically look like:

```bash
alias amp="/workspaces/devcontainer/ai-dev-pixi/.pixi/envs/default/bin/amp"
alias forge="/workspaces/devcontainer/ai-dev-pixi/.pixi/envs/default/bin/forge"
alias goose="/workspaces/devcontainer/ai-dev-pixi/.pixi/envs/default/bin/goose"
# ... other aliases
```

After editing, reload your shell configuration:

```bash
source ~/.zshrc
```

### Complete Fresh Start (Devcontainer)

If you want to completely start fresh and reset your entire development environment, follow these steps:

1. **Delete the ai-dev-pixi directory**:
   ```bash
   rm -rf /workspaces/devcontainer/ai-dev-pixi
   ```

2. **Remove shell aliases** (optional but recommended):
   - Edit `~/.zshrc` and remove all lines referencing the old `ai-dev-pixi` path
   - Or simply delete the entire `~/.zshrc` file if you want a completely clean slate

3. **Rebuild the devcontainer**:
   - In VSCode, open the Command Palette (Ctrl+Shift+P or Cmd+Shift+P)
   - Search for and select **"Dev Containers: Rebuild Container"**
   - Wait for the container to rebuild completely

4. **Reinstall tools** (optional):
   - Once the container is rebuilt, run `./aimenu` to select and install your desired tools again

### Why Rebuild the Devcontainer?

Rebuilding the devcontainer provides a completely clean environment by:
- Resetting all system packages to their original state
- Clearing all environment variables and configurations
- Removing all temporary files and caches
- Starting fresh with a clean filesystem

This is useful if you've made manual changes to system files or want to ensure your environment matches the original devcontainer configuration.

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
