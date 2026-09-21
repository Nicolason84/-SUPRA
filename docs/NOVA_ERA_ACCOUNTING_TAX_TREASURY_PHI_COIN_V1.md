# NOVA ERA — ACCOUNTING / TAX / TREASURY / Φ-COIN V1

Status: NEXT_CANONICAL_PHASE
Authority: NICOLAS
Owners: D10 Finance + D11 Legal/Risk + D06 CAnnoNico/Data + D04 R&D
Principles: PROOF_FIRST / NO_FAKE_MONEY / NO_SILENT_LEGAL_CLASSIFICATION / FULL_LINEAGE / CIRCULARITY

## 0. Objective

Build one finance truth layer connecting:

REAL BUSINESS EVENT
→ COMMERCIAL DOCUMENT
→ ACCOUNTING EVENT
→ TAX EVENT
→ CASH EVENT
→ EVIDENCE
→ CANNONICO
→ MANAGEMENT DECISION

And separately:

REAL COHERENT ACTIVITY
→ Φ-PROOF
→ Φ-LEDGER
→ Φ-COIN INTERNAL EVENT
→ USAGE
→ VALUE FEEDBACK
→ CANNONICO

The EUR/accounting ledger and Φ-ledger must be linked but NEVER silently merged.

## 1. Finance architecture

### A. Accounting Core
Maintain:
- chart of accounts mapping
- journal entries
- customer ledger
- supplier ledger
- bank/cash ledger
- fixed assets
- accruals / prepaid / deferred items
- VAT states
- closing controls
- supporting-document links
- immutable audit trail
- period locks
- accountant export / import contracts

Every accounting record requires:
event_id
source_document
economic_date
posting_date
amount
currency
tax
counterparty
account_mapping
evidence
authority
status
reversal_link
confidence

No accounting record becomes canonical from OCR/text extraction alone.

### B. Tax / Fiscality
Maintain a monitored obligation registry:
- VAT
- corporate income tax / tax on profits
- payroll/social obligations when applicable
- local taxes where applicable
- withholding / reporting obligations
- electronic invoicing / e-reporting
- digital-asset / token-related obligations if classification applies
- filing dates
- payment dates
- source-of-law
- effective date
- company applicability
- proof of filing/payment

Primary-source monitoring:
- BOFiP / impots.gouv.fr
- economie.gouv.fr / DGFiP
- Légifrance
- BOSS for social obligations
- ANC / French accounting standards
- AMF / EU law when Φ-Coin classification requires it

### C. Treasury
Maintain:
- bank balances
- receivables
- payables
- cash forecast
- collection schedule
- payment schedule
- tax reserve
- payroll/social reserve if applicable
- supplier commitments
- runway
- working-capital needs
- currency exposure if relevant

Never infer CASH from INVOICE.
Never infer REVENUE from CASH.
Never infer PAYMENT from BANK BALANCE.

### D. Electronic invoicing
The system must support:
- receiving electronic invoices
- emission readiness according to legal timetable
- platform/PA integration
- structured invoice metadata
- e-reporting fields
- payment-status data where required
- immutable transmission receipts

## 2. Φ-Coin — historical reconciliation

Official name: Φ-Coin.

Historical designs to preserve, not overwrite:

### HISTORICAL_BRANCH_A — coherent-energy unit
Earlier design:
- 1 Φ tied conceptually to 1 coherent kWh
- energy production
→ Φ-ProofGraph measurement
→ Φ-Ledger validation
→ Φ-Exchange circulation
→ CNCΦ ethical audit
- Φ-Score 0–1
- local wallets / exchange concepts
- sandbox with real microgrid data was envisioned

### HISTORICAL_BRANCH_B — internal utility / activity unit
Later design:
- internal unit tied to real coherent activity
- issuance may arise from validated purchases / production / use / contribution
- closed NOVA circulation initially
- no external speculation initially
- a historical design mentioned MAX 25% convertible to EUR and MIN 75% retained
- Φ-Score thresholds:
  >= 0.7 VALID
  0.5–0.7 ADJUST
  < 0.5 REFUSE

### HISTORICAL_BRANCH_C — internal credit implementation
A later implementation path used an internal coin wallet tied to paid-order events.
That implementation is evidence of experimentation, not final legal/economic definition.

## 3. Current canonical live position

Until explicit legal + tax + accounting classification is proven:

PHI_COIN_MODE=INTERNAL_SANDBOX_ONLY
PUBLIC_ISSUANCE=NO
PUBLIC_TRADING=NO
EXTERNAL_SPECULATION=NO
GUARANTEED_EUR_REDEMPTION=NO
EUR_CONVERTIBILITY=DISABLED_PENDING_CLASSIFICATION
CUSTOMER_MONEY_SUBSTITUTE=NO
LEGAL_CLASSIFICATION=UNRESOLVED
ACCOUNTING_CLASSIFICATION=UNRESOLVED
TAX_CLASSIFICATION=UNRESOLVED

The historic 25% EUR-conversion concept is retained as a design hypothesis, NOT an active right or promise.

## 4. Φ-Coin object model

Every Φ event must contain:

phi_event_id
wallet_id
subject_id
event_type
source_business_event
source_proof
phi_amount
phi_score
formula_version
issued_at
expires_at_if_any
transferability
redeemability
economic_value_reference
legal_classification
accounting_classification
tax_classification
authority
status
reversal_event
evidence_refs

Statuses:
PROPOSED
SIMULATED
VALIDATED_INTERNAL
BLOCKED_LEGAL
BLOCKED_ACCOUNTING
BLOCKED_TAX
REVERSED
ARCHIVED

## 5. Φ issuance engine

No periodic arbitrary minting.

Candidate issuance only from PROVEN events, for example:
- measured coherent production
- validated contribution
- validated product/service usage
- validated purchase/payment
- verified efficiency gain
- verified reuse/reinvestment event

Every candidate passes:

SOURCE_PROOF
→ FORMULA
→ Φ-SCORE
→ DUPLICATE CHECK
→ AUTHORITY
→ LEGAL/TAX/ACCOUNTING GATE
→ LEDGER

Idempotency is mandatory.
One source event must never mint twice.

## 6. Φ-Score

Keep the historical threshold model as an R&D policy candidate:

>= 0.70 = VALID
0.50–0.69 = ADJUST / REVIEW
< 0.50 = REFUSE

But the formula itself must be versioned, explainable, evidence-backed and non-retroactive unless explicitly reprocessed.

## 7. Accounting separation

The Φ-Ledger is NOT the general ledger.

Links are explicit:

BUSINESS EVENT
→ EUR/ACCOUNTING IMPACT (if any)
→ TAX IMPACT (if any)
→ Φ IMPACT (if any)

For each Φ event ask independently:
1. Is there a customer/supplier transaction?
2. Is there revenue/expense?
3. Is there VAT?
4. Is there a liability/obligation?
5. Is there a benefit in kind / rebate / loyalty treatment?
6. Is there a crypto-asset / e-money / payment-services implication?
7. Is there a taxable disposal/exchange event?

Answers remain UNRESOLVED until evidence/classification exists.

## 8. Φ Wallet

Internal wallet V1 requirements:
- wallet identity
- immutable history
- balance derived from ledger, never manually stored as truth
- pending vs validated balance
- proof opening
- source business-event opening
- reversal support
- duplicate prevention
- export
- audit view

No wallet may represent EUR cash.

## 9. Φ-Ledger

Append-only event ledger:
- signed event hash
- previous hash / chain
- source proof
- formula version
- authority
- timestamp
- status
- reversal references

Merkle / cryptographic aggregation may be used where it adds verifiability, but must not create false blockchain claims.

## 10. Φ circularity

Target loop:

REAL VALUE
→ PROOF
→ Φ
→ INTERNAL USE
→ REINVESTMENT / CONTRIBUTION
→ NEW REAL VALUE
→ NEW PROOF

Φ-Coin exists to measure and circulate coherent value, not to create speculative value disconnected from real activity.

## 11. Legal / regulatory gate

If future design introduces any of the following:
- public offer
- transfer to the public
- trading venue
- guaranteed or marketed redemption
- reference to EUR or another asset as stable value
- custody/exchange services
- payment functionality

then classification must be re-run against applicable French/EU frameworks before activation.

No product/UI language may call Φ-Coin a regulated status it has not actually obtained.

## 12. Finance ↔ Library / Patrimony

Every:
- invoice
- credit note
- tax filing
- bank statement
- payment proof
- accounting export
- Φ formula
- Φ event
- wallet export
- legal opinion
- classification decision

must be indexed in Library / Patrimony with privacy class, provenance and retention policy.

## 13. Finance ↔ Organization

D10 Finance:
- accounting truth
- treasury
- invoice/collection
- tax operations coordination
- management reporting

D11 Legal/Risk:
- legal classification
- contractual wording
- regulatory boundaries

D06 CAnnoNico/Data:
- provenance
- canonicality
- evidence
- reconciliations

D04 R&D:
- Φ formula
- coherence science
- simulation
- measurement

D03 Product:
- wallet/product experience only after gates

D05 Engineering:
- implementation and controls

## 14. Required dashboards

### Finance
- cash
- receivables
- payables
- invoiced
- collected
- VAT
- tax reserves
- filing calendar
- closing status
- runway
- margin

### Φ-Coin
- total internal Φ issued
- pending
- validated
- reversed
- wallets
- source-event classes
- Φ-score distribution
- duplicate-prevention health
- blocked legal/tax/accounting events
- real-value return loop

## 15. Hard invariants

NO_FAKE_CASH
NO_FAKE_REVENUE
NO_FAKE_TAX_STATUS
NO_FAKE_CRYPTO_CLASSIFICATION
NO_DOUBLE_MINT
NO_SILENT_REDEMPTION_PROMISE
NO_PUBLIC_TRADING_WITHOUT_GATE
NO_LEDGER_OVERWRITE
ALL_REVERSALS_TRACEABLE
ALL_FIAT_AND_PHI_RELATIONS_EXPLICIT

## 16. Acceptance

FINANCE_PHI_V1_PASS only if:
- accounting source documents are linked
- tax calendar is source-backed
- e-invoicing readiness is mapped
- bank/cash/revenue distinctions are enforced
- Φ historical branches are preserved
- current Φ mode is explicit
- Φ ledger is append-only
- idempotency is proven
- accounting ledger and Φ ledger are separate
- every Φ event has source proof
- no external convertibility/public trading is enabled by default
- legal/accounting/tax classifications are explicit or UNRESOLVED
- Library and Organization links are active

## 17. Current official-source notes (2026-09)

- France electronic invoicing reform is live in reception from 2026-09-01 for all companies.
- Emission/e-reporting dates depend on company category.
- Any future external crypto-asset design must be checked against then-current EU/French rules before activation.

These are implementation triggers, not substitutes for accountant/legal validation.
