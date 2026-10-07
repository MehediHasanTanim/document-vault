package io.paratoner.flutter_tesseract_ocr;

import com.googlecode.tesseract.android.TessBaseAPI;

import android.os.AsyncTask;
import androidx.annotation.NonNull;

import java.io.File;
import java.util.Map.*;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class FlutterTesseractOcrPlugin implements FlutterPlugin, MethodCallHandler {
  private static final int DEFAULT_PAGE_SEG_MODE = TessBaseAPI.PageSegMode.PSM_AUTO_OSD;
  private TessBaseAPI baseApi = null;
  private String lastLanguage = "";

  private MethodChannel channel;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    BinaryMessenger messenger = flutterPluginBinding.getBinaryMessenger();
    channel = new MethodChannel(messenger, "flutter_tesseract_ocr");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    if (channel != null) {
      channel.setMethodCallHandler(null);
      channel = null;
    }
    if (baseApi != null) {
      baseApi.recycle();
      baseApi = null;
    }
  }

  @Override
  public void onMethodCall(final MethodCall call, final Result result) {
    switch (call.method) {
      case "extractText":
      case "extractHocr":
        final String tessDataPath = call.argument("tessData");
        final String imagePath = call.argument("imagePath");
        final Map<String, String> args = call.argument("args");
        String DEFAULT_LANGUAGE = "eng";
        if (call.argument("language") != null) {
          DEFAULT_LANGUAGE = call.argument("language");
        }

        if (baseApi == null || !lastLanguage.equals(DEFAULT_LANGUAGE)) {
          if (baseApi != null) {
            baseApi.recycle();
          }
          baseApi = new TessBaseAPI();
          if (!baseApi.init(tessDataPath, DEFAULT_LANGUAGE)) {
            baseApi.recycle();
            baseApi = null;
            result.error("engine_unavailable", "On-device OCR is unavailable.", null);
            return;
          }
          lastLanguage = DEFAULT_LANGUAGE;
        }

        int psm = DEFAULT_PAGE_SEG_MODE;
        if (args != null) {
          for (Map.Entry<String, String> entry : args.entrySet()) {
            if (!entry.getKey().equals("psm")) {
              baseApi.setVariable(entry.getKey(), entry.getValue());
            } else {
              psm = Integer.parseInt(entry.getValue());
            }
          }
        }

        baseApi.setPageSegMode(psm);
        new OcrAsyncTask(baseApi, new File(imagePath), result, call.method.equals("extractHocr"))
            .executeOnExecutor(AsyncTask.SERIAL_EXECUTOR);
        break;

      default:
        result.notImplemented();
    }
  }

  private static class OcrAsyncTask extends AsyncTask<Void, Void, String> {
    private final TessBaseAPI baseApi;
    private final File imageFile;
    private final Result result;
    private final boolean extractHocr;
    private Exception failure;

    OcrAsyncTask(TessBaseAPI baseApi, File imageFile, Result result, boolean extractHocr) {
      this.baseApi = baseApi;
      this.imageFile = imageFile;
      this.result = result;
      this.extractHocr = extractHocr;
    }

    @Override
    protected String doInBackground(Void... voids) {
      try {
        this.baseApi.setImage(imageFile);
        if (extractHocr) {
          return this.baseApi.getHOCRText(0);
        }
        return this.baseApi.getUTF8Text();
      } catch (Exception error) {
        failure = error;
        return null;
      } finally {
        this.baseApi.stop();
        this.baseApi.clear();
      }

    }

    @Override
    protected void onPostExecute(String recognizedText) {
      if (failure != null) {
        result.error("recognition_failed", "Local OCR could not recognize this image.", null);
        return;
      }
      result.success(recognizedText);
    }
  }
}
