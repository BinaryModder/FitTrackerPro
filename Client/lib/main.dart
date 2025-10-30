import 'package:flutter/material.dart';
import 'package:health/health.dart'; // Убедитесь что этот импорт работает
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'services/background_service.dart';
import 'services/workmanager_service.dart';
import 'catalog.dart';
import 'profile.dart';
import 'workouts.dart';
import 'activity.dart';
import 'nutritions.dart';
// networkType: NetworkType.connected,
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация background service
  await initializeBackgroundService();
  
  // Инициализация Workmanager
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );
  
  // Запуск периодических задач
  await Workmanager().registerPeriodicTask(
    "stepTracker",
    "stepTrackingTask",
    frequency: const Duration(minutes: 15),
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
  );
  
  runApp(const FitnessApp());
}

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _steps = 0;
  bool _isAuthorized = false;
  bool _isLoading = true;
  bool _hasError = false;
  DateTime? _lastUpdate;
  
  final HealthFactory health = HealthFactory();
  static final types = [HealthDataType.STEPS];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
    _setupBackgroundServiceListener();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadCachedData();
      _fetchSteps();
    } else if (state == AppLifecycleState.paused) {
      _saveCurrentData();
    }
  }

  Future<void> _initializeApp() async {
    await _loadCachedData();
    await _initHealth();
    await _startBackgroundService();
  }

  Future<void> _loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedSteps = prefs.getInt('background_steps');
      final lastUpdate = prefs.getString('last_update');
      
      if (cachedSteps != null) {
        setState(() {
          _steps = cachedSteps;
        });
      }
      
      if (lastUpdate != null) {
        setState(() {
          _lastUpdate = DateTime.parse(lastUpdate);
        });
      }
    } catch (e) {
      print('Error loading cached data: $e');
    }
  }

  Future<void> _saveCurrentData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('background_steps', _steps);
      await prefs.setString('last_update', DateTime.now().toIso8601String());
    } catch (e) {
      print('Error saving data: $e');
    }
  }

  Future<void> _initHealth() async {
  try {
    await _requestPermissions();
    
     bool authorized = await health.requestAuthorization(types);
    setState(() {
      _isAuthorized = authorized;
    });

    if (_isAuthorized) {
      await _fetchSteps();
    } else {
      setState(() {
        _hasError = true;
      });
    }
  } catch (e) {
    print('Error initializing health: $e');
    setState(() {
      _hasError = true;
    });
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}
  Future<void> _requestPermissions() async {
    // Используем Platform из dart:io
    await [
      Permission.activityRecognition,
      Permission.location,
      Permission.notification,
      Permission.ignoreBatteryOptimizations,
    ].request();
  }

  Future<void> _startBackgroundService() async {
    final service = FlutterBackgroundService();
    await service.startService();
  }

void _setupBackgroundServiceListener() {
  FlutterBackgroundService().on('update').listen((event) {
    if (event != null) {
      final steps = event['steps'];
      if (steps != null) {
        setState(() {
          _steps = steps;
          _lastUpdate = DateTime.now();
        });
        _saveCurrentData();
      }
    }
  });
}
  Future<void> _fetchSteps() async {
  try {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    
    List<HealthDataPoint> stepsData = await health.getHealthDataFromTypes(
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
    
    setState(() {
      _steps = totalSteps;
      _lastUpdate = DateTime.now();
      _hasError = false;
    });
    
    await _saveCurrentData();
  } catch (e) {
    print('Error fetching steps: $e');
  }
}

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    await _fetchSteps();
    setState(() {
      _isLoading = false;
    });
  }

  String _formatSteps(int steps) {
    return steps.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  double _calculateDistance(int steps) {
    return (steps * 0.0008);
  }

  String _getLastUpdateText() {
    if (_lastUpdate == null) return '';
    final now = DateTime.now();
    final difference = now.difference(_lastUpdate!);
    
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }

  Widget _buildStepsCard() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFFD46C3B)),
            SizedBox(height: 10),
            Text('Loading...', style: TextStyle(fontSize: 12)),
          ],
        ),
      );
    }

    if (_hasError || !_isAuthorized) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 36, color: Colors.red[400]),
          const SizedBox(height: 14),
          const Text(
            'Need Permissions',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _initHealth,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD46C3B),
              foregroundColor: Colors.white,
            ),
            child: const Text('Grant Access'),
          ),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          _steps > 0 ? Icons.directions_walk : Icons.accessibility_new,
          size: 36,
          color: const Color(0xFFD46C3B),
        ),
        const SizedBox(height: 14),
        Text(
          _formatSteps(_steps),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'steps',
          style: TextStyle(fontSize: 18, color: Colors.black54),
        ),
        const SizedBox(height: 4),
        Text(
          '${_calculateDistance(_steps).toStringAsFixed(2)} km',
          style: const TextStyle(fontSize: 14, color: Colors.black45),
        ),
        if (_lastUpdate != null) ...[
          const SizedBox(height: 4),
          Text(
            _getLastUpdateText(),
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
        ],
        const SizedBox(height: 8),
        IconButton(
          onPressed: _refreshData,
          icon: const Icon(Icons.refresh, size: 20),
          color: const Color(0xFF446E67),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const double navBarHeight = 80.0;
    const double fabDiameter = 64.0;
    const double fabRadius = fabDiameter / 2;

    return Scaffold(
      body: Stack(
        children: [
          /// 📷 ФОНОВОЕ ИЗОБРАЖЕНИЕ
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/bg.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          /// КОНТЕНТ
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 34, right: 120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'FITNESS TRACKER',
                              style: TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Your personal trainer and nutritionist',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// 🔹 Кнопка профиля
                      Positioned(
                        top: 0,
                        right: -10,
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white,
                          child: IconButton(
                            icon: const Icon(
                              Icons.person,
                              size: 28,
                              color: Colors.black87,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProfilePage(),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Кнопка Start Workout
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CatalogPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 28),
                        backgroundColor: const Color(0xFFD49A5D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        'Start Workout',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // 📊 КАРТОЧКИ
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Steps карточка
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ActivityPage(),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              height: 180,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 6,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                              child: _buildStepsCard(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Workouts + Nutrition
                        Expanded(
                          child: Column(
                            children: [
                              // Workouts
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const WorkoutsPage(),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 6,
                                        offset: Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.fitness_center,
                                        size: 36,
                                        color: Color(0xFFD46C3B),
                                      ),
                                      SizedBox(height: 14),
                                      Text(
                                        'Workouts',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Nutrition
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const NutritionScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 6,
                                        offset: Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.local_pizza,
                                        size: 36,
                                        color: Color(0xFFD46C3B),
                                      ),
                                      SizedBox(height: 14),
                                      Text(
                                        'Nutrition',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// ⚪ Нижняя панель
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: navBarHeight,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFDFBF7),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, -2),
                  ),
                ],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  /// 🟠 Левая иконка — bar_chart (вместо домика)
                  IconButton(
                    icon: const Icon(
                      Icons.bar_chart,
                      size: 32,
                      color: Colors.black87,
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MainScreen()),
                      );
                    },
                  ),

                  const SizedBox(width: 60),

                  /// 🔹 Правая иконка — меню (три полоски)
                  IconButton(
                    icon: const Icon(
                      Icons.menu,
                      size: 32,
                      color: Colors.black87,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CatalogPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          /// ➕ FAB по центру
          Positioned(
            bottom: navBarHeight - fabRadius,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: fabDiameter,
                height: fabDiameter,
                child: FloatingActionButton(
                  onPressed: () {
                    _showCreateWorkoutDialog(context);
                  },
                  backgroundColor: const Color(0xFF446E67),
                  shape: const CircleBorder(),
                  child: const Icon(Icons.add, size: 32, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🌟 Диалог создания тренировки
  void _showCreateWorkoutDialog(BuildContext context) {
    String workoutName = '';
    String selectedType = 'Strength';
    int duration = 30;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Create Workout",
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation1, animation2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFDFBF7),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Create Workout",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF446E67),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Название тренировки
                      TextField(
                        decoration: InputDecoration(
                          labelText: "Workout Name",
                          labelStyle: const TextStyle(color: Colors.black87),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Color(0xFFD49A5D)),
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onChanged: (value) => workoutName = value,
                      ),
                      const SizedBox(height: 16),

                      // Тип тренировки
                      DropdownButtonFormField<String>(
                        value: selectedType,
                        decoration: InputDecoration(
                          labelText: "Workout Type",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Color(0xFFD49A5D)),
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: "Strength", child: Text("Strength")),
                          DropdownMenuItem(value: "Cardio", child: Text("Cardio")),
                          DropdownMenuItem(value: "Yoga", child: Text("Yoga")),
                          DropdownMenuItem(value: "Stretching", child: Text("Stretching")),
                        ],
                        onChanged: (value) {
                          setState(() => selectedType = value!);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Продолжительность
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                if (duration > 5) duration -= 5;
                              });
                            },
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text(
                            "$duration min",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                duration += 5;
                              });
                            },
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Кнопки действий
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(
                                    color: Colors.black87, fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: const Color(0xFF446E67),
                                    content: Text(
                                      "✅ Workout '$workoutName' ($selectedType, $duration min) created!",
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD49A5D),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Create",
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim1, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
            child: child,
          ),
        );
      },
    );
  }
}