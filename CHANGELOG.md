# Changelog

## [1.0.1] - 2023-10-10

### Fixed
- Fixed a bug with the console output.
- Script now exits if Mautic produces any console output.

## [1.0.0] - 2023-10-10

### Added
- Initial release of MauticSmartSend.
- Script designed to send Mautic emails in a controlled manner, providing real-time feedback.
- Conditional silent mode for minimal console output.
- Advanced error-handling with pre-run checks.
- Capability to replace Mautic's `mautic:emails:send` cron job.
- Locking mechanism to ensure a single instance.
- Real-time progress display with estimations for task completion.
- Integrated help functionality to guide users on script usage.

### Notes
- This version is designed to be run as frequently as desired with cron, even permitting minute-by-minute executions. The objective is to provide users with better visibility and control over Mautic email sending while ensuring efficient delivery.
