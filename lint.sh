#!/usr/bin/env bash

# trace ERR through pipes
set -o pipefail

# trace ERR through 'time command' and other functions
set -o errtrace

# set -u : exit the script if you try to use an uninitialised variable
set -o nounset

# Disable filename expansion (globbing).
set -f

ST_OK=0
ST_ERR=1
ST_HLP=2

PURPLE="\033[0;35m"
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

PHP_MAJOR="$(php -v | head -n 1 | awk '{print $2}' | cut -d '.' -f 1,2)"
PHP_FULL_VERSION=$(php -r 'echo phpversion();')

printf "${GREEN}PHP Simple Lint${NC}\n"

print_help() {
    printf "\n${YELLOW}Usage:${NC} $0 [command]\n"
    printf "\n  -H | --help                     ${PURPLE}Show this help message.${NC}"
    printf "\n  -L | --lint                     ${PURPLE}Recursive PHP syntax check (lint).${NC}"
    printf "\n\n"
}

start_lint() {
    if [ $# -lt 2 ]; then
        printf "\n${YELLOW}Using syntax checker:${NC}\n"
        printf "\n        $0 --lint ${PURPLE}./relative/path/to/the/files${NC}"
        printf "\n        $0 --lint ${PURPLE}/absolute/path/to/the/files${NC}"
        printf "\n\n"

        exit ${ST_HLP}
    fi

    IGNOREPATHS=""
    if [[ $# -ge 4 && $3 == --ignore ]]; then
        for path in $(echo "${4}" | sed "s/;/ /g"); do
            IGNOREPATHS="${IGNOREPATHS} ! -path ${path}"
        done
    fi

    declare PATH_TO_SCAN=$2
    declare ERROR=0

    if [ ! -d ${PATH_TO_SCAN} ] && [ ! -f ${PATH_TO_SCAN} ]; then
        printf "\nInvalid directory or file: ${PATH_TO_SCAN}"
        printf "\n\n"

        exit ${ST_ERR}
    fi

    printf "\nPHP version:  ${YELLOW}${PHP_MAJOR}${NC} (${PHP_FULL_VERSION})"
    printf "\nPath to scan: ${YELLOW}${PATH_TO_SCAN}${NC}"
    printf "\n\n"

    FILE_COUNTER=0
    SUCCESS_COUNTER=0
    ERROR_COUNTER=0

    for file in $(find ${PATH_TO_SCAN} -type f -name "*.php"${IGNOREPATHS}); do
        RESULTS=$(php -l ${file})

        FILE_COUNTER=$((FILE_COUNTER+1))

        if [ "$RESULTS" != "No syntax errors detected in $file" ]; then
            ERROR_COUNTER=$((ERROR_COUNTER+1))
            ERROR=1
        else
            SUCCESS_COUNTER=$((SUCCESS_COUNTER+1))
        fi
    done

    printf "\ncheck has finished\n"
    printf " - ${YELLOW}${FILE_COUNTER}${NC} files checked\n"
    printf " - ${GREEN}${SUCCESS_COUNTER}${NC} files without error\n"
    printf " - ${RED}${ERROR_COUNTER}${NC} files with error\n"

    if [ "${ERROR}" = 1 ] ; then
        exit ${ST_ERR}
    else
        exit ${ST_OK}
    fi

    printf "\n"
}

[[ $# == 0 || $1 == --help ]] && print_help && exit ${ST_HLP}

while test -n "$1"; do
    case $1 in
        --help|-H)
            print_help
            exit ${ST_HLP}
            ;;
        --lint|-L)
            start_lint ${@}
            exit ${ST_OK}
            ;;
        *)
            print_help
            exit ${ST_HLP}
            ;;
    esac
done
