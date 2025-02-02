import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyDmiCalculator extends StatefulWidget {
  const MyDmiCalculator({super.key});

  @override
  State<MyDmiCalculator> createState() => _MyDmiCalculatorState();
}

class _MyDmiCalculatorState extends State<MyDmiCalculator> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  String _bmiResult = "";
  String _bmiCategory = "";
  String _bmiInfo = "";

  @override
  void initState() {
    super.initState();
    _loadText();
  }

  Future<void> _saveText() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('result', _bmiResult);
    await prefs.setString('category', _bmiCategory);
    await prefs.setString('info', _bmiInfo);
  }

  Future<void> _loadText() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _bmiResult = prefs.getString('result') ?? '';
      _bmiCategory = prefs.getString('category') ?? '';
      _bmiInfo = prefs.getString('info') ?? '';
    });
  }

  Future<void> _removeText() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('result');
    await prefs.remove('category');
    await prefs.remove('info');
    setState(() {
      _bmiResult = '';
      _bmiCategory = '';
      _bmiInfo = '';
    });
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final double heightCm = double.tryParse(_heightController.text) ?? 0;
      final double weightKg = double.tryParse(_weightController.text) ?? 0;

      if (heightCm > 0 && weightKg > 0) {
        final double bmi = ((weightKg / heightCm / heightCm) * 10000);

        String result;
        String information;
        if (bmi < 18.5) {
          result = "Underweight";
          information =
              "You have a lower than normal body weight. You can eat a bit more.";
        } else if (bmi >= 18.5 && bmi < 25.0) {
          result = "Healthy weight range";
          information = "You have a normal body weight, Good job!";
        } else if (bmi >= 25.0 && bmi < 30.0) {
          result = "Overweight";
          information =
              "You have a higher than normal body weight. Try to exercise more.";
        } else {
          result = "Obesity";
          information = "Please exercise more and eat less.";
        }

        setState(() {
          _bmiResult = bmi.toStringAsFixed(2);
          _bmiCategory = result;
          _bmiInfo = information;
        });
        await _saveText();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter valid height and weight")),
        );
      }
    }
  }

  String? _heightValidator(String? height) {
    if (height == null || height.isEmpty) {
      return 'Please enter your height in centimeters';
    } else if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(height)) {
      return "Please enter a valid height in centimeters";
    } else {
      final double heightValue = double.parse(height);
      if (heightValue < 50 || heightValue > 300) {
        return "Please enter a height between 50 cm and 300 cm";
      }
    }
    return null;
  }

  String? _weightValidator(String? weight) {
    if (weight == null || weight.isEmpty) {
      return 'Please enter your weight in kilograms';
    } else if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(weight)) {
      return "Please enter a valid weight";
    } else {
      final double weightValue = double.parse(weight);
      if (weightValue < 3 || weightValue > 500) {
        return "Please enter a weight between 3 kg and 500 kg";
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        title: const Text(
          "BMI Calculator",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey[900],
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(50),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
                'https://static.vecteezy.com/system/resources/thumbnails/038/987/289/small/ai-generated-majestic-mountain-peak-reflects-tranquil-sunset-over-water-generated-by-ai-photo.jpg'),
            fit: BoxFit.fill,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30, 55, 30, 100),
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.blueGrey[800],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Calculate your BMI",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 50),
                    if (_bmiResult.isNotEmpty) ...[
                      Text(
                        _bmiResult,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 24),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _bmiCategory,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _bmiInfo,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: TextFormField(
                        controller: _heightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          label: Text("Height: Centimeters"),
                          hintText: "Height: Centimeters",
                          hintStyle: TextStyle(color: Colors.white),
                          labelStyle: TextStyle(color: Colors.white),
                          filled: false,
                          fillColor: Colors.white,
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: _heightValidator,
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text("Weight: Kilograms"),
                        hintText: "Weight: Kilograms",
                        hintStyle: TextStyle(color: Colors.white),
                        labelStyle: TextStyle(color: Colors.white),
                        filled: false,
                        fillColor: Colors.white,
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: _weightValidator,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                            child: ElevatedButton.icon(
                              onPressed: _submit,
                              icon: const Icon(
                                Icons.calculate,
                                color: Colors.black,
                              ),
                              label: const Text(
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17),
                                  'Calculate BMI'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 15),
                                shadowColor: Colors.black,
                                elevation: 10,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          ElevatedButton.icon(
                            onPressed: _removeText,
                            icon: const Icon(Icons.delete, color: Colors.black),
                            label: const Text(
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17),
                                'Remove Data'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              shadowColor: Colors.black,
                              elevation: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
