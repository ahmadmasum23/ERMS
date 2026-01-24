import 'package:flutter/material.dart';
import 'package:inven/app/global/widgets/CustomAppBar.dart';

class AdminActivityLogView extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const AdminActivityLogView({Key? key, required this.scaffoldKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomAppbar(
          title: 'Activity Log',
          boldTitle: 'Panel',
          showNotif: false,
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => scaffoldKey.currentState?.openDrawer(),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subtitle
                Text(
                  'Riwayat aktivitas sistem',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 24),

                // Header Tabel (Hanya di desktop/tablet)
                if (MediaQuery.of(context).size.width > 600) _buildTableHeader(context),

                const SizedBox(height: 16),

                // Daftar Aktivitas
                _buildActivityList(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text('USER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          Expanded(flex: 1, child: Text('ACTION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          Expanded(flex: 3, child: Text('ENTITY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          Expanded(flex: 2, child: Text('TIME', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildActivityList(BuildContext context) {
    final List<Map<String, dynamic>> logs = [
      {
        'userName': 'Petugas 1',
        'userId': 'ID: 2',
        'action': 'Approved',
        'entity': 'Peminjaman #2',
        'time': '10 Mar 2024, 10.30',
        'avatarLetter': 'P',
        'actionColor': Colors.green.withOpacity(0.1),
        'actionTextColor': Colors.green,
      },
      {
        'userName': 'Admin Utama',
        'userId': 'ID: 1',
        'action': 'Created',
        'entity': 'Alat: Laptop Asus ROG',
        'time': '9 Mar 2024, 15.20',
        'avatarLetter': 'A',
        'actionColor': Colors.green.withOpacity(0.1),
        'actionTextColor': Colors.green,
      },
      {
        'userName': 'Budi Santoso',
        'userId': 'ID: 3',
        'action': 'Submitted',
        'entity': 'Peminjaman #1',
        'time': '15 Mar 2024, 11.00',
        'avatarLetter': 'B',
        'actionColor': Colors.amber.withOpacity(0.1),
        'actionTextColor': Colors.amber,
      },
      {
        'userName': 'Petugas 1',
        'userId': 'ID: 2',
        'action': 'Confirmed Return',
        'entity': 'Peminjaman #3',
        'time': '8 Mar 2024, 16.45',
        'avatarLetter': 'P',
        'actionColor': Colors.blue.withOpacity(0.1),
        'actionTextColor': Colors.blue,
      },
    ];

    return Column(
      children: List.generate(logs.length, (index) {
        final log = logs[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildActivityCard(
            context: context,
            userName: log['userName'],
            userId: log['userId'],
            action: log['action'],
            entity: log['entity'],
            time: log['time'],
            avatarLetter: log['avatarLetter'],
            actionColor: log['actionColor'],
            actionTextColor: log['actionTextColor'],
          ),
        );
      }),
    );
  }

  Widget _buildActivityCard({
    required BuildContext context,
    required String userName,
    required String userId,
    required String action,
    required String entity,
    required String time,
    required String avatarLetter,
    required Color actionColor,
    required Color actionTextColor,
  }) {
    final isMobile = MediaQuery.of(context).size.width <= 600;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xffF4F7F7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: isMobile
            ? _buildMobileCardContent(
                userName,
                userId,
                action,
                entity,
                time,
                avatarLetter,
                actionColor,
                actionTextColor,
              )
            : _buildDesktopCardContent(
                userName,
                userId,
                action,
                entity,
                time,
                avatarLetter,
                actionColor,
                actionTextColor,
              ),
      ),
    );
  }

  Widget _buildMobileCardContent(
    String userName,
    String userId,
    String action,
    String entity,
    String time,
    String avatarLetter,
    Color actionColor,
    Color actionTextColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar + User Info
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Text(
                  avatarLetter,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(userId, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: actionColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                action,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: actionTextColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Entity
        Text(
          'Entity: $entity',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),

        // Time
        Text(
          time,
          style: TextStyle(fontSize: 13, color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildDesktopCardContent(
    String userName,
    String userId,
    String action,
    String entity,
    String time,
    String avatarLetter,
    Color actionColor,
    Color actionTextColor,
  ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.purple,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              avatarLetter,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(userId, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: actionColor,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: Text(
                action,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: actionTextColor,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            entity,
            style: const TextStyle(fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            time,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }
}