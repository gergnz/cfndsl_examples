#!/usr/bin/env bash 
set -x
set -o nounset
set -o errexit

for dir in $(ls -1 -d */ | sed 's/.$//'); do
  if [[ $# -gt 0 ]]; then
    if [[ "x$1" != "x$dir" ]]; then
      echo "skipping tests for ${dir}"
      continue
    fi
  fi
  echo "running tests for ${dir}"
  for item in $(cd ${dir}; ls -1 *.rb | awk -F. '{print $1}'); do
    echo "running test ${item}"
    rm -f /tmp/test.json
    cfndsl -m ${dir}/${item}.rb -o /tmp/test.json
    jsondiff ${dir}/${item}.template /tmp/test.json
    #aws --region ap-southeast-2 cloudformation validate-template --template-body file:///tmp/test.json
  done
done
