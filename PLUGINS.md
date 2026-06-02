# Plugin ufficiali Claude Code

Questo documento spiega come **consumare** i plugin ufficiali dentro questo setup.
Non parla di *distribuire* il setup come plugin (quello è l'L5, fuori scope per ora):
qui aggiungiamo capacità pronte mantenute da Anthropic.

> Verificato sulla doc ufficiale: <https://code.claude.com/docs/en/discover-plugins>

## Cos'è un plugin (e cosa NON è)

Un plugin è un pacchetto versionato che può contenere **skill, agent, hook, server MCP,
server LSP**. Si installa da un *marketplace* (un repo git che cataloga i plugin).
Le skill di un plugin sono **namespaced**: `/github:...`, non `/...`. Questo evita
conflitti con le tue skill locali (`commit-messages`, `code-review`, ecc.).

## I due marketplace ufficiali

| Marketplace | Come si aggiunge | Install |
|---|---|---|
| **`claude-plugins-official`** — curato da Anthropic | **già presente**, niente da fare | `/plugin install <nome>@claude-plugins-official` |
| **`claude-community`** — terze parti, validate | `/plugin marketplace add anthropics/claude-plugins-community` | `/plugin install <nome>@claude-community` |

## Comandi essenziali

```text
/plugin                              # UI: Discover / Installed / Marketplaces / Errors
/plugin install <nome>@<marketplace> # installa (default: user scope)
/plugin marketplace add owner/repo   # aggiunge un marketplace da GitHub
/plugin marketplace update <nome>    # aggiorna il catalogo
/reload-plugins                      # applica le modifiche senza riavviare
```

## Plugin consigliati per QUESTO setup

Scelti per coerenza con i default del [CLAUDE.md globale](global/CLAUDE.md)
(Python come linguaggio principale; workflow git). Tutti da `claude-plugins-official`.

### Code intelligence (LSP) — il guadagno più alto

Danno a Claude diagnostica automatica dopo ogni edit (errori di tipo, import mancanti)
e navigazione precisa (go-to-definition, find-references). **Richiedono il binario del
language server installato** sul sistema.

| Linguaggio | Plugin | Binario richiesto | Nel set di default? |
|---|---|---|---|
| Python | `pyright-lsp` | `pyright-langserver` | ✅ sì (linguaggio principale) |
| TypeScript | `typescript-lsp` | `typescript-language-server` | no — abilitalo se ti serve |
| Rust | `rust-analyzer-lsp` | `rust-analyzer` | no — abilitalo se ti serve |
| Go | `gopls-lsp` | `gopls` | no — abilitalo se ti serve |

Il set di default abilita **solo `pyright-lsp`**: gli altri li accendi al volo con
`/plugin install <nome>@claude-plugins-official` quando apri un progetto in quel linguaggio.

### Integrazioni esterne (MCP)

- `github` / `gitlab` — source control
- `linear`, `notion`, `slack`, `sentry`, `vercel`, `supabase`, `figma` — su richiesta

### Sicurezza

- `security-guidance` — rivede ogni modifica che Claude scrive cercando vulnerabilità
  comuni e gli fa correggere ciò che trova, nella stessa sessione. Complementare alla
  tua skill `code-review` (che è on-demand; questo è continuo).

## ⚠️ Sovrapposizioni con le tue skill

Alcuni plugin ufficiali coprono terreno che le tue skill già coprono. **Scegline uno**,
non entrambi, per evitare rumore e doppioni:

| Plugin ufficiale | Tua skill | Nota |
|---|---|---|
| `commit-commands` | `commit-messages` | La tua è più opinionata (Conventional Commits, regole di split). Tienila. |
| `pr-review-toolkit` | `code-review` | Il plugin usa agent multipli in parallelo: utile su PR grandi. Valuta caso per caso. |

Regola pratica: usa i plugin per ciò che **non** sai/vuoi mantenere a mano (LSP, MCP,
security), e tieni le tue skill per le cose dove vuoi *la tua* opinione.

## Renderli parte del setup versionato

L'aggancio dichiarativo: pre-dichiarare i plugin in un `settings.json`. Così non li
reinstalli a mano su ogni macchina — fanno parte del setup come le skill.

Questo setup include già [`global/settings.json`](global/settings.json) con il set
consigliato. `install.sh` **non lo linka**: fa il *merge* dei soli `enabledPlugins`
nel tuo `~/.claude/settings.json`, preservando permessi, tema, modello e i plugin che
hai già abilitato (settings.json è per-macchina e può contenere segreti — non si
sovrascrive). Il set:

```json
{
  "enabledPlugins": {
    "pyright-lsp@claude-plugins-official": true,
    "github@claude-plugins-official": true,
    "security-guidance@claude-plugins-official": true
  }
}
```

`enabledPlugins` è un **oggetto** `"plugin@marketplace": true` (non un array).
Il marketplace ufficiale è già noto, quindi non serve altro. Aggiungi o rimuovi righe
per personalizzare il set; per i plugin LSP ricorda di avere il binario sul `PATH`.

Per abilitare anche plugin **della community**, prima dichiara il marketplace:

```json
{
  "extraKnownMarketplaces": {
    "claude-community": {
      "source": { "source": "github", "repo": "anthropics/claude-plugins-community" }
    }
  },
  "enabledPlugins": {
    "nome-plugin@claude-community": true
  }
}
```


## Scope di installazione

- **User** (default): per te, in tutti i progetti → `~/.claude/settings.json` (questo setup)
- **Project**: per tutti i collaboratori del repo → `.claude/settings.json` (committato)
- **Local**: solo te, solo questo repo → non condiviso

Per i plugin specifici di un progetto, usa lo scope **project** dentro `.claude/settings.json`
del repo, non il settings globale.

## Sicurezza

I plugin e i marketplace **eseguono codice arbitrario** con i tuoi privilegi. Anthropic
non controlla cosa c'è dentro i plugin di terze parti. Installa solo da fonti fidate:
il marketplace ufficiale e, con giudizio, la community. Controlla la sezione *Will install*
nella UI `/plugin` prima di installare — elenca esattamente skill/agent/hook/MCP che aggiunge.
