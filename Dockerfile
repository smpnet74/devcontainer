FROM mcr.microsoft.com/devcontainers/base:noble

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install system packages and setup HashiCorp repository for Terraform
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    git \
    gh \
    ripgrep \
    libxcb1 \
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
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/apt/archives/*

# Install AWS CLI, kubectl, and Mountpoint for S3 in a single layer (multi-arch)
ARG TARGETARCH
RUN set -eux; \
    # AWS CLI
    if [ "$TARGETARCH" = "arm64" ]; then \
        curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"; \
    else \
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"; \
    fi && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf aws awscliv2.zip && \
    # kubectl
    if [ "$TARGETARCH" = "arm64" ]; then \
        KUBECTL_ARCH="arm64"; \
    else \
        KUBECTL_ARCH="amd64"; \
    fi && \
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/${KUBECTL_ARCH}/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl && \
    # Mountpoint for Amazon S3
    if [ "$TARGETARCH" = "arm64" ]; then \
        MOUNT_S3_ARCH="arm64"; \
    else \
        MOUNT_S3_ARCH="x86_64"; \
    fi && \
    wget "https://s3.amazonaws.com/mountpoint-s3-release/latest/${MOUNT_S3_ARCH}/mount-s3.deb" && \
    dpkg -i mount-s3.deb && \
    rm mount-s3.deb && \
    # Cleanup
    rm -rf /tmp/* /var/tmp/*

# Switch to vscode user for tool installations
USER vscode
WORKDIR /home/vscode

# Node.js, npm tools, and Qoder CLI are now managed via Pixi - see pixi.toml

# Install all user-level tools in a single layer
RUN set -eux; \
    # Starship prompt
    curl -sS https://starship.rs/install.sh | sh -s -- -y && \
    echo 'eval "$(starship init zsh)"' >> ~/.zshrc && \
    echo 'eval "$(starship init bash)"' >> ~/.bashrc && \
    # Pixi
    curl -fsSL https://pixi.sh/install.sh | sh && \
    echo 'export PATH="$HOME/.pixi/bin:$PATH"' >> ~/.zshrc && \
    echo 'export PATH="$HOME/.pixi/bin:$PATH"' >> ~/.bashrc && \
    # Pixi zsh completions
    mkdir -p ~/.zsh/completions && \
    ~/.pixi/bin/pixi completion --shell zsh > ~/.zsh/completions/_pixi && \
    sed -i '/^export ZSH=/a # Add custom completions directory to fpath\nfpath=(~/.zsh/completions $fpath)' ~/.zshrc && \
    # oh-my-zsh plugins
    sed -i 's/^plugins=(git)$/plugins=(git terraform aws kubectl fzf python)/' ~/.zshrc && \
    # fzf
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && \
    ~/.fzf/install --bin && \
    # Claude Code CLI
    (curl -fsSL https://claude.ai/install.sh | bash || echo "Claude CLI not available") && \
    # Cleanup
    rm -rf ~/.cache/* /tmp/* /var/tmp/*

# npm CLI tools and Qoder CLI now managed via Pixi - run 'pixi run setup' after container starts

# Switch back to root for any final system configurations
USER root

# Set the default shell to zsh for vscode user
RUN chsh -s /usr/bin/zsh vscode

# Switch back to vscode user
USER vscode
WORKDIR /home/vscode

# Set environment variables
ENV SHELL=/usr/bin/zsh
