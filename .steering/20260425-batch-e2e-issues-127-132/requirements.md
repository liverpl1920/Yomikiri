# Requirements: Batch E2E Issues #127-#132

## Goal
Add missing system specs (E2E) for the six issues created from the coverage review.

## Scope
- Issue #127: Mypage display and nickname update flow
- Issue #128: Email change flow (edit/update/complete)
- Issue #129: Password reset flow
- Issue #130: Book detail key UI states (urgency badge/class, Google Calendar section)
- Issue #131: Error-case E2E for progress update and deadline extension
- Issue #132: Top page transitions (guest, logged-in redirect, post-logout top)

## Acceptance Criteria
- Add system specs under `spec/system/**` for each issue scope above.
- Follow current test patterns:
	- non-JS: `login_as(user, scope: :user)`
	- JS: `sign_in_via_form(user)` + `wait_for_stimulus`
- Use stable selectors/text already used by existing views/components.
- Ensure tests are deterministic and avoid flaky timing dependencies.
- Existing tests continue to pass.

## Out of Scope
- Production code behavior changes unless testability bug is discovered.
- Refactor of existing request/model specs.
- UI redesign.

## Risks
- JS modal interactions can be flaky depending on timing.
- Password reset flow requires token handling in system tests.

## Validation
- Run `bundle exec rspec` (or targeted system specs first, then full suite if feasible).
- Run `bundle exec rubocop`.
