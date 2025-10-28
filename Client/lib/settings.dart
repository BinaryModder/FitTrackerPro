import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool vibrationEnabled = true;
  bool autoPauseEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBEF),
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// Фон из assets
          Image.asset(
            "assets/profile_background.png",
            fit: BoxFit.cover,
          ),

          /// Контент
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🔙 Кнопка Назад
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.deepOrange,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  /// Заголовок
                  const Text(
                    "Settings",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),

                  /// --- Список опций ---
                  _SettingsTile(
                    icon: Icons.notifications_active_rounded,
                    iconColor: Colors.orange.shade700,
                    title: "Notifications",
                    onTap: () {},
                  ),
                  const SizedBox(height: 14),

                  _SettingsTile(
                    icon: Icons.chat_bubble_outline_rounded,
                    iconColor: Colors.orange.shade500,
                    title: "Contact Support",
                    onTap: () {},
                  ),
                  const SizedBox(height: 14),

                  _SettingsTile(
                    icon: Icons.lock_rounded,
                    iconColor: Colors.deepOrange.shade600,
                    title: "Privacy Policy",
                    onTap: () {},
                  ),
                  const SizedBox(height: 14),

                  _SwitchTile(
                    icon: Icons.monitor_heart_rounded,
                    title: "Vibration",
                    value: vibrationEnabled,
                    onChanged: (v) => setState(() => vibrationEnabled = v),
                  ),
                  const SizedBox(height: 14),

                  _SwitchTile(
                    icon: Icons.pause_circle_filled_rounded,
                    title: "Auto-Pause",
                    value: autoPauseEnabled,
                    onChanged: (v) => setState(() => autoPauseEnabled = v),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 🔸 Стандартная карточка настройки
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFFBEF),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.orange.shade100),
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 26),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 🟠 Карточка с переключателем
class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Row(
        children: [
          Icon(icon, size: 26, color: Colors.black87),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: Colors.orange.shade700,
            inactiveTrackColor: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }
}
