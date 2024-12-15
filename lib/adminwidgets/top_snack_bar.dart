import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart'; // Import the sizer package

class TopSnackBar extends StatelessWidget {
  final String message;
  final Color backgroundColor;
  final Color textColor;
  final double paddingHorizontal;
  final double paddingVertical;
  final double width;
  final double height;
  final double borderRadius; // Add borderRadius property
  // value or setting of snackbar (show system status)
  const TopSnackBar({
    Key? key,
    required this.message,
    this.backgroundColor = Colors.black,
    this.textColor = Colors.white,
    this.paddingHorizontal = 4.0, 
    this.paddingVertical = 2.0, 
    this.width = 80.0, 
    this.height = 8.0, 
    this.borderRadius = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: width.w, 
        height: height.h, 
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius.w), 
        ),
        padding: EdgeInsets.symmetric(
          horizontal: paddingHorizontal.w, 
          vertical: paddingVertical.h, 
        ),
        child: Center(
          child: Text(
            message,
            style: TextStyle(
              color: textColor,
              fontSize: 10.sp,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}

void showTopSnackBar(BuildContext context, String message,
    {Color backgroundColor = Colors.black,
    Color textColor = Colors.white,
    double paddingHorizontal = 4.0,
    double paddingVertical = 1.0, 
    double width = 80.0, 
    double height = 5.0, 
    double borderRadius = 2.0}) { 
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: 2.5.h, 
      left: 18.w, 
      child: TopSnackBar(
        message: message,
        backgroundColor: backgroundColor,
        textColor: textColor,
        paddingHorizontal: paddingHorizontal,
        paddingVertical: paddingVertical,
        width: width,
        height: height,
        borderRadius: borderRadius, 
      ),
    ),
  );

  // Insert the overlay entry
  overlay.insert(overlayEntry);

  // Remove the overlay entry after a delay
  Future.delayed(const Duration(seconds: 3), () {
    overlayEntry.remove();
  });
}
