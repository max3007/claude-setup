---
name: init-claude-md
description: Use this skill when the user wants to create, generate, bootstrap, or scaffold a CLAUDE.md for a project — especially when they say things like "crea il CLAUDE.md", "set up Claude for this repo", "ho un'idea per un progetto, aiutami a partire", "non so ancora che stack usare", "inizializza il progetto". Handles BOTH a project that already has code (reads the repo and fills the file) AND a greenfield project that exists only as an idea (interviews the user, proposes a stack, then writes the file). Differs from the native /init: it covers the greenfield case via a structured interview and never invents facts. Use it instead of writing a CLAUDE.md freehand.
---

# Init CLAUDE.md

Genera il `CLAUDE.md` di un progetto riempiendo lo schema in `project/CLAUDE.md`.
Il template è la **forma target**; questa skill è il **processo** per riempirla senza inventare.

## Regola d'oro

**Mai scrivere una riga "plausibile" non verificata.** Ogni informazione nel CLAUDE.md
deve avere una di queste tre provenienze:

| Provenienza | Quando | Come la tratti |
|---|---|---|
| **Dedotta dal codice** | il file/comando/dipendenza esiste davvero nel repo | scrivila |
| **Confermata dall'utente** | l'hai chiesta e l'utente ha risposto | scrivila |
| **Ignota** | non sai e non l'hai chiesta | lascia `[TODO: ...]`, non riempire |

Un CLAUDE.md con tre `[TODO]` onesti è migliore di uno "completo" e per metà inventato.
Questo è coerente con la filosofia del setup: *meglio corto e vero che lungo e finto*.

## Passo 0 — Rileva lo scenario

Controlla la cartella corrente:

- Ci sono file sorgente, un `package.json`/`pyproject.toml`/`Cargo.toml`/`go.mod`,
  una struttura di cartelle reale? → **Brownfield**. Vai al workflow A.
- È vuota, o ha solo `README`/`.git`/file di config sparsi senza codice? → **Greenfield**.
  Vai al workflow B.

In dubbio, chiedi: *"Partiamo da codice esistente o da zero?"*

---

## Workflow A — Brownfield (il codice esiste)

Qui **deduci**, non chiedi ciò che puoi leggere.

1. **Scansiona** per riempire le sezioni deducibili:
   - *Stack* → da `package.json` / `pyproject.toml` / `Cargo.toml` / lockfile / Dockerfile
   - *Comandi* → da `scripts` in package.json, `Makefile`, `justfile`, CI workflow
   - *Struttura* → dall'albero reale delle cartelle (non da come "dovrebbe" essere)
   - *Convenzioni di nomi* → osserva i file esistenti (snake_case? camelCase?)
   - *Test* → quale runner, dove vivono, come si lanciano
2. **Scrivi** solo ciò che hai osservato. Se vedi `pytest` nel pyproject, scrivilo.
   Se NON vedi una strategia di coverage, NON inventarla: `[TODO: target di coverage?]`.
3. **Chiedi solo l'indeducibile** — le due sezioni che nessuno scan può ricavare:
   - *"Cosa NON si deve fare in questo repo?"* (dipendenze cicliche, pattern vietati)
   - *"Cosa dimenticheresti tra 3 mesi?"* (trabocchetti, gotcha, comandi con flag nascosti)
4. **Segnala le incongruenze** che trovi (es. due ORM, test che importano l'app in unit).

Per il brownfield esiste anche il comando nativo `/init`: se l'utente vuole solo uno
scan veloce senza la parte "indeducibile", indirizzalo lì. Questa skill aggiunge valore
proprio sulle ultime due sezioni e sul marcare i `[TODO]`.

---

## Workflow B — Greenfield (solo un'idea)

L'utente sa *cosa* vuole ma **non** la struttura né gli strumenti. Non puoi leggere niente:
devi **intervistare**. Usa domande strutturate (`AskUserQuestion`), un blocco alla volta,
perché ogni risposta vincola la successiva. Non scaricare 10 domande in una volta.

### Blocco 1 — L'idea e il dominio
Una domanda aperta: *"In una frase, cosa vuoi costruire e per chi?"*
Da qui ricavi "Cos'è questo progetto" e "Utenti".

### Blocco 2 — I vincoli (decidono lo stack più dei gusti)
Chiedi (a scelta multipla dove ha senso):
- Dove gira? (web / CLI / mobile / desktop / libreria / servizio backend)
- Vincoli duri? (on-premise, offline, deve girare su un device specifico, budget zero infra,
  team che conosce già un linguaggio)
- Scala attesa? (prototipo usa-e-getta / progetto serio da mantenere / sistema in produzione)

### Blocco 3 — Proponi lo stack (NON imporlo)
Adesso, e **solo adesso**, proponi 2-3 stack coerenti con i vincoli, ognuno con una riga
di motivazione e un trade-off. L'utente non conosceva gli strumenti: il tuo lavoro è dargli
**alternative motivate**, non una decisione calata dall'alto.
Esempio: *"Per una CLI da distribuire senza runtime → Rust (binario singolo, ma curva ripida)
vs Go (più semplice, binario un po' più grosso) vs Python+uv (velocissimo da scrivere, ma
richiede Python sul target)."*
Applica i default del CLAUDE.md globale come punto di partenza, non come dogma.

### Blocco 4 — Architettura minima
In base allo stack scelto, proponi una struttura di cartelle **minima** e i confini chiave
(es. "i router non parlano col DB"). Falla validare. Non sovra-ingegnerizzare un prototipo.

### Blocco 5 — Il "te futuro"
Chiedi: *"C'è qualcosa che già sai sarà un trabocchetto?"* (un'API esterna ostica, un vincolo
di formato, una scelta controintuitiva). Spesso l'utente ha già un'intuizione. Se non ne ha,
lascia la sezione con un `[TODO]` da riempire quando emergerà.

### Dopo l'intervista
1. **Scrivi** il `CLAUDE.md` riempiendo lo schema con le risposte confermate.
2. **Offri lo scaffold**: *"Creo le cartelle e i file segnaposto della struttura concordata?"*
   Se sì, crea le directory e file stub minimi (non codice inventato: cartelle + eventuale
   README per cartella). Se no, fermati al CLAUDE.md.
3. **Elenca i `[TODO]`** rimasti, così l'utente sa cosa manca ancora.

---

## Output

- Scrivi in `./CLAUDE.md` nella root del progetto.
- Parti dalla struttura di `project/CLAUDE.md` del setup, ma **cancella le sezioni vuote**:
  un template con header e nient'altro è rumore. Una sezione c'è solo se ha contenuto vero
  o un `[TODO]` esplicito.
- Alla fine, riepiloga in chat: cosa hai scritto, cosa hai dedotto vs chiesto, e la lista dei
  `[TODO]` aperti. Non incollare l'intero file in chat se è lungo — l'utente lo apre nel repo.

## Passo finale — permessi del progetto

Dopo aver scritto il CLAUDE.md, **proponi un allowlist di comandi per questo repo** e
chiedi all'utente cosa pre-autorizzare, così smette di confermare a mano i comandi di
routine. Va scritto in `.claude/settings.json` del progetto — **mai** nel settings globale:
un allow globale varrebbe anche in repo non fidate.

### Principio
- Pre-autorizza solo comandi **read-only** o del **ciclo di sviluppo** di questo progetto.
- **Mai** pre-autorizzare comandi distruttivi o mutanti: restano a conferma
  (`rm`, `git push`, `git reset --hard`, `alembic upgrade/downgrade`, `docker compose down`,
  `DROP …`, `pip install`, `curl` verso host arbitrari).
- **Chiedi, non decidere**: proponi un set ragionato, l'utente sceglie.

### Cosa proporre (adatta allo stack già rilevato/scelto)

Sempre sicuri (read-only, qualsiasi stack):
`Bash(git status:*)`, `Bash(git diff:*)`, `Bash(git log:*)`, `Bash(git show:*)`,
`Bash(rg:*)`, `Bash(fd:*)`, `Bash(ls:*)`, `Bash(tree:*)`.

Dev loop **Python**:
`Bash(pytest:*)`, `Bash(ruff check:*)`, `Bash(ruff format:*)`, `Bash(mypy:*)`,
`Bash(uv run:*)`, `Bash(uv pip list:*)`, `Bash(alembic current:*)`, `Bash(alembic history:*)`.

Dev loop **JS/TS**:
`Bash(pnpm test:*)`, `Bash(pnpm lint:*)`, `Bash(pnpm build:*)`, `Bash(pnpm typecheck:*)`.

Servizi (solo se il progetto li usa):
`Bash(pg_isready:*)`, `Bash(redis-cli ping)`, `Bash(docker compose ps:*)`, `Bash(docker compose logs:*)`.

⚠️ I comandi che **eseguono codice** del repo (`pytest`, `uv run`, `pnpm test`) sono comodi ma
girano il codice del progetto: vanno bene in un repo fidato. Dillo all'utente quando li proponi.

### Come chiedere
Usa `AskUserQuestion` (multi-select), raggruppando: "Read-only (git/ricerca)" (di norma tutti
sì), "Dev loop <stack>" (l'utente sceglie), "Servizi" (solo se rilevanti). Non proporre mai
voci distruttive, nemmeno come opzione.

### Scrivi
Scrivi `permissions.allow` in `.claude/settings.json` (scope **project**: condiviso e committato
col team). Se l'utente preferisce permessi personali non condivisi, usa
`.claude/settings.local.json` (gitignorato). Se il file esiste già, **fai l'unione** della allow
list — non sovrascrivere ciò che c'era.

## Anti-pattern da evitare

- ❌ Inventare comandi (`make test`) senza aver visto un Makefile
- ❌ Riempire "target di coverage 80%" perché "si fa così" — chiedilo o ometti
- ❌ In greenfield, scegliere lo stack al posto dell'utente senza dargli alternative
- ❌ Scaricare tutta l'intervista in un solo messaggio invece che a blocchi
- ❌ Produrre un CLAUDE.md di 200 righe per un progetto che non esiste ancora
- ❌ Lasciare le sezioni-template con i `[...]` segnaposto originali al posto di `[TODO]` reali
- ❌ Mettere l'allowlist nel settings globale invece che in `.claude/` del progetto
- ❌ Pre-autorizzare comandi distruttivi o mutanti "per comodità"
