# ADR-003: REWE T&Cs PDF Supply and Personalisation Strategy

## Status
Accepted

## Context

Each of the 1,600 REWE stores requires a T&C PDF that is personalised with the store name and location in two places per document. Phase I used pre-built Cloudinary-hosted PDFs for 6 pilot stores. OQ1 is now resolved: JET generates PDFs from a template; REWE does not supply pre-built files per store.

This ADR addresses:
1. How PDFs are supplied to JET (pre-built per store vs. template + variable injection)
2. Where generated or pre-built PDFs are stored
3. When personalisation is applied (at upload time, at request time, or at render time)

The choice here has a direct impact on storage costs, update workflows, and the email delivery approach (ADR-004).

## Options Considered

### Option A: Pre-Built PDFs Per Store (1,600 Files)
REWE supplies 1,600 ready-made PDFs, one per store. JET uploads each to Cloudinary and stores the URL in the mapping layer (ADR-002).

**Pros:**
- Zero generation infrastructure required on JET side
- Retrieval is a simple CDN URL fetch — no latency from generation
- REWE owns content and formatting entirely
- No risk of JET-side rendering defects in T&C content
- Simplest implementation for Phase I → Phase II transition

**Cons:**
- 1,600 files to manage; bulk upload required for initial onboarding
- When a T&C changes, REWE must supply a new file per affected store — could be hundreds of files per update
- Storage burden grows linearly with store count and update frequency
- No JET-side template control — format is opaque

**Assumptions:**
- REWE can and will supply PDFs in a format suitable for direct hosting (PDF/A or standard PDF)
- JET has a bulk-upload mechanism or can build one for initial onboarding

**Verdict:** Viable if REWE confirms they will supply pre-built PDFs (OQ1). Lowest JET engineering effort. High operational burden at update time if many stores share a T&C template.

### Option B: Single Template + Per-Store Variable Injection at Render Time
JET maintains one (or a small number of) PDF template(s). When a store's T&C is requested or generated, the store name and location are injected into the template's two variable fields at render time using a PDF generation service.

**Pros:**
- Single template to update when T&C content changes — one change propagates to all stores
- Storage overhead is minimal (one template vs. 1,600 files)
- Personalisation is dynamic — no bulk re-generation required on T&C content change

**Cons:**
- Requires a PDF generation service (e.g. Puppeteer/Headless Chrome, WeasyPrint, PDFium, or a SaaS like DocRaptor)
- Generation latency adds to the request path if generated on demand (see OQ7)
- Template maintenance requires engineering involvement
- REWE must agree to JET owning/rendering the document format — legal/compliance risk if format deviates

**Assumptions:**
- REWE's T&C content follows a consistent template across stores (only store name/location varies)
- JET is permitted to render the document on REWE's behalf

**Verdict:** Best long-term scalability. Only viable if REWE confirms template-based supply and JET is permitted to render (OQ1).

### Option C: Hybrid — Pre-Generated Per Store, Cached in Cloudinary
JET generates personalised PDFs using a template at upload/onboarding time (not at request time). Generated PDFs are uploaded to Cloudinary and the URL stored in the mapping layer. Re-generation is triggered when T&C content or store data changes.

**Pros:**
- Retrieval is a simple Cloudinary URL fetch (same as Option A) — no runtime latency from generation
- Fewer files to manage than Option A if REWE's T&C shares a common template (only re-generate changed stores)
- JET controls the template and can update it without waiting for REWE to supply 1,600 files
- Decouples content update from per-store file management

**Cons:**
- Requires a PDF generation service (same infrastructure as Option B)
- On T&C content change, all affected stores must be re-generated and re-uploaded — could be a batch job
- Storage burden is similar to Option A (1,600 files in Cloudinary)
- Initial bulk generation required for onboarding

**Verdict:** Best balance of runtime simplicity and update efficiency. Preferred default approach assuming template-based supply is confirmed (OQ1). Decouples retrieval latency from generation latency.

## Decision

**Option C — confirmed.** Hybrid: pre-generate personalised PDFs from a JET-owned template, cache in Cloudinary. OQ1 resolved: JET generates from template; REWE does not supply pre-built files.

**Generation trigger:** store onboarding (new store added to the mapping) or T&C content update (template or legal text changes). Generation does NOT occur at checkout render or email send time.

**Personalisation data source:** `store_name` and `store_address` are fetched from the **Restaurant Service** (`GET /restaurants/{store_id}`) at generation time. No separate REWE-supplied data feed is required for the two personalisation fields.

**Template approval:** REWE legal must sign off on the rendered template output before go-live. This is a compliance gate, not an engineering gate.

## Rationale

Option C subsumes Option A (pre-built PDFs are the degenerate case of pre-generated PDFs). Option B (on-demand generation) is excluded as the primary path because it adds latency to the order critical path (OQ7 is unresolved — no latency budget confirmed). Pre-generation at upload time isolates generation cost from order processing.

## Consequences

- **PDF generation service:** A PDF generation service must be selected, hosted, and secured. This is an M1 infrastructure dependency. Service must be callable from the store onboarding/update pipeline, not from the checkout or email path.
- **Restaurant Service dependency:** The PDF generation step calls the Restaurant Service (`GET /restaurants/{store_id}`) to retrieve `store_name` and `store_address`. The generation pipeline takes a hard dependency on Restaurant Service availability. If Restaurant Service is unavailable at generation time, the generation job must fail and retry — not silently produce a PDF with empty personalisation fields.
- **Cloudinary storage (confirmed 2026-03-23):** Pre-generated PDFs are stored in **Cloudinary** under a structured naming convention (e.g. `rewe/tcs/{store_id}/tc_v{version}.pdf`). URL is stored in the mapping layer (ADR-002). **In-memory cache is explicitly rejected** — if the service dies, any in-memory PDFs are lost. Cloudinary provides persistent, versioned PDF storage with CDN delivery and is the authoritative storage layer for all generated PDFs.
- **Update workflow:** A batch regeneration job must be implemented for the case where T&C content changes across many stores. This job is in scope for M3.
- **Versioning (OQ6):** If document versioning is required, the Cloudinary path must encode a version segment. The mapping layer records the current URL; historical URLs must be preserved (not overwritten).
- **Email delivery:** Pre-generated PDFs in Cloudinary enable straightforward attachment or linking at email send time — see ADR-004.

## Open Questions Blocking This ADR

- **OQ7** — P95 latency budget for PDF generation (no longer on the checkout critical path; relevant only if the generation pipeline SLA needs to be defined for M3 batch jobs)
