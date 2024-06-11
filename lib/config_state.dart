
/// 
/// Holds the current state of Configuration parameters that would be passed
/// as arguments to yt-dlp
///

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:guya/video_desc.dart';

enum AppState {
  IDLE,
  LOADING_DATA,
  LOADED,
  DOWNLOADING
}

class ConfigState extends ChangeNotifier{
  String url = "";

  List<VideoDescrtiption> videoDescrtiptions = [];
  
  bool includeAudio = true;
  bool includeVideo = true;

  String downloadPath = ".";

  String downloadProgress = "";

  AppState currentState = AppState.IDLE;
  
  void updateUrl(String newUrl){
    url = newUrl;
    
    if(newUrl.isEmpty){
      // TODO: Resets display info
      
      currentState = AppState.IDLE;    
    } else {
      videoDescrtiptions.clear();

      currentState = AppState.LOADING_DATA;
      getVideoInfo();
    }  

    notifyListeners();
  }
  
  void toggleAudio(){
    includeAudio = !includeAudio;
    notifyListeners();
  }

  void toggleVideo(){
    includeVideo = !includeVideo;
    notifyListeners();
  }

  void setDownloadPath(String newPath){
    downloadPath = newPath;

    notifyListeners();
  }

  // [download]   7.1% of   19.13MiB at  783.17KiB/s ETA 00:23
  void download() async {
    var process = await Process.start('yt-dlp', [
      ...[],
      url,
    ]);

    final RegExp downloadProgressRegExp = RegExp(r'\[download\]\s+(\d+\.\d+)%\s+of\s+(\d+\.\d+)([a-zA-Z]+)\s+at\s+(\d+.\d+)([a-zA-Z/]+)');
    process.stdout.transform(utf8.decoder).forEach((output) {
        var match = downloadProgressRegExp.firstMatch(output);
        // print(output);
        if(match != null){
          double progress = double.parse(match.group(1)!);
          double size = double.parse(match.group(2)!);
          String mb = match.group(3)!;
          double downloadSpeed = double.parse(match.group(4)!);
          String speed = match.group(5)!;
          
          // String example = "[download]   7.1% of   19.13MiB at  783.17KiB/s ETA 00:23";  
          downloadProgress = "$progress% of $size $mb";
          notifyListeners();
        }
      // }
    });
  }

  void getVideoInfo() async{
    var infoArgs = [
      "--skip-download",
      "--flat-playlist",
      // "--no-warnings",
      "--print-json",
      // "--print",
      // '"%(duration>%H:%M:%S.%s)s\n%(uploader)s\n%(title)s"'
    ];

    var result = await Process.run('yt-dlp', [...infoArgs, url]);
    
    if (result.stderr.isNotEmpty) {
      print('Error: ${result.stderr}');
    } else {
      List<dynamic> playlistJson = result.stdout.toString().trim().split('\n').map((video) => json.decode(video)).toList();

      playlistJson.forEach((jsonDesc) {
        videoDescrtiptions.add(VideoDescrtiption.fromJSON(jsonDesc));
      });
    }

    // print('${result.stdout}');
    currentState = AppState.IDLE;      
    notifyListeners();
    // var process = await Process.start('yt-dlp', [
    //   ...infoArgs,
    //   url,
    // ]);

    // print("kek?");
    // process.stdout.transform(utf8.decoder).forEach((element) {
    //   print(element);
    // }).onError((error, stackTrace){
    //   print(error);    
    // }).whenComplete((){
    //   print("https://www.youtube.com/watch?v=2Q_ZzBGPdqE&list=PLiQl43ty5itMDaFb_hXoKlgAvr4PWtDOw&pp=gAQBiAQB");
    // });

    // process.stdout.transform(utf8.decoder).first.then((output){
    //   print(output);
    //   var data = output.split('\n');
      
    //   if(data.length > 2){
    //     duration = data[0];
    //     uploader = data[1];
    //     title    = data[2];        
    //     currentState = AppState.LOADED;
    //     notifyListeners();
    //   }
    // }).onError((error, stackTrace) {
    //   currentState = AppState.IDLE;
    //   notifyListeners();
    //   print("残念 $error");
    // });
  }

  Stream<dynamic> callYtldp(List<String> params) async* {
    var process = await Process.start('yt-dlp', [...params, url]);
    yield process.stdout.transform(utf8.decoder);
  }
}