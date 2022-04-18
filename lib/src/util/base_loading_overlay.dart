import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:odaring_web_view/src/util/base_lottie_file_display.dart';

class BaseLoadingOverlay {

  BaseLoadingOverlay._();

  factory BaseLoadingOverlay() => _instance;

  static final BaseLoadingOverlay _instance = BaseLoadingOverlay._();

  OverlayEntry? _overlayEntry;

  OverlayEntry? createOverlayForLoading(BuildContext context){
    if(_overlayEntry == null){
      // Get the position of the current widget when clicked, and pass in overlayEntry
      try{
        _overlayEntry = OverlayEntry(builder: (_) {

          return loadingOverlayWidget();
        });

        // Show Overlay
        if(_overlayEntry != null){

        }
        if(_overlayEntry != null){
          Overlay.of(context)?.insert(_overlayEntry!);
        }
        return _overlayEntry;
      }catch(error){
        print(error);
      }
    }

  }

  void removeLoadingOverlay(){
    try{
      if(_overlayEntry != null){
        _overlayEntry!.remove();
        _overlayEntry = null;
      }
    }catch(error){
      print(error);
    }
  }

}

Widget loadingOverlayWidget(){
  return SizedBox.expand(
    child: Opacity(
      opacity: 0.5,
      child: Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.black,
        child: Align(
          alignment: Alignment.center,
          child:  BaseLottieFilesDisplay(
            lottieType: LottieType.Assets,
            containerHeight: 200,
            containerWidth: double.infinity,
            file: 'images/widgets/Loading animation.json',
            height: 60,
            width: double.infinity,
          ),
        ),
      ),
    ),
  );
}