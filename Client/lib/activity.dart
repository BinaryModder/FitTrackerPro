import 'package:flutter/material.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  bool syncGoogleFit = true;
  bool syncAppleHealth = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// 📷 Фон из assets
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/activity_background.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              // 👈 Добавлен скролл
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🔙 Назад + Иконка + Заголовок
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          size: 28,
                          color: Colors.black87,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      const Icon(
                        Icons.directions_run,
                        size: 28,
                        color: Colors.black87,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Activity",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  /// Статистика
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatCard("Steps", "0"),
                      _buildStatCard("Distance", "0 km"),
                      _buildStatCard("Calories", "0"),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// Прогресс бар
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("0 steps of 70,000"),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: 0.0,
                            minHeight: 6,
                            backgroundColor: Colors.grey.shade300,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text("0%"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// Activity Charts
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Activity Charts",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF6D9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.search, color: Colors.black54),
                              SizedBox(width: 8),
                              Text("Select period"),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        /// 👇 Теперь график НАД кнопками
                        Container(
                          height: 100, // уменьшена высота
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              "Graph Placeholder",
                              style: TextStyle(color: Colors.black54),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        /// Переключатели Day / Week
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [_buildButton("Day"), _buildButton("Week")],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// 🔹 Подзаголовок Sync
                  const Text(
                    "Sync",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  /// Синхронизация Google Fit
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Sync Google Fit",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Switch(
                        value: syncGoogleFit,
                        activeColor: Colors.orange,
                        onChanged: (val) {
                          setState(() {
                            syncGoogleFit = val;
                          });
                        },
                      ),
                    ],
                  ),

                  /// Синхронизация Apple Health
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Sync Apple Health",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Switch(
                        value: syncAppleHealth,
                        activeColor: Colors.orange,
                        onChanged: (val) {
                          setState(() {
                            syncAppleHealth = val;
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Карточка статистики
  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.9),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(title),
        ],
      ),
    );
  }

  /// Кнопка Day / Week
  static Widget _buildButton(String text) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {},
      child: Text(text),
    );
  }
}
