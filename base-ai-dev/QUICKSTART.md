# Quick Start Guide

## One-Command Setup

After starting your container, run:

```bash
cd /workspaces/devcontainer/python-env
./setup-env.sh
```

This will:
1. ✓ Verify Pixi is installed
2. ✓ Install Node.js 22.x and Python 3.13.x
3. ✓ Install all AI CLI tools (gemini-cli, qodo, opencode, codex)
4. ✓ Verify everything works

## Using the Environment

### Enter the Pixi Shell
```bash
pixi shell
```

Now you have access to:
- `node`, `npm`
- `python`, `pip`
- `gemini-cli`, `qodo`, `opencode`, `codex`
- All system commands (`git`, `docker`, `kubectl`, `aws`, etc.)

### Run Commands Without Shell
```bash
pixi run node --version
pixi run gemini-cli --help
pixi run python -c "import modal; print('Modal works!')"
```

## What Changed from Dockerfile?

### Before (Dockerfile approach)
```dockerfile
# NVM + Node installation baked into image
ENV NVM_DIR=/home/vscode/.nvm
RUN curl -fsSL .../nvm/install.sh | bash
RUN nvm install --lts
RUN npm install -g @google/gemini-cli ...
```

### After (Pixi approach)
```toml
# pixi.toml
[dependencies]
nodejs = "22.*"

[tasks]
setup-ai-tools = "npm install -g @google/gemini-cli ..."
```

### Benefits
- 🚀 No Docker rebuild needed for Node/tool updates
- 🔒 Version-locked via `pixi.lock`
- 🎯 Per-project Node versions
- 📦 Lighter Docker image
- ✅ System commands still available

## Next Steps

1. **Configure AI tools**: Each tool may need API keys
   ```bash
   export OPENAI_API_KEY="your-key"
   export GOOGLE_API_KEY="your-key"
   ```

2. **Add more tools**: Edit `pixi.toml` and run:
   ```bash
   pixi install
   pixi run setup-ai-tools
   ```

3. **Check pixi-default/README.md** for detailed documentation

## Troubleshooting

**Tools not found?**
```bash
pixi shell
which gemini-cli
```

**Need to reinstall?**
```bash
rm -rf .pixi
./setup-env.sh
```

**Want different Node version?**
Edit `pixi.toml`:
```toml
nodejs = "20.*"  # or any version
```
Then:
```bash
pixi install
```
