import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    print("Workmanager: Task running - $task");
    
    try {
      final types = [HealthDataType.STEPS];
      
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      
      // Для health 13.2.1 - правильный API
      final health = Health();
      List<HealthDataPoint> stepsData = await health.getHealthDataFromTypes(
        startTime: startOfDay,
        endTime: now,
        types: [HealthDataType.STEPS],
      );
      int totalSteps = 0;
      for (var dataPoint in stepsData) {
        if (dataPoint.type == HealthDataType.STEPS) {
          totalSteps += (dataPoint.value as num).toInt();
        }
      }
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('background_steps', totalSteps);
      await prefs.setString('last_update', now.toIso8601String());
      
      print("Workmanager: Steps updated - $totalSteps");
      return true;
    } catch (e) {
      print("Workmanager Error: $e");
      return false;
    }
  });
}