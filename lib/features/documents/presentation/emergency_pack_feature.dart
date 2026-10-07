import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/emergency/emergency_export_service.dart';
import 'emergency_pack_screen.dart';

/// The app remains functional when this post-MVP feature has not yet been
/// wired to an unlocked repository graph. A composition root can override this
/// provider with decrypted-on-screen labels and secure export callbacks.
final emergencyPackFeatureProvider = Provider<EmergencyPackFeature>(
  (ref) => const EmergencyPackFeature.disabled(),
);

class EmergencyPackFeature {
  const EmergencyPackFeature({
    required this.documents,
    required this.initialSelection,
    this.saveSelection,
    this.export,
  });

  const EmergencyPackFeature.disabled()
    : documents = const [],
      initialSelection = const {},
      saveSelection = null,
      export = null;

  final List<EmergencyDocumentOption> documents;
  final Set<String> initialSelection;
  final Future<void> Function(List<String> documentIds)? saveSelection;
  final Future<bool> Function(
    List<String> documentIds,
    EmergencyExportProtection protection,
  )?
  export;
}
