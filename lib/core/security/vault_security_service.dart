abstract interface class VaultSecurityService {
  Future<void> createVault({required String pin});
  Future<bool> unlockWithPin(String pin);
  Future<bool> unlockWithBiometrics();
  Future<void> lock();
  Future<void> clearInMemorySensitiveState();
}
