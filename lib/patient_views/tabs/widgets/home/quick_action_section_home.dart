import 'package:flutter/material.dart';
import '../../../../helpers/app_theme.dart';
import '../../../widgets/quick_action_card.dart';

class QuickActionSection extends StatelessWidget {
  final TickerProvider vsync;
  final bool isDarkMode;

  const QuickActionSection({
    super.key,
    required this.vsync,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppTheme.textColor(isDarkMode),
          ),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            // Calculate width for 3 cards per row with spacing
            double spacing = 12;
            int cardsPerRow = 3;
            double totalSpacing = spacing * (cardsPerRow - 1);
            double cardWidth =
                (constraints.maxWidth - totalSpacing) / cardsPerRow;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              alignment: WrapAlignment.center, // center the row
              children: [
                SizedBox(
                  width: cardWidth,
                  child: QuickActionCard(
                    icon: Icons.favorite,
                    iconColor: Colors.red,
                    title: "Heart Rate",
                    isDarkMode: isDarkMode,
                    onTap: () {
                      // Navigate to heart rate details
                    },
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: QuickActionCard(
                    icon: Icons.water_drop_outlined,
                    iconColor: Colors.blue,
                    title: "SPo2",
                    isDarkMode: isDarkMode,
                    onTap: () {
                      // Navigate to hydration details
                    },
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: QuickActionCard(
                    icon: Icons.monitor_weight_outlined,
                    iconColor: Colors.green,
                    title: "Weight",
                    isDarkMode: isDarkMode,
                    onTap: () {
                      // Navigate to weight details
                    },
                  ),
                ),
                
              ],
            );
          },
        ),
      ],
    );
  }
}
