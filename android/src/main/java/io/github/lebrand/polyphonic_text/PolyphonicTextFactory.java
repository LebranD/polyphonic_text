package io.github.lebrand.polyphonic_text;

import android.content.Context;

import java.util.Map;
import java.util.function.Function;

import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;
import io.flutter.plugin.common.StandardMessageCodec;

public class PolyphonicTextFactory extends PlatformViewFactory {
    final TextLayoutListener listener;
    public PolyphonicTextFactory(TextLayoutListener listener) {
        super(StandardMessageCodec.INSTANCE);
        this.listener = listener;
    }

    @Override
    public PlatformView create(Context context, int id, Object args) {
        Map<String, Object> params = (Map<String,Object>) args;
        FlutterTextParamsParse.WidgetParams p = FlutterTextParamsParse.parseParams(params);
        return new PolyphonicTextView(context, id, listener,p);
    }
}
