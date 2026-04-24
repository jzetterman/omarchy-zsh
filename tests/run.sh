#!/bin/bash
# Run all scenarios against one or more distro images.
#
# Usage:
#   ./tests/run.sh                      # all distros
#   ./tests/run.sh arch                 # single distro
#   ./tests/run.sh arch ubuntu          # multiple distros
#   ./tests/run.sh -s 01_fresh_install.sh arch
#
# Environment:
#   CONTAINER_CMD   override container tool (default: podman, falling back to docker)
set -u

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$TESTS_DIR")"

scenario_filter=""
distros=()

while [ $# -gt 0 ]; do
  case "$1" in
    -s|--scenario) scenario_filter="$2"; shift 2 ;;
    -h|--help) sed -n '3,14p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*) echo "Unknown flag: $1" >&2; exit 2 ;;
    *) distros+=("$1"); shift ;;
  esac
done

[ "${#distros[@]}" -eq 0 ] && distros=(arch ubuntu fedora)

CONTAINER_CMD="${CONTAINER_CMD:-$(command -v podman 2>/dev/null || command -v docker 2>/dev/null || true)}"
if [ -z "$CONTAINER_CMD" ]; then
  echo "Error: need podman or docker on PATH (or set CONTAINER_CMD)" >&2
  exit 2
fi

overall_fail=0

for distro in "${distros[@]}"; do
  dockerfile="$TESTS_DIR/docker/Dockerfile.$distro"
  if [ ! -f "$dockerfile" ]; then
    echo "Unknown distro: $distro (no $dockerfile)" >&2
    overall_fail=1
    continue
  fi
  image="legendary-zsh-test:$distro"

  echo ""
  echo "============================================================"
  echo "  Building image: $image"
  echo "============================================================"
  if ! "$CONTAINER_CMD" build -t "$image" -f "$dockerfile" "$TESTS_DIR"; then
    echo "Build failed for $distro"
    overall_fail=1
    continue
  fi

  for scenario in "$TESTS_DIR"/scenarios/*.sh; do
    name="$(basename "$scenario")"
    [ "$name" = "_lib.sh" ] && continue
    [ -n "$scenario_filter" ] && [ "$name" != "$scenario_filter" ] && continue

    echo ""
    echo "--- [$distro] $name ---"
    if "$CONTAINER_CMD" run --rm \
        -v "$REPO_DIR:/repo:ro" \
        "$image" \
        bash "/repo/tests/scenarios/$name"; then
      echo "[$distro] $name: PASS"
    else
      echo "[$distro] $name: FAIL"
      overall_fail=1
    fi
  done
done

echo ""
if [ "$overall_fail" -eq 0 ]; then
  echo "All tests passed."
else
  echo "Some tests failed."
fi
exit "$overall_fail"
