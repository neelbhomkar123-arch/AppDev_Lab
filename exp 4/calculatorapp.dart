import 'package:flutter/material.dart';

// The main function is the starting point for all Flutter apps.
void main() {
  runApp(const CalculatorApp());
}

// CalculatorApp is the root widget of the application.
class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Disables the debug banner in the top right corner.
      debugShowCheckedModeBanner: false,
      title: 'Flutter Calculator',
      // Sets the overall theme of the app.
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const CalculatorHomePage(),
    );
  }
}

// CalculatorHomePage is the main screen of the app. It's a StatefulWidget
// because its state (the displayed numbers and calculations) changes.
class CalculatorHomePage extends StatefulWidget {
  const CalculatorHomePage({super.key});

  @override
  State<CalculatorHomePage> createState() => _CalculatorHomePageState();
}

class _CalculatorHomePageState extends State<CalculatorHomePage> {
  // --- State Variables ---
  String output = "0"; // The text displayed on the calculator screen.
  String _output = "0"; // Internal variable for calculations.
  double num1 = 0.0;
  double num2 = 0.0;
  String operand = "";

  // --- Logic for Button Presses ---
  void buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == "AC") {
        // Reset all variables to their initial state.
        _output = "0";
        num1 = 0.0;
        num2 = 0.0;
        operand = "";
      } else if (buttonText == "+/-") {
        if (_output != "0") {
          if (_output.startsWith('-')) {
            _output = _output.substring(1);
          } else {
            _output = '-$_output';
          }
        }
      } else if (buttonText == "%") {
        _output = (double.parse(output) / 100).toString();
      } else if (buttonText == "+" ||
          buttonText == "-" ||
          buttonText == "÷" ||
          buttonText == "×") {
        // An operator button was pressed.
        num1 = double.parse(output);
        operand = buttonText;
        _output = "0"; // Reset for the next number.
      } else if (buttonText == ".") {
        // Decimal point was pressed.
        if (!_output.contains(".")) {
          _output = _output + buttonText;
        }
      } else if (buttonText == "=") {
        // Equals button was pressed.
        num2 = double.parse(output);

        // Perform the calculation based on the operand.
        if (operand == "+") {
          _output = (num1 + num2).toString();
        }
        if (operand == "-") {
          _output = (num1 - num2).toString();
        }
        if (operand == "×") {
          _output = (num1 * num2).toString();
        }
        if (operand == "÷") {
          if (num2 != 0) {
            _output = (num1 / num2).toString();
          } else {
            _output = "Error"; // Handle division by zero
          }
        }

        // Reset for future calculations.
        num1 = 0.0;
        num2 = 0.0;
        operand = "";
      } else {
        // A number button was pressed.
        if (_output == "0") {
          _output = buttonText;
        } else {
          _output = _output + buttonText;
        }
      }
      
      // Clean up the output string to remove unnecessary ".0"
      if (_output.endsWith(".0")) {
        output = _output.substring(0, _output.length - 2);
      } else {
        output = _output;
      }
    });
  }

  // --- UI Helper for building buttons ---
  Widget buildButton(String buttonText, {Color color = Colors.black54, Color textColor = Colors.white}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.all(24.0),
            shape: const CircleBorder(),
          ),
          child: Text(
            buttonText,
            style: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          onPressed: () => buttonPressed(buttonText),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Flutter Calculator'),
        backgroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          // --- Display Screen ---
          Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(
              vertical: 24.0,
              horizontal: 12.0,
            ),
            child: Text(
              output,
              style: const TextStyle(
                fontSize: 48.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const Expanded(
            child: Divider(color: Colors.white24),
          ),
          // --- Button Rows ---
          Column(
            children: [
              Row(
                children: [
                  buildButton("AC", color: Colors.grey, textColor: Colors.black),
                  buildButton("+/-", color: Colors.grey, textColor: Colors.black),
                  buildButton("%", color: Colors.grey, textColor: Colors.black),
                  buildButton("÷", color: Colors.amber[700]!),
                ],
              ),
              Row(
                children: [
                  buildButton("7"),
                  buildButton("8"),
                  buildButton("9"),
                  buildButton("×", color: Colors.amber[700]!),
                ],
              ),
              Row(
                children: [
                  buildButton("4"),
                  buildButton("5"),
                  buildButton("6"),
                  buildButton("-", color: Colors.amber[700]!),
                ],
              ),
              Row(
                children: [
                  buildButton("1"),
                  buildButton("2"),
                  buildButton("3"),
                  buildButton("+", color: Colors.amber[700]!),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black54,
                          padding: const EdgeInsets.symmetric(vertical: 24.0),
                          shape: const StadiumBorder(),
                        ),
                        onPressed: () => buttonPressed("0"),
                        child: const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: 24.0),
                            child: Text(
                              "0",
                              style: TextStyle(
                                fontSize: 22.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  buildButton("."),
                  buildButton("=", color: Colors.amber[700]!),
                ],
              ),
               const SizedBox(height: 10),
            ],
          )
        ],
      ),
    );
  }
}
