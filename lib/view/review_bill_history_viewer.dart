import 'package:flutter/material.dart';
import 'package:logistics_app/helper/app_colors.dart';
import 'package:logistics_app/helper/global_file.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ReviewBillHistoryViewer extends StatefulWidget {
  final String bol;
  const ReviewBillHistoryViewer({super.key, required this.bol});

  @override
  State<ReviewBillHistoryViewer> createState() =>
      ReviewBillHistoryViewerState();
}

class ReviewBillHistoryViewerState extends State<ReviewBillHistoryViewer> {
  @override
  Widget build(BuildContext context) {
    print("---------${widget.bol}");
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: customAppbar(text: "Uploaded BOL View"),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: widget.bol != 'null'
            ? SfPdfViewer.network(widget.bol.toString(), password: 'syncfusion')
            : Center(
                child: Text(
                  "Uploaded BOL not found!",
                  style: TextStyle(color: AppColors.themeColor,fontSize: 16),
                ),
              ),
      ),
    );
  }
}
