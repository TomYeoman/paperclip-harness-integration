# ADR-001: Age Verification UI Update (CTLG-384)

## Status
Accepted

## Context

CTLG-384 requires updating the age verification UI to match new text and layout per Figma design. Two screens are in scope:

1. **ID Age Verification Consent Modal** — shown when a user must consent to MitID-based age verification
2. **Name and Date of Birth Modal** — shown in checkout to collect DOB for age-restricted items

Both components follow the consumer-web `presentational / enhanced` pattern. The enhanced files wire Redux state and translation injection; the presentational `.jsx` files own all JSX and layout. Only the presentational `.jsx` files and their tests are in scope for this ticket.

## Decision

UI-only update: modify JSX structure, text rendering, and layout in the two presentational components only. No changes to enhanced files, ducks, sagas, selectors, or validation logic.

## Current Component Inventory

### 1. IdAgeVerificationConsentModal

**File:** `consumer-web/checkout/src/components/age-verification/id-age-verification-consent-modal/id-age-verification-consent-modal.jsx`

**Header type:** `ModalHeader` (from `@cw/common/src/components/modal/modal-header`)
- Wraps `snacks-design-system` `ModalHeader` with accessible aria labels via `translateGlobal`
- Renders heading text and a close button — no image

**JSX structure:**
```
<Modal isOpen onClose modPositionCenter priority="high">
  <ModalHeader heading onClose qaSelector />
  <ModalScrollContent>
    <ModalContent modNoBottomPadding>
      <!-- 3 x Text paragraphs (xdsFontBodyLSize) in Util marginBottom wrappers -->
      <!-- 1 x TextLink for "NoMitId" in Util marginBottom wrapper -->
    </ModalContent>
  </ModalScrollContent>
  <ModalFooter>
    <Button isLoading modFluid size="medium">
      <Media right={<IconLinkExternal size="s" />}>
        {translate('consentButton')}
      </Media>
    </Button>
  </ModalFooter>
</Modal>
```

**Translation keys used (namespace: `idAgeVerification.consentModal`):**
- `modalHeading` — modal title, also `contentLabel`
- `modalFirstContent` — first body paragraph
- `modalSecondContent` — second body paragraph
- `modalThirdContent` — third body paragraph
- `NoMitId` — TextLink label for users without MitID
- `consentButton` — primary CTA button label

**Design system components:** `snacks-design-system` (ModalContent, ModalFooter, ModalScrollContent, Text, TextLink, Button, Media, Util, globalStyles, createQASelector), `@justeattakeaway/pie-icons-webc` (IconLinkExternal), `@cw/common` (ModalHeader, Modal)

---

### 2. NameAndDateOfBirthModal

**File:** `consumer-web/checkout/src/components/age-verification/name-and-date-of-birth-modal/name-and-date-of-birth-modal.jsx`

**Header type:** `FullWidthImageModalHeader` (from `@cw/common/src/components/modal/full-width-image-modal-header`)
- Custom header with a full-width image, heading rendered as `<Heading level={3} tag="h2">`, and an absolutely-positioned `CloseIconButton`
- Uses `id-check.svg` asset from `@cw/common/src/assets/images/id-age-verification/id-check.svg`

**JSX structure:**
```
<Modal contentLabel isOpen modPositionCenter onClose>
  <FullWidthImageModalHeader onClose heading imageSrc={idCheck} imageAlt />
  <NameAndDateOfBirthForm />   <!-- enhanced form component, not in scope -->
</Modal>
```

**Translation keys used (namespace: `checkout.dateOfBirthModal` — same namespace used by the nested form):**
- `header` — modal heading and imageAlt

**Form translation keys (namespace: `checkout.dateOfBirthModal`, in `name-and-date-of-birth-form.jsx`):**
- `content` — introductory paragraph
- `details` — second paragraph (interpolates `detailsHighlight`)
- `detailsHighlight` — bold-wrapped fragment inside `details`
- `firstName` — first name input label
- `lastName` — last name input label
- `inputDateLabel` — date section heading (strong/large font)
- `continueButton` — submit button label
- `dateOfBirthError` — Yup validation error message (interpolates `age`)

**Design system components:** `@cw/common` (Modal, FullWidthImageModalHeader), asset import (`id-check.svg`)

---

### 3. NameAndDateOfBirthForm (nested, read-only reference)

**File:** `consumer-web/checkout/src/components/age-verification/name-and-date-of-birth-modal/name-and-date-of-birth-form/name-and-date-of-birth-form.jsx`

Not in scope for CTLG-384, but listed for completeness. This component owns:
- First name / last name inputs
- DD/MM/YY select dropdowns
- Error message display
- "Continue" submit button inside `ModalFooter`

---

## Data Schemas

UNKNOWN — owner: @design-system-team (to be confirmed in component library documentation)

---

## Figma Access

**Node ID:** `6642-37714`
**Design file:** Age Verification — Ventures
**Access status:** Figma requires authentication. The Builder must obtain Figma access or request a redline/screenshot from the designer before starting implementation. The Figma URL has been recorded in the GitHub issue (#2, #3) for reference.

**Workaround if Figma is inaccessible:** Request exported PNG redlines or a Zeplin/design handoff link from the designer via the `#ctlg-384` Slack channel (or the originating ticket).

---

## Translation Keys

All translation values are served by `@justeattakeaway/cw-l10n-services`. They are **not** stored in files in this repo. The Builder must:

1. Cross-reference current key values in the deployed staging environment or the l10n portal
2. Confirm updated copy against the Figma design (or design handoff artefact)
3. Request new/changed translation strings through the established l10n process if any copy changes are needed

**Consent modal namespace:** `idAgeVerification.consentModal`
| Key | Current use |
|-----|-------------|
| `modalHeading` | Modal title / aria contentLabel |
| `modalFirstContent` | First body paragraph |
| `modalSecondContent` | Second body paragraph |
| `modalThirdContent` | Third body paragraph |
| `NoMitId` | TextLink label |
| `consentButton` | Primary CTA |

**DOB modal namespace:** `checkout.dateOfBirthModal`
| Key | Current use |
|-----|-------------|
| `header` | Modal heading + image alt text |
| `content` | Intro paragraph (in Form) |
| `details` | Second paragraph with interpolation (in Form) |
| `detailsHighlight` | Bold fragment inside `details` (in Form) |
| `firstName` | Input label (in Form) |
| `lastName` | Input label (in Form) |
| `inputDateLabel` | Date section heading (in Form) |
| `continueButton` | Submit button (in Form) |
| `dateOfBirthError` | Validation error (in Form) |

---

## Builder Instructions

### Task 1 — IdAgeVerificationConsentModal (`id-age-verification-consent-modal.jsx`)

1. Obtain Figma redlines for node `6642-37714` (consent modal view).
2. Compare current JSX structure to Figma:
   - Does the modal still use `ModalHeader` (text-only) or should it switch to `FullWidthImageModalHeader` (with image)?
   - Is the number of body text paragraphs the same (currently 3)?
   - Does the `NoMitId` TextLink remain in a fourth `Util` block, or does the layout change?
   - Does the `IconLinkExternal` remain in the consent button?
3. Update JSX only — do not touch `id-age-verification-consent-modal-enhanced.js`.
4. Do not add, remove, or rename any `qaSelector` attributes unless the design requires an entirely new element.
5. If the layout change introduces a new design-system component, import it only if it does not already exist in the file's import block.
6. Run the existing unit tests after change; update only the test assertions that break due to layout changes.

### Task 2 — NameAndDateOfBirthModal (`name-and-date-of-birth-modal.jsx`)

1. Obtain Figma redlines for node `6642-37714` (DOB modal view).
2. Compare current JSX to Figma:
   - Does the modal still use `FullWidthImageModalHeader` with `id-check.svg`?
   - Has the image asset changed? (Check `@cw/common/src/assets/images/id-age-verification/` if a new SVG is referenced.)
   - Does the heading text key remain `header`?
3. Update JSX only — do not touch `name-and-date-of-birth-modal-enhanced.js`.
4. The nested `<NameAndDateOfBirthForm />` is not in scope; do not modify it.
5. Run the existing unit tests after change; update only assertions that break due to layout changes.

---

## Files to Change

| File | Reason |
|------|--------|
| `checkout/src/components/age-verification/id-age-verification-consent-modal/id-age-verification-consent-modal.jsx` | JSX/layout update |
| `checkout/tests/unit/component/id-age-verification/id-age-verification-consent-modal/id-age-verification-consent-modal.test.jsx` | Update assertions if layout changes |
| `checkout/src/components/age-verification/name-and-date-of-birth-modal/name-and-date-of-birth-modal.jsx` | JSX/layout update |
| `checkout/tests/unit/component/name-and-date-of-birth/name-and-date-of-birth-modal.test.jsx` | Update assertions if layout changes |

---

## Files NOT to Change

| File | Reason |
|------|--------|
| `id-age-verification-consent-modal-enhanced.js` | Redux wiring — logic only |
| `name-and-date-of-birth-modal-enhanced.js` | Redux wiring — logic only |
| `name-and-date-of-birth-form.jsx` | Form logic not in scope for CTLG-384 |
| `name-and-date-of-birth-form-enhanced.js` | Form Redux wiring — logic only |
| `helpers.js` | Validation logic — logic only |
| Any duck, saga, selector, or reducer file | Logic boundary — off limits |

---

## Test Strategy

- Both components have existing unit tests using `@testing-library/react`.
- Tests should **not** be changed to make a failing build pass. Only update assertions that are genuinely invalidated by the layout change (e.g., a text label or button role query that no longer matches the new Figma copy).
- `IdAgeVerificationConsentModal` test uses `renderWithIntl` + `RootWrapper`. Accessibility assertions run in `afterEach` via `addAccessibilityViolations`.
- `NameAndDateOfBirthModal` test uses `renderWithStore` + `StoreBuilder`. Accessibility assertions run in `afterEach` via `toHaveNoAccessibilityViolations`.
- Both tests mock `IntersectionObserver` — do not remove that setup.
- After changes: run `yarn test --testPathPattern="id-age-verification-consent-modal|name-and-date-of-birth-modal"` and confirm zero failures.

---

## Consequences

- **Low risk** — UI-only changes; no Redux, saga, or validation logic is touched.
- **Translation dependency** — if copy changes are required, they must go through the l10n pipeline and may not be immediately available in all environments.
- **Figma auth dependency** — Builder is blocked if they cannot access the Figma file. Escalate to design team immediately if access cannot be obtained.
- **Accessibility** — both test suites run axe accessibility checks. Any new layout must remain accessible; test failures here are hard blockers.

## In Scope

- JSX and layout updates to `id-age-verification-consent-modal.jsx` (UI structure only)
- JSX and layout updates to `name-and-date-of-birth-modal.jsx` (UI structure only)
- Test assertion updates if layout changes invalidate existing test queries
- Component imports required by any new design-system components introduced in the layout
- Translation key references (no new keys created — request via l10n process if needed)

## Out of Scope

- Changes to enhanced files (`id-age-verification-consent-modal-enhanced.js`, `name-and-date-of-birth-modal-enhanced.js`)
- Redux logic, ducks, sagas, selectors, or reducers
- Changes to `NameAndDateOfBirthForm` component or its tests
- Validation logic in `helpers.js`
- Creation of new translation keys (request via established l10n process)
- Changes to test assertions unless they are genuinely invalidated by layout changes
- Any logic beyond presentational JSX and styling

## TBD / Open Questions

- Figma design specifics will be confirmed during Builder execution (modal header type, paragraph count, layout structure may differ from current assumptions)
- New translation key creation process and timeline (if copy changes are needed) — determined when Builder reviews Figma design
- Exact accessibility assertion updates in tests — determined by actual layout changes
