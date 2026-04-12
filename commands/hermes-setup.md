---
description: Install and configure Hermes Agent — self-improving AI agent with persistent memory
---

# Hermes Setup

Install and configure Hermes Agent, Nous Research's self-improving AI agent with persistent memory and multi-provider LLM support.

## Purpose

Guide the user through a complete Hermes Agent setup:
1. Check prerequisites and system compatibility
2. Install the Hermes Agent CLI
3. Configure an LLM provider
4. Set up the memory and skill system
5. Optionally configure messaging gateways
6. Verify the installation

## Usage

```
/hermes-setup
```

## Workflow

### Step 1: Prerequisites Check

Verify the system is ready:

| Requirement | Check Command |
|-------------|---------------|
| Python 3.11 | `python3 --version` |
| Node.js 20+ | `node --version` |
| Git | `git --version` |
| ripgrep | `rg --version` |
| ffmpeg | `ffmpeg -version` |
| WSL2 (Windows only) | `wsl --status` |

If any prerequisite is missing, provide installation instructions for the user's platform before proceeding.

### Step 2: Installation

Run the official installer:

```bash
curl -fsSL https://raw.githubusercontent.com/nousresearch/hermes-agent/main/scripts/install.sh | bash
```

Verify with `hermes --version`.

### Step 3: Provider Configuration

Ask the user which LLM provider to use:

| Provider | Best For |
|----------|----------|
| **OpenRouter** | Flexibility — one API key, 200+ models |
| **Anthropic** | Direct Claude access, best reasoning |
| **OpenAI** | GPT models, broad compatibility |
| **Google AI Studio** | Gemini models, native v0.8.0 support |
| **Ollama** | Free, local, fully private |

Configure the chosen provider:

```bash
hermes model set <provider>/<model-name>
```

Set the API key via environment variable (skip for Ollama):

```bash
export OPENROUTER_API_KEY="your-key-here"
# or
export ANTHROPIC_API_KEY="your-key-here"
```

### Step 4: Memory and Skill Configuration

Confirm default settings are active:
- Memory persistence: **enabled**
- Skill auto-generation: **enabled**
- Search engine: **SQLite FTS5**

These are defaults — no changes needed unless the user has specific requirements.

### Step 5: Gateway Setup (Optional)

Ask if the user wants messaging integrations. If yes:

```bash
hermes gateway setup telegram   # or discord, slack, whatsapp, signal, matrix, mattermost
```

Walk through the platform-specific bot token or webhook setup.

If no, skip — the agent runs CLI-only and can add gateways later with `hermes gateway setup`.

### Step 6: Verification

Run verification checks:

```bash
# Check all components
hermes status

# Test model connectivity with a simple prompt
hermes chat "Hello, confirm you're working."

# Verify skill system
hermes skill list
```

## Output

Show the user a configuration summary:

```
HERMES AGENT SETUP COMPLETE

Version:    v0.8.0
Provider:   openrouter (anthropic/claude-sonnet-4-20250514)
Memory:     enabled (SQLite FTS5)
Skills:     auto-generation enabled
Gateways:   telegram (connected)

Config:     ~/.hermes/config.yaml
Skills dir: ~/.hermes/skills/
Memory DB:  ~/.hermes/memory.db
Logs:       ~/.hermes/logs/

Next steps:
  hermes start              # Start the agent
  hermes gateway setup      # Add more messaging platforms
  hermes skill list         # View auto-generated skills
  hermes logs               # Monitor agent activity
```

## Related

- Skill: `hermes-agent-setup` — Detailed reference for configuration options
- Guide: [The Agent That Remembers Everything](../the-hermes-agent-guide.md)
