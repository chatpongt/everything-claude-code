---
name: hermes-agent-setup
description: Install and configure Hermes Agent — self-improving AI agent with persistent memory, multi-provider LLM support, and auto-generated skills.
origin: ECC
---

# Hermes Agent Setup

Set up and configure Hermes Agent, the open-source self-improving AI agent from Nous Research. Covers installation, provider configuration, memory system, skill management, and messaging gateway setup.

## When to Activate

- User wants to install or configure Hermes Agent
- User asks about self-improving agents with persistent memory
- User needs multi-provider LLM agent setup (OpenRouter, Anthropic, OpenAI, Google, Ollama)
- User wants an autonomous agent running 24/7 on their server
- User asks about Hermes Agent memory system or skill generation

## Core Concepts

### Architecture

Hermes Agent uses three core components:

1. **AIAgent Loop** — Synchronous orchestration engine handling reasoning, tool execution, skill creation, and self-evaluation
2. **SQLite Database** — Persistent state via `hermes_state.py` (portable, no external server)
3. **Skill System** — Auto-generated Markdown skill documents following the agentskills.io standard

### Three-Layer Memory

| Layer | Purpose | Storage |
|-------|---------|---------|
| Layer 1 — Frozen System Prompt | Core identity and base instructions | Injected every session |
| Layer 2 — Episodic Memory / Skills | Auto-generated skill documents from experience | `~/.hermes/skills/` |
| Layer 3 — Session Search | Full conversation history with FTS5 search | SQLite database |

### Self-Improving Loop

After completing complex tasks (5+ tool calls):
1. Agent evaluates its own performance
2. Identifies what worked and what failed
3. Generates a Skill Document capturing the approach and edge cases
4. Stores the skill for retrieval on similar future tasks

### Supported Providers

| Provider | Command | Notes |
|----------|---------|-------|
| OpenRouter | `hermes model set openrouter/<model>` | 200+ models, recommended for flexibility |
| Anthropic | `hermes model set anthropic/claude-sonnet-4-20250514` | Direct Claude access |
| OpenAI | `hermes model set openai/gpt-4o` | GPT models |
| Google AI Studio | `hermes model set google/gemini-2.5-pro` | Native Gemini (v0.8.0+) |
| Ollama | `hermes model set ollama/llama3` | Local, free, private |
| DeepSeek | `hermes model set deepseek/deepseek-chat` | Cost-effective |
| Custom | `hermes model set custom/<endpoint>` | Any OpenAI-compatible API |

### Messaging Gateways

Supported platforms: Telegram, Discord, Slack, WhatsApp, Signal, Matrix, Mattermost.

Each gateway allows interacting with the agent from any device. The agent runs persistently on your server.

## Code Examples

### Installation

```bash
# One-line install (Linux, macOS, WSL2)
curl -fsSL https://raw.githubusercontent.com/nousresearch/hermes-agent/main/scripts/install.sh | bash

# Verify installation
hermes --version
```

### Initial Configuration

```bash
# Interactive setup wizard
hermes setup

# Or configure individually:
hermes model          # Choose LLM provider and model
hermes tools          # Enable/disable tools
hermes gateway setup  # Configure messaging platforms
hermes logs           # View structured logs
```

### config.yaml Example

```yaml
model:
  provider: openrouter
  name: anthropic/claude-sonnet-4-20250514
  api_key: ${OPENROUTER_API_KEY}

memory:
  persistence: true
  skill_generation: true
  search_engine: sqlite_fts5

tools:
  web_search: true
  file_operations: true
  shell_execution: true

gateways:
  telegram:
    enabled: true
    bot_token: ${TELEGRAM_BOT_TOKEN}
```

### Skill Management

```bash
# List auto-generated skills
hermes skill list

# View a specific skill
hermes skill show deploy-workflow

# Manually create a skill
hermes skill create "deploy-workflow" --description "Production deployment steps"

# Delete a low-quality auto-generated skill
hermes skill delete <skill-name>
```

### Running the Agent

```bash
# Start in foreground
hermes start

# Start as background daemon
hermes start --daemon

# Check status
hermes status

# Stop the agent
hermes stop

# View logs
hermes logs --tail 50
```

### Live Model Switching (v0.8.0)

```bash
# Switch model mid-session via chat command
/model openrouter/anthropic/claude-sonnet-4-20250514

# Or via CLI
hermes model set ollama/llama3
```

## Best Practices

- **Start with one provider.** Confirm your setup works before adding backup providers or switching models.
- **Use Ollama for local development.** Zero API cost, full data privacy, no network dependency.
- **Review auto-generated skills periodically.** Delete generic or low-quality ones to keep the skill library useful.
- **Limit messaging gateways.** Each gateway is an attack surface. Only enable what you actually use.
- **Back up `~/.hermes/` regularly.** This directory contains your agent's accumulated knowledge, memory database, and configuration.
- **Use environment variables for API keys.** Never hardcode secrets in `config.yaml`.
- **Run in a sandboxed environment for production.** Use a dedicated user, container, or VM to limit blast radius.
- **Monitor token usage.** Running 24/7 with premium models can accumulate costs. Use `hermes logs` to track usage patterns.

## Security Considerations

- Each messaging gateway is an injection surface — untrusted messages can contain prompt injection attempts
- Auto-generated skills should be reviewed before they influence future agent behavior at scale
- SQLite memory is local-only by default — no cloud sync unless explicitly configured
- v0.8.0 adds SSRF protections, timing attack mitigations, tar traversal prevention, and OSV malware scanning
- For sensitive work, prefer local models (Ollama) to keep all data on your machine

## Prerequisites

| Requirement | Version | Notes |
|-------------|---------|-------|
| Python | 3.11 | Specifically 3.11 (not 3.12+) |
| Node.js | 20+ | For tooling and MCP |
| ripgrep | Latest | For code search tools |
| ffmpeg | Latest | For media processing |
| OS | Linux, macOS, WSL2 | Native Windows not supported |
