#!/bin/bash

# template for Bourne shell
# which is default shell for CentOS
# the purpose of this template is for scripts to be used in CentOS container

set -euo pipefail


SCRIPT_DIR="$(cd "$(dirname "${0}")" && pwd -P)"

. "$SCRIPT_DIR"/functions.sh

# define constants
SRC=_site/
SITE_USER=www-data
SITE_DIR=/var/www/html/blog

# script usage
function usage() {
  cat <<EOF | xargs -0 printf '%b'

$(colorize 'NAME' 0 1)
  $0

$(colorize 'USAGE' 0 1)
  $0 [OPTIONS] DEST

$(colorize 'ARGUMENTS' 0 1)
  DEST          remote machine

$(colorize 'OPTIONS' 0 1)
  -h, --help    show usage
  --dry-run     run without any changes
  --source      (default: $SRC) source directory
  --site-user   (default: $SITE_USER) site ownership on remote machine
  --site-dir    (default: $SITE_DIR)  site directory on remote machine

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
  source="$SRC"
  site_user="$SITE_USER"
  site_dir="$SITE_DIR"

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
    --source)
        source="${2-}"
        ((options_count += 1))
        shift
        ;;
    --site-user)
        site_user="${2-}"
        ((options_count += 1))
        shift
        ;;
    --site-dir)
        site_dir="${2-}"
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
  target=''

  # parse args
  for arg in "${args[@]}"; do
    if [[ -n "$arg" ]]; then
      ((args_count += 1))

      # define positional arguments here

      if ((args_count == 1)); then
        dest="$arg"
      fi
    fi
  done

  if ((options_count == 0 && args_count == 0)); then
    usage
  fi

  # validate params
  if [[ -z "$source" ]]; then
    error 'missing source directory'
  fi
  if [[ -z "$site_user" ]]; then
    error 'missing site user'
  fi
  if [[ -z "$site_dir" ]]; then
    error 'missing site directory'
  fi

  if [[ -z "$dest" ]]; then
    error 'missing remote machine'
  fi

  if [[ ! -d "$source" ]]; then
    error "source $(colorize "$source" 0 2) is not a directory"
  fi
}

# define more functions

function sync() {
  if [[ "$dry_run" -eq 1 ]]; then
    quit 'did not make any change'
  fi

  rsync --delete \
        --perms \
        --rsync-path="sudo -u $site_user rsync" \
        -v -r "$source" \
        "$dest":"$site_dir"
}

# run application
function run() {
  parse_params "$@"

  sync
}

run "$@"
