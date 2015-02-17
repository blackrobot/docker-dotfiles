# damon/dotfiles

FROM ubuntu:trusty

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
        rake \
        ruby-dev \
        silversearcher-ag \
        tmux \
        zsh && \
    rm -Rf /var/lib/apt/lists/* && \
    apt-get clean && \
    apt-get autoremove -y

# Set HOME
ENV HOME /home
WORKDIR /home

# Compile vim
ADD https://github.com/b4winckler/vim/archive/master.tar.gz /tmp/vim-master.tar.gz
RUN tar xfz /tmp/vim-master.tar.gz -C /tmp && \
    cd /tmp/vim-master && \
    ./configure --with-features=huge \
                --enable-multibyte \
                --enable-rubyinterp \
                --enable-pythoninterp \
                --with-python-config-dir=/usr/lib/python2.7/config \
                --enable-perlinterp \
                --enable-luainterp \
                --enable-cscope \
                --prefix=/usr && \
    make VIMRUNTIMEDIR=/usr/share/vim/vim74 && \
    make install && \
    rm -Rf /tmp/vim-master*

# Set vim as default
RUN update-alternatives --install /usr/bin/editor editor /usr/bin/vim 1 && \
    update-alternatives --set editor /usr/bin/vim && \
    update-alternatives --install /usr/bin/vi vi /usr/bin/vim 1 && \
    update-alternatives --set vi /usr/bin/vim

# Install oh-my-zsh
RUN git clone git://github.com/robbyrussell/oh-my-zsh.git .oh-my-zsh

# Install janus
RUN curl -Lo- https://bit.ly/janus-bootstrap | bash

# Clone dotfiles
RUN git clone git://github.com/blackrobot/dotfiles.git .dotfiles && \
    cd .dotfiles && \
    git submodule update --init --recursive

# Symlink stuff
RUN ln -s $HOME/.dotfiles/.gitconfig $HOME && \
    ln -s $HOME/.dotfiles/.janus $HOME && \
    ln -s $HOME/.dotfiles/.tmux.conf $HOME && \
    ln -s $HOME/.dotfiles/.vimrc.before $HOME && \
    ln -s $HOME/.dotfiles/.vimrc.after $HOME && \
    ln -s $HOME/.dotfiles/.zlogin $HOME && \
    ln -s $HOME/.dotfiles/.zshrc $HOME && \
    ln -s $HOME/.dotfiles/zsh.custom/*.zsh-theme $HOME/.oh-my-zsh/custom && \
    ln -s $HOME/.dotfiles/zsh.custom/plugins/* $HOME/.oh-my-zsh/custom/plugins

# Install YouCompleteMe
RUN cd .dotfiles/.janus/YouCompleteMe && ./install.sh --clang-completer

# Install flake8 for python syntax checking
RUN pip install flake8

# Share the work volume
VOLUME ["/work"]
WORKDIR /work

# Run zsh as login shell
ENTRYPOINT ["/usr/bin/zsh"]
CMD ["--login"]
