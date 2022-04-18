import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

enum LottieType { Network, Assets }

class BaseLottieFilesDisplay extends StatelessWidget{

  String? url;
  String? file;
  double? height;
  double? width;
  double? containerHeight;
  double? containerWidth;
  bool isRepeat;
  LottieType lottieType;

  BaseLottieFilesDisplay({this.file,required this.lottieType,this.url,this.height, this.width, this.containerHeight, this.containerWidth, this.isRepeat=true});

  Widget build(BuildContext context) {
    return Container(
      height: containerHeight,
      width: containerWidth,
      child: ListView(
        physics: NeverScrollableScrollPhysics(),
        children: [
          lottieType == LottieType.Network
              ?
          Lottie.network(
              url != null ? url! : "",
              repeat: isRepeat,
              reverse: false,
              height: height,
              width: width
          ):Lottie.asset(
              file != null ? file! : "",
              repeat: isRepeat,
              reverse: false,
              height: height,
              width: width
          ),
        ],
      ),
    );
  }


}
