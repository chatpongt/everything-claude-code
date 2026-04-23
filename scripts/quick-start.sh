#!/usr/bin/env bash
# quick-start.sh — One-command setup for ECC + Hermes Agent
#
# Usage:
#   ./quick-start.sh                    # Interactive setup
#   ./quick-start.sh --ecc-only         # Install ECC only
#   ./quick-start.sh --hermes-only      # Install Hermes Agent only
#   ./quick-start.sh --all              # Install both without prompting

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

info()  { echo -e "${BLUE}→${NC} $*"; }
ok()    { echo -e "${GREEN}✓${NC} $*"; }
warn()  { echo -e "${YELLOW}!${NC} $*"; }
fail()  { echo -e "${RED}✗${NC} $*"; }
header(){ echo -e "\n${BOLD}${CYAN}$*${NC}\n"; }

# ============================================================================
header "┌─────────────────────────────────────────────────┐"
echo -e "${BOLD}${CYAN}│  ECC + Hermes Agent — Quick Start               │${NC}"
echo -e "${BOLD}${CYAN}└─────────────────────────────────────────────────┘${NC}"
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALL_ECC=false
INSTALL_HERMES=false

# Parse args
case "${1:-}" in
  --ecc-only)    INSTALL_ECC=true ;;
  --hermes-only) INSTALL_HERMES=true ;;
  --all)         INSTALL_ECC=true; INSTALL_HERMES=true ;;
  *)
    echo ""
    echo "What would you like to install?"
    echo ""
    echo "  1) Everything Claude Code (ECC) — plugin for Claude Code"
    echo "  2) Hermes Agent — self-improving AI agent (by Nous Research)"
    echo "  3) Both"
    echo ""
    read -rp "Choose [1/2/3]: " choice
    case "$choice" in
      1) INSTALL_ECC=true ;;
      2) INSTALL_HERMES=true ;;
      3) INSTALL_ECC=true; INSTALL_HERMES=true ;;
      *) fail "Invalid choice"; exit 1 ;;
    esac
    ;;
esac

# ============================================================================
# Prerequisites check
# ============================================================================
header "Checking prerequisites..."

check_cmd() {
  if command -v "$1" &>/dev/null; then
    ok "$1 found: $($1 --version 2>&1 | head -1)"
    return 0
  else
    fail "$1 not found"
    return 1
  fi
}

MISSING=0
check_cmd node   || MISSING=$((MISSING + 1))
check_cmd git    || MISSING=$((MISSING + 1))
check_cmd npm    || MISSING=$((MISSING + 1))

if $INSTALL_HERMES; then
  check_cmd python3 || MISSING=$((MISSING + 1))
  check_cmd rg      || warn "ripgrep not found (optional, for code search)"
  check_cmd ffmpeg  || warn "ffmpeg not found (optional, for voice messages)"
fi

if [ "$MISSING" -gt 0 ]; then
  fail "Missing $MISSING required tool(s). Please install them first."
  exit 1
fi

ok "All required prerequisites met!"

# ============================================================================
# Install ECC
# ============================================================================
if $INSTALL_ECC; then
  header "Installing Everything Claude Code (ECC)..."

  cd "$SCRIPT_DIR"

  # Install npm dependencies
  info "Installing npm dependencies..."
  npm install --silent 2>&1 | tail -1
  ok "Dependencies installed"

  # Install rules for Claude Code
  info "Installing ECC rules for Claude Code..."
  if [ -f "$SCRIPT_DIR/install.sh" ]; then
    bash "$SCRIPT_DIR/install.sh" typescript 2>&1 | tail -5
    ok "ECC rules installed to ~/.claude/rules/"
  else
    warn "install.sh not found, skipping rules installation"
  fi

  echo ""
  ok "${BOLD}ECC installed!${NC}"
  echo ""
  echo "  Available commands:"
  echo "    /plan             — Implementation planning"
  echo "    /tdd              — Test-driven development"
  echo "    /code-review      — Code quality review"
  echo "    /build-fix        — Fix build errors"
  echo "    /hermes-setup     — Setup Hermes Agent"
  echo "    /e2e              — Generate E2E tests"
  echo ""
fi

# ============================================================================
# Install Hermes Agent
# ============================================================================
if $INSTALL_HERMES; then
  header "Installing Hermes Agent..."

  if command -v hermes &>/dev/null; then
    ok "Hermes Agent already installed: $(hermes --version 2>&1 | head -1)"
  else
    info "Downloading and running Hermes Agent installer..."
    curl -fsSL https://raw.githubusercontent.com/nousresearch/hermes-agent/main/scripts/install.sh | bash
  fi

  # Verify installation
  if command -v hermes &>/dev/null; then
    ok "Hermes Agent ready: $(hermes --version 2>&1 | head -1)"

    echo ""
    echo "  Quick commands:"
    echo "    hermes setup          — Interactive configuration wizard"
    echo "    hermes model          — Choose LLM provider and model"
    echo "    hermes start          — Start the agent"
    echo "    hermes gateway setup  — Connect Telegram/Discord/Slack"
    echo "    hermes status         — Check current status"
    echo "    hermes skill list     — View auto-generated skills"
    echo ""
  else
    fail "Hermes Agent installation failed. Try manually:"
    echo "  curl -fsSL https://raw.githubusercontent.com/nousresearch/hermes-agent/main/scripts/install.sh | bash"
  fi
fi

# ============================================================================
# Summary
# ============================================================================
header "┌─────────────────────────────────────────────────┐"
echo -e "${BOLD}${CYAN}│  Setup Complete!                                │${NC}"
echo -e "${BOLD}${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo ""

if $INSTALL_ECC && $INSTALL_HERMES; then
  echo "  Both tools are ready. Here's how they work together:"
  echo ""
  echo "  ${BOLD}Claude Code + ECC${NC} → for coding (in your IDE/terminal)"
  echo "    Use /plan, /tdd, /code-review, /build-fix"
  echo ""
  echo "  ${BOLD}Hermes Agent${NC} → for everything else (runs 24/7 on your server)"
  echo "    Remembers context across sessions"
  echo "    Chat via Telegram/Discord/Slack"
  echo "    Self-improves with every task"
  echo ""
  echo "  Next steps:"
  echo "    1. hermes setup          — Configure your LLM provider"
  echo "    2. hermes start          — Start the agent"
  echo "    3. hermes gateway setup  — Connect messaging (optional)"
  echo ""
elif $INSTALL_ECC; then
  echo "  ECC is ready. Open Claude Code and try: /plan \"your task\""
  echo ""
elif $INSTALL_HERMES; then
  echo "  Hermes Agent is ready. Run: hermes setup"
  echo ""
fi
