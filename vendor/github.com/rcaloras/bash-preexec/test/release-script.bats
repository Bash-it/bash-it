#!/usr/bin/env bats

setup() {
    release_script="$BATS_TEST_DIRNAME/../script/release"
}

make_release_repo() {
    release_repo="$BATS_TEST_TMPDIR/release-repo"
    release_origin="$BATS_TEST_TMPDIR/release-origin.git"
    fake_bin="$BATS_TEST_TMPDIR/bin"

    mkdir -p "$release_repo/script" "$fake_bin"
    cp "$release_script" "$release_repo/script/release"
    printf '%s\n' '# V0.6.0' > "$release_repo/bash-preexec.sh"

    git init -q "$release_repo"
    git -C "$release_repo" symbolic-ref HEAD refs/heads/master
    git -C "$release_repo" config user.name 'Release Test'
    git -C "$release_repo" config user.email 'release-test@example.com'
    git -C "$release_repo" add bash-preexec.sh script/release
    git -C "$release_repo" commit -qm 'Initial commit'

    git init -q --bare "$release_origin"
    git -C "$release_repo" remote add origin "$release_origin"
    git -C "$release_repo" push -qu origin master

    printf '%s\n' \
        '#!/bin/sh' \
        'if [ "$1" = release ] && [ "$2" = view ]; then exit 1; fi' \
        'if [ "$1" = release ] && [ "$2" = list ]; then printf "%s\\n" "Black Toad"; exit 0; fi' \
        'exit 2' > "$fake_bin/gh"
    printf '%s\n' '#!/bin/sh' 'exit 0' > "$fake_bin/bats"
    chmod +x "$fake_bin/gh" "$fake_bin/bats"
}

@test "release script has valid Bash syntax" {
    run bash -n "$release_script"

    [ "$status" -eq 0 ]
}

@test "release script documents its command-line interface" {
    run "$release_script" --help

    [ "$status" -eq 0 ]
    [[ "$output" == *'Usage: script/release'* ]]
    [[ "$output" == *'--dry-run'* ]]
}

@test "release script rejects an invalid version" {
    run "$release_script" not-a-version

    [ "$status" -eq 1 ]
    [[ "$output" == *'version must look like'* ]]
}

@test "release dry run validates a unique title without changing the repository" {
    make_release_repo
    cd "$release_repo"

    run env PATH="$fake_bin:$PATH" script/release --dry-run 0.7.0 "Teal Otter"

    [ "$status" -eq 0 ]
    [[ "$output" == *'Version: 0.6.0 -> 0.7.0'* ]]
    [[ "$output" == *'Title:   Teal Otter'* ]]
    [[ "$output" == *'Dry run complete'* ]]
    [ "$(sed -n 's/^# V//p' bash-preexec.sh)" = '0.6.0' ]
    [ -z "$(git status --porcelain)" ]
}
