# Product Brief: Co-op Loyalty Integration — Mid-term Solution (Phase 2)

**One-line description**: Replace the manual item-level discount workaround with a scalable `NewPrice` offer type, making membership prices visible to all customers across Menu, Item Details, Basket, Checkout, and post-purchase — driving card linking and incremental grocery growth.

**Target user**: All JET customers browsing Co-op stores on OneApp and OneWeb (UK market). Both Co-op members (linked card) and non-members benefit from price visibility.

**Core problem**: The short-term solution (Phase 1, shipped Dec 2025) has three limitations:
1. **Limited visibility** — only linked members see membership prices. Co-op confirmed that visibility to ALL customers is the #1 driver for card linking (currently only 4% of active JET Co-op customers have linked).
2. **Poor UX** — item-level discounts create a cluttered menu with excessive offer banners and tags instead of a clean membership price display.
3. **No scalability** — manual setup of 30-40 offers per promotion; hardcoded partner info prevents expansion to other partners.

**Key metrics** (from Dec '25 - Feb '26 short-term results):
- 44,515 Co-op cards linked
- +18.2% grocery order frequency (vs -7.3% control group)
- 7.7x higher reactivation of churned grocery customers
- 25% of linked members are New to Grocery customers
- AOV: £22.90 for membership orders (vs £20.32 regular)
- 9.35 avg items in basket (vs 7.11 regular)

**Business value**: €15.5M GTV projected in first year, 44K additional monthly orders.

## MVP Scope — IN

### Backend: New Offer Type + CSV Import
- New `NewPrice` offer type in the offers system
- Offer Management Web: UI flow for CSV upload of membership prices
- Offer Management API: new POST endpoint for CSV upload to S3, versioned storage
- Consumer Offers Lambda: persist NewPrice offers, read price data from CSV in S3, map product names to IDs via MenuMaster projection, store as ProductPrice in Redis
- GlobalMenuCdnWorker: consume `MembershipPricesChanged` and `MembershipPricesDeleted` events, project membership prices for client consumption
- Consumer Offers API (`POST /consumeroffers/{tenant}/basket/calculate`): return NewPrice offers for ALL customers regardless of membership status, with `applicable` flag (true for linked members, false for non-members) and `isPotentialSaving` + reason object for non-members

### Backend: GBO Offers Engine Integration
- GBO applies membership prices using the offers engine (GARG-1346)
- Determines whether to apply membershipPrice or return potential savings info
- Returns `isPotentialSaving` boolean + reason object with `POTENTIAL_MEMBERSHIP` code

### Frontend: Membership Prices Visible to ALL Customers
- **Menu**: show membership prices (with original price strikethrough) to all customers — linked members see "Member price", non-members see price with prompt to link
- **Item Details**: same pattern as Menu
- **Basket**: linked members see "Member Savings AMOUNT" applied to total; non-members see "You could save AMOUNT" with link prompt
- **Checkout**: same savings display pattern as Basket
- ~~**Post-purchase**: confirmation of savings earned on the order~~ — not in GARG-1323 epic; deferred

### Backend: CO Lambda Membership Prices File
- Update CO Lambda UpdateRestaurantMenu to upload membership prices file and publish MembershipPricesChanged (GARG-1390)

## MVP Scope — OUT

- Downstream system support for substitutions and missing items (not confirmed)
- Card linking from basket or checkout (card linking is via existing account/settings flow only)
- Scaling to other partners (Morrisons, Sainsbury's — Phase 3)
- Personalized offers (requires additional API call to partner)
- Tier-based benefits
- Points redemption
- Points earning (Nectar, More Card — Phase 3+)

## Already Complete (no work needed)

- **Partner Metadata Service**: loyaltyschemesapi repo — stores partner-specific data (name, logo, URLs, colour scheme, benefits type, T&Cs/legal copy)
- **Legal copy on card linking screen** (GARG-886)
- **Card linking flow** (web polling — GARG-767)
- **Short-term membership prices on web** (item-level discounts — GARG-595)
- **Short-term membership prices on iOS Item Details** (GARG-579)

## Hard Constraints

- UK market only, Co-op brand only
- Platform: OneApp (iOS, Android) and OneWeb
- Must use existing JET offers infrastructure (Offer Management, Consumer Offers, GBO)
- CSV upload is full-file replacement (no granular item-level edits in MVP)
- Performance: large CSV processing and Redis cache updates must be performant to avoid latency
- New offer type must not break existing offer flows

## Dependencies

- Partner Offers team: NewPrice offer type support
- Menu Customer team: GMCDN projection changes
- Account team: membership verification via benefit context (ADR 048.4)

## Reference Documents

- PRD: Partner Loyalty Integrations Mid Term Strategy (March 2026) — PDF in repo
- ADR: [048.3 - Partner Loyalty Integrations - Membership Prices](https://justeattakeaway.atlassian.net/wiki/spaces/AH/pages/7827362054)
- Epic: [GARG-1323](https://justeattakeaway.atlassian.net/browse/GARG-1323)
- Figma: [Loyalty Integration Design](https://www.figma.com/design/eWczIWsFOqv1f1AGRS4kQo/Loyalty-integration?node-id=11032-75489)
- Partner Metadata Service: [loyaltyschemesapi](https://github.je-labs.com/grocery-and-retail-growth/loyaltyschemesapi)

## Related ADRs

- ADR 048.3: Partner Loyalty Integrations — Membership Prices
- ADR 048.4: Partner Loyalty Integrations — CO-OP Membership Benefit (short term)

**Discovery date**: 2026-03-17
**Conducted by**: pm-loyalty (PM agent, issue #75)
