#!/bin/bash

# template for Bourne shell
# which is default shell for CentOS
# the purpose of this template is for scripts to be used in CentOS container

set -euo pipefail


SCRIPT_DIR="$(cd "$(dirname "${0}")" && pwd -P)"

. "$SCRIPT_DIR"/functions.sh

# define constants
SITE_USER=www-data

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
  --site-user   (default: $SITE_USER) ownership for extracted files

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
  site_user="$SITE_USER"

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
        site_user="${2-}"
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
  archive_dir=''

  # parse args
  for arg in "${args[@]}"; do
    if [[ -n "$arg" ]]; then
      ((args_count += 1))

      # define positional arguments here

      if ((args_count == 1)); then
        archive="$arg"
      fi
      if ((args_count == 2)); then
        archive_dir="$arg"
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

  if [[ ! -d "$archive_dir" ]]; then
    mkdir "$archive_dir"
    chown "$site_user":"$site_user" "$archive_dir"
  else
    if [[ "$archive_dir" = '/' ]]; then
      error "very very dangerous action to delete $archive_dir"
    fi

    sudo -u "$site_user" rm -r "$archive_dir"/*
  fi

  sudo -u "$site_user" \
       tar -xj -f "$archive" -C "$archive_dir" .
}

# run application
function run() {
  parse_params "$@"

  deploy

  quit "$archive has been extracted to $archive_dir."
}

run "$@"
