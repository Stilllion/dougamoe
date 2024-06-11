
/// 
/// Holds the current state of Configuration parameters that would be passed
/// as arguments to yt-dlp
///

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dougamoe/video_desc.dart';

enum AppState {
  IDLE,
  LOADING_DATA,
  LOADED,
  DOWNLOADING
}

enum VideoHeight {
  v144p('144'),
  v240p('240'),
  v360p('360'),
  v480p('480'),
  v720p('720'),
  v1080p('1080'),
  v1440p('1440'),
  v2160p('2160'),
  Best('Best');

  const VideoHeight(this.res);
  final String res;
}

enum VideoContainer {
  mp4('mp4'),
  Best('Best');

  const VideoContainer(this.ext);
  final String ext;
}

enum AudioContainer {
  mp4('m4a'),
  Best('Best');

  const AudioContainer(this.ext);
  final String ext;
}


class ConfigState extends ChangeNotifier{
  String url = "";

  List<VideoDescrtiption> videoDescrtiptions = [];
  
  bool includeAudio = true;
  bool includeVideo = true;

  String downloadPath = "./dl";

  String downloadProgress = "";

  VideoHeight selectedVideoHeight = VideoHeight.Best;

  VideoContainer selectedVideoContainer = VideoContainer.Best;
  AudioContainer selectedAudioContainer = AudioContainer.Best;

  String outputFile = "%(title)s.%(ext)s";

  AppState currentState = AppState.IDLE;
  
  void updateUrl(String newUrl){
    url = newUrl;
    
    if(newUrl.isEmpty){
      // TODO: Resets display info
      videoDescrtiptions = [];
      currentState = AppState.IDLE;    
    } else {
      videoDescrtiptions.clear();

      currentState = AppState.LOADING_DATA;
      getVideoInfo();
    }  

    notifyListeners();
  }

  void changeOutputHeigth(VideoHeight newHeight){
    selectedVideoHeight = newHeight;

    notifyListeners();
  }

  void changeVideoContainer(VideoContainer newContainer){
    selectedVideoContainer = newContainer;

    notifyListeners();
  }

  void changeAudioContainer(AudioContainer newContainer){
    selectedAudioContainer = newContainer;

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
    if(!includeAudio && !includeVideo){
      return;
    }
    // String params = "";
    StringBuffer params = StringBuffer();

    // params.write("-P $downloadPath");

    // params.write("-o $outputFile");
    
    params.write('-f ');

    if(includeVideo){
      params.write('bv');
    }
    if(includeVideo && (selectedVideoHeight != VideoHeight.Best)){
      params.write('[height<=${selectedVideoHeight.res}]');
    }
    if(includeVideo && (selectedVideoContainer != VideoContainer.Best)){
      params.write('[ext=${selectedVideoContainer.ext}]');
    }

    if(includeAudio && !includeVideo){
      params.write('ba');
    } else if(includeAudio && includeVideo){
      params.write(' +ba');
    }

    if(includeAudio && (selectedAudioContainer != AudioContainer.Best)){
      params.write('[ext=${selectedAudioContainer.ext}]');
    }
    
    // String temp = "-o $outputFile -f bv[height<=144]";

    var process = await Process.start('yt-dlp', [
      "-P $downloadPath",
      "-o$outputFile",
      "-i",
      params.toString(),
      url,
    ]);
    final RegExp downloadProgressRegExp = RegExp(r'\[download\]\s+(\d+\.\d+)%\s+of\s+(\d+\.\d+)([a-zA-Z]+)\s+at\s+(\d+.\d+)([a-zA-Z/]+)');
    // [download] Downloading item 1 of 28
    final RegExp indexOutOf = RegExp(r'\[download\] Downloading item (\d+) of (\d+)');

    // https://www.youtube.com/watch?v=Qp3b-RXtz4w&list=PLiQl43ty5itMxxRIXpTSJzTFktwJaGwDQ&pp=gAQBiAQB
    int currentVideoIndex = 0;
    process.stdout.transform(utf8.decoder).forEach((output) {

      var indexMatch = indexOutOf.firstMatch(output);
      if(indexMatch != null){
        if(indexMatch.group(1) != null){
          currentVideoIndex = int.parse(indexMatch.group(1)!);
        }
      }
        print(currentVideoIndex);
      var match = downloadProgressRegExp.firstMatch(output);
      // print(output);
      if(match != null){
        double progress = double.parse(match.group(1)!);
        double size = double.parse(match.group(2)!);
        String mb = match.group(3)!;
        double downloadSpeed = double.parse(match.group(4)!);
        String speed = match.group(5)!;
        
        // String example = "[download]   7.1% of   19.13MiB at  783.17KiB/s ETA 00:23";  
        videoDescrtiptions[currentVideoIndex].downloadProgress = "$progress% of $size $mb";
        notifyListeners();
      }
      // }
    });

    process.stderr.transform(utf8.decoder).forEach((output) {
        print(output);
      // }
    });
  }

  void getVideoInfo() async{
    var infoArgs = [
      "-i",
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
    } 
    List<dynamic> playlistJson = result.stdout.toString().trim().split('\n').map((video) => json.decode(video)).toList();

    playlistJson.forEach((jsonDesc) {
      videoDescrtiptions.add(VideoDescrtiption.fromJSON(jsonDesc));
    });
    

    // print('${result.stdout}');
    // currentState = AppState.IDLE;
    currentState = AppState.LOADED;
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