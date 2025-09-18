Aim : Write a simple Dart program for input/output and loops.

steps followed:

1. Importing Dart Library for Input

Dart uses the dart:io library to handle input and output operations like reading from the keyboard.
The statement:
import 'dart:io';


imports this library.

2. User Input Prompt
The program asks the user to enter a number by printing a prompt to the console.
print('Enter a number:');

3. Reading and Parsing User Input
The program reads the user's input as a string using stdin.readLineSync().
int number = int.parse(stdin.readLineSync()!);
The stdin.readLineSync() function returns the input as a string.
The int.parse() function is then used to convert the string into an integer.
The ! is used to assert that the input is not null.

4. Using a Loop (Countdown)
A for loop is used to count down from the number entered by the user to 0.
for (int i = number; i >= 0; i--) {
  print(i);
}

The loop starts with i = number (the number entered by the user) and decrements i with each iteration (i--).
The loop condition checks if i is greater than or equal to 0, and if true, it continues printing the value of i until it reaches 0.

