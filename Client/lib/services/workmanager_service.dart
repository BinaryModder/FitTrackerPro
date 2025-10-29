import 'package:workmanager/workmanager.dart';
import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print("Workmanager: Task running - $task");
    
    try {
      // Создаем экземпляр HealthFactory внутри workmanager
      final HealthFactory health = HealthFactory();
      final types = [HealthDataType.STEPS];
      
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      
      // Используем экземпляр health
      List<HealthDataPoint> stepsData = await health.getHealthDataFromTypes(
        startOfDay, 
        now, 
        types,
      );
      
      int totalSteps = 0;
      for (var dataPoint in stepsData) {
        if (dataPoint.type == HealthDataType.STEPS) {
          // Исправляем получение значения
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