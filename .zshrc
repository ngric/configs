# Change default zim location
export ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim

# Start zim
[[ -s ${ZIM_HOME}/init.zsh ]] && source ${ZIM_HOME}/init.zsh

# Aliases
# alias v=nvim
# alias vim=nvim
# alias n='vim ~/notes/index.md'
alias ls='ls --color'
alias info='info --vi-keys'
#alias ssh="TERM=xterm-256color ssh "
#alias zath="zathura"
alias e="emacsclient -n"
alias o="emacsclient -n"
#alias o="xdg-open"

function d() {
  local dir="${1:-$PWD}"
  emacsclient -e "(dired \"$dir\")" 
}

function g() {
  local dir="${1:-$PWD}"
  emacsclient -e "(magit \"$dir\")" 
}

export EDITOR=emacsclient

# more zim shit, wouldn't proc in zimrc
MNML_MAGICENTER=()

# color less
export LESS=-R

#fzf magic
source ~/.zim/completion.zsh
source ~/.zim/key-bindings.zsh

autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line

PATH=$PATH:/home/nomen/.local/bin
PATH=$PATH:/home/nomen/go/bin
PATH=$PATH:/home/nomen/.cargo/bin
# PATH=$PATH:/home/nomen/.config/emacs/bin

# GTK_IM_MODULE=fcitx
# QT_IM_MODULE=fcitx
# XMODIFIERS=@im=fcitx
# INPUT_METHOD=fcitx
# IMSETTINGS_MODULE=fcitx
# GLFW_IM_MODULE=fcitx

# MOZ_ENABLE_WAYLAND=1
# QT_QPA_PLATFORM=wayland
# ANKI_WAYLAND=1

# vterm integration
if [[ "$INSIDE_EMACS" = 'vterm' ]] \
    && [[ -n ${EMACS_VTERM_PATH} ]] \
    && [[ -f ${EMACS_VTERM_PATH}/etc/emacs-vterm-zsh.sh ]]; then
	source ${EMACS_VTERM_PATH}/etc/emacs-vterm-zsh.sh
fi
