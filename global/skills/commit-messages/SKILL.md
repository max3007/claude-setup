---
name: commit-messages
description: Use this skill whenever the user asks to write, generate, suggest, or improve a git commit message. Also use when the user asks to commit staged changes, when they paste a diff and ask "what should the commit say", or when they ask to split a large change into multiple commits. Produces messages in Conventional Commits format with appropriate scope detection and helps decide when a single change should become multiple commits.
---

# Commit messages

## Format

Conventional Commits:

```
<type>(<scope>): <subject>

<body>

<footer>
```

- **type** (obbligatorio): `feat`, `fix`, `refactor`, `perf`, `test`, `docs`, `style`, `chore`, `build`, `ci`, `revert`
- **scope** (opzionale ma incoraggiato): area del codice toccata. Es: `(auth)`, `(api/orders)`, `(db)`
- **subject**: imperativo, minuscolo, ≤ 50 caratteri, **senza punto finale**
- **body** (opzionale): perché, non cosa. Wrappa a 72 caratteri
- **footer** (opzionale): `BREAKING CHANGE: ...`, `Closes #123`, `Co-authored-by: ...`

## Workflow

1. Leggi il diff effettivo (`git diff --staged`). **Non inventare** basandoti sui nomi dei file
2. Identifica lo scope dal path più toccato
3. Scegli il type:
   - Nuova funzionalità visibile all'utente → `feat`
   - Correzione di bug → `fix`
   - Cambio interno senza effetti esterni → `refactor`
   - Miglioramento prestazioni misurabile → `perf`
   - Solo test → `test`
   - Solo documentazione → `docs`
   - Build/deps/tooling → `chore` o `build`
4. Scrivi il subject in imperativo: "add", "fix", "remove" — non "added"/"fixes"/"removing"

## Esempi buoni

```
feat(auth): add refresh token rotation

Tokens are now rotated on every use. Old tokens become invalid
after 30s grace period to handle concurrent requests.

Closes #234
```

```
fix(api/orders): prevent double charge on retry

The retry middleware was not deduplicating requests when the
client sent the same Idempotency-Key twice within 1s.
```

```
refactor(db): extract repository base class
```

## Esempi cattivi (e perché)

| ❌ Cattivo | Problema |
|-----------|----------|
| `update code` | Non dice cosa né perché |
| `Fixed bug.` | Maiuscola, passato, punto finale |
| `feat: implemented the new user authentication system with JWT and refresh tokens and rate limiting` | Subject troppo lungo, sposta nel body |
| `wip` | Mai committare WIP su branch condivisi |
| `feat(auth): added stuff` | "stuff" non è informazione |

## Quando suggerire di splittare

Se il diff contiene cambiamenti **logicamente indipendenti**, proponi più commit:

- Refactor + nuova feature → 2 commit (prima il refactor, poi la feature sopra)
- Fix + test per quel fix → spesso UN commit (sono la stessa unità)
- Rinominare un file + modificarne il contenuto → 2 commit (rename puro prima, così git riconosce il rename)
- Bump dipendenze + uso di nuove API → 2 commit

Quando proponi lo split, mostra:
1. L'ordine consigliato
2. I file/hunk per ciascun commit
3. Il messaggio di ciascuno

## Output da consegnare

Quando l'utente chiede un messaggio, fornisci **solo il messaggio**, in un blocco di codice, pronto per `git commit -m` o per pasted in editor. Niente preambolo tipo "Ecco il messaggio:".

Se serve un body, usa la sintassi multi-`-m` o suggerisci di aprire l'editor:

```bash
git commit -m "feat(auth): add refresh token rotation" \
           -m "Tokens are rotated on every use. Old tokens..."
```
