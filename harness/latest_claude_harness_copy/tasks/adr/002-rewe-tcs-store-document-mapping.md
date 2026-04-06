# ADR-002: REWE T&Cs Store → Document Mapping

## Status
Accepted — partial. Stack confirmed (2026-03-23): mapping service is .NET (ASP.NET Core). Option selection (C vs. D) deferred pending OQ3.

## Context

REWE requires store-specific T&C and Privacy Policy links on checkout (Web, iOS, Android) and email receipts for all 1,600 REWE stores. Phase I hardcoded 6 Cloudinary URLs directly in the codebase. This does not scale — onboarding a new store or updating a URL requires an engineering deploy.

The mapping layer must:
- Be queryable at checkout time with low latency (~1,600 key lookups)
- Support updates without code deploys (REWE or JET ops-triggered)
- Be readable by all four platforms (Web, iOS, Android, Backend/Email)
- Store at minimum: store ID → T&C URL, Privacy Policy URL, (optionally) PDF URL or generation reference

## Options Considered

### Option A: Cloudinary Metadata
Extend the Phase I approach by storing the mapping as Cloudinary metadata tags or structured context on each asset.

**Pros:**
- Reuses existing Cloudinary infrastructure
- PDF and metadata co-located in one system

**Cons:**
- Cloudinary is an asset CDN, not a config/query service — querying "give me the T&C URL for store 12345" requires a metadata search, not a key lookup
- Cloudinary's metadata API is not designed for high-QPS point lookups at checkout
- Updating a mapping requires Cloudinary admin access or a custom upload workflow
- No native support for structured multi-field records per store
- Couples document storage with routing logic — hard to migrate either independently

**Verdict:** Not suitable as the primary mapping layer. Cloudinary remains the document host; mapping belongs elsewhere.

### Option B: Feature Flag / Config Service (e.g. LaunchDarkly, JetFM)
Store the mapping as a feature flag payload or remote config value, keyed by store ID.

**Pros:**
- Low-latency reads (cached client-side on SDK initialisation)
- No infrastructure to operate
- Updates deployable without code changes

**Cons:**
- Feature flag services are designed for boolean/variant flags, not for 1,600-entry structured mappings
- Config payload size limits vary; a 1,600-store JSON blob may exceed flag size limits or increase SDK initialisation time significantly
- Not designed for per-record CRUD operations — updating one store's URL requires overwriting the full payload
- Versioning and audit trail absent
- Cost scales with flag evaluations; 1,600-store lookup per order is expensive in some pricing models

**Verdict:** Unsuitable at 1,600-store scale. Acceptable for a pilot (≤50 stores) but not for the full REWE estate.

### Option C: CMS (e.g. Contentful)
Model store records in a CMS with structured content types — one entry per store, fields for store ID, T&C URL, Privacy Policy URL, PDF reference.

**Pros:**
- Structured, per-record CRUD with a UI for non-engineers
- Native versioning and publish workflows
- Content Delivery API (CDA) is a CDN-cached REST endpoint — low-latency reads
- Self-serve update capability satisfies M3 without custom tooling
- Webhooks available for cache invalidation

**Cons:**
- Operational dependency on a third-party SaaS
- 1,600 entries is within CMS norms but requires an initial bulk import
- Read API requires API key management on all clients
- CDA caching means eventual consistency — updates may lag up to CDN TTL (typically 1–5 min)
- Not all JET platforms may already integrate Contentful — integration cost per platform

**Verdict:** Strong candidate for M1+M3 combined. Provides self-serve and low-latency reads. Preferred if Contentful is already available in the JET platform stack.

### Option D: Dedicated Backend Service / Database Table
Build or extend a backend service with a dedicated mapping table (store_id → tc_url, privacy_url, pdf_url). Expose via an internal REST or GraphQL API consumed by all platforms.

**Pros:**
- Fully owned by JET — no third-party dependency for core data
- Point-key lookup (store_id) is O(1) with an indexed table — lowest latency of all options
- Versioning, audit trail, and CRUD all implementable to spec
- Response contract fully under JET control
- Works well with an in-process or edge cache (Redis, CDN) for checkout hot path

**Cons:**
- Requires engineering to build and operate the service
- No self-serve UI out of the box (M3 still required)
- Adds a network hop on the checkout critical path (mitigated by caching)
- Data model migration required if schema evolves

**Verdict:** Highest operational control and performance at scale. Preferred if JET already operates a store configuration service or if Contentful is not available. Requires most upfront engineering.

## Decision

**Stack confirmed (2026-03-23):** The mapping service is implemented in **.NET (ASP.NET Core)**. Option selection (C vs. D) remains deferred pending OQ3 — pending answer to which platform/service owns the store → document mapping at scale.

**Default assumption for M1 design:** Option D (dedicated backend service with a database table) because it provides the lowest query latency, full schema control, and the ability to add versioning (OQ6) and audit trail without rearchitecting. If Contentful is already available across all platforms (Web, iOS, Android, Backend), Option C should be revisited as it reduces M3 scope significantly.

**Regardless of mapping storage choice:** Cloudinary continues to host the PDF and link assets. The mapping layer stores URLs pointing into Cloudinary — it does not replace Cloudinary as the CDN.

## Rationale

At 1,600 stores with potential for growth:
- Cloudinary metadata (A) is architecturally wrong for key-value lookups
- Feature flag services (B) are not designed for per-record updates at this volume
- CMS (C) and dedicated service (D) are both viable; the choice is a platform-availability question
- The data model is simple (store_id → URL set) — this does not require a general-purpose multi-tenant framework

## Consequences

- **API contract:** All four platforms must consume a single source of truth. The API contract must be defined before M2 platform integration begins. Response envelope: `{ tcs_url, privacy_url, pdf_url }`.
- **Native client read path:** iOS and Android clients read `pdf_url` directly from the mapping service response and open the Cloudinary URL without a BFF intermediary. The mapping service must therefore be accessible to native clients (authenticated). No BFF dependency for PDF viewing.
- **Restaurant Service dependency (PDF generation pipeline only):** The `pdf_url` stored in the mapping is produced by the PDF generation pipeline (ADR-003), which calls the Restaurant Service (`GET /restaurants/{store_id}`) to fetch `store_name` and `store_address` at generation time. The mapping service itself has no runtime dependency on the Restaurant Service — it only stores and serves the pre-generated Cloudinary URL.
- **Caching:** The mapping changes infrequently. All clients should cache the response with a TTL of ≥ 5 min to avoid a checkout-path blocking call. Cache invalidation at M1/M2 is TTL-based only — no webhook or active invalidation signal required. Revisit if REWE requires real-time propagation of T&C updates.
- **Fallback:** When a store_id is not found in the mapping, the system must have a defined fallback behaviour — either a generic REWE T&C URL or a hard failure. Builder must implement a fallback path.
- **Self-serve (M3):** Option C (CMS) bundles M3 tooling; Option D requires a separate admin UI or ops workflow for M3.
- **Versioning (OQ6):** If document versioning is required, the mapping table must store a version field alongside the URL. This must be captured at order-acceptance time, not lookup time.

## Open Questions Blocking This ADR

- **OQ3** — which service/system owns the mapping at scale (unblocks final option selection)
- **OQ6** — whether document versioning must be tracked at order time (unblocks data model field set)
