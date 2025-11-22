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
    fuse \
    libfuse2t64 \
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

# Install Mountpoint for Amazon S3 (multi-arch)
RUN if [ "$TARGETARCH" = "arm64" ]; then \
        MOUNT_S3_ARCH="arm64"; \
    else \
        MOUNT_S3_ARCH="x86_64"; \
    fi && \
    wget "https://s3.amazonaws.com/mountpoint-s3-release/latest/${MOUNT_S3_ARCH}/mount-s3.deb" && \
    dpkg -i mount-s3.deb && \
    rm mount-s3.deb

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

# Install Qoder CLI (installer autodetects OS/arch)
RUN curl -fsSL https://qoder.com/install | bash && \
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc && \
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc

# Setup Pixi zsh completions
RUN mkdir -p ~/.zsh/completions && \
    ~/.pixi/bin/pixi completion --shell zsh > ~/.zsh/completions/_pixi && \
    sed -i '/^export ZSH=/a # Add custom completions directory to fpath\nfpath=(~/.zsh/completions $fpath)' ~/.zshrc

# Enable oh-my-zsh plugins for better completions and features
RUN sed -i 's/^plugins=(git)$/plugins=(git terraform aws kubectl fzf nvm npm node python)/' ~/.zshrc

# Install fzf (oh-my-zsh fzf plugin will handle sourcing)
RUN git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && \
    ~/.fzf/install --bin

# Install Claude Code CLI
RUN curl -fsSL https://claude.ai/install.sh | bash || echo "Claude CLI not available"

# Configure NVM_DIR (oh-my-zsh nvm plugin will handle loading for zsh)
RUN echo '# NVM configuration - NVM_DIR will be auto-detected by the nvm plugin' >> ~/.zshrc && \
    echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.zshrc && \
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
