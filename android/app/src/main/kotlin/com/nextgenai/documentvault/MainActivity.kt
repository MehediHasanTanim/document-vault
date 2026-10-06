package com.nextgenai.documentvault

import android.content.Intent
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private var backupResult: MethodChannel.Result? = null
    private var backupSourcePath: String? = null

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
    }

    @Deprecated("Deprecated in Android API")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != REQUEST_SAVE_BACKUP) return
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
    }

    companion object {
        private const val REQUEST_SAVE_BACKUP = 8101
    }
}
