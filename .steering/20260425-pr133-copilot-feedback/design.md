# Design: PR133 Copilot Feedback Reflection

## Approach
- `mypage_spec`: keep current assertion but rename example to reflect maxlength behavior.
- `top_transition_spec`: replace `Warden.instance_variable_set` usage with public helper reset (`Warden.test_reset!`) before JS form login.
- `error_cases_spec`:
  - Switch to JS flow and open UI elements via user actions.
  - Add helper that actually opens extend modal using `modal#openExtend` and waits for visible state.
  - For deadline tests, set date input value via JS (same pattern as existing deadline system spec).

## Validation
- Run targeted specs for edited files.
- Run RuboCop on edited files.
