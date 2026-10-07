package com.nextgenai.documentvault

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.WindowManager
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private var backupResult: MethodChannel.Result? = null
    private var backupSourcePath: String? = null
    private var shareResult: MethodChannel.Result? = null
    private var oauthResult: MethodChannel.Result? = null
    private var oauthRedirectScheme: String? = null
    private val oauthTimeout = Handler(Looper.getMainLooper())

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Prevent screenshots and recent-app previews while the vault is active.
        window.setFlags(WindowManager.LayoutParams.FLAG_SECURE, WindowManager.LayoutParams.FLAG_SECURE)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "documentvault/backup_destination")
            .setMethodCallHandler { call, result ->
                if (call.method != "saveBackup") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                if (backupResult != null) {
                    result.error("busy", "A backup destination is already open.", null)
                    return@setMethodCallHandler
                }
                val sourcePath = call.argument<String>("sourcePath")
                val filename = call.argument<String>("suggestedFilename")
                if (sourcePath.isNullOrBlank() || filename.isNullOrBlank() || !File(sourcePath).isFile) {
                    result.error("invalid_source", "Backup package is unavailable.", null)
                    return@setMethodCallHandler
                }
                backupResult = result
                backupSourcePath = sourcePath
                startActivityForResult(
                    Intent(Intent.ACTION_CREATE_DOCUMENT)
                        .addCategory(Intent.CATEGORY_OPENABLE)
                        .setType("application/octet-stream")
                        .putExtra(Intent.EXTRA_TITLE, filename),
                    REQUEST_SAVE_BACKUP,
                )
            }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "documentvault/secure_share")
            .setMethodCallHandler { call, result ->
                if (call.method != "share") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                if (shareResult != null) {
                    result.error("busy", "A secure share is already open.", null)
                    return@setMethodCallHandler
                }
                val paths = call.argument<List<String>>("sourcePaths")
                val mimeType = call.argument<String>("mimeType")
                if (paths.isNullOrEmpty() || mimeType.isNullOrBlank() || paths.any { !File(it).isFile }) {
                    result.error("invalid_source", "Secure export is unavailable.", null)
                    return@setMethodCallHandler
                }
                try {
                    val uris = ArrayList(paths.map { path ->
                        FileProvider.getUriForFile(this, "$packageName.secure_share", File(path))
                    })
                    val shareIntent = if (uris.size == 1) {
                        Intent(Intent.ACTION_SEND)
                            .setType(mimeType)
                            .putExtra(Intent.EXTRA_STREAM, uris.single())
                    } else {
                        Intent(Intent.ACTION_SEND_MULTIPLE)
                            .setType(mimeType)
                            .putParcelableArrayListExtra(Intent.EXTRA_STREAM, uris)
                    }.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                    shareResult = result
                    startActivityForResult(
                        Intent.createChooser(shareIntent, "Share document"),
                        REQUEST_SECURE_SHARE,
                    )
                } catch (_: Exception) {
                    result.error("share_failed", "Could not open secure sharing.", null)
                }
            }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "documentvault/cloud_oauth")
            .setMethodCallHandler { call, result ->
                if (call.method != "authorize") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                if (oauthResult != null) {
                    result.error("busy", "Cloud sign-in is already open.", null)
                    return@setMethodCallHandler
                }
                val authorizationUrl = call.argument<String>("authorizationUrl")
                val redirectScheme = call.argument<String>("redirectScheme")
                val parsed = authorizationUrl?.let { Uri.parse(it) }
                if (parsed == null || parsed.scheme != "https" || redirectScheme != "documentvault") {
                    result.error("invalid_request", "Cloud sign-in is unavailable.", null)
                    return@setMethodCallHandler
                }
                oauthResult = result
                oauthRedirectScheme = redirectScheme
                oauthTimeout.postDelayed({
                    val pending = oauthResult ?: return@postDelayed
                    oauthResult = null
                    oauthRedirectScheme = null
                    pending.error("timeout", "Cloud sign-in timed out.", null)
                }, OAUTH_TIMEOUT_MS)
                try {
                    startActivity(Intent(Intent.ACTION_VIEW, parsed))
                } catch (_: Exception) {
                    oauthTimeout.removeCallbacksAndMessages(null)
                    oauthResult = null
                    oauthRedirectScheme = null
                    result.error("unavailable", "Cloud sign-in is unavailable.", null)
                }
            }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "documentvault/privacy_display")
            .setMethodCallHandler { call, result ->
                if (call.method != "apply") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val hideInSwitcher = call.argument<Boolean>("hideInAppSwitcher") ?: true
                val blockScreenshots = call.argument<Boolean>("screenshotProtection") ?: true
                if (hideInSwitcher || blockScreenshots) {
                    window.setFlags(WindowManager.LayoutParams.FLAG_SECURE, WindowManager.LayoutParams.FLAG_SECURE)
                } else {
                    window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                }
                result.success(null)
            }
    }

    @Deprecated("Deprecated in Android API")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_SAVE_BACKUP) {
            val result = backupResult ?: return
            val sourcePath = backupSourcePath
            backupResult = null
            backupSourcePath = null
            val uri = data?.data
            if (resultCode != RESULT_OK || uri == null || sourcePath == null) {
                result.success(false)
                return
            }
            Thread {
                try {
                    File(sourcePath).inputStream().use { input ->
                        contentResolver.openOutputStream(uri, "w")!!.use { output ->
                            input.copyTo(output, DEFAULT_BUFFER_SIZE)
                            output.flush()
                        }
                    }
                    runOnUiThread { result.success(true) }
                } catch (_: Exception) {
                    runOnUiThread { result.error("save_failed", "Could not save backup.", null) }
                }
            }.start()
            return
        }
        if (requestCode == REQUEST_SECURE_SHARE) {
            val result = shareResult ?: return
            shareResult = null
            // Android does not expose recipient identity. This merely records
            // that the user completed the chooser return path, never a recipient.
            result.success(resultCode == RESULT_OK)
            return
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        val result = oauthResult ?: return
        val redirect = intent.data
        if (redirect == null || redirect.scheme != oauthRedirectScheme) return
        oauthTimeout.removeCallbacksAndMessages(null)
        oauthResult = null
        oauthRedirectScheme = null
        result.success(redirect.toString())
    }

    override fun onDestroy() {
        oauthTimeout.removeCallbacksAndMessages(null)
        oauthResult?.error("cancelled", "Cloud sign-in was cancelled.", null)
        oauthResult = null
        oauthRedirectScheme = null
        super.onDestroy()
    }

    companion object {
        private const val REQUEST_SAVE_BACKUP = 8101
        private const val REQUEST_SECURE_SHARE = 8102
        private const val OAUTH_TIMEOUT_MS = 5 * 60 * 1000L
    }
}
