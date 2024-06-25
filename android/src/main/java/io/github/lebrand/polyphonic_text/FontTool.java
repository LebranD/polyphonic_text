package io.github.lebrand.polyphonic_text;

import android.graphics.Typeface;
import android.os.AsyncTask;
import android.util.Log;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;

public class FontTool{

    static private FontTool _instance;

    private FontTool() {
    }

    static FontTool getInstance(){
        if(_instance == null) {
            _instance = new FontTool();
        }
        return  _instance;
    }

    public boolean fontIsInstalled(String path){
        File fontFile = new File(path);
        if (fontFile.exists()) {
            try {
                Typeface typeface = Typeface.createFromFile(fontFile);
                return typeface != null;
            } catch (Exception e) {
                e.printStackTrace();
                return false;
            }
        }
        return false;
    }

}



  interface DownloadResult{
     void onSuccess();
     void onFail();
}


class DownloadFileTask extends AsyncTask<Void, Void, Boolean> {
    private final String fontUrl;
    private final String savePath;
    private final String fontName;
    final DownloadResult result;

    DownloadFileTask(String fontUrl, String savePath, String fontName, DownloadResult result) {
        this.fontUrl = fontUrl;
        this.savePath = savePath;
        this.fontName = fontName;
        this.result = result;
    }

    @Override
    protected Boolean doInBackground(Void... voids) {
        try {
            File storagePath = new File(savePath);
            Log.i("downloadFont","存储文件夹："+ storagePath);
            if (!storagePath.exists()) {
                Log.i("downloadFont","创建存储文件夹"+storagePath);
                storagePath.mkdirs();
            }

            File fontFile = new File(storagePath, fontName);
            Log.i("downloadFont","字体存储路径："+fontFile.getPath());

            if (!fontFile.exists()) {
                Log.i("downloadFont","创建文件"+fontFile.getPath());
                fontFile.createNewFile();
            }

            Log.i("downloadFont","开始下载："+fontUrl);

            URL url = new URL(fontUrl);
            HttpURLConnection urlConnection = (HttpURLConnection) url.openConnection();
            urlConnection.setRequestMethod("GET");
            urlConnection.connect();

            InputStream inputStream = urlConnection.getInputStream();
            FileOutputStream fileOutputStream = new FileOutputStream(fontFile);

            byte[] buffer = new byte[1024];
            int bufferLength;

            while ((bufferLength = inputStream.read(buffer)) > 0) {
                fileOutputStream.write(buffer, 0, bufferLength);
            }

            fileOutputStream.close();
            inputStream.close();
            Log.i("downloadFont","下载结束："+fontFile);
            return true;
        } catch (Exception e) {
            Log.e("downloadFont","下载失败：" + e.toString());
            // 删除文件
            File fontFile = new File(savePath + "/" + fontName);
            Log.e("downloadFont","删除文件：" + fontFile.getPath());
            fontFile.deleteOnExit();
            return false;
        }
    }

    @Override
    protected void onPostExecute(Boolean success) {
        if (success) {
            // 返回下载成功
            result.onSuccess();
        } else {
            // 返回下载失败
            result.onFail();
        }
    }
}