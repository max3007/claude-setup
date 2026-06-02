# CLAUDE.md — Preferenze globali

> Questo file è sempre caricato. Tienilo corto e opinionato.
> Tutto ciò che è specifico di un progetto va nel CLAUDE.md di quel repo.

## Come voglio che tu comunichi

- Risposte dirette, niente preamboli ("Ottima domanda!", "Certo!"...)
- Quando spieghi codice, mostra il diff o il file completo, non frammenti senza contesto
- Se non sei sicuro, dillo esplicitamente invece di inventare
- Non scusarti ripetutamente — riconosci l'errore una volta e correggi
- Italiano per la conversazione, inglese per codice/commenti/commit
- Non coniugare termini inglesi in italiano: di' "fare un commit", "creare un symlink", "dividere in più commit" — non "committare", "linkare", "splittare", "pushare"

## Stile di lavoro

- **Prima capire, poi agire**: per task non triviali, dimmi il piano prima di eseguirlo
- **Piccoli passi**: preferisci più commit piccoli a un commit gigante
- **Mostra il lavoro**: dopo aver modificato file, fai un riepilogo di cosa hai cambiato e perché
- **Niente "ho finito" prematuri**: dichiara completo solo dopo che test/lint passano

## Default tecnici (se il progetto non specifica altro)

- Linguaggi: **Python con type hints** come default; TypeScript per il frontend; Rust per CLI dove servono performance o distribuzione di un binario
- Package manager: `uv` per Python, `pnpm` per JS/TS
- Test: scrivili insieme al codice, non dopo
- Formatter: usa quello del progetto. Se non c'è: Prettier (JS/TS), Ruff (Python), rustfmt (Rust)
- Stringhe: virgolette doppie ovunque tranne dove la lingua impone il contrario

## Stack ricorrente (i miei progetti più comuni)

Molti miei progetti condividono lo stesso impianto. Quando un repo lo usa, valgono questi default — il CLAUDE.md del progetto può sovrascriverli.

- **DB**: PostgreSQL + Alembic. Le migration generate con `--autogenerate` vanno **sempre riviste a mano** prima di applicarle (autogenerate sbaglia spesso con enum, indici e tipi custom).
- **Cache/coda**: Redis. Tratta i dati come volatili, non come persistenti.
- **Runtime locale**: Docker Compose. Prima di concludere "non funziona", verifica che i servizi (db, redis) siano su.
- **Bot Telegram**: il token sta in una env-var (`TELEGRAM_BOT_TOKEN`), **mai** hardcoded, **mai** dentro regole di permesso o comandi committati.
- **Segreti in generale**: env-var o secret manager. Se vedi un segreto in chiaro in un file di config (incluso `settings.json`), **segnalalo** invece di usarlo.

## Operazioni distruttive

Chiedi conferma esplicita prima di:
- `rm -rf`, `git reset --hard`, `git push --force`
- `DROP TABLE`, migrazioni che eliminano colonne
- Modificare file fuori dal repo corrente
- Installare dipendenze globali

Per operazioni reversibili (creare branch, fare commit locali) procedi senza chiedere.

## Cosa NON fare mai

- Non committare segreti, chiavi API, `.env` con valori reali
- Non riscrivere la storia di branch condivisi (`main`, `develop`, release branches)
- Non disattivare test che falliscono — capisci il perché
- Non aggiungere dipendenze senza spiegare cosa risolvono
- Non generare commenti ovvi (`// incrementa i`)

## Quando lavori in shell

- Usa `rg` invece di `grep`, `fd` invece di `find` se disponibili
- Mostra il comando prima di eseguirlo se è non banale
- Per output lunghi, pipe in `head` o usa `--limit` invece di stampare tutto

## Quando lavori con git

- Commit message in inglese, formato Conventional Commits (vedi skill `commit-messages`)
- Un commit = una unità logica di cambiamento
- Prima del commit: `git diff --staged` per rileggere cosa stai committando
- Mai `git add .` senza prima un `git status`
