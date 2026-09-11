# Changelog
All notable changes to this project will be documented in this file.
## [1.0.14] - 2026-9-11
- Fix `OtpInputField` overflowing on narrow screens. The digit boxes now share the
  available width and shrink to fit instead of overflowing.
- Fix `OtpController.shake()` resetting the field to 6 digits, ignoring the configured `length`.
## [1.0.13] - 2025-4-30
- Refactoring
## [1.0.12] - 2025-4-30
- Update motion_toast package to latest version
## [1.0.11] - 2025-4-30
- Update vibration package to latest version

## [1.0.10] - 2024-11-21
- Add physical keys support to Keyboard widget (need focus node).
- 
## [1.0.9] - 2024-10-10
- Upgrade dependencies
- 
## [1.0.8] - 2024-05-26
- Add `secondaryColor` to the `OtpInputField` to make it more customizable.

## [1.0.7] - 2024-04-24
- Add `onKeyPressed` to the `KrOtpKeyboard` to use it independently of the `OtpInputField`.
- extract the `shake` method in the `OtpController` to maunually shake the `OtpInputField`.
  
## [1.0.6] - 2024-04-11
- Update Example and README.md file

## [1.0.0] - 2024-04-11
- Initial release of `kr_otp`.
- Added `OtpInputField` class.
- Introduced `KrOtpKeyboard`.
- Provided example in the `example` directory.