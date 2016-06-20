# damon/dotfiles

FROM ubuntu:latest

# Install pre-requisites
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        build-essential \
        cmake \
        exuberant-ctags \
        git \
        libncurses5-dev \
        mercurial \
        python \
        python-dev \
        python-pip \
        software-properties-common \
        rake \
        ruby-dev \
        silversearcher-ag \
        sudo \
        tmux \
        zsh && \
    add-apt-repository -y ppa:neovim-ppa/unstable && \
    apt-get update && \
    apt-get install -y neovim && \
    rm -Rf /var/lib/apt/lists/* && \
    apt-get clean && \
    apt-get autoremove -y \

# Add the damon user, with passwordless sudo
RUN useradd --user-group \
            --create-home \
            --shell /usr/bin/zsh \
            damon && \
    echo 'damon ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# Install flake8 for python syntax checking
RUN pip install flake8

# Switch to damon user and /home/damon directory
USER damon
ENV HOME /home/damon
WORKDIR /home/damon

# Set neovim as default editor
RUN update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60 && \
    update-alternatives --config editor && \
    update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 60 && \
    update-alternatives --config vi && \
    update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 60 && \
    update-alternatives --config vim

# Install oh-my-zsh
RUN git clone git://github.com/robbyrussell/oh-my-zsh.git .oh-my-zsh

# Install janus
RUN curl -Lo- https://bit.ly/janus-bootstrap | bash

# Clone dotfiles
RUN git clone git://github.com/blackrobot/dotfiles.git .dotfiles && \
    cd .dotfiles && \
    git submodule update --init --recursive && \
    cd .janus/YouCompleteMe && \
    ./install.sh --clang-completer

# Symlink stuff
RUN ln -s .dotfiles/.gitconfig . && \
    ln -s .dotfiles/.janus . && \
    ln -s .dotfiles/.tmux.conf . && \
    ln -s .dotfiles/.vimrc.before . && \
    ln -s .dotfiles/.vimrc.after . && \
    ln -s .dotfiles/.zlogin . && \
    ln -s .dotfiles/.zshrc . && \
    ln -s .dotfiles/zsh.custom/*.zsh-theme .oh-my-zsh/custom && \
    ln -s .dotfiles/zsh.custom/plugins/* .oh-my-zsh/custom/plugins

# Share the work volume
VOLUME ["/home/damon/workspace"]

# Run zsh as login shell
ENTRYPOINT ["/usr/bin/zsh"]
CMD ["--login"]
