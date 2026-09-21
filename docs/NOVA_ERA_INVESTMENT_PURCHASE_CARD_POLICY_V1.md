# NOVA ERA — INVESTMENT / PURCHASING / COMPANY CARD POLICY V1

Status: POLICY_DEFINED_PENDING_OPERATIONAL_LIMITS
Authority: NICOLAS
Owners: D00 + D10 + D11
Scope: founder, associates, employees, contractors, departments and digital workers

## 1. Core separation

SHAREHOLDING != BANK AUTHORITY
BANK AUTHORITY != CARD AUTHORITY
CARD AUTHORITY != PURCHASE APPROVAL
PURCHASE APPROVAL != INVESTMENT APPROVAL
INVESTMENT APPROVAL != LEGAL SIGNATURE

## 2. Spend classes

OPEX
CAPEX
SOFTWARE_SUBSCRIPTION
MARKETING
TRAVEL
FIELD_OPERATIONS
R&D
PROFESSIONAL_SERVICES
LEGAL
TAX
INVENTORY
STRATEGIC_INVESTMENT
TREASURY_INVESTMENT
M&A
EXCEPTIONAL

Each spend event requires:
request_id
requester
department
class
amount
currency
vendor
purpose
budget
alternatives
expected_value
risk
accounting_treatment
tax_treatment
approver
card_or_payment_route
invoice_or_receipt
delivery_or_acceptance
evidence

## 3. Purchase workflow

NEED
→ CHECK EXISTING ASSET / LICENSE / STOCK
→ REQUEST
→ BUDGET CHECK
→ ALTERNATIVES
→ VENDOR CHECK
→ APPROVAL
→ PAYMENT METHOD
→ PURCHASE
→ RECEIPT / INVOICE
→ DELIVERY
→ ACCOUNTING
→ LIBRARY / ASSET REGISTER
→ VALUE REVIEW

No purchase is approved merely because a card transaction technically succeeds.

## 4. Investment workflow

OPPORTUNITY
→ THESIS
→ STRATEGIC FIT
→ AMOUNT
→ CASH/RUNWAY IMPACT
→ DOWNSIDE
→ UPSIDE
→ LIQUIDITY
→ LEGAL / TAX
→ CONFLICTS OF INTEREST
→ DECISION
→ EXECUTION
→ MONITORING
→ EXIT / HOLD / WRITE-DOWN
→ LEARNING

Investment types:
- strategic supplier/customer
- equity
- debt
- fund/security
- treasury/cash management
- IP
- equipment/capacity
- acquisition/M&A

## 5. Approval bands

The POLICY STRUCTURE is canonical.
Numeric thresholds are CONFIGURABLE and must reflect current cash/runway.

BAND_A — routine approved-budget purchase
BAND_B — manager/founder approval
BAND_C — material purchase / investment committee
BAND_D — founder-reserved / shareholder or legal decision if required

No numeric amount is silently invented as a permanent corporate rule.

## 6. Company card law

Every card has:
CARD_ID
BANK_PROVIDER
HOLDER
ROLE
CARD_TYPE
MONTHLY_LIMIT
DAILY_LIMIT_IF_SUPPORTED
PER_TRANSACTION_LIMIT
CASH_WITHDRAWAL
ALLOWED_CATEGORIES
ALLOWED_DAYS
ONLINE
CONTACTLESS
INTERNATIONAL
BUDGET
APPROVER
RECEIPT_REQUIRED
AUTO_FREEZE_RULES
STATUS

Default policy:
- cash withdrawal OFF unless justified
- receipt/invoice REQUIRED
- card cannot pay personal expenses
- limits must be explicit
- category restrictions when useful
- international use explicit
- missing documents enter exception queue
- lost/stolen card freeze immediately
- self-limit increase forbidden

## 7. Associate cards

Hélène:
CARD_ELIGIBLE=YES
ISSUANCE=PROPOSED_PENDING_KYC_BANK_SETUP_AND_LIMIT_APPROVAL
LIMIT_PROFILE=TO_BE_APPROVED
CASH_WITHDRAWAL=OFF_BY_DEFAULT
RECEIPT_REQUIRED=YES

Jaime:
CARD_ELIGIBLE=YES
ISSUANCE=PROPOSED_PENDING_KYC_BANK_SETUP_AND_LIMIT_APPROVAL
LIMIT_PROFILE=TO_BE_APPROVED
CASH_WITHDRAWAL=OFF_BY_DEFAULT
RECEIPT_REQUIRED=YES

Ownership percentage does not change spend controls.

## 8. Qonto-compatible controls

Where Qonto is used, map policy to provider controls where available:
- user/team card assignment
- monthly payment limit
- daily limit where plan supports it
- per-transaction limit
- allowed categories
- allowed days
- physical / virtual / temporary card
- team budgets
- expense approval workflow

Provider capabilities never replace NOVA policy/evidence.

## 9. Receipts and accounting

Every company-card transaction:
BANK/CARD EVENT
→ TRANSACTION MATCH
→ RECEIPT/INVOICE
→ BUSINESS PURPOSE
→ ACCOUNTING CATEGORY
→ VAT/TAX CHECK
→ APPROVAL/EXCEPTION
→ ACCOUNTING LEDGER
→ EVIDENCE

Missing receipt != automatically personal, but remains unresolved until justified.

## 10. Digital workers

Digital workers may:
- detect duplicates
- compare prices
- prepare purchase requests
- model investment scenarios
- reconcile receipts
- identify missing evidence
- monitor budgets

They may NOT:
- issue a bank card
- expose card details
- increase limits
- move money
- make final investment decisions
unless a separately explicit bounded financial execution policy exists.

## 11. Conflict of interest

Associates and staff must disclose:
- related-party vendor
- personal economic interest
- family/close relationship where material
- self-benefiting transaction

Related-party transaction:
DISCLOSE
→ EVIDENCE
→ INDEPENDENT APPROVAL
→ ACCOUNTING/LEGAL CLASSIFICATION

## 12. Acceptance

SPEND_POLICY_V1_PASS when:
- every card maps to a holder and policy
- every purchase maps to a budget/approval
- investment decisions have evidence
- numeric limits are explicit
- associates cannot self-approve their own material spend
- bank/card data reconciles to accounting
- receipts/invoices are retained
- exceptions are visible
