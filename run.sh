#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

exec "${TPT_BENCH_EXECUTABLE-powder}" disable-network ddir:"$(dirname "$0")"
