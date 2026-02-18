import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:viraeshop_api/models/analytics/analytics_models.dart';
import 'package:viraeshop_admin/screens/smart_dashboard/employee_scorecard_screen.dart';

class HumanResourcesCard extends StatelessWidget {
  final EmployeeScorecard scorecard;
  const HumanResourcesCard({super.key, required this.scorecard});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "HUMAN RESOURCES",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Colors.grey[600],
                ),
              ),
              Icon(Icons.people_outline, color: Colors.purple),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            "Top Performers",
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...scorecard.staffList.map((e) => _buildStaffRow(e)).toList(),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EmployeeScorecardScreen(
                        token: ""), // Token handling needed
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF111816),
                side: BorderSide(color: Colors.grey[300]!),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text("View Full Scorecard"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffRow(EmployeeStat staff) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.purple.withOpacity(0.1),
            child: Text(
              staff.name[0],
              style:
                  TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  staff.name,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                Text(
                  staff.status,
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "${staff.score}",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: Colors.green,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
