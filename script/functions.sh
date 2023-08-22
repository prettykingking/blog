#!/bin/sh

set -eo pipefail

setup_colors() {
  # shellcheck disable=SC2034
  if [ -t 1 ]; then
    RESET_COLOR='\033[0m'

    # regular
    BLACK='\033[0;30m'
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    ORANGE='\033[0;33m'
    BLUE='\033[0;34m'
    PURPLE='\033[0;35m'
    CYAN='\033[0;36m'

    # bold
    BLACK_BOLD='\033[1;30m'
    RED_BOLD='\033[1;31m'
    GREEN_BOLD='\033[1;32m'
    ORANGE_BOLD='\033[1;33m'
    BLUE_BOLD='\033[1;34m'
    PURPLE_BOLD='\033[1;35m'
    CYAN_BOLD='\033[1;36m'

    # underline
    BLACK_UNDERLINE='\033[4;30m'
    RED_UNDERLINE='\033[4;31m'
    GREEN_UNDERLINE='\033[4;32m'
    ORANGE_UNDERLINE='\033[4;33m'
    BLUE_UNDERLINE='\033[4;34m'
    PURPLE_UNDERLINE='\033[4;35m'
    CYAN_UNDERLINE='\033[4;36m'
  else
    RESET_COLOR=''

    # regular
    BLACK=''
    RED=''
    GREEN=''
    ORANGE=''
    BLUE=''
    PURPLE=''
    CYAN=''

    # bold
    BLACK_BOLD=''
    RED_BOLD=''
    GREEN_BOLD=''
    ORANGE_BOLD=''
    BLUE_BOLD=''
    PURPLE_BOLD=''
    CYAN_BOLD=''

    # underline
    BLACK_UNDERLINE=''
    RED_UNDERLINE=''
    GREEN_UNDERLINE=''
    ORANGE_UNDERLINE=''
    BLUE_UNDERLINE=''
    PURPLE_UNDERLINE=''
    CYAN_UNDERLINE=''
  fi
}

print() {
  printf '%b' "${1-}\n"
}

error() {
  print "$(colorize 'ERROR' 1 1) ${1-}"
  exit "${2-1}"
}

info() {
  print "$(colorize 'INFO' 2 1) ${1-}"
}

warn() {
  print "$(colorize 'WARN' 3 1) ${1-}"
}

quit() {
  exit "${1-0}"
}

# USAGE
# colorize <text> <color> <style>
#
# ARGUMENTS
# text
#   the content to print
# color
#   0 - black
#   1 - red
#   2 - green
#   3 - orange
#   4 - blue
#   5 - purple
#   6 - cyan
# style
#   0 - no style
#   1 - bold
#   2 - underline
colorize() {
  style="${3-0}"

  case "${2-}" in
  1)
    color="$RED"

    if [ "$style" -eq 1 ]; then
      color="$RED_BOLD"
    fi

    if [ "$style" -eq 2 ]; then
      color="$RED_UNDERLINE"
    fi
    ;;
  2)
    color="$GREEN"

    if [ "$style" -eq 1 ]; then
      color="$GREEN_BOLD"
    fi

    if [ "$style" -eq 2 ]; then
      color="$GREEN_UNDERLINE"
    fi
    ;;
  3)
    color="$ORANGE"

    if [ "$style" -eq 1 ]; then
      color="$ORANGE_BOLD"
    fi

    if [ "$style" -eq 2 ]; then
      color="$ORANGE_UNDERLINE"
    fi
    ;;
  4)
    color="$BLUE"

    if [ "$style" -eq 1 ]; then
      color="$BLUE_BOLD"
    fi

    if [ "$style" -eq 2 ]; then
      color="$BLUE_UNDERLINE"
    fi
    ;;
  5)
    color="$PURPLE"

    if [ "$style" -eq 1 ]; then
      color="$PURPLE_BOLD"
    fi

    if [ "$style" -eq 2 ]; then
      color="$PURPLE_UNDERLINE"
    fi
    ;;
  6)
    color="$CYAN"

    if [ "$style" -eq 1 ]; then
      color="$CYAN_BOLD"
    fi

    if [ "$style" -eq 2 ]; then
      color="$CYAN_UNDERLINE"
    fi
    ;;
  *)
    color="$BLACK"

    if [ "$style" -eq 1 ]; then
      color="$BLACK_BOLD"
    fi

    if [ "$style" -eq 2 ]; then
      color="$BLACK_UNDERLINE"
    fi
  esac

  print "${color}${1-}${RESET_COLOR}"
}

# init
setup_colors
