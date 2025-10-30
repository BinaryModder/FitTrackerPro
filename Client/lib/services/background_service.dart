import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';
//health
Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'fitness_tracker_channel',
      initialNotificationTitle: 'Fitness Tracker',
      initialNotificationContent: 'Tracking your steps...',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
  }

  await _startStepTracking(service);
}

Future<void> _startStepTracking(ServiceInstance service) async {

  
  final types = [HealthDataType.STEPS];
  Timer.periodic(const Duration(minutes: 5), (timer) async {
    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: "Fitness Tracker",
        content: "Tracking your steps...",
      );
    }

    try {
      final types = [HealthDataType.STEPS];
      
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      
      List<HealthDataPoint> stepsData = await HealthFactory.getHealthDataFromTypes(
        startOfDay, 
        now, 
        types,
      );
      
      int totalSteps = 0;
      for (var dataPoint in stepsData) {
        if (dataPoint.type == HealthDataType.STEPS) {
          totalSteps += (dataPoint.value as num).toInt();
        }
      }
      
      // Сохраняем в SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('background_steps', totalSteps);
      await prefs.setString('last_update', now.toIso8601String());
      
      print('Background Service: Steps updated - $totalSteps');
      
      // Отправляем обновление в UI (если приложение активно)
      service.invoke('update', {'steps': totalSteps});
      
    } catch (e) {
      print('Background Service Error: $e');
    }
  });
}