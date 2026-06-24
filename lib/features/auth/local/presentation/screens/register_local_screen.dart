import 'package:flutter/material.dart';
import 'package:treasureflow/features/auth/local/presentation/screens/step1_business_data.dart';
import 'package:treasureflow/features/auth/local/presentation/screens/step2_operations_data.dart';
import 'package:treasureflow/features/auth/local/presentation/screens/step3_location_data.dart';
import 'package:treasureflow/shared/widgets/custom_stepper_widget.dart';

class RegisterLocalScreen extends StatefulWidget {
  const RegisterLocalScreen({super.key});

  @override
  State<RegisterLocalScreen> createState() => _RegisterLocalScreenState();
}

class _RegisterLocalScreenState extends State<RegisterLocalScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 1;

  void _nextStep() {
    if (_currentStep < 3) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Registra tu establecimiento"),
        backgroundColor: colors.background,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomStepperWidget(
              currentStep: _currentStep,
              stepLabels: const ['Datos del negocio', 'Datos de operación', 'Ubicación'],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Step1BusinessData(onNext: _nextStep),
                Step2OperationsData(onNext: _nextStep, onBack: _previousStep),
                Step3LocationData(onNext: _nextStep, onBack: _previousStep)
              ],
            ),
          ),
        ],
      ),
    );
  }
}