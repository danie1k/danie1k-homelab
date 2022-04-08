#!/bin/sh
set -e

if [ -f /.dockerenv ]; then
  readonly IS_DOCKER=1
  readonly LOOKUP_PATH='{{ secrets.storage.in_container }}'
else
  readonly IS_DOCKER=0
  readonly LOOKUP_PATH='{{ secrets.storage.on_host }}'
fi

for file_path in $(find "${LOOKUP_PATH}" -mindepth 1 -maxdepth 1 -type f ! -size 0 | grep -E "^${LOOKUP_PATH}/[A-Z_][a-zA-Z0-9_]+$")
do
  env_name="$(basename "${file_path}")"
  env_value="$(cat "${file_path}" | awk '{$1=$1;print}')"
  [ $IS_DOCKER -eq 1 ] && echo "[Loading Secret] ${env_name}" >&2
  export ${env_name}="$(echo "${env_value}" | sed 's/^[ \t]*//;s/[ \t]*$//')"
done

exec "${@}"
