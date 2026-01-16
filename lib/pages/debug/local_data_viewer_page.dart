import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:periksa_kesehatan/core/database/database_helper.dart';
import 'package:periksa_kesehatan/core/constants/app_colors.dart';
import 'package:intl/intl.dart';

/// Debug page untuk melihat dan menghapus data lokal
class LocalDataViewerPage extends StatefulWidget {
  const LocalDataViewerPage({super.key});

  @override
  State<LocalDataViewerPage> createState() => _LocalDataViewerPageState();
}

class _LocalDataViewerPageState extends State<LocalDataViewerPage> {
  List<Map<String, dynamic>> _localData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLocalData();
  }

  Future<void> _loadLocalData() async {
    setState(() => _isLoading = true);
    try {
      final data = await DatabaseHelper.instance.getHealthDataHistory();
      setState(() {
        _localData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _deleteRecord(int id) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.delete('health_data', where: 'id = ?', whereArgs: [id]);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      }
      _loadLocalData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error menghapus data: $e')),
        );
      }
    }
  }

  Future<void> _clearAllData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Hapus Semua Data?',
          style: GoogleFonts.nunitoSans(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus SEMUA data lokal? Tindakan ini tidak dapat dibatalkan.',
          style: GoogleFonts.nunitoSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final db = await DatabaseHelper.instance.database;
        await db.delete('health_data');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Semua data berhasil dihapus'),
              backgroundColor: Colors.green,
            ),
          );
        }
        _loadLocalData();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Data Lokal (SQLite)',
          style: GoogleFonts.nunitoSans(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_localData.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearAllData,
              tooltip: 'Hapus Semua',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLocalData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _localData.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tidak ada data lokal',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _localData.length,
                  itemBuilder: (context, index) {
                    final item = _localData[index];
                    final recordDate = DateTime.parse(item['record_date']);
                    final isSynced = item['is_synced'] == 1;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSynced ? Colors.green : Colors.orange,
                          width: 2,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
                                            .format(recordDate),
                                        style: GoogleFonts.nunitoSans(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            isSynced ? Icons.cloud_done : Icons.cloud_off,
                                            size: 14,
                                            color: isSynced ? Colors.green : Colors.orange,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            isSynced ? 'Tersinkron' : 'Belum Sinkron',
                                            style: GoogleFonts.nunitoSans(
                                              fontSize: 12,
                                              color: isSynced ? Colors.green : Colors.orange,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteRecord(item['id']),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            _buildDataRow('ID', item['id'].toString()),
                            if (item['systolic'] != null)
                              _buildDataRow(
                                'Tekanan Darah',
                                '${item['systolic']}/${item['diastolic']} mmHg',
                              ),
                            if (item['blood_sugar'] != null)
                              _buildDataRow(
                                'Gula Darah',
                                '${item['blood_sugar']} mg/dL',
                              ),
                            if (item['weight'] != null)
                              _buildDataRow('Berat Badan', '${item['weight']} kg'),
                            if (item['height_cm'] != null)
                              _buildDataRow('Tinggi Badan', '${item['height_cm']} cm'),
                            if (item['activity'] != null)
                              _buildDataRow('Aktivitas', item['activity']),
                            if (item['heart_rate'] != null)
                              _buildDataRow('Detak Jantung', '${item['heart_rate']} bpm'),
                            const SizedBox(height: 8),
                            Text(
                              'User ID: ${item['user_id'] ?? 'N/A'}',
                              style: GoogleFonts.nunitoSans(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.nunitoSans(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.nunitoSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
