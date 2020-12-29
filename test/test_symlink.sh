#!/usr/bin/env bash

set -uo pipefail;

####################################
# Ensure we can execute standalone #
####################################

function early_death() {
  echo "[FATAL] ${0}: ${1}" >&2;
  exit 1;
};

if [ -z "${TGENV_ROOT:-""}" ]; then
  # http://stackoverflow.com/questions/1055671/how-can-i-get-the-behavior-of-gnus-readlink-f-on-a-mac
  readlink_f() {
    local target_file="${1}";
    local file_name;

    while [ "${target_file}" != "" ]; do
      cd "$(dirname ${target_file})" || early_death "Failed to 'cd \$(dirname ${target_file})' while trying to determine TGENV_ROOT";
      file_name="$(basename "${target_file}")" || early_death "Failed to 'basename \"${target_file}\"' while trying to determine TGENV_ROOT";
      target_file="$(readlink "${file_name}")";
    done;

    echo "$(pwd -P)/${file_name}";
  };

  TGENV_ROOT="$(cd "$(dirname "$(readlink_f "${0}")")/.." && pwd)";
  [ -n ${TGENV_ROOT} ] || early_death "Failed to 'cd \"\$(dirname \"\$(readlink_f \"${0}\")\")/..\" && pwd' while trying to determine TGENV_ROOT";
else
  TGENV_ROOT="${TGENV_ROOT%/}";
fi;
export TGENV_ROOT;

if [ -n "${TGENV_HELPERS:-""}" ]; then
  log 'debug' 'TGENV_HELPERS is set, not sourcing helpers again';
else
  [ "${TGENV_DEBUG:-0}" -gt 0 ] && echo "[DEBUG] Sourcing helpers from ${TGENV_ROOT}/lib/helpers.sh";
  if source "${TGENV_ROOT}/lib/helpers.sh"; then
    log 'debug' 'Helpers sourced successfully';
  else
    early_death "Failed to source helpers from ${TGENV_ROOT}/lib/helpers.sh";
  fi;
fi;

#####################
# Begin Script Body #
#####################

declare -a errors=();

log 'info' '### Testing symlink functionality';

TGENV_BIN_DIR='/tmp/tgenv-test';
log 'info' "## Creating/clearing ${TGENV_BIN_DIR}"
rm -rf "${TGENV_BIN_DIR}" && mkdir "${TGENV_BIN_DIR}";
log 'info' "## Symlinking ${PWD}/bin/* into ${TGENV_BIN_DIR}";
ln -s "${PWD}"/bin/* "${TGENV_BIN_DIR}";

cleanup || log 'error' 'Cleanup failed?!';

log 'info' '## Installing 0.26.7';
${TGENV_BIN_DIR}/tgenv install 0.26.7 || error_and_proceed 'Install failed';

log 'info' '## Using 0.26.7';
${TGENV_BIN_DIR}/tgenv use 0.26.7 || error_and_proceed 'Use failed';

log 'info' '## Check-Version for 0.26.7';
check_active_version 0.26.7 || error_and_proceed 'Version check failed';

if [ "${#errors[@]}" -gt 0 ]; then
  log 'warn' '===== The following symlink tests failed =====';
  for error in "${errors[@]}"; do
    log 'warn' "\t${error}";
  done;
  log 'error' 'Symlink test failure(s)';
  exit 1;
else
  log 'info' 'All symlink tests passed.';
fi;

exit 0;
