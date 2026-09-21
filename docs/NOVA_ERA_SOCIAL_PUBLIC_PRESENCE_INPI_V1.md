# NOVA ERA — SOCIAL / PUBLIC PRESENCE / INPI V1

Status: CANONICAL_NEXT_PHASE
Authority: NICOLAS
Owners: D02 Marketing/Brand + D01 Commercial + D11 Legal/IP + D06 CAnnoNico/Data
Priority: INPI=P0

## 0. Objective

Create one governed public-presence layer for:

LINKEDIN
X
INSTAGRAM
META / FACEBOOK
YOUTUBE
GOOGLE BUSINESS PROFILE
THREADS
PUBLIC WEBSITE
NEWSLETTER
PRESS / MEDIA
INPI / IP MONITORING

with one identity graph, one brand truth, one publication ledger and one evidence trail.

## 1. INPI — P0 PRIORITY

INPI is not a generic public-body connector.

It is a strategic source for:
- Registre national des entreprises (RNE)
- company creations / modifications / cessations
- annual accounts where public
- corporate acts and statutes
- French trademarks
- patents
- designs and models
- legal/administrative status
- IP monitoring
- competitor / partner corporate evidence

Official INPI data routes must be preferred over scraping.

### INPI data feeds
Target official access:
- API / SFTP account
- RNE datasets
- corporate acts
- annual accounts
- trademarks API
- patents API
- designs/models API

### INPI missions inside SUPRA
- verify company identity
- verify directors / corporate status where legally available
- monitor modifications / cessations
- retrieve public annual accounts
- retrieve corporate acts
- trademark availability / conflict research
- monitor NOVA ERA / SUPRA / product marks
- patent/design prior-art research
- competitor IP landscape
- watch filings relevant to products
- evidence pack for legal / commercial / M&A / procurement missions

### INPI human gates
READ / MONITOR = autonomous when authorized
DRAFT_FILING = autonomous preparation
FILE_TRADEMARK = HUMAN_GATE
FILE_PATENT = HUMAN_GATE
FILE_DESIGN = HUMAN_GATE
CHANGE_COMPANY_DATA = HUMAN_GATE
PAY_INPI_FEES = HUMAN_GATE
LEGAL_REPRESENTATION = HUMAN_GATE

## 2. LinkedIn

Targets:
- Nicolas professional identity
- NOVA ERA company page
- product / company posts
- comments / reactions
- page analytics
- followers
- employee / company signals
- prospect research
- company / executive intelligence
- social selling

Preferred:
- official LinkedIn APIs for company-page operations
- approved integration where available
- no brittle browser scraping as canonical write path

Modes:
READ_SIGNALS
DRAFT_POST
PUBLISH_ORGANIC
PUBLISH_SPONSORED
COMMENT
REPLY
ANALYTICS
PROSPECT_RESEARCH

Publishing remains human-gated by default.

## 3. X

Targets:
- brand monitoring
- technical / AI / logistics intelligence
- public conversation
- product updates
- founder commentary
- media monitoring

Preferred:
- official X API custom connector
- approved social-management provider if selected

Modes:
SEARCH
MENTION_MONITOR
DRAFT_POST
PUBLISH
REPLY
THREAD
MEDIA_ATTACH
ANALYTICS

No uncontrolled autonomous public posting.

## 4. Instagram / Meta

Targets:
- Instagram professional account
- Meta page / business assets
- Reels / posts / stories preparation
- comments / replies
- ad performance
- leads / audience signals

Preferred:
- official Meta/Instagram Business APIs
- approved integration provider

Modes:
READ_MEDIA
READ_COMMENTS
DRAFT
PUBLISH
REPLY
ANALYTICS
AD_INSIGHTS

## 5. Content pipeline

REAL_EVENT / PRODUCT / EVIDENCE
→ STORY CANDIDATE
→ AUDIENCE
→ CHANNEL
→ DRAFT
→ FACT CHECK
→ LEGAL / CLAIM CHECK
→ BRAND CHECK
→ HUMAN GATE
→ PUBLISH
→ DELIVERY PROOF
→ ENGAGEMENT
→ LEADS / CUSTOMER SIGNALS
→ COMMERCIAL / PRODUCT
→ MEMORY
→ CANNONICO

## 6. One content object, many channels

Every canonical content asset:
content_id
source_event
source_evidence
message_core
audience
claims
legal_review
media_refs
variants
channels
publication_ids
published_at
performance
lead_links
product_links
company_links
archive
supersession

Channel variants are derived assets, not separate truths.

## 7. Public claim law

Never publish:
- invented customer results
- unproven performance claims
- unapproved legal/regulatory status
- confidential data
- personal data without basis
- fake partnerships
- fake sales
- fake awards/certifications
- speculative claims presented as facts

## 8. Social identity graph

Resolve:
PERSON
COMPANY
BRAND
PRODUCT
SOCIAL_ACCOUNT
PAGE
HANDLE
EMAIL
PHONE
DOMAIN

Identity linking requires evidence.
Do not merge accounts by display name alone.

## 9. Suggested external integrations

### Windsor.ai
Potentially useful as a broad read/action layer for:
- Instagram
- LinkedIn Company Pages / Ads
- Meta / Facebook
- Google Business Profile
- Stripe
- Shopify
- CRM / marketing sources

Use as convenience connector, not source-of-truth replacement.

### Canva
Useful for:
- brand kit
- social creative variants
- resize for Instagram / LinkedIn / Facebook
- repeatable templates

### RingCentral Phone
Useful if adopted for:
- SMS
- calls
- voicemail
- message history
- send SMS

### Custom official connectors
Still required / preferred for:
- X official API
- WhatsApp Business Platform
- INPI
- bank / PSD2
- administrations

## 10. Social universe in SUPRA

Universe: PUBLIC PRESENCE

Views:
- Brand Truth
- Accounts
- Content Pipeline
- Drafts
- Scheduled
- Published
- Engagement
- Leads
- Media
- Reputation
- Social Listening
- Campaigns
- Claims / Proof
- INPI / IP Watch
- Competitor Signals

## 11. INPI universe in SUPRA

INPI remains visible as a P0 strategic module under Legal / IP and Connections.

Views:
- Company identity / RNE
- Corporate acts
- Annual accounts
- Trademarks
- Patents
- Designs & Models
- Watchlists
- Filing candidates
- Conflicts
- Competitors
- Evidence packs
- Deadlines
- Human gates

## 12. Acceptance

SOCIAL_INPI_V1_PASS if:
- LinkedIn / X / Instagram connectors have passports
- public writes are gated
- every publication links to evidence
- INPI official APIs/SFTP are preferred
- RNE / accounts / acts / IP datasets are separated
- trademark/patent/design filing actions are human-gated
- social performance returns to Commercial/Product/Memory
- no unofficial scraping path is canonical for write operations
