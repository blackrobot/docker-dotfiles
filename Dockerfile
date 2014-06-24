# damon/dotfiles

FROM damon/base

# Install pre-requisites
RUN apt-get install -qqy \
      python \
      python-dev \
      ruby-dev \
      mercurial \
      zsh \
      rake \
      exuberant-ctags \
      tmux \
      silversearcher-ag \
      build-essential \
      cmake

# Set HOME
ENV HOME /home
WORKDIR /home

# Compile vim
RUN cd /tmp && \
    hg clone https://code.google.com/p/vim/ && \
    cd vim \
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
    make install

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
RUN git clone git://github.com/blackrobot/dotfiles.git .dotfiles
RUN cd .dotfiles && \
    git submodule init && \
    git submodule update

# Symlink stuff
RUN ln -s $HOME/.dotfiles/.gitconfig $HOME && \
    ln -s $HOME/.dotfiles/.janus $HOME && \
    ln -s $HOME/.dotfiles/.tmux.conf $HOME && \
    ln -s $HOME/.dotfiles/.vimrc.before $HOME && \
    ln -s $HOME/.dotfiles/.vimrc.after $HOME && \
    ln -s $HOME/.dotfiles/.zlogin $HOME && \
    ln -s $HOME/.dotfiles/.zshrc $HOME && \
    ln -s $HOME/.dotfiles/zsh.custom/dzj.zsh-theme $HOME/.oh-my-zsh/custom

# Install YouCompleteMe
RUN cd .dotfiles/.janus/YouCompleteMe && \
    git submodule init && \
    git submodule update && \
    ./install.sh --clang-completer

# Share the work volume
VOLUME ["/workspace"]
WORKDIR /workspace

# Run zsh as login shell
ENTRYPOINT ["/usr/bin/zsh"]
CMD ["--login"]
