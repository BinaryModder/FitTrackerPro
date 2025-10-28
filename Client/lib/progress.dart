import 'package:flutter/material.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  // Цвета, чтобы легче править
  static const Color bg = Color(0xFFFFF8E6); // пастельно-жёлтый фон
  static const Color cardBg = Color(0xFFFFF9E9);
  static const Color borderColor = Color(0xFFF2DFAE);
  static const Color titleColor = Color(0xFF0F2F2B); // тёмно-зелёный
  static const Color accent = Color(0xFFF0A95D); // оранжево-янтарный
  static const Color subtleText = Color(0xFF3B4A47);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // фон через контейнер-обёртку
      body: Stack(
        children: [
          // Background image (full screen)
          Positioned.fill(
            child: Container(
              color: bg,
              child: Image.asset(
                'assets/nutritions_background.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Контент
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Верх: Title с иконкой (чекбокс)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // чекбокс-иконка слева (большая)
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          border: Border.all(color: accent, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.check, size: 20, color: accent),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Progress',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // --- Weight Change Card ---
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weight Change',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Chart placeholder
                        Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: borderColor),
                          ),
                          child: Center(
                            child: Text(
                              'Weight change chart',
                              style: TextStyle(
                                color: subtleText,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Starting / Current Weight row
                        Row(
                          children: [
                            Expanded(
                              child: _statBox(
                                title: 'Starting Weight',
                                value: '78 kg',
                                borderColor: borderColor,
                                bgColor: Colors.white,
                                textColor: titleColor,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _statBox(
                                title: 'Current Weight',
                                value: '75 kg',
                                borderColor: borderColor,
                                bgColor: Colors.white,
                                textColor: titleColor,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Add Measurement button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // TODO: hook up action
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accent,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              '+ Add Measurement',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // --- Achievements & Rewards ---
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Achievements & Rewards',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // grid 2x2 (каждый элемент - карточка)
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _rewardTile('First 5 Steps', 'Earned 12.05'),
                            _rewardTile('Workout Week', 'Earned 20.05'),
                            _rewardTile('-3 kg', 'Earned 28.05'),
                            _rewardTile('Workout Month', '5 days left', highlight: true),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // --- Activity Stats (частично видимый на скрине) ---
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Activity Stats',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _statBoxSimple('Avg. Steps', '0')),
                            const SizedBox(width: 10),
                            Expanded(child: _statBoxSimple('Avg. Distance', '0.0 km')),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Back button — левый верхний угол поверх контента
          Positioned(
            left: 8,
            top: 8,
            child: SafeArea(
              child: Material(
                color: Colors.transparent,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Вспомогательный виджет для статистики (блок с заголовком и большим значением)
  Widget _statBox({
    required String title,
    required String value,
    Color? bgColor,
    Color? textColor,
    Color? borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: bgColor ?? Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor ?? const Color(0xFFEFEFEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 13, color: const Color(0xFF5A6A66)),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: textColor ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // Виджет для карточки достижения
  Widget _rewardTile(String title, String subtitle, {bool highlight = false}) {
    return SizedBox(
      width: (MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width - 22 * 2 - 10) / 2 - 1,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFF2DFAE)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: highlight ? Colors.red.shade700 : const Color(0xFF4D5A57),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Простая статистическая карточка (для Activity Stats)
  Widget _statBoxSimple(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 13, color: Color(0xFF5A6A66))),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
