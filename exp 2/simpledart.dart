// Import the 'dart:io' library for input/output functions.
import 'dart:io';

void main() {
  // 1. OUTPUT: Prompt the user for their name.
  // stdout.write() prints without adding a new line at the end.
  stdout.write('Please enter your name: ');

  // 2. INPUT: Read the name from the console.
  // readLineSync() reads the full line of text the user types.
  // The '?' means the variable 'name' can be null if no input is given.
  String? name = stdin.readLineSync();

  // Prompt the user for a number.
  stdout.write('How many times should I greet you? ');

  // Read the number as a string and convert it to an integer.
  String? inputNumber = stdin.readLineSync();
  int count = int.parse(inputNumber ?? '0'); // Use '0' if input is null

  print('--------------------'); // A simple separator

  // 3. LOOP: Repeat the greeting 'count' times.
  // This 'for' loop starts at 1 and continues as long as 'i' is less than or equal to 'count'.
  for (int i = 1; i <= count; i++) {
    // OUTPUT within the loop.
    // String interpolation ($) is used to insert variable values into the string.
    print('Hello, $name! (Greeting #$i)');
  }

  print('--------------------');
  print('Loop finished. Goodbye! 👋');
}