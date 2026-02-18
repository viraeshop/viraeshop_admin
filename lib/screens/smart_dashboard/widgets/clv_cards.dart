import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ClvCards extends StatelessWidget {
  const ClvCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildCard("Avg Purchase", "৳1,250", "+5%", Colors.green),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildCard("Order Freq", "2.4/mo", "-1%", Colors.red),
        ),
      ],
    );
  }

  Widget _buildCard(String title, String value, String trend, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Text(
                trend,
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold, color: color, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
