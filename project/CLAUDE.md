# CLAUDE.md — [NOME PROGETTO]

> Template da personalizzare. Sostituisci tutto ciò che è tra `[...]`.
> Cancella le sezioni che non si applicano. Meglio corto e vero che lungo e finto.

## Cos'è questo progetto

[Una frase. Es: "API REST per gestire ordini e magazzino, consumata dal frontend Next.js in `../frontend`."]

**Stato**: [WIP / produzione / legacy]
**Utenti**: [chi lo usa]
**Vincoli importanti**: [es: deve girare on-premise, deve supportare IE11, ecc.]

## Stack

- **Linguaggio**: [es. Python 3.12]
- **Framework**: [es. FastAPI + SQLAlchemy 2.0]
- **Database**: [es. PostgreSQL 16]
- **Test**: [es. pytest + httpx]
- **Deploy**: [es. Docker → AWS ECS via GitHub Actions]

## Architettura in 60 secondi

[Descrivi il flusso principale. Es:]

```
HTTP request → router (api/) → service (services/) → repository (db/)
                                       ↓
                            event bus (events/) → workers
```

- I router NON parlano mai col DB direttamente
- I service NON conoscono HTTP (niente `Request` come argomento)
- I repository NON contengono logica di business

## Convenzioni di nomi

- File: `snake_case.py`
- Classi: `PascalCase`, funzioni/variabili: `snake_case`
- Test: `test_<modulo>.py`, una classe `Test<Cosa>` per ogni unità testata
- Branch: `feat/`, `fix/`, `chore/`, `refactor/` + descrizione kebab-case
  - es: `feat/order-cancellation`, `fix/race-condition-in-checkout`

## Dove vivono le cose

```
src/
├── api/          # router HTTP, validazione input/output
├── services/     # logica di business, orchestrazione
├── db/           # modelli SQLAlchemy + repository
├── events/       # publisher/subscriber
└── core/         # config, logging, eccezioni custom

tests/
├── unit/         # niente DB, niente network
├── integration/  # con DB reale (testcontainers)
└── e2e/          # via HTTP, contro l'app montata
```

## Test: cosa ci aspettiamo

- Ogni nuovo endpoint → almeno 1 test e2e (happy path) + 1 test unit per il service
- Bug fix → prima il test che riproduce, poi il fix
- Niente mock del DB nei test integration (usa testcontainers)
- Target di coverage: 80% sulle services/, non ci interessa coprire router banali

## Cose che il tuo "io futuro" dimenticherà

- Le migration vanno create con `alembic revision --autogenerate` MA poi vanno **sempre** riviste a mano (autogenerate spesso sbaglia con gli enum)
- Il client HTTP per il servizio X richiede `Idempotency-Key` su tutte le POST
- I timestamp nel DB sono in UTC. Convertire al fuso utente solo al confine HTTP
- `make dev` carica `.env.local`, NON `.env` (che è il template committato)

## Cosa NON fare in questo repo

- Non aggiungere ORM diversi da SQLAlchemy
- Non importare da `services/` dentro `db/` (dipendenza ciclica)
- Non chiamare API esterne dai service senza passare per `core/http_client.py` (ha retry + tracing)
- Non aggiungere endpoint senza updatare lo OpenAPI schema (`make docs`)

## Comandi che uso spesso

```bash
make dev              # avvia con hot reload
make test             # tutti i test
make test-unit        # solo unit, veloce
make lint             # ruff + mypy
make migrate          # applica migration in locale
make docs             # rigenera OpenAPI
```
