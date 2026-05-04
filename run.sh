#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# export SDL_VIDEODRIVER=dummy
exec "${TPT_BENCH_EXECUTABLE-powder}" disable-network ddir:"$(dirname "$0")"
