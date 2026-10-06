import 'package:documentvault/core/errors/app_failure.dart';
import 'package:documentvault/features/authentication/application/vault_security_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('creates a vault without retaining a raw PIN', () async {
    final store = MemoryVaultMetadataStore();
    final manager = VaultSecurityManager(store);
    await manager.createVault('184639');
    expect(store.value, isNot(contains('184639')));
    expect(await manager.hasVault, isTrue);
  });

  test('unlocks with correct PIN and rejects wrong PIN', () async {
    final store = MemoryVaultMetadataStore();
    final creator = VaultSecurityManager(store);
    await creator.createVault('184639');
    await creator.lock();
    final unlocker = VaultSecurityManager(store);
    expect(await unlocker.unlockWithPin('000000'), isFalse);
    expect(await unlocker.unlockWithPin('184639'), isTrue);
  });

  test('rate limits repeated invalid PIN attempts', () async {
    final store = MemoryVaultMetadataStore();
    final manager = VaultSecurityManager(store);
    await manager.createVault('184639');
    await manager.lock();
    expect(await manager.unlockWithPin('000000'), isFalse);
    expect(await manager.unlockWithPin('000000'), isFalse);
    expect(await manager.unlockWithPin('000000'), isFalse);
    expect(
      () => manager.unlockWithPin('184639'),
      throwsA(isA<SecurityFailure>()),
    );
  });

  test('manual lock destroys the in-memory vault key', () async {
    final manager = VaultSecurityManager(MemoryVaultMetadataStore());
    await manager.createVault('184639');
    expect(manager.isUnlocked, isTrue);
    await manager.lock();
    expect(manager.isUnlocked, isFalse);
  });
}
