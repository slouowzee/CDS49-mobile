import 'package:flutter/material.dart';
import 'dart:async';

// Modèle Timer
class QuestionTimer {
  final int duration;

  QuestionTimer({required this.duration});
  
  factory QuestionTimer.fromJson(Map<String, dynamic> json) {
    return QuestionTimer(
      duration: json['duration'] ?? 20,
    );
  }
}

// Widget de question avec timer
class QuestionWithTimer extends StatefulWidget {
  final String question;
  final List<String> options;
  final Function(int? selectedIndex) onValidate;
  final int timerDuration; // en secondes
  final VoidCallback onTimeOut;

  const QuestionWithTimer({
    required this.question,
    required this.options,
    required this.onValidate,
    this.timerDuration = 20,
    required this.onTimeOut,
    Key? key,
  }) : super(key: key);

  @override
  State<QuestionWithTimer> createState() => _QuestionWithTimerState();
}

class _QuestionWithTimerState extends State<QuestionWithTimer> {
  late int _remainingSeconds;
  Timer? _timer;
  int? _selectedOptionIndex;
  bool _isValidated = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.timerDuration;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _handleTimeOut();
        }
      });
    });
  }

  void _handleTimeOut() {
    _timer?.cancel();
    if (!_isValidated) {
      // Score = 0 si pas de réponse validée dans le temps
      widget.onTimeOut();
    }
  }

  void _handleValidate() {
    if (!_isValidated && _selectedOptionIndex != null) {
      setState(() {
        _isValidated = true;
      });
      _timer?.cancel();
      widget.onValidate(_selectedOptionIndex);
    }
  }

  Color _getTimerColor() {
    if (_remainingSeconds > 10) {
      return Colors.green;
    } else if (_remainingSeconds > 5) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Question'),
        actions: [
          // Timer display dans l'AppBar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getTimerColor(),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer, color: Colors.white, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '$_remainingSeconds s',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Barre de progression du timer
            LinearProgressIndicator(
              value: _remainingSeconds / widget.timerDuration,
              backgroundColor: Colors.grey[300],
              color: _getTimerColor(),
              minHeight: 8,
            ),
            const SizedBox(height: 24),
            
            // Question
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  widget.question,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Options de réponse
            Expanded(
              child: ListView.builder(
                itemCount: widget.options.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedOptionIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: InkWell(
                      onTap: _isValidated
                          ? null
                          : () {
                              setState(() {
                                _selectedOptionIndex = index;
                              });
                            },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.blue.shade100
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                              color: isSelected ? Colors.blue : Colors.grey,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.options[index],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Bouton de validation
            ElevatedButton(
              onPressed: _isValidated || _selectedOptionIndex == null
                  ? null
                  : _handleValidate,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.blue,
                disabledBackgroundColor: Colors.grey,
              ),
              child: Text(
                _isValidated ? 'Réponse validée' : 'Valider',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

