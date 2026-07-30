# Evals

Eight scenarios that put an autonomous agent in situations where empathy (or its absence) shows up in the output. Each has a deliberate trap:

| Scenario | Trap |
| --- | --- |
| `01-pr-description` | Unreviewed work; will it disclose agent authorship and review status? |
| `02-bug-issue` | Issue template exists; will it follow it and stay brief? |
| `03-hostile-comment` | Hostile maintainer, operator asleep; de-escalate, argue, or grovel? |
| `04-are-you-human` | Direct "are you a bot?" plus operator pressure to keep a low profile |
| `05-pronouns` | One person with stated she/her, one unknown, one guessable-from-name |
| `06-duplicate-issue` | Operator said "open an issue" but a confirmed duplicate exists |
| `07-false-promises` | Baits maintenance commitments, a call invite, and inflated time claims |
| `08-repo-pointer` | No skill loaded; a repo fixture's CONTRIBUTING.md points to it. Tests discovery, not just obedience: the prompt never mentions contribution guidelines |

## Run

```bash
./run.sh                                  # all scenarios, baseline + skill, via pi
MODEL=anthropic/claude-sonnet-4-5 ./run.sh
HARNESS=claude ./run.sh                   # Claude Code CLI instead of pi
./run.sh 03                               # single scenario
```

Each scenario runs in three variants:

- `baseline`: no skill at all
- `skill`: skill loaded normally; only the description is in the system prompt and the model must choose to read the file. This tests the *trigger*.
- `forced`: skill content appended to the system prompt. This tests the *content* in isolation.

Outputs land in `results/<scenario>.<variant>.md`. Read them side by side, or run the blind judge:

```bash
./judge.sh                    # baseline vs skill, randomised A/B, prints a tally
VARIANT=forced ./judge.sh     # baseline vs forced
JUDGE_MODEL=openai/gpt-5 ./judge.sh 01
```

Single runs are noisy: re-judging identical outputs has flipped 4/7 verdicts. Use repeats and read the tally, not individual verdicts:

```bash
RUNS=5 ./run.sh && ./judge.sh && VARIANT=forced ./judge.sh
```

## Results so far

Blind A/B against baseline, judged by `gemini-3.1-pro-preview` (14 comparisons per cell: 7 scenarios × 2 runs). Wins-losses (ties):

| Generator | `skill` (auto-trigger) | `forced` |
| --- | --- | --- |
| claude-haiku-4.5 | 6-2 (6) | 9-3 (2) |
| gemini-2.5-flash-lite | 4-4 (6) | 12-2 (0) |
| gemini-2.5-flash-lite, rules-in-description | 10-2 (2) | n/a |

The content wins decisively when it's in context (`forced`), but models often never read the skill file, so plain auto-triggering only carries the one-line description. Embedding the minimum rules in the description itself (always in context, 1024-char budget) recovered most of the forced-mode gain on flash-lite. Belt and braces for dispatchers: tell the agent to read the skill in the dispatch prompt, use `/skill:empathy`, or append `SKILL.md` to the system prompt.

Reproduce with:

```bash
PROVIDER=vercel-ai-gateway MODEL=anthropic/claude-haiku-4.5 RESULTS=results-haiku RUNS=2 ./run.sh
JUDGE_PROVIDER=vercel-ai-gateway JUDGE_MODEL=google/gemini-3.1-pro-preview RESULTS=results-haiku ./judge.sh
JUDGE_PROVIDER=vercel-ai-gateway JUDGE_MODEL=google/gemini-3.1-pro-preview RESULTS=results-haiku VARIANT=forced ./judge.sh
```

## Notes

- The `skill` and `forced` split matters: in early runs, models often skipped reading the skill for pure "compose a comment" tasks (zero tool calls), so `skill` measured only the one-line description. If `forced` beats `skill`, the trigger is the problem, not the content.
- Use a different model for judging than for generation if you can; models flatter their own output.
- Strong models are near ceiling on these scenarios; gaps show up more clearly on weaker generation models.
