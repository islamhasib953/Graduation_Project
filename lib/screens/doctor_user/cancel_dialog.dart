import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:segma/utils/colors.dart';

class CancelDialog extends StatefulWidget {
  final VoidCallback onConfirm;

  const CancelDialog({Key? key, required this.onConfirm}) : super(key: key);

  @override
  _CancelDialogState createState() => _CancelDialogState();
}

class _CancelDialogState extends State<CancelDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _isConfirmEnabled = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _isConfirmEnabled = _controller.text.toUpperCase() == 'CANCEL';
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Cancel Appointment', style: Theme.of(context).textTheme.titleMedium),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Do you want to cancel the appointment?', style: Theme.of(context).textTheme.bodyMedium),
          SizedBox(height: 8.h),
          Text('Please type "CANCEL" in the box below', style: Theme.of(context).textTheme.bodySmall),
          SizedBox(height: 8.h),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
              hintText: 'CANCEL',
              filled: true,
              fillColor: Theme.of(context).dividerColor,
            ),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Back', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).primaryColor)),
        ),
        ElevatedButton(
          onPressed: _isConfirmEnabled ? widget.onConfirm : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.statusOverdue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          ),
          child: Text('Confirm', style: Theme.of(context).textTheme.bodyLarge),
        ),
      ],
    );
  }
}