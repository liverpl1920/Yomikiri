# Tasklist: Batch E2E Issues #127-#132

- [x] Add system spec for mypage display and nickname update (#127)
- [x] Add system spec for email change flow (#128)
- [x] Add system spec for password reset flow (#129)
- [x] Add system spec for book detail key UI states (#130)
- [x] Add system spec for progress/deadline error cases (#131)
- [x] Add system spec for top page transitions (#132)
- [x] Run RSpec and fix failures
- [x] Run RuboCop and fix offenses
- [x] Run implementation-validator subagent review
- [x] Update steering reflection section after completion

## Reflection
- Implemented at: 2026-04-25
- Plan vs actual diff: Added 6 new system spec files as planned; additionally fixed `BooksController#calculate_new_page` to reject out-of-range `direct_page`, discovered during new E2E execution.
- Learnings: Browser-side constraints (`maxlength`, `min/max`, `type=date`) can hide server-side validation paths; system specs should explicitly choose stable interaction paths per driver.
- Next improvements: Reduce `visible: :all` dependence in modal-related system specs by introducing stable open/submit helpers and, where needed, dedicated JS scenarios.
