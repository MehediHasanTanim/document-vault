import 'package:documentvault/app/router/app_router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'locked users are sent to unlock before accessing the vault',
    () => expect(
      routeForAccessState(VaultAccessState.locked, '/documents'),
      '/unlock',
    ),
  );
  test('onboarding users cannot access protected routes', () {
    expect(
      routeForAccessState(VaultAccessState.onboarding, '/unlock'),
      '/welcome',
    );
    expect(
      routeForAccessState(VaultAccessState.onboarding, '/home'),
      '/welcome',
    );
  });
  test(
    'unlocked users land on home instead of setup',
    () => expect(
      routeForAccessState(VaultAccessState.unlocked, '/welcome'),
      '/home',
    ),
  );
}
