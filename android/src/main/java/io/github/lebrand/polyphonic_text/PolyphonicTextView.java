package io.github.lebrand.polyphonic_text;

import android.content.Context;
import android.graphics.Color;
import android.graphics.Typeface;
import android.text.TextUtils;
import android.util.DisplayMetrics;
import android.util.Log;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.widget.TextView;

import java.time.format.TextStyle;
import java.util.HashMap;
import java.util.Map;

import androidx.annotation.NonNull;


import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.BinaryMessenger;


public class PolyphonicTextView implements PlatformView, MethodCallHandler {

    private final TextView textView;
    public MethodChannel methodChannel;

    final FlutterTextParamsParse.WidgetParams params;

    PolyphonicTextView(Context context, int id, FlutterTextParamsParse.WidgetParams params, BinaryMessenger messager) {
        methodChannel = new MethodChannel(messager, "polyphonic_text_factory_" + id);
        methodChannel.setMethodCallHandler(this);
        textView = new TextView(context);
        textView.setId(id);
        this.params = params;
        configTextView(context);
    }

    private void configTextView(Context context){
        textView.setText(params.text);
        if(params.maxLines != -1){
            textView.setMaxLines(params.maxLines);
        }
        textView.setGravity(getTextAlign(params.textAlign));
        textView.setEllipsize(TextUtils.TruncateAt.END);

        int color = Color.argb(params.textColor.a, params.textColor.r, params.textColor.g, params.textColor.b);
        textView.setTextColor(color);

        // 设置行高
        textView.setTextSize(TypedValue.COMPLEX_UNIT_SP, params.fontSize);
        textView.setLineSpacing(0, params.height);

        // 设置字体
        if(params.fontFamily !=null && !params.fontFamily.isEmpty()){
            Typeface typeface = FontTool.getInstance().getByName(context,params.fontFamily);
            int fontStyle = params.getFontStyle();
            Log.i("PolyphonicText", "fontStyle: " + fontStyle);
            if(fontStyle != -1){
                textView.setTypeface(typeface,fontStyle);
            }else{
                textView.setTypeface(typeface);
            }
        }

        textView.getViewTreeObserver().addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
            @Override
            public void onGlobalLayout() {
                // 获取 TextView 的测量高度
                int measuredHeight = textView.getLineHeight() * textView.getLineCount();
                int measuredWidth = textView.getMeasuredWidth();
                DisplayMetrics displayMetrics = context.getResources().getDisplayMetrics();
                float density = displayMetrics.density;
                float width = measuredWidth / density;
                float height = measuredHeight / density;
                // 取消监听，以免重复调用
                textView.getViewTreeObserver().removeOnGlobalLayoutListener(this);
                onLayoutUpdate(textView.getId(), height, width);
                textView.postInvalidateDelayed(150);
            }
        });
    }

    public void onLayoutUpdate(int id, float height, float width) {
        Log.i("PolyphonicText" ,"onLayoutUpdate " + "id=" + id + ", width=" + width + ", height="+height);
        Map<String,Float> p = new HashMap<>();
        p.put("width",width);
        p.put("height", height);
        methodChannel.invokeMethod("afterLayout", p);
    }

    private int getTextAlign(int textAlign){
            switch (textAlign) {
                case 0:
                    return Gravity.LEFT;
                case 1:
                    return Gravity.RIGHT;
                case 2:
                    return Gravity.CENTER_HORIZONTAL;
                case 3:
                    // Android没有直接等价于JUSTIFY的Gravity
                    return Gravity.FILL_HORIZONTAL;
                case 5:
                    return Gravity.END;
                default:
                    return Gravity.START;
            }
    }

    @Override
    public android.view.View getView() {
        return textView;
    }

    @Override
    public void dispose() {}

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("refreshText")) {
            Log.i("PolyphonicText", "delay:500 refreshText = " + textView.getId());
            textView.postInvalidate();
            result.success(null);
        }
    }
}
