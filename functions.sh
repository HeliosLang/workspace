
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

cleanup() {
    # echo "Cleaning up... "
    # cat $TMPD/* 
    rm -rf $TMPD
}

TMPD=""
mkTempDir() {
    [[ -z "$TMPD" ]] && {
        # echo "  --- creating temp dir"
        TMPD=$(mktemp -d /tmp/.tmp-HeliosLang.XXXXXX)
        trap "cleanup" EXIT
    }
}

IS_TTY=""
[[ -t 0 ]] && IS_TTY=1
optionalPager() {
    [[ $IS_TTY ]] && {
        LESS="${LESS:-} -F --raw-control-chars --no-init" ${PAGER:-less}
    }
    [[ $IS_TTY ]] || {
        echo "stdout is not a terminal; not using pager" >&2
        cat
    }
}

labeledOutput() {
    LABEL=$1
    EXTRA=${2:-}
    while read output ; do {
        printf  "%-18s | ${EXTRA} %s\n" "$LABEL" "$output" 
    } done 
}

labeledErrors() {
    LABEL=$1
    while read output ; do {
        printf  "${YELLOW}%-15sERR | %s ${NC}\n" "$LABEL" "$output" 
    } done 
}

eachRepoUsage() {
    {
        err=$1    
        [[ -z "$err" ]] || {
            echo "Error: eachRepo(): $err"
            echo
        }
        echo "  Usage: eachRepo [parallel [buffered]] \"‹activity description›\" \"callbackFuncName\" [...repos]"
        echo
        echo "    Your named callback function will be called for each repo"
        echo "     ... with \`pwd\` set to the repo dir"
        echo "     ... and shell variables \$REPO, \$DIR, \$LABEL available"
        echo
        echo "    The function returns when all repos are done processing through your callback."
        echo 
        echo "    If 'parallel' is specified as the first arg, repo tasks are run in parallel. "
        echo
        echo "    With 'parallel buffered', each result is collected, & emitted only as it finishes."
        echo
        echo "    With a list of repos, only those repos are processed.  Otherwise, all Helios repos are processed."
        echo
        echo aborted
    } >&2
    exit 42
}

REPOS=""
fetchRepoList() {
    [[ -z "$REPOS" ]] && {
        echo -n "  -- fetching Helios repo list ... "
        REPOS=$(
        	curl --silent https://github.com/orgs/HeliosLang/repositories.json | 
                jq -r '.payload.repositories[].name' |
               # grep -ev "^cli$" |
                sort
        )
        OK=""
        if [[ $? -ne 0 ]] ; then {
            echo "failed!"
            echo
            echo "Error: failed fetching Helios repo list ... are you online?"
        } else {
            OK=1
            echo ok
        } ; fi
       [[ -z "$OK" ]] && exit 42
    } >&2
}

eachRepo() {
    parallel=""
    buffered=""
    [[ "$1" == "parallel" ]] && {
        parallel="$1"
        shift
        [[ "$1" == "buffered" ]] && {
            buffered="$1"
            mkTempDir
            shift
        }
    }
    [[ "$1" == "buffered" ]] && {
        eachRepoUsage "'buffered' option invalid without 'parallel' specified first"
    }

    activity=$1
    # [[ $# -gt 2 ]] && eachRepoUsage "extra args ($*)"
    [[ -z "$2" ]] && eachRepoUsage "missing callbackFunctionName ($*)" 
    shift
    func=$1
    [[ -z $(type -t "$func") ]] && eachRepoUsage "callback function not found:  '$func'" 
    shift

    if [[ $# -gt 0 ]] ; then {
        ITERATE_REPOS=$*
    } else {
        fetchRepoList
        ITERATE_REPOS=$REPOS
    } ; fi
    echo "  -- $activity ..." >&2
    echo >&2

    # set -x
    for REPO in $ITERATE_REPOS ; do {
        DIR=$REPO
        LABEL=$REPO
        if [[ "workspace" == "${REPO}" ]] ; then
            DIR="."
            LABEL="workspace:./"
        fi
        TEMP=""
        [[ -z "$buffered" ]] || {
            TEMP=$(mktemp $TMPD/${REPO}.XXXXXX)
            # echo mkTemp in $TMPD: $TEMP
        }

        [[ $parallel ]] && {
            [[ $buffered ]] && {
                # background, buffered
                { 
                    pushd $DIR >/dev/null
                    $func > $TEMP 2> >(labeledErrors $LABEL) 
                    cat $TEMP
                    popd > /dev/null
                } &
            }
            [[ $buffered ]] || {
                # background, unbuffered
                {
                    pushd $DIR >/dev/null
                    $func 2> >(labeledErrors $LABEL) 
                    popd > /dev/null
                } &
            }
        }
        [[ -z $parallel ]] && {
            # foreground; buffering is senseless
            pushd $DIR >/dev/null
            $func 2> >(labeledErrors $LABEL) 
            popd > /dev/null
        }
        # [[ "compiler" == "${REPO}" ]] && {
        #     break
        # }
    } done
    [[ -z parallel ]] || {
        wait
    }
    echo >&2
}

