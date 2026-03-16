# Production Hardening Checklist

## Android

- Keep only required permissions in `AndroidManifest.xml`.
- Enforce HTTPS only:
  - `android:usesCleartextTraffic="false"`
  - `network_security_config.xml` with `cleartextTrafficPermitted="false"`
- Disable backups for sensitive on-device data:
  - `android:allowBackup="false"`
  - `backup_rules.xml` / `data_extraction_rules.xml` exclusions
- Ensure release build signing, minification, and obfuscation in Gradle.

## iOS

- Provide precise privacy usage descriptions in `Info.plist`.
- Keep background modes minimal (`fetch` only if required).
- Use ATS defaults (HTTPS endpoints only).
- Enable App Transport Security exceptions only when absolutely necessary.

## Secrets and API Keys

- Never commit API keys or Firebase secrets.
- Provide runtime secrets using `--dart-define`.
- Use CI/CD secret management for production builds.

## Data Protection

- Store only minimal user data.
- Avoid uploading raw images unless user opted in.
- Consider encrypting local persisted records if handling sensitive workloads.

## Release Process

- Run `flutter analyze` and `flutter test` on CI.
- Add dependency vulnerability scanning.
- Verify permission prompts and fallback behavior on fresh installs.
