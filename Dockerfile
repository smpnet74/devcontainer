FROM mcr.microsoft.com/devcontainers/base:noble

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install system packages and setup HashiCorp repository for Terraform
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    git \
    ripgrep \
    iputils-ping \
    unzip \
    gnupg \
    software-properties-common \
    wget \
    lsb-release \
    && wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list \
    && apt-get update \
    && apt-get install -y terraform \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install AWS CLI (multi-arch)
ARG TARGETARCH
RUN if [ "$TARGETARCH" = "arm64" ]; then \
        curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"; \
    else \
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"; \
    fi && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf aws awscliv2.zip

# Install kubectl (multi-arch)
RUN if [ "$TARGETARCH" = "arm64" ]; then \
        KUBECTL_ARCH="arm64"; \
    else \
        KUBECTL_ARCH="amd64"; \
    fi && \
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/${KUBECTL_ARCH}/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl

# Switch to vscode user for tool installations
USER vscode
WORKDIR /home/vscode

# Install NVM and Node.js LTS
ENV NVM_DIR=/home/vscode/.nvm
RUN curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash && \
    . "$NVM_DIR/nvm.sh" && \
    nvm install --lts && \
    nvm use --lts && \
    nvm alias default 'lts/*' && \
    npm cache clean --force

# Install Starship prompt
RUN curl -sS https://starship.rs/install.sh | sh -s -- -y && \
    echo 'eval "$(starship init zsh)"' >> ~/.zshrc && \
    echo 'eval "$(starship init bash)"' >> ~/.bashrc

# Install Pixi
RUN curl -fsSL https://pixi.sh/install.sh | sh && \
    echo 'export PATH="$HOME/.pixi/bin:$PATH"' >> ~/.zshrc && \
    echo 'export PATH="$HOME/.pixi/bin:$PATH"' >> ~/.bashrc

# Configure fzf key bindings and completion for zsh
# Download the scripts since oh-my-zsh's fzf plugin expects them in ~/.fzf
RUN git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && \
    ~/.fzf/install --key-bindings --completion --no-update-rc --no-bash --no-fish

# Source fzf after oh-my-zsh loads
RUN echo '' >> ~/.zshrc && \
    echo '# FZF configuration' >> ~/.zshrc && \
    echo '[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh' >> ~/.zshrc

# Install Claude Code CLI
RUN curl -fsSL https://claude.ai/install.sh | bash || echo "Claude CLI not available"

# Add NVM to shell initialization
RUN echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.zshrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.zshrc && \
    echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> ~/.zshrc && \
    echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> ~/.bashrc

# Install CLI tools via npm
RUN . "$NVM_DIR/nvm.sh" && npm install -g \
    '@google/gemini-cli' \
    '@qodo/command' \
    'opencode-ai' \
    '@openai/codex' \
    || echo "Some CLI tools not available"

# Clean up caches to reduce image size
RUN rm -rf ~/.cache/* && \
    rm -rf ~/.npm/_cacache && \
    . "$NVM_DIR/nvm.sh" && npm cache clean --force || true

# Switch back to root for any final system configurations
USER root

# Set the default shell to zsh for vscode user
RUN chsh -s /usr/bin/zsh vscode

# Switch back to vscode user
USER vscode
WORKDIR /home/vscode

# Set environment variables
ENV SHELL=/usr/bin/zsh
