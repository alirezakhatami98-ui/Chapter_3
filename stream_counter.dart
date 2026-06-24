import 'dart:async'; // StreamController در این کتابخانه است

void main() {
  // creating a StreamController type of int
  final controller = StreamController<int>();

  // listening to the stream
  controller.stream.listen(
    (data) {
      print('Received: $data');
    },
    onDone: () {
      print('Stream finished.');
    },
    onError: (error) {
      print('Error: $error');
    },
  );

  // adding data to the stream
  int counter = 1;
  Timer.periodic(Duration(seconds: 1), (timer) {
    controller.add(counter);
    counter++;
    if (counter > 10) {
      timer.cancel();
      controller.close();
    }
  });
}
