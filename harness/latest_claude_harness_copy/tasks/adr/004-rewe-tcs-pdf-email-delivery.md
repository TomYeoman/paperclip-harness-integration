# ADR-004: REWE T&Cs PDF Email Delivery

## Status
Proposed

## Context

REWE requires that the T&C document is included in the order confirmation email sent to the customer. Phase I included a Cloudinary link to the T&C PDF in the email body. German law may require the T&C to be attached as a PDF rather than linked — this is an open legal question (OQ2).

The two approaches differ significantly in implementation complexity, email size, and the impact on the order confirmation critical path. This ADR evaluates both approaches so that the correct one can be selected once OQ2 is resolved, and defines the interface boundary between the email service and the PDF/mapping layer regardless of which approach is chosen.

This ADR depends on ADR-002 (mapping layer) and ADR-003 (PDF supply strategy) — specifically on whether PDFs are pre-generated and available as Cloudinary URLs at email-send time.

## Options Considered

### Option A: Cloudinary Link in Email (Current Phase I Approach, Extended)
The email receipt contains a hyperlink to the store's Cloudinary-hosted T&C PDF. The URL is retrieved from the mapping layer (ADR-002) at email generation time.

**Pros:**
- Already live in Phase I — lowest-risk extension
- Zero generation overhead at email send time
- Email size unaffected — no binary payload
- Works immediately once the mapping layer (M1) is populated for all 1,600 stores
- No changes to email sending infrastructure

**Cons:**
- Customer must click through to access the document — they do not receive the PDF in their inbox
- If the Cloudinary URL becomes unreachable after the email is sent, the customer cannot access the T&C they agreed to
- May not satisfy the German legal requirement for a "digital hard copy" (OQ2 unresolved)
- No guarantee the linked document matches the version the customer agreed to at order time, unless versioning is implemented (OQ6)

**Verdict:** Acceptable if OQ2 confirms a link is legally sufficient. Already partially implemented. Extension to all 1,600 stores is an M1+M2 change only.

### Option B: Inline PDF Attachment
The T&C PDF is attached directly to the order confirmation email as a binary attachment.

#### Sub-option B1: Attach Pre-Generated PDF (fetched from Cloudinary at email send time)
The email service retrieves the store's pre-generated PDF from Cloudinary (URL from the mapping layer) and attaches it as a multipart MIME attachment.

**Pros:**
- Customer receives the PDF directly — satisfies a "digital hard copy" requirement
- Document content is frozen at send time — no link-rot risk
- No generation infrastructure needed beyond what ADR-003 already requires
- Pre-generation (ADR-003 Option C) means the PDF is available immediately without blocking email send
- Can snapshot the version at order time (satisfies OQ6 if required)

**Cons:**
- Increases email size significantly — a typical T&C PDF may be 50–500 KB per email
- Email providers (SMTP relay, deliverability services) may reject or filter large attachments
- Must fetch the PDF from Cloudinary synchronously during email generation — adds a network call
- If Cloudinary is unavailable at send time, email must either delay, fail, or fall back to a link

#### Sub-option B2: Generate PDF Inline at Order Time
The email service calls a PDF generation service at order time to produce the personalised PDF and attach it.

**Pros:**
- Freshest possible document — generated at the moment of the order
- No pre-generation batch job required

**Cons:**
- PDF generation on the order-confirmation critical path — adds latency (OQ7 unresolved)
- Generation service must be highly available — single point of failure for email delivery
- Higher complexity than B1
- If generation is synchronous, any generation error blocks the email

**Verdict (B2):** Not recommended as the primary path. The latency and reliability risks are significant. Only viable if pre-generated PDFs are not available (e.g. if OQ1 confirms no templating is possible and pre-generation is infeasible).

## Decision

**DEFERRED** — pending answer to OQ2 (whether PDF attachment is legally required or a link is sufficient).

**Default assumption for M2 design:**
- If OQ2 confirms a **link is sufficient**: implement Option A (extend Phase I link approach to all 1,600 stores via mapping layer).
- If OQ2 confirms **attachment is required**: implement Option B1 (fetch pre-generated PDF from Cloudinary and attach). Do NOT implement B2 — the latency risk is unacceptable until OQ7 is resolved with a confirmed budget.

**The interface between the email service and the mapping/PDF layer is the same for both options:** the email service calls the mapping layer with a store_id and receives back a T&C URL (and Privacy Policy URL). For Option B1, the email service additionally fetches the binary at that URL and attaches it. This boundary should be implemented in M1 regardless of which final option is chosen.

## Rationale

Option A is lowest risk and already partially live. Option B1 is the only attachment path that does not add generation latency to the critical path — it trades generation-time cost (offline batch) for a single Cloudinary fetch at email send time. Option B2 is excluded from the default path because it couples generation latency to email delivery with no established latency budget (OQ7).

The legal question (OQ2) is binary — it either requires attachment or it does not. Designing the interface to support both means the legal answer does not require an architecture change, only a behaviour flag.

## Consequences

- **Email service interface:** The email service must accept a store_id parameter for REWE orders and look up the T&C URL from the mapping layer. This is a required change regardless of Option A or B1.
- **Attachment size limit:** If Option B1 is chosen, the email relay/SMTP service must be verified to support attachments of the expected PDF size range. SLA impact of large emails must be assessed.
- **Cloudinary availability dependency (B1):** The email generation path gains a dependency on Cloudinary availability. A fallback strategy (degrade to link, queue retry) must be defined.
- **Versioning (OQ6):** If document versioning is required, the email service must record which PDF URL (and version) was included in or linked from the email at order time. This is a data model concern in the mapping layer (ADR-002).
- **Fallback on mapping miss:** If the mapping layer returns no result for a store_id, the email service must have a defined fallback — either a generic REWE T&C URL, omit the attachment/link, or hard-fail. The product team must define the fallback behaviour.
- **M2 scope gate:** OQ2 must be answered before M2 email implementation begins. Proceeding with Option A and later switching to B1 is low-risk (same mapping layer, additional fetch + attach step). Starting with B2 and later removing inline generation is higher-risk.

## Open Questions Blocking This ADR

- **OQ2** — whether PDF email attachment is legally required or a link is sufficient (unblocks final option selection and M2 email scope)
- **OQ5** — effort delta between attachment and link in the email service (implementation detail, does not block architecture decision but informs M2 estimation)
- **OQ7** — P95 latency budget for PDF generation (relevant only if B2 path is pursued; does not block B1 or A)
