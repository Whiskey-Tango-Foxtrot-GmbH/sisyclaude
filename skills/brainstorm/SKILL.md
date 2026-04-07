---
name: brainstorm
description: Challenge your design ideas before committing to a plan. Spawns the Socrates agent for adversarial-constructive dialogue that stress-tests assumptions, surfaces trade-offs, and sharpens your thinking.
user-invocable: true
allowed-tools: Agent
argument-hint: <idea or feature to explore>
---

Spawn the Socrates agent to challenge and refine this idea through interactive dialogue.

**If the user provided an argument**, pass it as the starting topic:

```
Agent(subagent_type="socrates", prompt="The user wants to brainstorm and stress-test this idea: $ARGUMENTS — Start by researching the codebase for relevant context, then begin challenging their design thinking.")
```

**If no argument was provided**, start with an open prompt:

```
Agent(subagent_type="socrates", prompt="The user invoked /brainstorm without a specific topic. Ask them what idea or design they'd like to stress-test.")
```
