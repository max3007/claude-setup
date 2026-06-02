# Claude Code Setup — L1 + L2

Setup di partenza per Claude Code: **Memory Layer** (CLAUDE.md) + **Knowledge Layer** (Skills).

## Struttura

```
claude-setup/
├── global/                          → va in ~/.claude/
│   ├── CLAUDE.md                    # Preferenze personali, sempre attive
│   ├── settings.json               # Plugin ufficiali pre-abilitati (vedi PLUGINS.md)
│   └── skills/                      # Skill riusabili in ogni progetto
│       ├── init-claude-md/          # Genera il CLAUDE.md via intervista o scan
│       ├── commit-messages/
│       ├── code-review/
│       └── debug-systematically/
│
└── project/                         → template da copiare in ogni repo
    ├── CLAUDE.md                    # Convenzioni del progetto
    └── .claude/skills/              # Skill specifiche del progetto
```

## Installazione

### 1. Setup globale (una volta sola)

```bash
./install.sh --dry-run   # mostra cosa farebbe, senza toccare niente
./install.sh             # crea i symlink
```

Lo script crea **symlink** da `~/.claude/` verso questo repo (CLAUDE.md globale + ogni skill). Così il repo resta la single source of truth: editi qui e l'effetto è immediato ovunque, senza ri-copiare. È idempotente e mette in backup eventuali file in conflitto.

### 2. Setup per ogni progetto

**Modo consigliato** — fai compilare il CLAUDE.md a Claude. Nel repo chiedi:
*"Inizializza il CLAUDE.md di questo progetto"*. Si attiva la skill `init-claude-md`, che:
- se il codice esiste già → lo scansiona e riempie le sezioni deducibili
- se hai solo l'idea → ti intervista, propone uno stack, poi scrive il file

Non inventa: ciò che non sa lo lascia come `[TODO]` esplicito.

**Modo manuale** — se preferisci partire dal template a mano:

```bash
cd /path/al/tuo/repo
cp /path/a/claude-setup/project/CLAUDE.md ./CLAUDE.md
mkdir -p .claude/skills

# Adesso edita CLAUDE.md con i dettagli del progetto
$EDITOR CLAUDE.md
```

### 3. Verifica

Apri Claude Code nel repo e chiedi: *"Cosa sai di questo progetto?"*
Dovrebbe rispondere usando il contenuto del CLAUDE.md.

## Filosofia

- **CLAUDE.md globale** = la tua *voce* (come vuoi che Claude risponda sempre)
- **CLAUDE.md di progetto** = le *regole* di questo repo (architettura, convenzioni)
- **Skills** = *competenze on-demand* (caricate solo quando rilevanti)

Le skill restano dormienti finché la loro `description` non matcha il task corrente. Costo zero quando non servono.

## Plugin ufficiali

Oltre alle skill locali puoi **consumare** i plugin ufficiali di Anthropic (LSP,
integrazioni MCP come `github`, security review). Quali installare, i comandi e come
renderli parte del setup versionato: vedi [PLUGINS.md](PLUGINS.md).

## Prossimi step

Quando questo setup ti sta stretto, aggiungi i layer successivi:
- **L3 Hooks** → enforcement deterministico (es. blocca `rm -rf`)
- **L4 Subagents** → delegare task pesanti senza inquinare la sessione
- **L5 Plugins** → distribuire il *tuo* setup come plugin al team (vedi [PLUGINS.md](PLUGINS.md) per il lato *consumo*)
