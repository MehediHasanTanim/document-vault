import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var privacyView: UIView?
  private var backupExportDelegate: BackupExportDelegate?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    NotificationCenter.default.addObserver(self, selector: #selector(showPrivacyCover), name: UIApplication.willResignActiveNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(hidePrivacyCover), name: UIApplication.didBecomeActiveNotification, object: nil)
    let launched = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "documentvault/backup_destination",
        binaryMessenger: controller.binaryMessenger
      )
      channel.setMethodCallHandler { [weak self, weak controller] call, result in
        guard call.method == "saveBackup" else {
          result(FlutterMethodNotImplemented)
          return
        }
        guard let arguments = call.arguments as? [String: Any],
              let sourcePath = arguments["sourcePath"] as? String,
              FileManager.default.fileExists(atPath: sourcePath),
              let presenter = controller else {
          result(FlutterError(code: "invalid_source", message: "Backup package is unavailable.", details: nil))
          return
        }
        let exporter = BackupExportDelegate(result: result) { [weak self] in
          self?.backupExportDelegate = nil
        }
        self?.backupExportDelegate = exporter
        let picker = UIDocumentPickerViewController(
          url: URL(fileURLWithPath: sourcePath),
          in: .exportToService
        )
        picker.delegate = exporter
        presenter.present(picker, animated: true)
      }
    }
    return launched
  }

  @objc private func showPrivacyCover() {
    guard let window = self.window, privacyView == nil else { return }
    let cover = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterialDark))
    cover.frame = window.bounds
    cover.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    window.addSubview(cover)
    privacyView = cover
  }

  @objc private func hidePrivacyCover() {
    privacyView?.removeFromSuperview()
    privacyView = nil
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}

private final class BackupExportDelegate: NSObject, UIDocumentPickerDelegate {
  private let result: FlutterResult
  private let finished: () -> Void
  private var resolved = false

  init(result: @escaping FlutterResult, finished: @escaping () -> Void) {
    self.result = result
    self.finished = finished
  }

  func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    resolve(false)
  }

  func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    resolve(!urls.isEmpty)
  }

  private func resolve(_ value: Bool) {
    guard !resolved else { return }
    resolved = true
    result(value)
    finished()
  }
}
