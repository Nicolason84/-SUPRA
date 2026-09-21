# NOVA ERA — EXTERNAL CONNECTIVITY FABRIC V1

Status: CANONICAL_CONNECTIVITY_MODEL
Authority: NICOLAS
Owners: D05 Engineering/Platform + D06 CAnnoNico/Data + D10 Finance + D11 Legal/Risk + D12 People where relevant
Mode: READ_FIRST / LEAST_PRIVILEGE / PROOF_FIRST / HUMAN_GATED_ACTIONS / NO_SECRET_IN_MEMORY

## 0. Objective

Connect SUPRA to the real external world through one governed fabric:

EMAIL
SMS / PHONE
WHATSAPP
CALENDAR
CONTACTS
DRIVE / DOCUMENTS
BANKING / OPEN BANKING
PAYMENTS
ACCOUNTING
TAX / ADMINISTRATIONS
SOCIAL / PUBLIC ORGANISMS
CRM / SALES
E-COMMERCE
SUPPLIERS / PARTNERS
OFFICIAL APIs
WEBHOOKS

All external signals must return through:
SOURCE
→ AUTHENTICATION
→ PERMISSION
→ OBSERVATION
→ NORMALIZATION
→ EVIDENCE
→ MISSION
→ ACTION GATE
→ RESULT
→ MEMORY
→ CANNONICO

## 1. Core law

ONE_CONNECTIVITY_FABRIC
MANY_EXTERNAL_SYSTEMS
ONE_AUTHORITY_MODEL
ONE_EVIDENCE_MODEL
NO_SHARED_SECRET_SPRAWL
NO_SILENT_WRITE
NO_SILENT_PAYMENT
NO_SILENT_PUBLICATION
NO_SILENT_LEGAL_SUBMISSION
NO_SCRAPING_WHEN_OFFICIAL_API_EXISTS

## 2. Connection classes

### C0 — READ_PUBLIC
Public APIs / public documents.
No account authority.

### C1 — READ_PRIVATE
Read connected private account data.
Examples:
- Gmail
- Calendar
- Contacts
- Drive
- bank transactions read-only
- tax documents read-only

### C2 — WRITE_REVERSIBLE
Draft/create/update reversible objects.
Examples:
- email drafts
- calendar events
- CRM notes
- labels
- task updates

### C3 — COMMUNICATION_SEND
Send externally:
- email
- SMS
- WhatsApp Business message
- partner/customer messages
Requires explicit send authority or policy-bound automation.

### C4 — FINANCIAL_PREPARE
Prepare:
- payment proposal
- transfer batch
- invoice
- reconciliation
- tax payment plan
No money moves yet.

### C5 — FINANCIAL_EXECUTE
Move money / charge / refund / bank transfer.
HUMAN_GATE=MANDATORY unless a separately approved bounded policy exists.

### C6 — LEGAL_ADMIN_SUBMIT
Submit to administration / regulator / tax / social organism.
HUMAN_GATE=MANDATORY.

## 3. Existing immediately available connections

### Gmail
Capabilities:
- search/read email
- threads
- attachments
- drafts
- send/forward
- labels/archive

Policy:
READ may be autonomous when mission-authorized.
SEND remains human-gated by default for external-impact messages.

### Google Calendar
Capabilities:
- read/search events
- availability
- create/update/delete
- invitation response

### Google Contacts
Capabilities:
- search/read contacts

### Google Drive
Capabilities:
- search/read
- Docs/Sheets/Slides
- create/update
- comments
- folder operations
- exports/imports

These are first-class sources for External Connectivity Fabric.

## 4. SMS / Phone

Preferred supported route:
- official telephony/SMS provider connector
- business phone system
- provider API

Connection contract:
conversation_id
counterparty
phone_number
direction
timestamp
message
delivery_status
provider_message_id
evidence_ref
privacy_class

Sending requires:
communication policy
recipient validation
content check
authority
delivery proof

No consumer-phone database scraping as canonical integration.

## 5. WhatsApp

Preferred path:
WHATSAPP BUSINESS PLATFORM / approved provider API.

Do not automate personal WhatsApp by brittle UI scraping or unofficial reverse-engineered clients.

Required objects:
wa_business_account
phone_number_id
conversation
template
message_id
delivery/read status
media refs
customer consent/basis where applicable

Modes:
READ_SYNC
DRAFT
SEND_TEMPLATE
SEND_SESSION_MESSAGE
MEDIA_SEND

Human gate:
first-contact / sensitive / contractual / financial / legal messages.

## 6. Banking / Open Banking

Preferred:
official bank API or regulated PSD2/Open Banking provider.

Start READ-ONLY.

Read objects:
accounts
balances
transactions
counterparties
bank statements
pending transactions
fees
IBAN metadata
cash positions

Finance pipeline:
BANK_EVENT
→ NORMALIZATION
→ MATCHING
→ INVOICE/PAYMENT LINK
→ ACCOUNTING PROPOSAL
→ EVIDENCE
→ HUMAN/ACCOUNTANT REVIEW

Never infer:
BANK_TRANSACTION = ACCOUNTING_ENTRY
BANK_BALANCE = AVAILABLE_CASH
TRANSFER_REQUEST = EXECUTED_TRANSFER

Payment execution must be separately permissioned.

## 7. Payments

Examples:
Stripe or other payment processors.

Read:
customers
payments
refunds
payouts
fees
invoices/subscriptions where available

Write:
payment links / refunds / subscription changes only under explicit authority.

Every payment object links to:
commercial event
invoice
customer
bank settlement
accounting entry
tax treatment
evidence

## 8. Accounting systems

Potential systems:
- accounting SaaS
- accountant exports
- ERP
- spreadsheet imports
- FEC-compatible exports where applicable

SUPRA must support:
import
reconciliation
mapping
exceptions
closing evidence
audit trail
export back to accountant/system

No autonomous posting to statutory books until accounting owner approves policy.

## 9. Administrations / Organisms

Connection priority:

1. OFFICIAL API
2. OFFICIAL EXPORT / DOWNLOAD
3. OFFICIAL EMAIL / NOTIFICATION
4. AUTHENTICATED PORTAL WITH HUMAN-AUTHORIZED BROWSER AUTOMATION
5. MANUAL ONLY if no supported digital interface

Target classes:
- DGFiP / impôts
- URSSAF / social bodies
- INPI
- INSEE / SIRENE
- France Travail
- Bpifrance
- local authorities
- customs where relevant
- ADEME / public funding
- grants / tenders
- public procurement portals
- insurance organisms
- banks
- professional registries

Do not treat FranceConnect as a generic data API.
Authentication mechanism ≠ business-data interface.

## 10. Administrative action gate

READ_DOCUMENT=may be autonomous
CHECK_STATUS=may be autonomous
PREPARE_FORM=may be autonomous
DRAFT_DECLARATION=may be autonomous

SUBMIT_DECLARATION=HUMAN_GATE
ACCEPT_TERMS=HUMAN_GATE
SIGN=HUMAN_GATE
PAY_TAX=HUMAN_GATE
CHANGE_LEGAL_DATA=HUMAN_GATE
CREATE_BINDING_COMMITMENT=HUMAN_GATE

## 11. Identity and secrets

Secrets may live only in:
- OS keychain
- provider OAuth/token vault
- approved secret manager
- ephemeral runtime memory

Never in:
- Git repository
- CAnnoNico plain text
- chat memory
- Drive documents
- logs
- screenshots
- Library/Patrimony index

Store only secret references:
credential_ref
provider
scope
owner
created_at
expires_at
rotation_status

## 12. Connector passport

Every connector must have:

connector_id
provider
account_identity
environment
auth_type
credential_ref
read_scopes
write_scopes
money_movement
legal_submission
data_classes
owner
human_gate
rate_limit
webhook_support
last_sync
last_success
last_error
evidence
status

Statuses:
DISCOVERED
CONNECTABLE
AUTH_REQUIRED
CONNECTED_READ
CONNECTED_WRITE
DEGRADED
REVOKED
BLOCKED

## 13. Event normalization

Every external event becomes a normalized envelope:

external_event_id
provider
connector_id
source_object_id
source_type
event_type
occurred_at
observed_at
counterparty
subject
payload_ref
media_refs
evidence_hash
privacy_class
commercial_link
finance_link
mission_link
canonical_status

Payload remains at authoritative source when possible.

## 14. Unified Communication Inbox

Target SUPRA universe:
COMMUNICATIONS

Streams:
EMAIL
SMS
WHATSAPP
CALLS
VOICEMAIL
CALENDAR
CONTACT_REQUESTS
CRM_COMMUNICATION

Capabilities:
- search across channels
- one contact timeline
- one customer/company timeline
- action items
- draft reply
- channel-aware reply
- follow-up queue
- commitment extraction
- evidence links

Never merge identities solely by similar names.
Identity linking requires evidence.

## 15. External Accounts universe

Target SUPRA universe:
CONNECTIONS

Views:
- Connected accounts
- Health
- Permissions
- Last sync
- Pending human gates
- Revoked/expired auth
- Connector map
- Data flow
- Webhooks
- Errors
- Credential rotation status

## 16. Automation

Allowed autonomous loops:
- inbox triage
- attachment indexing
- contact/company matching
- transaction reconciliation proposals
- deadline detection
- administrative status monitoring
- follow-up reminders
- webhook ingestion
- stale credential detection
- provider health monitoring

Human-gated:
- external send when materially consequential
- money movement
- legal/admin submission
- contract acceptance
- sensitive data disclosure
- identity/authority changes

## 17. Banking + Tax + Phi integration

External Finance:
BANK
→ PAYMENT
→ ACCOUNTING
→ TAX
→ CASH
→ EVIDENCE

Phi:
REAL_EVENT
→ PROOF
→ PHI_LEDGER

No banking connector may mint Φ directly.
Only a validated business/proof event may become a Φ source event.

## 18. Current connection plan

PHASE A — AVAILABLE NOW
- Gmail
- Google Calendar
- Google Contacts
- Google Drive
- GitHub

PHASE B — CONNECT VIA PLUGIN / PROVIDER
- SMS / phone
- payment processor
- CRM if selected

PHASE C — CUSTOM OFFICIAL API CONNECTORS
- WhatsApp Business
- bank / PSD2 Open Banking
- accounting software
- tax/admin APIs
- URSSAF/public bodies
- selected insurers / institutions

PHASE D — AUTHENTICATED PORTAL AUTOMATION
Only where no API exists and terms/authority allow it.

## 19. Acceptance

CONNECTIVITY_V1_PASS only if:
- all connectors have passports
- scopes are explicit
- secrets are not stored in general memory
- READ and WRITE are separate
- money movement is gated
- legal/admin submission is gated
- communications preserve delivery evidence
- normalized events return to CAnnoNico
- external account identities are evidence-linked
- revoked/expired credentials are visible
- no unofficial WhatsApp or banking workaround is presented as canonical
- connector health is observable

## 20. Target

ONE EXTERNAL NERVOUS SYSTEM
ONE AUTHORITY MODEL
ONE CONNECTION REGISTRY
MANY PROVIDERS
READ-FIRST
WRITE-BOUNDED
MONEY/LEGAL HUMAN-GATED
EVERY RESULT RETURNS TO MEMORY
