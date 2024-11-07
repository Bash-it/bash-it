#!/bin/bash

CONTAINER_ENGINE=${CONTAINER_ENGINE:-docker}

${CONTAINER_ENGINE} build --file ./testing.Dockerfile --tag test .
${CONTAINER_ENGINE} run --rm --interactive --tty --volume $(pwd -P):$(pwd) --workdir $(pwd) test bash ./lint_clean_files.sh
