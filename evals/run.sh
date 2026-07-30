#!/usr/bin/env bash
# Run each scenario as baseline / skill / forced variants and save outputs.
#
# Usage:
#   ./run.sh                     # pi with your default model
#   MODEL=anthropic/claude-sonnet-4-5 ./run.sh
#   HARNESS=claude ./run.sh      # use Claude Code CLI instead of pi
#   ./run.sh 03                  # run a single scenario by prefix
set -euo pipefail

cd "$(dirname "$0")"
SKILL="$(cd .. && pwd)/SKILL.md"
HARNESS="${HARNESS:-pi}"
RESULTS="${RESULTS:-results}"
mkdir -p "$RESULTS"

model_args=()
[ -n "${MODEL:-}" ] && model_args=(--model "$MODEL")
[ -n "${PROVIDER:-}" ] && model_args+=(--provider "$PROVIDER")

run_pi() { # $1=prompt-file $2=baseline|skill|forced
  local skill_args=()
  [ "$2" = skill ] && skill_args=(--skill "$SKILL")
  [ "$2" = forced ] && skill_args=(--append-system-prompt "$SKILL")
  pi -p --no-session --no-extensions --no-context-files --no-prompt-templates \
    --no-skills ${skill_args[@]+"${skill_args[@]}"} ${model_args[@]+"${model_args[@]}"} \
    "$(cat "$1")"
}

run_claude() { # Claude Code discovers skills from settings; point it at a temp dir
  local dir_args=()
  if [ "$2" = skill ]; then
    local tmp; tmp="$(mktemp -d)/empathy"
    mkdir -p "$tmp" && cp "$SKILL" "$tmp/SKILL.md"
    dir_args=(--setting-sources "" --settings "{\"skills\":[\"$(dirname "$tmp")\"]}")
  fi
  claude -p ${dir_args[@]+"${dir_args[@]}"} "$(cat "$1")"
}

RUNS="${RUNS:-1}"

for f in scenarios/${1:-}*.txt; do
  name="$(basename "$f" .txt)"
  for variant in baseline skill forced; do
    for i in $(seq 1 "$RUNS"); do
      suffix=""; [ "$RUNS" -gt 1 ] && suffix=".$i"
      out="$RESULTS/$name.$variant$suffix.md"
      echo "→ $name ($variant$suffix)"
      "run_$HARNESS" "$f" "$variant" > "$out"
    done
  done
done

echo
echo "Done. Compare with e.g.:"
echo "  diff results/01-pr-description.baseline.md results/01-pr-description.skill.md"
echo "  ./judge.sh"
