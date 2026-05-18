# cain-skills

Workflow-first skills for software development agents.

Traditional Chinese version: [README.zh-TW.md](README.zh-TW.md)

This repository is built for developers who want more than fast code generation. It provides a set of skills that push an agent through the real work of software delivery: clarifying requirements, planning execution, isolating tasks, reviewing outputs, and verifying that the system actually works.

These skills are designed to make an agent more reliable under real project pressure, not just more impressive in a single prompt.

## Why This Exists

Most development agents can write code quickly.

That is not the hard part.

The hard part is turning a vague idea into software that is actually scoped, reviewed, testable, and ready to ship. In practice, projects usually break down because the workflow is weak, not because the model cannot produce code.

Common failure modes:

- Coding starts before the requirements are stable
- One large prompt turns into a messy, hard-to-review change
- Multiple tasks interfere with each other
- "Done" means code was written, not that the system was verified
- Testing is partial, late, or skipped entirely
- The final result looks plausible in chat but fails in the real environment

cain-skills is built to close that gap.

## What Makes It Different

Instead of treating software development like one long coding conversation, cain-skills treats it as a delivery workflow with explicit phases and evidence.

| Area                | Typical development agent           | cain-skills                                                 |
| ------------------- | ----------------------------------- | ----------------------------------------------------------- |
| Primary job         | Generate code quickly               | Orchestrate delivery from idea to verified output           |
| Starting point      | Jump into implementation            | Clarify requirements and acceptance criteria first          |
| Task shape          | Large prompts with fuzzy boundaries | Small, explicit, independently verifiable tasks             |
| Parallel work       | Shared context, shared risk         | Isolated task ownership and controlled handoffs             |
| Review model        | Optional or ad-hoc                  | Structured review gates for scope and quality               |
| Verification        | Often limited to a quick test run   | Evidence-based checks across task, integration, and runtime |
| Completion standard | "Looks done"                        | Proved by artifacts, tests, review, and verification        |

## Problems It Solves

cain-skills is for developers who have seen these problems before:

- "I have an idea, but the agent starts coding before the problem is fully defined."
- "The result kind of works, but I cannot tell whether it is actually complete."
- "A single large prompt created too much code at once and now the change is hard to inspect."
- "Parallel work keeps stepping on itself."
- "The agent says the task is done, but the app still fails when it actually runs."
- "I need inspectable outputs and checkpoints, not just confident chat responses."

## Core Workflow

The repository is organized around a practical software delivery flow:

1. Capture and refine requirements
2. Turn requirements into a technical plan and task graph
3. Create execution records and environment readiness gates
4. Dispatch focused implementation agents with isolated task scope
5. Review each task for spec compliance and code quality
6. Verify integration across tasks
7. Verify runtime or deployment behavior before claiming completion

This is meant to reduce chaos, not add ceremony for its own sake.

## Included Skills

Key skills in this repository include:

- `requirements-interviewer`: turns vague requests into explicit requirements and acceptance criteria
- `dev-task-planner`: converts requirements into a spec, task breakdown, and execution-ready work items
- `dev-manager`: acts as a non-coding orchestrator across the full delivery lifecycle
- `senior-engineer`: executes one focused implementation task with test-first discipline
- `deployment-verifier`: checks whether the finished system actually starts and behaves correctly

Together, these skills aim to make agentic development more controlled, auditable, and useful in real projects.

## Who It Is For

cain-skills is especially useful for:

- Solo developers who want stronger engineering discipline without adding heavy process
- Builders starting from vague product ideas and wanting a more reliable path to delivery
- Developers experimenting with multi-agent workflows and task isolation
- Small teams that want clearer checkpoints, cleaner task boundaries, and better verification

## Design Principles

- Workflow over improvisation
- Evidence over confidence
- Small tasks over oversized prompts
- Isolation over context sprawl
- Delivery over demos

## Getting Started

This repository is a skill library, not a standalone app.

To use it effectively:

1. Start from the skills in the `skills/` directory
2. Use `dev-manager` when you want end-to-end orchestration
3. Use `senior-engineer` as a task executor, not as the project-level planner
4. Adapt the skills to the agent harness and workflow conventions you use

If your goal is not just to generate code, but to deliver software with clearer boundaries and stronger verification, this repository is built for that job.
