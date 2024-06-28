package com.eden.eden;


import android.app.Application;

public class MyApplication extends Application
{

  private static MyApplication myApplication = null;

  public static MyApplication getApplication()
  {
    return myApplication;
  }

  @Override
  public void onCreate()
  {
    super.onCreate();
    myApplication = this;
  }
}
