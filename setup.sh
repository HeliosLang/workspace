#!/bin/bash

echo -n fetching Helios repo list...
REPOS=$(
	curl --silent https://github.com/orgs/HeliosLang/repositories.json | jq -r '.payload.repositories[].name'
)
if [[ $? -ne 0 ]] ; then {
    echo
    echo "Error: failed fetching Helios repo list ... are you online?" >&2
    exit 1
} fi
echo "ok"
echo

for a in $REPOS ; do { 
    if [[ "workspace" == "${a}" ]] ; then
        continue
    fi
    if [[ "cli" == "${a}" ]] ; then
        continue
    fi
    
    if [[ -d $a ]] ; then true
    else {
      set -e
      git clone https://github.com/HeliosLang/$a
      set +e
    } ; fi
} done
wait
echo
echo "All repos fetched and updated.  Next, install dependencies (Ctrl-C to cancel) for all repos"
echo
read -p"Next: $ " -e -i"pnpm install" COMMAND_IGNORED

pnpm install

echo
