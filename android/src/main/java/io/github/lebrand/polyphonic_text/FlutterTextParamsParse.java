package io.github.lebrand.polyphonic_text;

import java.util.Map;

public class FlutterTextParamsParse {

    public static class TextColor {
        public int r;
        public int g;
        public int b;
        public int a;
    }

    public static class WidgetParams {
        public String text;
        public String fontFamily;
        public int maxLines;
        public int overflow;
        public float fontSize;
        public int textAlign;
        public TextColor textColor;
        public float height;
        public int fontWeight;

        public int getFontStyle(){
            if(fontWeight >= 5) return  0;
            return -1;
        }

    }

    public static WidgetParams parseParams(Map<String, Object> params) {
        WidgetParams widgetParams = new WidgetParams();
        widgetParams.text = (String) params.get("text");
        widgetParams.fontFamily = (String) params.get("fontFamily");
        if(params.get("maxLines") != null){
            widgetParams.maxLines = (Integer) params.get("maxLines");
        }else{
            widgetParams.maxLines = -1;
        }
        widgetParams.overflow = (Integer) params.get("overflow");
        widgetParams.fontSize = ((Number) params.get("fontSize")).floatValue();
        widgetParams.textAlign = (Integer) params.get("textAlign");
        widgetParams.fontWeight = (Integer) params.get("fontWeight");

        Map<String, Number> textColorMap = (Map<String, Number>) params.get("textColor");
        TextColor textColor = new TextColor();
        textColor.r = textColorMap.get("r").intValue();
        textColor.g = textColorMap.get("g").intValue();
        textColor.b = textColorMap.get("b").intValue();
        textColor.a = textColorMap.get("a").intValue();
        widgetParams.textColor = textColor;

        if(params.get("height") != null){
            widgetParams.height = ((Number) params.get("height")).floatValue();
        }else{
            widgetParams.height = 1;
        }

        return widgetParams;
    }
}
