# Manual Gemini CLI Installation

Gemini CLI requires manual installation since the auto-detect is disabled by default.

## Requirements

- Gemini CLI installed (`gemini` command available)
- `~/.agents/skills/` directory accessible

## Installation

### 1. Install skills via Gemini CLI

```bash
gemini skills install /path/to/sprite/src/gemini/skills/wish --scope user --consent
gemini skills install /path/to/sprite/src/gemini/skills/fulfill --scope user --consent
```

### 2. Create config directory

```bash
mkdir -p ~/.gemini
```

### 3. Copy config template

```bash
cp /path/to/sprite/src/config/sprite.yaml ~/.gemini/sprite.yaml
```

Edit `~/.gemini/sprite.yaml` to customize for your project.

## Usage

Unlike other agents, Gemini CLI requires a description with `/wish`:

```bash
gemini
> /wish add dark mode
```

## Uninstall

```bash
gemini skills uninstall wish --scope user
gemini skills uninstall fulfill --scope user
rm -rf ~/.gemini/sprite.yaml
```
