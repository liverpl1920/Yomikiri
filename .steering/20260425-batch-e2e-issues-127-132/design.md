# Design: Batch E2E Issues #127-#132

## Strategy
Create focused system spec files by domain to keep test intent clear and maintenance easy.

## Test File Plan
- `spec/system/mypages/mypage_spec.rb`
	- show page rendering
	- nickname update success/failure
	- history empty/present branch

- `spec/system/users/email_change_spec.rb`
	- edit page rendering
	- successful update flow to mypage notice
	- invalid password/same email/taken email error rendering
	- complete page rendering

- `spec/system/auth/password_reset_spec.rb`
	- open reset request page from sign-in
	- submit existing/non-existing email and assert paranoia-safe behavior
	- apply token to reset password and ensure redirected login state

- `spec/system/books/detail_ui_states_spec.rb`
	- urgency class/badge rendering by deadline window
	- Google calendar section rendering

- `spec/system/books/error_cases_spec.rb`
	- progress update invalid values (0/non-numeric/over target by direct input)
	- deadline extension invalid values (same date/past date/invalid date)

- `spec/system/top/top_transition_spec.rb`
	- guest sees top
	- logged-in user visiting top is redirected
	- logout returns to top and guest nav appears

## Reuse Existing Patterns
- Use existing helper `sign_in_via_form` for JS tests.
- Use existing dropdown interaction technique for logout.
- For date input in JS modal, use script assignment where needed.

## Expected Impact
- Test-only change in `spec/system/**` and steering docs.
- No app runtime behavior change expected.
