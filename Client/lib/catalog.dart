import 'package:flutter/material.dart';
import 'progress.dart'; // Экран Progress
import 'settings.dart'; // Экран Settings

class CatalogPage extends StatelessWidget {
  const CatalogPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// Фон
          Image.asset("assets/catalog_background.jpg", fit: BoxFit.cover),

          /// Контент
          SafeArea(
            child: Stack(
              children: [
                // Основное содержимое
                SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 8),

                      /// Аватар
                      Center(
                        child: Image.asset(
                          "assets/catalog_avatar.png",
                          width: 180,
                          height: 180,
                        ),
                      ),

                      const SizedBox(height: 8),

                      /// Карточки каталога
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            const _CatalogCard(
                              icon: Icons.person,
                              title: "Profile",
                              subtitle: "Personal data, goals, avatar",
                              iconColor: Colors.amber,
                            ),
                            const SizedBox(height: 12),
                            const _CatalogCard(
                              icon: Icons.fitness_center,
                              title: "Workouts",
                              subtitle: "Exercise catalog, create programs",
                              iconColor: Colors.orange,
                            ),
                            const SizedBox(height: 12),
                            const _CatalogCard(
                              icon: Icons.directions_walk,
                              title: "Activity",
                              subtitle: "Step counting, activity charts",
                              iconColor: Colors.green,
                            ),
                            const SizedBox(height: 12),
                            const _CatalogCard(
                              icon: Icons.restaurant,
                              title: "Nutrition",
                              subtitle: "Food diary, calorie calculation",
                              iconColor: Colors.red,
                            ),
                            const SizedBox(height: 12),

                            /// >>> Карточка PROGRESS <<<
                            _CatalogCard(
                              icon: Icons.timeline,
                              title: "Progress",
                              subtitle: "Track your fitness progress",
                              iconColor: Colors.purple,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ProgressScreen(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 12),

                            /// >>> Карточка SETTINGS <<<
                            _CatalogCard(
                              icon: Icons.settings,
                              title: "Settings",
                              subtitle: "App preferences and configuration",
                              iconColor: Colors.blue,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const SettingsPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Кнопка назад
                Positioned(
                  left: 12,
                  top: 12,
                  child: ClipOval(
                    child: Material(
                      color: Colors.white.withOpacity(0.9),
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const SizedBox(
                          width: 44,
                          height: 44,
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.black87,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Кнопка-робот справа снизу
                Positioned(
                  right: 20,
                  bottom: 20,
                  child: ClipOval(
                    child: Material(
                      color: Colors.white.withOpacity(0.95),
                      elevation: 6,
                      child: InkWell(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("🤖 Robot button pressed"),
                            ),
                          );
                        },
                        child: const SizedBox(
                          width: 64,
                          height: 64,
                          child: Icon(
                            Icons.smart_toy,
                            color: Colors.deepPurple,
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Виджет карточки каталога
class _CatalogCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final VoidCallback? onTap;

  const _CatalogCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 30, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
