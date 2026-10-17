import 'package:flutter/material.dart';

// ========================================
// AGRIMART COLORS — HEX VALUES
// ========================================

const Color agriGreen = Color(0xFF176B3A);
const Color agriLightGreen = Color(0xFFE8F1EA);
const Color agriBackground = Color(0xFFF5F6F5);
const Color agriWhite = Color(0xFFFFFFFF);
const Color agriText = Color(0xFF202820);
const Color agriMuted = Color(0xFF757575);
const Color agriBorder = Color(0xFFE0E5E0);
const Color agriRed = Color(0xFFD32F2F);
const Color agriOrange = Color(0xFFF59E0B);

// ========================================
// PAGE TRANSITIONS
// ========================================

void goNoAnimation(BuildContext context, Widget page) {
  Navigator.of(context).pushReplacement(
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    ),
  );
}

void pushNoAnimation(BuildContext context, Widget page) {
  Navigator.of(context).push(
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    ),
  );
}

// ========================================
// RESPONSIVE CONTENT
// ========================================

Widget responsiveContent({
  required Widget child,
  double maxWidth = 1200,
  EdgeInsetsGeometry padding = const EdgeInsets.all(16),
}) {
  return Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Padding(padding: padding, child: child),
    ),
  );
}

// ========================================
// INPUT DECORATION
// ========================================

InputDecoration inputDecoration({
  required String label,
  String? hint,
  Widget? prefixIcon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: const Color(0xFFFFFFFF),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE0E5E0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE0E5E0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF176B3A), width: 1.5),
    ),
  );
}

// ========================================
// REUSABLE PRODUCT CARD
// ========================================

Widget productCard({
  required String name,
  required String category,
  required double price,
  required String unit,
  required String emoji,
  required VoidCallback onTap,
  String? imageUrl,
}) {
  return Card(
    color: const Color(0xFFFFFFFF),
    elevation: 1,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: Color(0xFFE0E5E0)),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              color: const Color(0xFFE8F1EA),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 54),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 54)),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF757575),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF202820),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '₱${price.toStringAsFixed(2)} / $unit',
                  style: const TextStyle(
                    color: Color(0xFF176B3A),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// ========================================
// REUSABLE SECTION TITLE
// ========================================

Widget sectionTitle({
  required String title,
  String? actionText,
  VoidCallback? onAction,
}) {
  return Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF202820),
          ),
        ),
      ),
      if (actionText != null && onAction != null)
        TextButton(
          onPressed: onAction,
          child: Text(
            actionText,
            style: const TextStyle(
              color: Color(0xFF176B3A),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
    ],
  );
}

// ========================================
// REUSABLE PRIMARY BUTTON
// ========================================

Widget agriPrimaryButton({
  required String label,
  required VoidCallback? onPressed,
  IconData? icon,
}) {
  return SizedBox(
    width: double.infinity,
    height: 50,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF176B3A),
        foregroundColor: const Color(0xFFFFFFFF),
        disabledBackgroundColor: const Color(0xFFE0E5E0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: icon == null
          ? Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
    ),
  );
}
