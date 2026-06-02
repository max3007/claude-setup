---
name: debug-systematically
description: Use this skill when the user is debugging — when they report something is broken, not working, throwing an error, behaving unexpectedly, intermittent, flaky, or "works on my machine". Also use when they paste a stack trace, error message, or describe a bug and ask for help. Enforces a hypothesis-driven approach instead of random changes, helps isolate the bug before fixing, and prevents "fixed" reports without a verified root cause.
---

# Debug sistematico

## Regola d'oro

**Una modifica alla volta.** Se cambio due cose e il bug sparisce, non so quale delle due era il problema. Il bug può tornare in produzione perché ho "risolto" la cosa sbagliata.

## Workflow

### Fase 1 — Riprodurre

Prima di toccare qualsiasi cosa:
1. **Riproduci il bug deterministicamente.** Se non riesco a riprodurlo, non posso sapere se l'ho risolto.
2. Se è intermittente: trova il fattore variabile (ordine dei test, timing, dati di input, fuso orario, cache).
3. Riduci al minimo: qual è l'input più piccolo che ancora rompe? (vedi "minimal reproducible example")

Se l'utente dice "a volte non funziona" e non c'è un repro, **il primo task è trovare un repro**, non scrivere il fix.

### Fase 2 — Localizzare

Restringere lo spazio di ricerca prima di leggere codice a caso:

- **Bisection temporale**: `git bisect` se ieri funzionava
- **Bisection spaziale**: commenta metà del codice, vedi se il bug persiste, ripeti
- **Logging chirurgico**: stampa input/output ai confini delle funzioni sospette. Non spammare log ovunque.
- **Stack trace letta dal basso**: l'eccezione finale è spesso un sintomo. La causa è più in alto.

### Fase 3 — Formulare un'ipotesi

**Scrivi l'ipotesi prima di testarla**, anche solo nella tua testa:

> "Penso che il bug sia X perché Y. Se ho ragione, mi aspetto di vedere Z."

Poi verifica Z. Se vedi Z → ipotesi confermata. Se non vedi Z → ipotesi sbagliata, formulane un'altra.

Senza questo passo, finisci a fare debugging "shotgun": cambi cose a caso finché qualcosa funziona, senza capire perché.

### Fase 4 — Fix

Solo ora si scrive codice:
1. Il fix deve indirizzare la **causa**, non il sintomo
2. Il fix deve essere il più piccolo possibile che risolve il problema
3. Aggiungi un **test di regressione** che fallirebbe senza il fix
4. Esegui il test prima e dopo il fix per dimostrare che cattura il bug

### Fase 5 — Verifica

- Il repro originale ora passa
- I test esistenti passano ancora
- Il nuovo test di regressione passa
- Hai capito **perché** funzionava prima sembrare di funzionare (se applicabile)

## Pattern di bug ricorrenti

Prima di andare in fondo a una tana del coniglio, controlla se è uno di questi:

| Sintomo | Sospetta |
|---------|----------|
| Funziona in dev, rotto in prod | Variabili d'ambiente, race condition, cache, dati reali ≠ seed |
| Funziona la prima volta, poi no | Stato globale, cache, connection pool esaurito |
| Test passano da soli, falliscono in suite | Ordine dei test, stato condiviso, mock leak |
| Funziona oggi, rotto domani | Date hardcoded, certificati scaduti, dipendenza esterna cambiata |
| Funziona su Mac, rotto su Linux | Case sensitivity del filesystem, line endings, path separator |
| Errore "undefined" | Race condition async, import circolare, hot reload sporco |
| Rotto solo per alcuni utenti | Encoding (emoji, accenti), fuso orario, permessi, dati legacy |

## Anti-pattern da evitare

- ❌ "Riavvia il server" come soluzione — è un workaround, non un fix
- ❌ Aggiungere `try/except: pass` per far sparire l'errore
- ❌ Aggiungere `sleep()` per "risolvere" una race condition
- ❌ Dichiarare "risolto" senza un test che lo dimostri
- ❌ Fare 5 modifiche contemporaneamente e vedere se il bug sparisce
- ❌ Modificare il test invece del codice quando il test fallisce "ingiustamente"

## Cosa riferire all'utente

Quando hai finito, dichiara esplicitamente:

1. **Causa**: cosa stava succedendo davvero (non solo "ho cambiato X")
2. **Fix**: cosa hai modificato e perché risolve la causa
3. **Verifica**: come hai dimostrato che funziona (test, repro, log)
4. **Rischi residui**: c'è altro codice che potrebbe avere la stessa classe di bug?

Se non hai trovato la causa ma hai solo un workaround, **dillo chiaramente**. "Bug nascosto sotto il tappeto" è peggio di "bug aperto".
