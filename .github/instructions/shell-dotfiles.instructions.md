---
applyTo: "setup.sh,lib/**/*.sh,dotfiles/.bash_profile,dotfiles/.bashrc,dotfiles/.profile,dotfiles/.shell_common,dotfiles/.zshrc,dotfiles/.ohmyzshrc"
---

# Shell And Dotfiles Conventions

## Core Principles

- Prefer the smallest behavior-preserving change that solves the problem.
- Keep shared shell logic in `.shell_common` and move shell-specific behavior into `.bashrc` or `.zshrc`.
- Preserve macOS and Linux parity where practical, and document intentional differences.
- Do not reintroduce removed tools such as `autojump`, `exa`, `neofetch`, `thefuck`, `htop`, or Screen without explicit justification.

## Validation

- Run `npm run lint` after shell changes.
- Use `bash -n` for bash-oriented files and `zsh -n` for zsh-specific files when narrowing failures.
- Treat `.zshrc` and `.ohmyzshrc` as zsh-native surfaces; do not assume bash completion or bash-only behavior there.

## Editing Guidelines

- Keep aliases and PATH changes readable and local to the owning shell file.
- When adding dynamic `source` calls, annotate intentional ShellCheck exceptions narrowly.
- Prefer repo-rooted paths in installer code via `SCRIPT_DIR` rather than assuming the current working directory.
- Keep documentation in `README.md` and `tmp/repo_review.md` aligned with behavior changes that affect setup or developer workflow.
