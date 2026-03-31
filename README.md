# SisyClaude — Multi-Agent Orchestration for Claude Code

A port of [oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent)'s Greek mythology-themed agent system, brought back to Claude Code.

## Background

This project exists because of work that happened *outside* the Anthropic ecosystem — and the story is worth telling.

In early 2026, [oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent) (originally "oh-my-opencode") by [@code-yeongyu](https://github.com/code-yeongyu) introduced a multi-agent orchestration layer for [OpenCode](https://github.com/AnomalyInnovations/opencode) — a model-agnostic open-source coding agent. The system used Greek mythology-themed agents (Prometheus for planning, Hephaestus for deep implementation, Oracle for architecture decisions, etc.) to route tasks to the right specialist. It grew to 43k+ GitHub stars and became one of the most popular plugins in the OpenCode ecosystem.

Around the same time, Anthropic moved to block third-party tools from using Claude subscription credentials via OAuth, citing terms-of-service violations around identity spoofing and token routing. This action — which broke OpenCode, Cline, RooCode, and others overnight — was [partly attributed](https://github.com/code-yeongyu/oh-my-openagent) to oh-my-openagent's success. The dispute escalated through formal legal demands, and by March 2026 OpenCode had removed all Anthropic integration entirely.

The oh-my-openagent community built something genuinely innovative during and despite that conflict. Their multi-agent architecture — the idea that a coding assistant should *delegate* rather than do everything in one context window — proved itself across thousands of real-world projects.

## What This Port Is

SisyClaude takes the agent architecture and design philosophy pioneered by oh-my-openagent and adapts it for Claude Code's native sub-agent system. Instead of TypeScript orchestration running outside Claude, the agents are defined as markdown agent definitions that Claude Code loads natively.

The name "SisyClaude" is intentional — this is a reduced, Claude-specific adaptation, not a replacement for the original. Think of it as a tribute, not a competitor.

**What works well:**
- Agent specialization (planner, executor, researcher, reviewer, etc.)
- Parallel delegation for independent tasks
- Structured verification workflows
- The core insight: an orchestrator that delegates beats a single agent doing everything

**What oh-my-openagent does better:**
- Model routing across 75+ providers (SisyClaude is Claude-only)
- Dynamic cost optimization by routing cheap tasks to cheaper models across providers
- Deeper integration with OpenCode's plugin ecosystem
- The full TypeScript orchestration layer with programmatic control flow
- Active community development with faster iteration cycles

If you want the full experience with provider flexibility, go use [oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent). This port is for people who prefer (or need) to stay within Claude Code and want better orchestration than the vanilla experience.

## Agents

| Agent | Role | Model | Invocation |
|---|---|---|---|
| **Sisyphus** | Main orchestrator — classifies intent, delegates, verifies | Opus | `@sisyphus` |
| **Atlas** | Plan executor — delegates ALL implementation, never codes | Opus | `@atlas` |
| **Hephaestus** | Autonomous deep worker — never asks, just completes | Opus | `@hephaestus` |
| **Prometheus** | Strategic planner — interviews, researches, writes plans | Opus | `@prometheus` |
| **Oracle** | Architecture consultant — read-only, effort-tagged advice | Opus | `@oracle` |
| **Momus** | Plan reviewer — approval-biased, max 3 issues per rejection | Sonnet | `@momus` |
| **Metis** | Pre-planning analyst — catches hidden requirements, AI slop | Opus | `@metis` |
| **Explore** | Fast codebase search — structured results, parallel execution | Haiku | `@explore` |
| **Librarian** | OSS docs researcher — evidence-based with GitHub permalinks | Sonnet | `@librarian` |

## Installation

### As a Plugin

```bash
/plugin marketplace add Whiskey-Tango-Foxtrot-GmbH/sisyclaude
/plugin install sisyclaude@sisyclaude
```

### Activate

```bash
/sisyclaude:activate
```

## Attribution & License

The agent architecture, naming conventions, and design philosophy in this project are ported from [oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent) by [@code-yeongyu](https://github.com/code-yeongyu). Their work pioneered the multi-agent orchestration pattern for AI coding assistants, and this port would not exist without it.

This project is licensed under the [Sustainable Use License v1.0](LICENSE), matching oh-my-openagent's original license. See the LICENSE file for full terms.

This port runs entirely within Claude Code's official CLI and does not circumvent any access controls, subscription boundaries, or terms of service.
