package io.github.lebrand.polyphonic_text;

import android.content.Context;

import java.util.Map;

import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.common.BinaryMessenger;

public class PolyphonicTextFactory extends PlatformViewFactory {
    final BinaryMessenger messenger;
    public PolyphonicTextFactory(BinaryMessenger messenger) {
        super(StandardMessageCodec.INSTANCE);
        this.messenger = messenger;
    }

    @Override
    public PlatformView create(Context context, int id, Object args) {
        Map<String, Object> params = (Map<String,Object>) args;
        FlutterTextParamsParse.WidgetParams p = FlutterTextParamsParse.parseParams(params);
        return new PolyphonicTextView(context, id,p, messenger);
    }
}
