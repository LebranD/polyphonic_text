package io.github.lebrand.polyphonic_text;

import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** PolyphonicTextPlugin */
public class PolyphonicTextPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;

  private String savePath;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "polyphonic_text");
    Context applicationContext = flutterPluginBinding.getApplicationContext();
    savePath = applicationContext.getFilesDir().getAbsolutePath();
    channel.setMethodCallHandler(this);
    flutterPluginBinding.getPlatformViewRegistry()
            .registerViewFactory("polyphonic_text_factory", new PolyphonicTextFactory(flutterPluginBinding.getBinaryMessenger()));
  }

  private String getFontSavePath(){
    return savePath + "/Fonts";
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    }else if(call.method.equals("downloadFontIfNeed")){
      final FontTool fontTool =  FontTool.getInstance();
      Map<String, Object> arguments = call.arguments();
      String fontName = (String) arguments.get("fontName");
      String fontUrl = (String) arguments.get("fontUrl");
      boolean installed =  fontTool.fontIsInstalled(getFontSavePath() + "/" + fontName + ".ttf" );
      if(!installed){
        new DownloadFileTask(fontUrl,getFontSavePath(),fontName + ".ttf", new DownloadResult() {
          @Override
          public void onSuccess() {
            Log.i("downloadFont", "下载成功");
            // 缓存
            fontTool.cacheFont(getFontSavePath() + "/" + fontName + ".ttf", fontName);
            result.success(true);
          }
          @Override
          public void onFail() {
            Log.i("downloadFont", "下载失败");
            result.success(false);
          }
        }).execute();
      }else{
        // 缓存字体
        fontTool.cacheFont(getFontSavePath() + "/" + fontName + ".ttf", fontName);
        result.success(true);
      }
    }else if(call.method.equals("isFontInstalled")){
      // 字体是否存在
      final FontTool fontTool =  FontTool.getInstance();
      Map<String, Object> arguments = call.arguments();
      String fontName = (String) arguments.get("fontName");
      boolean installed =  fontTool.fontIsInstalled(getFontSavePath() + "/" + fontName + ".ttf" );
      result.success(installed);
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
