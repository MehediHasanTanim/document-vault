import Flutter
import UIKit
import AuthenticationServices

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate, ASWebAuthenticationPresentationContextProviding {
  private var privacyView: UIView?
  private var backupExportDelegate: BackupExportDelegate?
  private var secureShareCompletion: FlutterResult?
  private var oauthSession: ASWebAuthenticationSession?
  private var privacyCoverEnabled = true

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
      let shareChannel = FlutterMethodChannel(
        name: "documentvault/secure_share",
        binaryMessenger: controller.binaryMessenger
      )
      shareChannel.setMethodCallHandler { [weak self, weak controller] call, result in
        guard call.method == "share" else {
          result(FlutterMethodNotImplemented)
          return
        }
        guard self?.secureShareCompletion == nil,
              let arguments = call.arguments as? [String: Any],
              let sourcePaths = arguments["sourcePaths"] as? [String],
              let presenter = controller,
              !sourcePaths.isEmpty,
              sourcePaths.allSatisfy({ FileManager.default.fileExists(atPath: $0) }) else {
          result(FlutterError(code: "invalid_source", message: "Secure export is unavailable.", details: nil))
          return
        }
        let activity = UIActivityViewController(
          activityItems: sourcePaths.map { URL(fileURLWithPath: $0) },
          applicationActivities: nil
        )
        self?.secureShareCompletion = result
        activity.completionWithItemsHandler = { [weak self] _, completed, _, _ in
          guard let callback = self?.secureShareCompletion else { return }
          self?.secureShareCompletion = nil
          // iOS deliberately withholds recipient identity; only completion is returned.
          callback(completed)
        }
        presenter.present(activity, animated: true)
      }
      let oauthChannel = FlutterMethodChannel(
        name: "documentvault/cloud_oauth",
        binaryMessenger: controller.binaryMessenger
      )
      oauthChannel.setMethodCallHandler { [weak self] call, result in
        guard call.method == "authorize",
              self?.oauthSession == nil,
              let arguments = call.arguments as? [String: Any],
              let rawUrl = arguments["authorizationUrl"] as? String,
              let url = URL(string: rawUrl), url.scheme == "https",
              let redirectScheme = arguments["redirectScheme"] as? String,
              redirectScheme == "documentvault" else {
          result(FlutterError(code: "invalid_request", message: "Cloud sign-in is unavailable.", details: nil))
          return
        }
        let session = ASWebAuthenticationSession(url: url, callbackURLScheme: redirectScheme) { [weak self] callbackUrl, error in
          self?.oauthSession = nil
          guard error == nil, let callbackUrl = callbackUrl else {
            result(FlutterError(code: "cancelled", message: "Cloud sign-in was cancelled.", details: nil))
            return
          }
          result(callbackUrl.absoluteString)
        }
        session.presentationContextProvider = self
        self?.oauthSession = session
        if !session.start() {
          self?.oauthSession = nil
          result(FlutterError(code: "unavailable", message: "Cloud sign-in is unavailable.", details: nil))
        }
      }
      let privacyChannel = FlutterMethodChannel(
        name: "documentvault/privacy_display",
        binaryMessenger: controller.binaryMessenger
      )
      privacyChannel.setMethodCallHandler { [weak self] call, result in
        guard call.method == "apply" else {
          result(FlutterMethodNotImplemented)
          return
        }
        let arguments = call.arguments as? [String: Any]
        self?.privacyCoverEnabled = arguments?["hideInAppSwitcher"] as? Bool ?? true
        // iOS does not provide a public application-level screenshot block.
        // The app-switcher cover remains supported and screenshot preference
        // is retained in encrypted app settings for compatible platforms.
        result(nil)
      }
    }
    return launched
  }

  @objc private func showPrivacyCover() {
    guard privacyCoverEnabled, let window = self.window, privacyView == nil else { return }
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

  func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
    window ?? ASPresentationAnchor()
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
