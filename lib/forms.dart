import 'package:flutter/material.dart';

class FormPage extends StatefulWidget {
  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State {
//This key will be used to identify the state of the form.
  final _formKey = GlobalKey<FormState>();

  TextEditingController userInput = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  const Text("Test Iterations:"),
                  TextFormField(
                    controller: userInput,
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.blue,
                      fontWeight: FontWeight.w600, 
                    ),
                    onChanged: (value) {
                      setState(() {
                        userInput.text = value.toString();
                      });
                    },
                  ),
                ]),
                ElevatedButton(
                  style: const ButtonStyle(
                    backgroundColor:
                        MaterialStatePropertyAll<Color>(Colors.blue),
                  ),
                  onPressed: () {},
                  child: const Text('Submit'),
                ),
              ]),
        ),
      ),
    );
  }
}
