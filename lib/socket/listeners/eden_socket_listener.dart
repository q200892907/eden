abstract class EdenSocketListener {
  void onReceivedMessage(
    Map<String, dynamic> message,
  ); //接收步消息

  void onSocketConnected(); //socket链接成功
}
