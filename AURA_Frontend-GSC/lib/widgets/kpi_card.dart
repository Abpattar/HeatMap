import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KpiCard extends StatelessWidget {
  final bool isAlert;
  final String title;
  final String? subtitle;
  final String? badgeText;
  final IconData? icon;
  final VoidCallback onTap;

  const KpiCard({
    super.key,
    required this.isAlert,
    required this.title,
    this.subtitle,
    this.badgeText,
    this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isAlert
              ? const LinearGradient(
                  colors: [Color(0xFF8B4B4B), Color(0xFF4A3434)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isAlert ? null : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13), // 0.05 * 255 approx 13
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isAlert && icon != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.black54, size: 20),
              ),
            if (!isAlert) const Spacer(),
            Text(
              title,
              style: GoogleFonts.inter(
                color: isAlert ? Colors.white : Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: GoogleFonts.inter(
                  color: isAlert ? Colors.white70 : Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
            if (isAlert) const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (badgeText != null)
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        badgeText!,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox(),
                if (isAlert && icon != null)
                  Icon(icon, color: Colors.amber, size: 40)
                else if (!isAlert)
                  const Icon(Icons.arrow_forward, color: Colors.black, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
