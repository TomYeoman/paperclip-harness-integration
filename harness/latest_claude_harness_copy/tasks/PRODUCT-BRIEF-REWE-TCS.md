# Product Brief: REWE T&Cs Scalable Solution

**Discovery date**: 2026-03-23
**Conducted by**: pm-rewe (from GitHub #354 + GARG-869 context)
**Last updated**: 2026-03-23 — OQ2/9/10/11 resolved; OQ12 spike notes added
**Status**: OQ12 spike pending (TMS API) — does not block Architect or M1

---

## Problem Statement

REWE requires that each of its 1,600 stores presents store-specific Terms & Conditions and Privacy Statement on the checkout page and as a PDF attachment in the email receipt (required under German law). Phase I shipped a hardcoded pilot for 6 stores using Cloudinary links. That approach does not scale. The scalable solution generates PDFs on demand from a base template, personalised per store using `store_name` and `store_address`, with store data sourced from TMS.

---

## Current State (Phase I)

- 6 pilot stores have hardcoded Cloudinary URLs for T&C and Privacy Policy links
- Links appear on: checkout page (below Order & Pay button) on Web, iOS, and Android
- Email receipt includes a per-store T&C link (not an attachment)
- PDFs are not generated — pre-existing files hosted on Cloudinary
- No self-serve mechanism; no versioning; changes require engineering deploys

---

## Goal

Replace the hardcoded pilot implementation with on-demand PDF generation from a base template, personalised per store using TMS data (`store_name`, `store_address`), delivered as a PDF attachment on the checkout page and in the email receipt for all 1,600 REWE stores across all platforms.

---

## Platforms

| Platform | In Scope |
|----------|----------|
| Web (checkout) | Yes |
| iOS (checkout) | Yes |
| Android (checkout) | Yes |
| Backend (email receipt) | Yes |
| Self-serve portal / CMS | No — killed |

---

## User Stories

**Customer**
As a customer placing an order at a REWE store,
I want to receive the T&Cs specific to that store as a PDF on the checkout page and attached to my email receipt,
So that I have the correct legal document for my store as required by German law.

**JET Ops / Engineering**
As a JET engineer,
I want to update T&C content by editing the base PDF template in source control,
So that document updates are deployed without per-store manual work.

---

## Key Decisions (PO-confirmed, not open)

| # | Decision |
|---|----------|
| D1 | PDF is **generated on demand** from a base template; JET owns the base text; no pre-built per-store PDFs |
| D2 | Store data (`store_name`, `store_address`) sourced from **TMS** — how to retrieve this is a spike (see OQ12) |
| D3 | Store → document **mapping is TMS** — store_id is the lookup key |
| D4 | **PDF attachment required** in email — not a link. Confirmed for German law compliance |
| D5 | **No persistent PDF storage** — generate on demand, do not store after delivery |
| D6 | **Email attachment:** spike required on transit-acknowledgement storage (hold in physical storage until delivery confirmed, then discard — see OQ13) |
| D7 | **PDF versioning required** — version must be recorded at the point the customer views/accepts T&Cs |
| D8 | **No self-serve** — T&C base text updated by JET engineering via source control deploy |
| D9 | **M3 killed** — no self-serve portal, no automation milestone |
| D10 | **Default PDF fallback** — if mapping service is down or store data unavailable, show/attach a default PDF (no store name) to remain legally compliant |
| D11 | **Observability required** — flag in monitoring when TMS returns no `store_name`/`store_address` for a queried store_id, to catch data gaps early |
| D12 | **Performance:** PDF visible at checkout within **2000ms P95**; email attachment delivered within **5 minutes** of order |

---

## Scope

### In
- On-demand PDF generation from base template, personalised with `store_name` and `store_address` from TMS
- T&C and Privacy Policy display on checkout (Web, iOS, Android) — PDF viewable at checkout, not just link
- PDF attached to email receipt — not a link; within 5 minutes of order
- PDF versioning: version captured at checkout interaction time
- Default PDF (no store name) served when TMS data is unavailable or mapping service is down
- Spike: transit-acknowledgement email attachment storage (hold until delivery confirmed, discard after)
- Spike: how to retrieve `store_name` and `store_address` from TMS per store_id
- Observability: alert when TMS returns no store data for a queried store_id
- Feature flag (`rewe_tcs_scalable_enabled`, global scope — name pending OQ11)

### Out
- Self-serve portal for REWE or JET ops to update documents
- Persistent PDF storage after delivery
- PDF generation at order time exceeding 2000ms P95 on checkout critical path
- T&Cs for non-REWE brands or other JET operators
- General-purpose multi-tenant T&C framework
- Translation/localisation of T&C content (owned by REWE)
- Audit trail beyond version capture at checkout time

### Acceptance Criteria (core)
- Given a store_id with valid TMS data: PDF generated with correct `store_name` and `store_address`, shown at checkout and attached to email receipt
- Given a store_id with no TMS data: default PDF (no store name) shown/attached; observability alert fired; checkout not blocked
- Given mapping service 5xx or timeout: default PDF shown/attached; checkout not blocked; no customer-visible error (AC-8)
- Given no T&C mapping for store: T&C and Privacy Policy link elements not rendered; checkout not blocked
- PDF version recorded at the point customer views/accepts T&Cs
- PDF visible at checkout within **2000ms P95**
- Email attachment delivered within **5 minutes** of order
- Feature flag OFF: reverts to Phase I behaviour for 6 pilot stores; nothing shown for all other stores
- Test environment: hardcoded test assertion for store `REWE_TEST_999` with known expected URL — dynamic-vs-hardcoded verified by asserting the returned URL matches the TMS-seeded value, not any Phase I hardcoded value

---

## Open Questions

The following questions remain open. They do **not** block Architect from starting M1 unless noted.

9. **[REWE] What is the expected link/button label text for the T&C and Privacy Policy on checkout?**
   Copy is a REWE content decision. Does not block M1 or M2 implementation — Builder uses placeholder; copy swap is a one-liner.

10. **[Platform teams — Web, iOS, Android] Does the T&C PDF open in-app (WebView/PDF viewer) or external browser?**
    Brief provisionally assumes in-app PDF viewer for checkout display. Each platform team must confirm. Does not block M1.

11. ~~RESOLVED~~ — Feature flag name confirmed: `rewe_tcs_scalable_enabled`, system: JETFM.

12. **[Backend / TMS team] How does the PDF generation service retrieve `store_name` and `store_address` from TMS given a store_id?**
    Stub for now — Architect designs against a stubbed TMS interface. Real integration resolved in M2. Does not block M1.
    **Spike notes:** TMS web UI is at `https://jetms.production.jet-internal.com/de/partner/{partner_id}/general/information` — store data is keyed by `partner_id` in the UI. Unknown: (a) whether a REST/gRPC API backs this UI, (b) what auth it requires, (c) whether `store_id` maps 1:1 to `partner_id`. Backend team must resolve these in the M2 spike.

13. ~~RESOLVED~~ — Email transit storage approach left to Backend team's discretion. Constraint: PDF **must** be attached (not linked). At-least-once delivery is required. Architect chooses the mechanism (in-memory pass-through, short-TTL blob, message queue) based on the 5-minute SLA.

14. ~~RESOLVED~~ — P95 latency budgets confirmed: PDF visible at checkout within **2000ms**; email attachment delivered within **5 minutes** of order.

---

## Milestones

**M1 — PDF Generation + Data Layer**
On-demand PDF generation service consuming TMS store data. Covers: base template management, `store_name`/`store_address` injection, default PDF fallback, PDF versioning, observability alerting on missing TMS data. TMS integration stubbed in M1 — real integration in M2.

**M2 — Platform Integration**
Wire all platforms (Web, iOS, Android, Backend/Email) to the M1 generation service. Checkout displays PDF within 2000ms P95; email attaches PDF within 5 minutes of order. Real TMS integration replaces M1 stub. Replace all Phase I hardcoded URLs. Architect chooses email transit mechanism to meet the 5-minute SLA with at-least-once delivery.

---

## Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| TMS has no reliable API for store name/address — requires batch sync or workaround | Medium | High | OQ12 spike must complete before M1 design is locked |
| PDF generation exceeds 2000ms P95 at checkout — budget is tight for on-demand generation | Medium | High | Architect must benchmark generation time early in M1; async pre-generation if needed |
| Email transit mechanism fails to deliver attachment — at-least-once delivery not guaranteed | Low | High | Architect selects mechanism with at-least-once guarantee; alert on delivery failure |
| Default PDF (no store name) shown at scale if TMS is flaky — legal exposure | Low | High | Observability alert (D11) gives early warning; default PDF keeps basic compliance |
| PDF versioning schema not compatible with existing order data model | Low | Medium | Architect must review order data model in M1 design |
| Legal entity vs. store_id granularity mismatch with REWE expectations | Low | Medium | Confirm with REWE before M1 data model finalised (brief assumes one-to-one) |
