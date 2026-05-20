import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/reusable_widgets/general/profile_image.dart';
class CustomerOrderInfoCard extends StatelessWidget {
  const CustomerOrderInfoCard({
    Key? key,
    required this.customerInfo,
    required this.orderInfo,
    required this.title,
    required this.onBack,
  }) : super(key: key);

  final Map<String, dynamic> customerInfo;
  final Map<String, dynamic> orderInfo;
  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    String displayRole = customerInfo['role'] != null 
        ? '(${customerInfo['role'][0].toUpperCase()}${customerInfo['role'].substring(1)})' 
        : '(General)';

    return Container(
      width: double.infinity,
      color: kNewMainColor, // Deep teal background from Image 1
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 2.0,
        left: 10.0,
        right: 10.0,
        bottom: 10.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Navigation Overlay
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const Icon(Icons.notifications_none, color: Colors.white, size: 24),
            ],
          ),
          const SizedBox(height: 5.0),
          // ID Card Box (Image 2 style)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0), // Minimized vertical padding
            decoration: BoxDecoration(
              color: kNewMainColor,
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black45, // Darker shadow for pronounced floating effect
                  blurRadius: 15.0,
                  offset: Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1.0,
              ), // Optional subtle border
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Image with White/Gold border
                    Container(
                      padding: const EdgeInsets.all(2.0),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white, // White border
                      ),
                      child: ProfileImage(
                        image: customerInfo['profileImage'],
                      ),
                    ),
                    const SizedBox(width: 15.0),
                    // Right Content: Name, Role, Stats Row
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            displayRole,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14.0,
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          // Stats Row with Vertical Dividers
                          IntrinsicHeight(
                            child: Row(
                              children: [
                                _buildStatColumn('Orders:', orderInfo['total']?.toString() ?? '0'),
                                const VerticalDivider(color: Colors.white54, thickness: 1, width: 20),
                                _buildStatColumn('Amount:', '${orderInfo['amount'] ?? 0}৳'),
                                const VerticalDivider(color: Colors.white54, thickness: 1, width: 20),
                                _buildStatColumn('Due:', '${orderInfo['due'] ?? 0}৳'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 8.0),
                // Bottom Contact Info Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildContactItem(
                      context,
                      Icons.phone, 
                      customerInfo['mobile'] ?? 'N/A',
                      onTap: () async {
                        final mobile = customerInfo['mobile'];
                        if (mobile != null && mobile.isNotEmpty) {
                          final Uri url = Uri(scheme: 'tel', path: mobile);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          }
                        }
                      }
                    ),
                    _buildContactItem(
                      context,
                      Icons.email, 
                      customerInfo['email'] ?? 'N/A',
                      onTap: () {
                        final email = customerInfo['email'];
                        if (email != null && email.isNotEmpty) {
                          Clipboard.setData(ClipboardData(text: email));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Copied to Clipboard')),
                          );
                        }
                      }
                    ),
                    Expanded(
                      child: _buildContactItem(
                        context,
                        Icons.location_on, 
                        customerInfo['address'] ?? 'N/A', 
                        isTrailing: true,
                        maxLines: null,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12.0,
          ),
        ),
        const SizedBox(height: 2.0),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildContactItem(BuildContext context, IconData icon, String text, {bool isTrailing = false, VoidCallback? onTap, int? maxLines = 1, TextOverflow overflow = TextOverflow.ellipsis}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.0),
      child: Container(
        padding: EdgeInsets.only(right: isTrailing ? 0 : 8.0, top: 2.0, bottom: 2.0), // Reduced padding
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1.0),
              child: Icon(icon, color: Colors.white70, size: 14.0),
            ),
            const SizedBox(width: 4.0),
            Flexible(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10.5, // Slightly smaller font for slim fit
                  height: 1.0, // Compressed line height 
                ),
                maxLines: maxLines,
                overflow: overflow,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
