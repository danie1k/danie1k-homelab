export EDITOR=nano

export ZSH=/root/.oh-my-zsh
export ZSH_CACHE_DIR=/root/.cache/oh-my-zsh
export DISABLE_UPDATE_PROMPT=true

#ZSH_THEME=tonotdo
#ZSH_THEME=jtriley
export ZSH_THEME=jonathan

plugins=(
  colorize
  colored-man-pages
  docker
  docker-compose
  screen
  timer
  zsh-autosuggestions
  zsh-syntax-highlighting
)

TIMER_FORMAT=') %d ─┘ '
TIMER_PRECISION=1

source $ZSH/oh-my-zsh.sh

HISTSIZE=10000
SAVEHIST=10000
HISTFILE=/root/.cache/.history
