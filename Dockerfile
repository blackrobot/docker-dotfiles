# damon/dotfiles

FROM damon/base

# Install pre-requisites
RUN apt-get install -qqy vim zsh rake exuberant-ctags tmux silversearcher-ag

# Set HOME
ENV HOME /home
WORKDIR /home

# Install oh-my-zsh
RUN git clone git://github.com/robbyrussell/oh-my-zsh.git .oh-my-zsh

# Install janus
RUN curl -Lo- https://bit.ly/janus-bootstrap | bash

# Clone dotfiles
RUN git clone git://github.com/blackrobot/dotfiles.git .dotfiles
RUN cd .dotfiles && git submodule init && git submodule update

# Symlink stuff
RUN ln -s $HOME/.dotfiles/.gitconfig $HOME && \
    ln -s $HOME/.dotfiles/.janus $HOME && \
    ln -s $HOME/.dotfiles/.tmux.conf $HOME && \
    ln -s $HOME/.dotfiles/.vimrc.before $HOME && \
    ln -s $HOME/.dotfiles/.vimrc.after $HOME && \
    ln -s $HOME/.dotfiles/.zlogin $HOME && \
    ln -s $HOME/.dotfiles/.zshrc $HOME && \
    ln -s $HOME/.dotfiles/zsh.custom/dzj.zsh-theme $HOME/.oh-my-zsh/custom

# Share the work volume
VOLUME ["/workspace"]
WORKDIR /workspace

# Run zsh as login shell
ENTRYPOINT ["/usr/bin/zsh"]
CMD ["--login"]
