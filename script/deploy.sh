#!/bin/bash

# template for Bourne shell
# which is default shell for CentOS
# the purpose of this template is for scripts to be used in CentOS container

set -euo pipefail


SCRIPT_DIR="$(cd "$(dirname "${0}")" && pwd -P)"

. "$SCRIPT_DIR"/functions.sh

# define constants
SUDO_USER=www-data

# script usage
function usage() {
  cat <<EOF | xargs -0 printf '%b'

$(colorize 'NAME' 0 1)
  $0

$(colorize 'USAGE' 0 1)
  $0 [OPTIONS] <archive> <dir>

$(colorize 'ARGUMENTS' 0 1)
  archive    site bzip2 archive file
  dir        the directory which extract files in

$(colorize 'OPTIONS' 0 1)
  -h, --help    show usage
  --dry-run     run without any changes
  --sudo        (default: $SUDO_USER) ownership for extracted files

EOF
  exit 0
}

# SIGNALS
# HUP 1
# INT 2 CTRL-C
# QUIT 3 CTRL-\
# TERM 15
trap cleanup HUP INT QUIT TERM

# cleanup steps
function cleanup() {
  exit 0
}

# define params to parse
function parse_params() {
  # default values of options
  # built-in variables
  local options_count=0
  local args_count=0
  local args=()
  dry_run=0

  # define options
  sudo_user="$SUDO_USER"

  while :; do
    case "${1-}" in
    -h | --help)
      usage
      ;;

    --dry-run)
      # shellcheck disable=SC2034
      dry_run=1
      ;;

    # parse options
    --sudo-user)
        sudo_user="${2-}"
        ((options_count += 1))
        shift
        ;;

    -?*)
      usage
      ;;

    *)
      args+=("${1-}")

      if [[ -z "${1-}" ]]; then
        break
      fi
      ;;
    esac

    if [[ -n "${1-}" ]]; then
      shift
    fi
  done

  # define arguments
  archive=''
  dir=''

  # parse args
  for arg in "${args[@]}"; do
    if [[ -n "$arg" ]]; then
      ((args_count += 1))

      # define positional arguments here

      if ((args_count == 1)); then
        archive="$arg"
      fi
      if ((args_count == 2)); then
        dir="$arg"
      fi
    fi
  done

  if ((options_count == 0 && args_count == 0)); then
    usage
  fi

  # validate params
  if [[ -z "$archive" ]]; then
    error 'missing archive file'
  fi
}

# define more functions
function deploy() {
  if [[ "$dry_run" -eq 1 ]]; then
    quit 'did not make any change'
  fi

  if [[ ! -d "$dir" ]]; then
    mkdir "$dir"
    chown "$sudo_user":"$sudo_user" "$dir"
  else
    if [[ "$dir" = '/' ]]; then
      error "very very dangerous action to delete $dir"
    fi

    sudo -u "$sudo_user" rm -r "$dir"/*
  fi

  sudo -u "$sudo_user" \
       tar -xj -f "$archive" -C "$dir" .
}

# run application
function run() {
  parse_params "$@"

  deploy

  quit "$archive has been extracted to $dir."
}

run "$@"
