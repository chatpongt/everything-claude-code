# The Agent That Remembers Everything

![Header: The Agent That Remembers Everything — Hermes Agent and the Self-Improving Future](./assets/images/hermes-agent/01-header.png)

---

> **This is Part 4 of the Everything Claude Code guide series.** Part 1 is [The Shorthand Guide](./the-shortform-guide.md) (setup and configuration). Part 2 is [The Longform Guide](./the-longform-guide.md) (advanced patterns and workflows). Part 3 is [The OpenClaw Guide](./the-openclaw-guide.md) (security analysis). This guide is about Hermes Agent — what happens when an AI agent is built to learn from itself.

I've been running Hermes Agent for two weeks. This is what I found.

---

## The Problem Every AI User Knows

Here's the frustration that unites every AI power user: your AI assistant is brilliant but amnesiac. Every session starts from zero. You explain your codebase structure, your naming conventions, your deployment pipeline — again. And again. Close the tab, open a new one, and your genius collaborator has forgotten everything you ever taught it.

Claude Code, Codex, Cursor — they're all extraordinary at what they do. But they reset. Every conversation is a blank slate. You're essentially re-onboarding a new hire every single time.

Hermes Agent was built to solve exactly this problem.

---

## What Hermes Agent Actually Is

Hermes Agent is an open-source AI agent from [Nous Research](https://nousresearch.com/), released under the MIT license. It's not a coding copilot tethered to an IDE, and it's not a chatbot wrapper around a single API. It's an autonomous agent that lives on your server, remembers what it learns, and gets more capable the longer it runs.

The headline feature is the **self-improving loop**. Every time Hermes completes a complex task (anything involving 5+ tool calls), it does something no other agent does automatically: it evaluates its own performance, identifies what worked and what didn't, and generates a **Skill Document** — a structured Markdown file capturing the approach, edge cases, and domain knowledge it discovered. Next time it encounters a similar task, it retrieves that skill and executes faster and more reliably.

This isn't memory in the traditional sense. It's procedural learning. The agent doesn't just remember *what* happened — it remembers *how to do things better*.

> **Key stats:** 57.7k GitHub stars. 7.6k forks. 18 active contributors. 209 merged PRs in the v0.8.0 release cycle alone. This is not a hobby project — it's one of the most actively developed open-source AI agents in the ecosystem.

---

## The Architecture

Hermes Agent's design is opinionated and deliberate. Understanding the architecture explains why it behaves differently from other agents.

### The AIAgent Loop

At the core is a synchronous orchestration engine called the **AIAgent Loop**. It handles reasoning, tool execution, skill creation, and self-evaluation in a single, predictable cycle. There's no traditional control plane — the learning loop is a first-class architectural concern, not an afterthought bolted on.

### Three-Layer Memory System

This is where Hermes diverges from every other agent I've tested:

| Layer | What It Stores | How It's Used |
|-------|---------------|---------------|
| **Layer 1 — Frozen System Prompt** | Core identity, base instructions | Injected into every session automatically |
| **Layer 2 — Episodic Memory / Skills** | Skill Documents generated from experience | Retrieved when encountering similar tasks |
| **Layer 3 — Session Search** | Full conversation history | SQLite FTS5 full-text search across all past sessions |

Layer 2 is the magic. When the agent completes a complex task, it generates a Skill Document following the [agentskills.io](https://agentskills.io) standard. These documents are searchable Markdown files that capture not just *what* the agent did, but *why* certain approaches worked and what pitfalls to avoid. Over time, the agent builds a library of its own expertise.

Layer 3 uses SQLite with FTS5 full-text search — no external database server, no cloud dependency. Everything stays local. The agent can recall conversations from weeks or months ago, with LLM-powered summarization to surface the relevant context.

### Storage

Everything runs on SQLite. Portable, zero-dependency, runs anywhere. State management is handled through `hermes_state.py` with no external server required. Your data stays on your machine.

---

## How It Compares

### vs. OpenClaw

Both Hermes and OpenClaw remember things. But the *mechanism* of remembering is fundamentally different.

| Dimension | OpenClaw | Hermes Agent |
|-----------|----------|--------------|
| **Memory storage** | Markdown files on disk | SQLite with FTS5 search + Skill Documents |
| **Skill creation** | Manual — humans write skill "recipes" | Automatic — agent generates skills from experience |
| **Improvement** | Static unless you update manually | Self-improving loop after every complex task |
| **Security model** | Broad attack surface (see [Part 3](./the-openclaw-guide.md)) | Sandboxed execution, SSRF protection, tar traversal prevention |
| **Multi-channel** | Yes (Telegram, Discord, X, WhatsApp, etc.) | Yes (Telegram, Discord, Slack, WhatsApp, Signal, Matrix, Mattermost) |
| **Marketplace** | ClawdHub (unvetted community skills) | No marketplace — skills are self-generated |
| **Setup complexity** | GUI dashboard + CLI | CLI-first |

The critical difference: OpenClaw's skills are *recipes* that humans write. If you want your OpenClaw agent to get better at a task, you write a better skill file. Hermes generates its own skills autonomously. You use the agent, and it gets better on its own.

The security difference also matters. In [Part 3](./the-openclaw-guide.md), I documented how OpenClaw's multi-channel architecture maximizes attack surface and how 20% of ClawdHub marketplace skills contained malicious payloads. Hermes doesn't have a marketplace — its skills are self-generated from the agent's own experience, which eliminates the supply-chain attack vector entirely.

That said, OpenClaw has strengths: its GUI dashboard is genuinely more accessible for non-technical users, and its multi-agent orchestration is more mature for complex automation workflows. If you need six agents coordinating across twelve platforms, OpenClaw's orchestration layer handles that better today.

### vs. Claude Code / Codex

| Dimension | Claude Code / Codex | Hermes Agent |
|-----------|-------------------|--------------|
| **Primary use** | Coding assistant | General-purpose autonomous agent |
| **Session persistence** | Resets each session | Persistent across days/months |
| **Where it runs** | Your terminal / IDE | Your server, 24/7 |
| **Interaction** | Terminal / IDE | Telegram, Discord, Slack, CLI, etc. |
| **Learning** | None (fresh each session) | Self-improving loop |
| **Coding capability** | Exceptional | Good (depends on model) |

Claude Code and Codex are far superior as coding tools. They're purpose-built for software engineering with deep IDE integration, context-aware completions, and tool use that's specifically tuned for code. Hermes isn't trying to replace them — it's solving a different problem.

Hermes is the agent you talk to from your phone at midnight through Telegram, asking it to check your server logs, summarize what happened since your last session, and schedule a deployment for tomorrow morning. It remembers what you deployed last week. It knows your infrastructure. It doesn't need re-onboarding.

The ideal setup for many developers: Claude Code for coding, Hermes for everything else.

---

## Setup Guide

### Prerequisites

- Linux, macOS, or Windows (via WSL2)
- Python 3.11
- Node.js
- ripgrep
- ffmpeg

### Installation

One command:

```bash
curl -fsSL https://raw.githubusercontent.com/nousresearch/hermes-agent/main/scripts/install.sh | bash
```

The installer handles dependencies, clones the repository with submodules, creates a virtual environment, and sets up the global `hermes` command.

> **Windows users:** Native Windows is not supported. Install WSL2 first, then run the installer inside WSL. This is the biggest friction point for non-Linux users, but once past this step, everything works identically.

### Configuration

After installation, run the setup wizard:

```bash
hermes setup
```

Or configure components individually:

```bash
# Choose your LLM provider and model
hermes model

# Enable/disable available tools
hermes tools

# Set up messaging platforms
hermes gateway setup

# View logs
hermes logs
```

### Provider Setup

Hermes supports 20+ LLM providers with automatic capability detection (vision, streaming, tool use):

| Provider | Notes |
|----------|-------|
| **OpenRouter** | 200+ models, recommended for flexibility |
| **Anthropic** | Claude models directly |
| **OpenAI** | GPT models |
| **Google AI Studio** | Gemini models (native in v0.8.0) |
| **Nous Portal** | Optimized Nous models |
| **DeepSeek** | Cost-effective option |
| **Ollama** | Local models, zero API cost |
| **Custom endpoints** | Any OpenAI-compatible API |

The provider configuration lives in `config.yaml`. Hermes auto-detects context length via three fallback methods: Nous Portal metadata, models.dev community registry (3,800+ models), and built-in defaults.

### Messaging Gateway

Connect Hermes to your preferred platform:

```bash
hermes gateway setup
```

Supported platforms: **Telegram**, **Discord**, **Slack**, **WhatsApp**, **Signal**, **Matrix**, **Mattermost**

Once connected, you can interact with your agent from your phone, your desktop, or any device with a messaging client. The agent runs persistently on your server — you just chat with it.

---

## v0.8.0 — What's New

The latest release (April 2026) is substantial. 209 merged PRs across 82 issues from 18 contributors:

### Highlights

- **Background task notifications** — Long-running tasks notify the agent on completion. No more polling.
- **Native Gemini integration** — Google AI Studio as a first-class provider with context length auto-detection.
- **Live model switching** — `/model` command switches provider and model mid-session. No restart required.
- **Approval buttons** — Dangerous commands show native approval buttons on Slack and Telegram (emoji reactions on Telegram, thread-based on Slack).
- **Smart inactivity timeouts** — Tracks actual tool activity, not wall-clock time. Long-running active tasks never get killed.
- **MCP OAuth 2.1 PKCE** — Standards-compliant OAuth for MCP server authentication.
- **OSV malware scanning** — Automatic scanning of MCP extension packages against the OSV vulnerability database.
- **Centralized logging** — Structured logs to `~/.hermes/logs/` with `hermes logs` for tailing and filtering.
- **Config validation** — Catches malformed YAML at startup before anything breaks.

### Security Hardening

- SSRF protections on outbound requests
- Timing attack mitigations
- Tar traversal prevention on file extractions
- OSV scanning for all extension packages

This matters. In [Part 3](./the-openclaw-guide.md) I showed how OpenClaw's security model has gaps that put users at real risk. Hermes is taking the opposite approach — proactive security hardening with each release, no community marketplace to police, and automated scanning of any extensions.

---

## Honest Assessment

### What's Great

1. **The self-improving loop actually works.** After two weeks of use, my Hermes instance noticeably handles my common tasks faster and with fewer mistakes. The Skill Documents it generates are genuinely useful — I've read through several and they capture real patterns I'd otherwise have to re-explain.

2. **Memory across sessions is transformative.** Being able to say "remember the deployment issue from last Tuesday?" and having the agent actually recall the conversation changes the relationship with the tool. It stops being a utility and starts being a collaborator.

3. **Model flexibility.** Switching from Claude to GPT to a local Llama model mid-session is something no other agent handles this smoothly. If you're cost-conscious, you can route routine tasks to cheaper models and complex ones to Claude or GPT-4.

4. **It's genuinely free.** The agent itself is MIT-licensed, zero cost. You only pay for the model API you choose. Use local models via Ollama and your total cost is electricity.

5. **Security posture is solid.** No marketplace, no unvetted community skills, SSRF protection, OSV scanning. For an open-source project, the security engineering is above average.

### What's Not Great

1. **Installation barrier.** If you've never used a terminal, the setup process will be intimidating. Python 3.11 specifically (not 3.12, not 3.10), WSL2 on Windows, submodules, virtual environments — this is not "download and double-click." Once past the initial setup, interacting via chat is straightforward, but getting there requires comfort with the command line.

2. **Skill quality depends on model quality.** The self-improving loop is only as good as the model generating the Skill Documents. With a strong model (Claude, GPT-4), the skills are genuinely insightful. With a weaker local model, the generated skills can be generic or miss important edge cases. You get what you pay for.

3. **Not a coding replacement.** Hermes is a general-purpose agent, not a coding specialist. For writing code, Claude Code or Codex will outperform it. Hermes shines at operational tasks, research, communication management, and anything that benefits from persistent memory — not at implementing complex features in a large codebase.

4. **Resource usage.** Running an agent 24/7 on a server means keeping a process alive and using API tokens for every interaction. For heavy users, costs can accumulate. Monitor your token usage, especially if using premium models.

5. **Ecosystem maturity.** At 57.7k stars it's popular, but the ecosystem is still young. Documentation has gaps. Some platform integrations (especially Signal and Matrix) are newer and less battle-tested than Telegram or Discord.

---

## Who Should Use This

**Use Hermes Agent if:**
- You want an AI assistant that remembers your context across days and months
- You need an autonomous agent running 24/7 on your server
- You want to interact with your AI via Telegram, Discord, or Slack from any device
- You're comfortable with CLI setup and server management
- You want self-improving behavior without manually curating skill libraries

**Stick with Claude Code if:**
- Your primary need is coding assistance
- You want deep IDE integration
- You prefer session-based interactions
- You don't need persistent memory across sessions

**Consider both:**
- Claude Code for coding, Hermes for operational tasks, research, and persistent memory. They complement each other well.

---

## Getting Started Today

```bash
# 1. Install
curl -fsSL https://raw.githubusercontent.com/nousresearch/hermes-agent/main/scripts/install.sh | bash

# 2. Configure
hermes setup

# 3. Choose your model
hermes model

# 4. Connect your messaging platform
hermes gateway setup

# 5. Start the agent
hermes start
```

The first session will feel like any other AI chat. By the tenth session, you'll notice it finishing your sentences. By the fiftieth, it'll handle tasks you haven't explicitly taught it because it learned from the patterns in your previous requests.

That's the promise of a self-improving agent. And from what I've seen, Hermes delivers on it.

---

## Resources

- **GitHub:** [NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent)
- **Documentation:** [hermes-agent.nousresearch.com/docs](https://hermes-agent.nousresearch.com/docs/)
- **Release Notes (v0.8.0):** [GitHub Releases](https://github.com/NousResearch/hermes-agent/releases/tag/v2026.4.8)
- **Community Resources:** [awesome-hermes-agent](https://github.com/0xNyk/awesome-hermes-agent)

---

*Next in the series: [The Security Guide](./the-security-guide.md) — defense patterns for agent-powered development.*
