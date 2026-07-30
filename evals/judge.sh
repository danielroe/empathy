#!/usr/bin/env bash
# Blind A/B judgement of baseline vs skill outputs, one scenario at a time.
# Randomises which response is A and which is B so the judge can't pattern-match.
set -euo pipefail

cd "$(dirname "$0")"
model_args=()
[ -n "${JUDGE_MODEL:-}" ] && model_args=(--model "$JUDGE_MODEL")
[ -n "${JUDGE_PROVIDER:-}" ] && model_args+=(--provider "$JUDGE_PROVIDER")

VARIANT="${VARIANT:-skill}" # skill or forced
RESULTS="${RESULTS:-results}"
declare -i wins_base=0 wins_var=0 ties=0

for f in scenarios/${1:-}*.txt; do
  name="$(basename "$f" .txt)"
  for base in "$RESULTS"/$name.baseline.md "$RESULTS"/$name.baseline.[0-9]*.md; do
    [ -f "$base" ] || continue
    skill="${base/baseline/$VARIANT}"
    [ -f "$skill" ] || { echo "skip $name (missing $skill)"; continue; }

    if [ $((RANDOM % 2)) -eq 0 ]; then a="$base"; b="$skill"; key="A=baseline B=$VARIANT"
    else a="$skill"; b="$base"; key="A=$VARIANT B=baseline"; fi

    echo "===== $(basename "$base" .md) vs $VARIANT ($key)"
    verdict="$(pi -p --no-session --no-extensions --no-context-files --no-skills --no-tools \
      ${model_args[@]+"${model_args[@]}"} \
      "$(printf '%s\n\n## Scenario given to the agent\n\n%s\n\n## Response A\n\n%s\n\n## Response B\n\n%s\n' \
        "$(cat judge-rubric.txt)" "$(cat "$f")" "$(cat "$a")" "$(cat "$b")")")"
    echo "$verdict"
    echo

    winner="$(echo "$verdict" | grep -io 'Verdict:[* ]*\(Response \)\?\(A\|B\|tie\)' | tail -1 | grep -io 'A$\|B$\|tie')"
    case "$winner" in
      tie|Tie|TIE) ties+=1 ;;
      A|a) if [ "$a" = "$base" ]; then wins_base+=1; else wins_var+=1; fi ;;
      B|b) if [ "$b" = "$base" ]; then wins_base+=1; else wins_var+=1; fi ;;
    esac
  done
done

echo "===== Tally: baseline $wins_base, $VARIANT $wins_var, ties $ties"
