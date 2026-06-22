Future<String> simulateNetworkRequest() {
  return Future.delayed(Duration(seconds: 3), () => "Data received.");
}

Future<void> main() async {
  print("Receiving data...");

  String data = await simulateNetworkRequest();
  print(data);

  print("Operation completed.");
}
