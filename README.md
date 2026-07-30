# empathy

[![skills.sh][skills-src]][skills-href]

This is a skill that helps AI agents talk to humans.

I'm an open source maintainer, and every day, I read issues, PRs and comments written by agents. And that is not unique to the repositories I maintain. Unfortunately, this is taking a toll on the mental health of maintainers across the whole ecosystem, for a number of reasons.

Personally, I think agents should not get _between_ people. Human-to-human interaction is precious, and what makes open source a delight. [My rules for using AI in open source](https://roe.dev/blog/using-ai-in-open-source) specifically exclude LLM-written comments and PR descriptions, for that reason.

But I realise not everyone agrees with me.

So this skill exists as an experiment. I want to see if it's possible to tackle the _way_ that agents tend to relate to open source maintainers. Before an agent posts anything a human will read, it should ask:

- How will this person feel when they read this?
- Would they want to receive it at all?
- Do they know they're talking to an agent?
- Am I giving them something, or just taking their attention?

Plus some instructions I consider non-negotiable:

- **Never pretend to be human.**
- **Use people's pronouns.**
- **Be brief.**
- **Sometimes the kindest thing is not to post.**

> [!NOTE]
> I used an LLM to generate the text of the skill.

## Install

This follows the [Agent Skills](https://agentskills.io) standard, so it works with any compatible harness.

With the [skills CLI](https://github.com/vercel-labs/skills):

```bash
npx skills add danielroe/empathy
```

Or clone it into your harness's skills directory:

```bash
# Claude Code
git clone https://github.com/danielroe/empathy ~/.claude/skills/empathy

# pi
git clone https://github.com/danielroe/empathy ~/.pi/agent/skills/empathy

# OpenClaw
git clone https://github.com/danielroe/empathy ~/.openclaw/skills/empathy
```

The skill content lives in [`empathy.md`](./empathy.md); `SKILL.md` is a symlink so the repo installs as a standard skill package.

### Making sure it actually loads

Models [don't reliably read skills](./evals/README.md) before composing text, so the skill's description embeds the minimum rules so they're always in context.

For autonomous agents please consider forcing the full skill:

- say "read the empathy skill before posting anything a human will read" in your dispatch prompt
- or invoke it directly (`/skill:empathy` in pi)
- or append `empathy.md` to the agent's system prompt

If you dispatch agents to interact with projects I maintain, I'd be delighted if you loaded this skill first. And if you have ideas for making agents better guests in open source spaces, I would love to hear them.

Much ❤️

## License

Published under [MIT License](./LICENCE).

<!-- Badges -->

[skills-src]: https://skills.sh/b/danielroe/empathy
[skills-href]: https://skills.sh/danielroe/empathy
