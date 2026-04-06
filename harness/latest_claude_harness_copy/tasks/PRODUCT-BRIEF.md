# Product Brief

**One-line description**: Update the age verification consent modal and DOB entry screen in checkout to match new text and layout from Figma design.

**Target user**: Consumers purchasing age-restricted products (e.g. alcohol) via the JustEatTakeaway consumer web checkout.

**Core problem**: The age verification UIs (consent modal + DOB entry screen) have an outdated design; new text and layout are defined in Figma and translations are already in place.

**MVP scope — IN**:
- Update `IdAgeVerificationConsentModal` text and layout to match Figma (node 6642-37714)
- Update `NameAndDateOfBirthModal` text and layout to match Figma (node 6642-37714)
- Unit tests updated/added for both components
- Visual regression and cross-browser coverage per test strategy

**MVP scope — OUT**:
- Logic/Redux state changes (no behaviour change — UI only)
- New translation keys (translations already in place via cw-l10n-services)
- Changes to the age verification error modal or MitID modal
- Backend API changes

**Hard constraints**:
- UI only — no changes to business logic, sagas, or Redux ducks
- Must use existing `snacks-design-system` components and PIE icon library
- Must pass existing accessibility checks (axe) in unit tests
- Cross-browser: Chrome, Safari, Firefox, Edge
- Figma design: https://www.figma.com/design/xAEtX8SmMr0ZSgn3ZFnNen/Age-Verification---Ventures?node-id=6642-37714&m=dev
- Translations reference: https://docs.google.com/spreadsheets/d/1pbsQcpfPSImknPT8eUZnBCm_ZpHHK3zIfZljWzi1zNE/edit?gid=781598070#gid=781598070

**Discovery date**: 2026-03-13
**Conducted by**: lead (pm-discovery unavailable — lead conducted discovery from Jira ticket CTLG-384)
