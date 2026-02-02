import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inven/app/data/models/LogAktivitas.dart';
import 'package:inven/app/global/widgets/CustomAppBar.dart';
import 'package:inven/app/global/widgets/CustomTxtForm.dart';
import 'package:inven/app/modules/admin/controllers/admin_activity_log_controller.dart';

class AdminActivityLogView extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final AdminActivityLogController controller = Get.put(AdminActivityLogController());

  AdminActivityLogView({Key? key, required this.scaffoldKey}) : super(key: key);

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
          child: Padding(
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
                const SizedBox(height: 16),

                // Search and Filters
                _buildSearchAndFilters(context),
                const SizedBox(height: 16),

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

  Widget _buildSearchAndFilters(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Search bar
          CustomTxtForm(
            Label: 'Cari aktivitas...',
            Controller: controller.searchController,
            Focus: FocusNode(),
            OnSubmit: (val) {
              controller.onSearchChanged(val!);
            },
            OnChange: (val) {
              controller.onSearchChanged(val!);
            },
          ),
          const SizedBox(height: 12),

          // Filter row
          LayoutBuilder(
  builder: (context, constraints) {
    final isMobile = constraints.maxWidth < 600;

    return isMobile
        // 📱 MODE HP → TUMPUK KE BAWAH
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Action',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
                value: controller.selectedAction.value.isEmpty
                    ? null
                    : controller.selectedAction.value,
                items: [
                  const DropdownMenuItem(value: '', child: Text('All Actions')),
                  ...controller.getUniqueActions().map((action) =>
                      DropdownMenuItem(value: action, child: Text(action))),
                ],
                onChanged: controller.onActionFilterChanged,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Entity',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
                value: controller.selectedEntity.value.isEmpty
                    ? null
                    : controller.selectedEntity.value,
                items: [
                  const DropdownMenuItem(value: '', child: Text('All Entities')),
                  ...controller.getUniqueEntities().map((entity) =>
                      DropdownMenuItem(value: entity, child: Text(entity))),
                ],
                onChanged: controller.onEntityFilterChanged,
              ),
              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: controller.refreshLogs,
                  tooltip: 'Refresh logs',
                ),
              ),
            ],
          )

        // 🖥 TABLET / DESKTOP → SEJAJAR
        : Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Action',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  ),
                  value: controller.selectedAction.value.isEmpty
                      ? null
                      : controller.selectedAction.value,
                  items: [
                    const DropdownMenuItem(value: '', child: Text('All Actions')),
                    ...controller.getUniqueActions().map((action) =>
                        DropdownMenuItem(value: action, child: Text(action))),
                  ],
                  onChanged: controller.onActionFilterChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Entity',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  ),
                  value: controller.selectedEntity.value.isEmpty
                      ? null
                      : controller.selectedEntity.value,
                  items: [
                    const DropdownMenuItem(value: '', child: Text('All Entities')),
                    ...controller.getUniqueEntities().map((entity) =>
                        DropdownMenuItem(value: entity, child: Text(entity))),
                  ],
                  onChanged: controller.onEntityFilterChanged,
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: controller.refreshLogs,
                tooltip: 'Refresh logs',
              ),
            ],
          );
  },
          ),

        ],
      ),
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
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      }

      final logs = controller.filteredLogs;

      if (logs.isEmpty) {
        return _buildEmptyState();
      }

      return Expanded(
        child: ListView.builder(
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildActivityCard(context, log),
            );
          },
        ),
      );
    });
  }

  Widget _buildActivityCard(BuildContext context, LogAktivitas log) {
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
            ? _buildMobileCardContent(log)
            : _buildDesktopCardContent(log),
      ),
    );
  }

  Widget _buildMobileCardContent(LogAktivitas log) {
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
                color: Colors.black,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Text(
                  log.getAvatarLetter(),
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
                  Text(
                    log.getUserDisplay(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (log.penggunaId != null)
                    Text(
                      'ID: ${log.penggunaId}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: log.getActionColor(),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                log.getActionDisplay(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: log.getActionTextColor(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Entity
        Text(
          'Entity: ${log.entitas}${log.entitasId != null ? ' #${log.entitasId}' : ''}',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),

        // Detailed changes for update actions
        if (log.aksi.toLowerCase() == 'updated' || log.aksi.toLowerCase() == 'update')
          _buildChangeDetails(log),
        
        // Time
        Text(
          log.getTimeDisplay(),
          style: TextStyle(fontSize: 13, color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildDesktopCardContent(LogAktivitas log) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              log.getAvatarLetter(),
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
              Text(
                log.getUserDisplay(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (log.penggunaId != null)
                Text(
                  'ID: ${log.penggunaId}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: log.getActionColor(),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: Text(
                log.getActionDisplay(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: log.getActionTextColor(),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${log.entitas}${log.entitasId != null ? ' #${log.entitasId}' : ''}',
                style: const TextStyle(fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              // Detailed changes for update actions
              if (log.aksi.toLowerCase() == 'updated' || log.aksi.toLowerCase() == 'update')
                _buildChangeDetails(log),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            log.getTimeDisplay(),
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  Widget _buildChangeDetails(LogAktivitas log) {
    if ((log.nilaiLama == null || log.nilaiLama!.isEmpty) && 
        (log.nilaiBaru == null || log.nilaiBaru!.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Changes:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          if (log.nilaiLama != null && log.nilaiLama!.isNotEmpty) ...[
            const Text(
              'From:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 11,
                color: Colors.red,
              ),
            ),
            Text(
              _formatJsonData(log.nilaiLama!),
              style: const TextStyle(
                fontSize: 11,
                color: Colors.red,
                fontFamily: 'monospace',
              ),
            ),
          ],
          if (log.nilaiBaru != null && log.nilaiBaru!.isNotEmpty) ...[
            const Text(
              'To:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 11,
                color: Colors.green,
              ),
            ),
            Text(
              _formatJsonData(log.nilaiBaru!),
              style: const TextStyle(
                fontSize: 11,
                color: Colors.green,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatJsonData(Map<String, dynamic> data) {
    if (data.isEmpty) return 'No data';
    
    List<String> changes = [];
    data.forEach((key, value) {
      changes.add('$key: $value');
    });
    
    return changes.join('\n');
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_toggle_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No activity logs found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'There are no activity records matching your criteria',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: controller.refreshLogs,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}