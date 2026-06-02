#!/usr/bin/env bash
#
# Installa il setup globale di Claude Code via symlink.
#
# Crea link simbolici da ~/.claude/ verso questo repo, così il repo resta
# la single source of truth: editi qui e l'effetto è immediato ovunque.
#
# Idempotente: rieseguirlo non rompe nulla. I file/cartelle in conflitto
# che NON sono già link verso questo repo vengono salvati in backup.
#
# Uso:
#   ./install.sh           installa
#   ./install.sh --dry-run mostra cosa farebbe senza toccare niente
#
set -euo pipefail

# --- Risoluzione path -------------------------------------------------------
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"
DRY_RUN=0

if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=1
  echo "DRY-RUN: nessun file verrà modificato."
fi

run() {
  if [[ "${DRY_RUN}" -eq 1 ]]; then
    echo "  [dry-run] $*"
  else
    "$@"
  fi
}

# --- Crea un symlink in modo sicuro -----------------------------------------
# $1 = sorgente (nel repo)   $2 = destinazione (in ~/.claude)
link() {
  local src="$1" dest="$2"

  # Già linkato correttamente verso questo repo? niente da fare.
  if [[ -L "${dest}" && "$(readlink "${dest}")" == "${src}" ]]; then
    echo "  ✓ già linkato: ${dest}"
    return
  fi

  # Esiste qualcosa di diverso? backup prima di sovrascrivere.
  if [[ -e "${dest}" || -L "${dest}" ]]; then
    local backup="${dest}.backup.$(date +%s)"
    echo "  ⚠ conflitto su ${dest} → backup in ${backup}"
    run mv "${dest}" "${backup}"
  fi

  echo "  → ${dest}  ➜  ${src}"
  run ln -s "${src}" "${dest}"
}

# --- Installazione ----------------------------------------------------------
echo "Repo:   ${REPO_DIR}"
echo "Target: ${CLAUDE_DIR}"
echo

run mkdir -p "${CLAUDE_DIR}/skills"

# CLAUDE.md globale (file singolo)
echo "CLAUDE.md globale:"
link "${REPO_DIR}/global/CLAUDE.md" "${CLAUDE_DIR}/CLAUDE.md"
echo

# Skill (una per una, così coesistono con eventuali skill già presenti)
echo "Skill:"
for skill_dir in "${REPO_DIR}"/global/skills/*/; do
  [[ -d "${skill_dir}" ]] || continue
  skill_name="$(basename "${skill_dir%/}")"
  link "${skill_dir%/}" "${CLAUDE_DIR}/skills/${skill_name}"
done
echo

echo "Fatto."
echo
echo "Per ogni progetto, copia (NON linkare) il template e personalizzalo:"
echo "  cp ${REPO_DIR}/project/CLAUDE.md /path/al/tuo/repo/CLAUDE.md"
