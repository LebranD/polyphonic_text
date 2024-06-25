package io.github.lebrand.polyphonic_text;

import android.content.Context;
import android.graphics.Color;
import android.graphics.Typeface;
import android.graphics.text.LineBreaker;
import android.os.Build;
import android.text.TextUtils;
import android.util.DisplayMetrics;
import android.util.Log;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.widget.TextView;

import java.io.File;
import java.util.function.Function;

import io.flutter.plugin.platform.PlatformView;

public class PolyphonicTextView implements PlatformView {

    final TextLayoutListener listener;

    private final TextView textView;

    final FlutterTextParamsParse.WidgetParams params;

    PolyphonicTextView(Context context, int id,TextLayoutListener listener, FlutterTextParamsParse.WidgetParams params) {
        textView = new TextView(context);
        textView.setId(id);
        this.listener = listener;
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
//        Typeface typeface = Typeface.createFromAsset(context.getAssets(), "fonts/ToneOZ-Pinyin-WenKai-Regular.ttf");

        if(params.fontFamily !=null && !params.fontFamily.isEmpty()){
            Typeface typeface = Typeface.createFromFile(context.getFilesDir().getAbsolutePath() + "/Fonts/"+params.fontFamily+".ttf");
            textView.setTypeface(typeface);
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
                listener.onLayoutUpdate(textView.getId(), height, width);
            }
        });
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
}
