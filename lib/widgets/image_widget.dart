import 'dart:io';
import 'package:flutter/material.dart';

class ImageWidget extends StatelessWidget {
  final String? path;
  const ImageWidget({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    if(path==null||path!.isEmpty){
      return const Icon(Icons.image_not_supported, size: 50);
    }
    if(path!.startsWith('http')){
      //cloud mode
      return Image.network(path!, width: 50,height: 50,fit: BoxFit.cover);
    }else{
      //local mode
      return Image.file(File(path!), width: 50,height: 50,fit: BoxFit.cover);
    }
  }
}