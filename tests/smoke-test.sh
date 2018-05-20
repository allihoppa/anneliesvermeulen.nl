#!/usr/bin/env bash

set -e

assert_page_contains() {
    local test_url="$1";
    local expected_content="$2"
    local test_output

    declare -i timeout=5

    while ! test_output=`docker run --rm --network=container:anneliesvermeulen-nl-web-ci byrnedo/alpine-curl --silent --fail ${test_url}`;
        do sleep 0.1;
    done

    if [[ -z $(echo "${test_output}" | grep "${expected_content}") ]]; then
        echo "Failed asserting that ${test_url} contains ${expected_content}" && exit 1;
    fi

}

assert_page_contains "http://web" "Schrijven en corrigeren"
