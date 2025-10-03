import 'package:flutter/material.dart';

class Timer {

  final int duration;

  Timer({required this.duration});
  factory Timer.fromJson(Map<String, dynamic> json) {
    return Timer(
      duration: json['duration'],
    );
  }
}
