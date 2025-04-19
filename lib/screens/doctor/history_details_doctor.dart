import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:segma/models/history_model.dart';
import 'package:segma/screens/doctor/log_diagnosis.dart';
import 'package:segma/services/history_service.dart';
import 'package:segma/utils/colors.dart';

class HistoryDetailsDoctorScreen extends StatefulWidget {
  final History history;
  final String childId;

  const HistoryDetailsDoctorScreen({Key? key, required this.history, required this.childId})
      : super(key: key);

  @override
  _HistoryDetailsDoctorScreenState createState() => _HistoryDetailsDoctorScreenState();
}

class _HistoryDetailsDoctorScreenState extends State<HistoryDetailsDoctorScreen> {
  final TextEditingController _deleteController = TextEditingController();
  bool _isUpdatePressed = false;
  bool _isDeletePressed = false;
  bool _isDialogDeletePressed = false;

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                'Confirm Deletion',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Type DELETE to confirm deletion of this diagnosis.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: _deleteController,
                    decoration: InputDecoration(
                      hintText: 'Type DELETE',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).dividerColor,
                    ),
                    style: Theme.of(context).textTheme.bodyLarge,
                    onChanged: (value) {
                      setDialogState(() {});
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                ),
                GestureDetector(
                  onTapDown: (_) => setDialogState(() => _isDialogDeletePressed = true),
                  onTapUp: (_) {
                    setDialogState(() => _isDialogDeletePressed = false);
                    if (_deleteController.text.toUpperCase() == 'DELETE') {
                      _deleteHistory();
                    }
                  },
                  onTapCancel: () => setDialogState(() => _isDialogDeletePressed = false),
                  child: AnimatedScale(
                    scale: _isDialogDeletePressed ? 0.95 : 1.0,
                    duration: const Duration(milliseconds: 100),
                    child: ElevatedButton(
                      onPressed: _deleteController.text.toUpperCase() == 'DELETE' ? _deleteHistory : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.statusOverdue,
                      ),
                      child: Text(
                        'Delete',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteHistory() async {
    final response = await HistoryService.deleteHistory(widget.childId, widget.history.id);
    if (response['status'] == 'success') {
      Navigator.pop(context); // إغلاق الحوار
      Navigator.pop(context); // العودة إلى الشاشة السابقة
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Diagnosis deleted'),
          backgroundColor: AppColors.statusUpcoming,
        ),
      );
    } else {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${response['message']}'),
          backgroundColor: AppColors.statusOverdue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Diagnosis Details',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailCard('Diagnosis', widget.history.diagnosis),
            _buildDetailCard('Disease', widget.history.disease),
            _buildDetailCard('Treatment', widget.history.treatment),
            _buildDetailCard('Notes', widget.history.notes),
            if (widget.history.notesImage.isNotEmpty)
              _buildImageCard('Notes Image', widget.history.notesImage),
            _buildDetailCard('Date', DateFormat('dd MMM, yyyy').format(widget.history.date)),
            _buildDetailCard('Time', widget.history.time),
            _buildDetailCard('Doctor', widget.history.doctorName),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatefulBuilder(
                  builder: (context, setState) {
                    return GestureDetector(
                      onTapDown: (_) => setState(() => _isUpdatePressed = true),
                      onTapUp: (_) {
                        setState(() => _isUpdatePressed = false);
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => LogDiagnosisScreen(
                              childId: widget.childId,
                              history: widget.history,
                            ),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                          ),
                        ).then((_) => Navigator.pop(context));
                      },
                      onTapCancel: () => setState(() => _isUpdatePressed = false),
                      child: AnimatedScale(
                        scale: _isUpdatePressed ? 0.95 : 1.0,
                        duration: const Duration(milliseconds: 100),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => LogDiagnosisScreen(
                                  childId: widget.childId,
                                  history: widget.history,
                                ),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                              ),
                            ).then((_) => Navigator.pop(context));
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                          child: Text(
                            'Update Diagnosis',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                StatefulBuilder(
                  builder: (context, setState) {
                    return GestureDetector(
                      onTapDown: (_) => setState(() => _isDeletePressed = true),
                      onTapUp: (_) {
                        setState(() => _isDeletePressed = false);
                        _showDeleteDialog();
                      },
                      onTapCancel: () => setState(() => _isDeletePressed = false),
                      child: AnimatedScale(
                        scale: _isDeletePressed ? 0.95 : 1.0,
                        duration: const Duration(milliseconds: 100),
                        child: ElevatedButton(
                          onPressed: _showDeleteDialog,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                            backgroundColor: AppColors.statusOverdue,
                          ),
                          child: Text(
                            'Delete',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(String label, String value) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: EdgeInsets.all(12.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 4.h),
            Text(
              value.isEmpty ? 'N/A' : value,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard(String label, String imageUrl) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: EdgeInsets.all(12.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.network(
                imageUrl,
                height: 150.h,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 150.h,
                  color: Theme.of(context).dividerColor,
                  child: Center(
                    child: Text(
                      'Error loading image',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}