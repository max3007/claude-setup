---
name: code-review
description: Use this skill when the user asks for a code review, to review a diff, to review a pull request, to check code before merging, to provide feedback on code changes, or asks "what do you think of this code". Also use when the user pastes a diff/PR link and asks for opinions, problems, or improvements. Provides a structured review covering correctness, design, tests, security, and style — with severity levels so the user knows what blocks merge vs what's a nit.
---

# Code review

## Cosa controllo, in quest'ordine

Salto immediatamente al **risultato**, non recito tutto il codice all'utente. La review è in 5 passaggi.

### 1. Correttezza (blocker)
- La logica fa ciò che il commit message/PR description dichiara?
- Edge case: null, lista vuota, off-by-one, overflow, divisione per zero, input duplicati
- Race condition: stato condiviso, accessi concorrenti, ordine di scrittura
- Error handling: gli errori vengono ingoiati silenziosamente?
- Side effect inattesi: scrive su disco, manda email, modifica globals?

### 2. Sicurezza (blocker se applicabile)
- Input non validato che finisce in: SQL, shell, file path, HTML, regex
- Secret hardcoded o loggati
- Autorizzazione mancante su endpoint o operazioni
- Dipendenze nuove: chi le mantiene? Quante stelle? Ultima release?

### 3. Design (major)
- Sta nel posto giusto? (es: logica di business in un controller HTTP = no)
- Astrazione prematura o duplicazione tollerabile?
- Nomi: una funzione `process()` non dice nulla
- Funzione troppo lunga (> ~50 righe) o troppi parametri (> ~5)?
- API pubbliche: sono retro-compatibili? Documentate?

### 4. Test (major)
- C'è un test che fallirebbe senza questa modifica?
- I test testano comportamento o implementazione?
- Coperti gli edge case del punto 1?
- Test deterministici? (no `time.now()`, no random senza seed, no ordine-dipendenti)

### 5. Stile (nit)
- Convenzioni del progetto rispettate?
- Commenti utili (perché) vs rumorosi (cosa)?
- Codice morto, import non usati, console.log dimenticati

## Formato dell'output

Organizza per **severità**, non per file. L'utente deve sapere subito cosa blocca.

```markdown
## Review di [PR / diff]

### 🔴 Blockers (da risolvere prima del merge)
1. **[file:linea]** — descrizione. Suggerimento concreto.

### 🟡 Major (forte raccomandazione)
1. **[file:linea]** — ...

### 🟢 Nits (opzionali, a discrezione)
1. **[file:linea]** — ...

### 👍 Cose fatte bene
- Una o due cose genuinamente buone (non lecca-piedi)
```

## Regole d'oro

- **Sii specifico**: "questa funzione fa troppe cose" è inutile. "Estrai le righe 12-30 in `validateOrderPayload` e testala separatamente" è utile.
- **Mostra, non dire**: per ogni problema, proponi il fix in codice (anche se 3 righe).
- **Non inventare problemi** per riempire la review. Se la PR è piccola e pulita, dillo.
- **Distinguere preferenze da regole**: "io preferirei X" ≠ "questo è sbagliato".
- **Non rifare la PR**: se hai 15 blocker, il codice forse non è pronto per review. Dillo all'autore invece di sommergerlo.

## Cosa NON fare

- Non riassumere il diff riga per riga — l'utente lo ha già letto
- Non dire "questo codice è buono" senza motivare
- Non insistere su stile se il progetto ha un linter (il linter ha ragione, non tu)
- Non chiedere modifiche su codice non toccato dalla PR (drive-by changes vanno in PR separate)

## Quando il diff è grosso

Se > ~500 righe modificate:
1. Suggerisci subito di splittare la PR e spiega come
2. Fai comunque la review, ma avvisa che la qualità diminuisce sopra questa soglia
3. Concentrati su architettura/design, non sui dettagli
