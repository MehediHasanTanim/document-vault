# Build environments

The app has three runtime environments: `dev`, `test`, and `prod`.

- Android uses `dev`, `qa`, and `prod` Gradle product flavors because Gradle reserves `test` for test tasks. `qa` is the test-distribution flavor and is built with `--dart-define=APP_ENV=test`.
- `prod` has no suffix and therefore uses the required package/application ID: `com.nextgenai.documentvault`.
- iOS has the required production bundle identifier `com.nextgenai.documentvault`. Runtime behavior is selected with `--dart-define=APP_ENV=dev|test|prod`; dedicated Xcode schemes will be added with signing/release configuration in the release sprint.

Commands:

```text
flutter run --flavor dev --dart-define=APP_ENV=dev
flutter run --flavor qa --dart-define=APP_ENV=test
flutter build apk --flavor prod --dart-define=APP_ENV=prod
```
