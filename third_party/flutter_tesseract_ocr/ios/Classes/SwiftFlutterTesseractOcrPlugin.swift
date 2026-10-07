import Flutter
import UIKit
import SwiftyTesseract

public class SwiftFlutterTesseractOcrPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_tesseract_ocr", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterTesseractOcrPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        initializeTessData()
        if call.method == "extractText" {
            
            guard let args = call.arguments else {
                result("iOS could not recognize flutter arguments in method: (sendParams)")
                return
            }
            
            let params: [String : Any] = args as! [String : Any]
            let language: String? = params["language"] as? String
            let imagePath = params["imagePath"] as! String
            guard let image = UIImage(contentsOfFile: imagePath) else {
                result(FlutterError(code: "invalid_image", message: "The private OCR image is unavailable.", details: nil))
                return
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                var swiftyTesseract = SwiftyTesseract(language: .english)
                if let language = language {
                    swiftyTesseract = SwiftyTesseract(language: .custom(language))
                }
                
                swiftyTesseract.performOCR(on: image) { recognizedString in
                    DispatchQueue.main.async {
                        guard let extractText = recognizedString else {
                            result(FlutterError(code: "recognition_failed", message: "Local OCR could not recognize this image.", details: nil))
                            return
                        }
                        result(extractText)
                    }
                }
            }
        }
    }
    
    func initializeTessData() {
        
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let destURL = documentsURL.appendingPathComponent("tessdata")
        let sourceURL = Bundle.main.bundleURL.appendingPathComponent("tessdata")
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: sourceURL.path), !fileManager.fileExists(atPath: destURL.path) else { return }
        do {
            // The bundled models are read-only. A private symlink gives the
            // native engine its expected Documents/tessdata location without
            // copying document-derived data or emitting diagnostics.
            try fileManager.createSymbolicLink(at: destURL, withDestinationURL: sourceURL)
        } catch {
            // Recognition will return a safe error if the engine cannot load.
        }
    }
}
