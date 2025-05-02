#!/usr/bin/env bash
# [[ -f ./.heliosRepos ]] && {
#     echo "Helios repos already fetched.  To re-fetch, delete ./.heliosRepos before running this script." >&2
#     exit 0
# }
source ./functions.sh

read -p"Create and edit .fork-config file [Y/n]? " -e  CREATE_CONFIG
{
    [[ "y" == "$CREATE_CONFIG" ]] || 
    [[ "Y" == "$CREATE_CONFIG" ]] || 
    [[ "" == "$CREATE_CONFIG" ]] 
} && {
    echo "Creating .fork-config file"
    [[ -f .fork-config ]] && {
        echo "File .fork-config already exists."
    } || { 
        echo cp .fork-config.example .fork-config
        cp .fork-config.example .fork-config
        echo 
    }
    echo "Next: Edit the .fork-config file"
    echo
    echo "If you want to use your own forks of Helios repos, now is a good time"
    echo "  ... to arrange them.  The .fork-config file is where you can specify a repo prefix"
    echo "  ... and set up other details about operating on your forked repos."
    read -p "Editor: " -e -i"${EDITOR:-nano}" EDIT_WITH
    $EDIT_WITH .fork-config
}
[[ -f ./.fork-config ]] && source ./.fork-config

cloneIfNeeded() {
    if [[ "workspace" == "${REPO}" ]] ; then
        return
    fi
    if [[ "cli" == "${REPO}" ]] ; then
        return
    fi
    [[ -d $REPO/.git ]] && {
        echo "$REPO already cloned"
    } || {
        customOrigin=""
        [[ -z "$UPSTREAM_REMOTE_NAME" ]] || {
            customOrigin="--origin $UPSTREAM_REMOTE_NAME"
            echo " -- using $customOrigin"
        }

        # check out using the upstream repo name
        git clone https://github.com/HeliosLang/$REPO $customOrigin --branch main
        [[ -z $UPSTREAM_BRANCH_NAME ]] || {
            cd $REPO
            echo "Renaming main branch to $UPSTREAM_BRANCH_NAME"
            git branch -m main "$UPSTREAM_BRANCH_NAME"
            cd -
        }
        [[ -z $GIT_DEFAULT_REMOTE ]] || {
            # When this setting is enabled, the git 'checkout.defaultRemote' option is set in each repo,
            cd $REPO
            git config checkout.defaultRemote $GIT_DEFAULT_REMOTE
            cd -
        }
    } | labeledOutput $LABEL
}
eachRepo parallel buffered nocd "cloning repos" cloneIfNeeded 
echo
echo "All repos fetched and updated."
echo


read -p"Find forks for cloned repos [Y/n]? " -e FIND_FORKS
{
    [[ "y" == "$FIND_FORKS" ]] || 
    [[ "Y" == "$FIND_FORKS" ]] || 
    [[ "" == "$FIND_FORKS" ]] 
} && ./forked-repos

echo "Next, install dependencies (Ctrl-C to cancel) for all repos"
echo
read -p"Next: $ " -e -i"pnpm install" COMMAND_IGNORED

pnpm install

echo "Next, build all packages (Ctrl-C to cancel)"
echo
read -p"Next: $ " -e -i"pnpm build:all" COMMAND_IGNORED

pnpm build:all

echo
