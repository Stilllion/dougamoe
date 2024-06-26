
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
  ConfigState(Map<String, dynamic> savedSettings){
    if(savedSettings.isNotEmpty){
      appSettings = savedSettings;
    }
  }

  String url = "";

  Map<String, VideoDescrtiption> videoDescrtiptions = {};
  
  bool includeAudio = true;
  bool includeVideo = true;

  bool includeAll = true;
  
  String pathToExe = "yt-dlp";
  String downloadProgress = "";
  int? downloadPID;

  VideoHeight selectedVideoHeight = VideoHeight.Best;

  VideoContainer selectedVideoContainer = VideoContainer.Best;
  AudioContainer selectedAudioContainer = AudioContainer.Best;

  String outputFile = "%(title)s.%(ext)s";

  Map<String, dynamic> appSettings = {
    "dark_mode": false,
    "download_path": ""
  };

  AppState currentState = AppState.IDLE;
  List<String> consoleLog = []; 
  
  void setDarkMode(bool value){
    appSettings["dark_mode"] = value;

    File savedSettings = File("conf.json");
    savedSettings.writeAsString(jsonEncode(appSettings));

    notifyListeners();
  }

  void setDownloadPath(String newPath) {
    appSettings["download_path"] = newPath;

    File savedSettings = File("conf.json");
    savedSettings.writeAsString(jsonEncode(appSettings));
    
    notifyListeners();
  }
  
  void updateUrl(String newUrl){
    url = newUrl;
    
    if(newUrl.isEmpty){
      // TODO: Resets display info
      videoDescrtiptions = {};
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

 
  void toggleIncludeVideo(int index, bool value){
    if(videoDescrtiptions.values.elementAt(index) != null){
      videoDescrtiptions.values.elementAt(index).include = value;
    }

    notifyListeners();
  }

  void toggleIncludeForAll(bool value){
    for(var vd in videoDescrtiptions.values){
      vd.include = value;      
    }
    
    includeAll = value;
    notifyListeners();
  }

  void stopDownload(){
    if(downloadPID != null){
      Process.killPid(downloadPID!);
      downloadPID = null;
    }
  }


  String includeParams(){
    String include = "";

    int startIndex = 1;
    int endIndex = 1;

    String section = "";
    List<VideoDescrtiption> descrList = videoDescrtiptions.values.toList();
    
    for(int i = 0; i < descrList.length; ++i){              
      if(!descrList[i].include){
        if(section.isNotEmpty){
          if(include.length > 2){
            include += ",$section";
          } else {
            include += "-I$section";
          }
        }
          
        section = "";
        startIndex = endIndex = i + 2;
      } else {
        endIndex = i + 1;
        
        if(startIndex == endIndex){
          section = "$startIndex";
        } else {
          section = "$startIndex:$endIndex";
        }
      }
    }
    
    if(include.isEmpty){
      return "-I$section";
    } else {
      return include;
    }

  }
  // [download]   7.1% of   19.13MiB at  783.17KiB/s ETA 00:23
  // Here we need the context to show error snackbar
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
    // On Linux we assume that the yt-dlp is in the PATH
    // On Windows we use bundeled exe, for now
   
    if(Platform.isWindows){
      String appPath = Platform.resolvedExecutable;
      String appDir = appPath.substring(0, appPath.lastIndexOf(Platform.pathSeparator));
  
      pathToExe = Directory("$appDir/data/flutter_assets/assets/").listSync()
        .where((element) => element.path
        .endsWith('yt-dlp.exe'))
        .first.path;    
    }

    var process = await Process.start(pathToExe, [
      "-P ${appSettings["download_path"]}",
      "-o$outputFile",
      "-i",
      params.toString(),
      includeParams(),
      url,
    ]);

    for(VideoDescrtiption vd in videoDescrtiptions.values){
      vd.downloadProgress = "";
      vd.errorText = "";

      currentState = AppState.DOWNLOADING;
      notifyListeners();
    }
    consoleLog = [];
    downloadPID = process.pid;

    final RegExp downloadProgressRegExp = RegExp(r'\[download\]\s+(\d+\.\d+)%\s+of\s+~?\s+(\d+\.\d+)([a-zA-Z]+)\s+at\s+(\d+.\d+)([a-zA-Z/]+)');
    // [download] Downloading item 1 of 28
    final RegExp indexOutOf = RegExp(r'\[.+\] (.+): Downloading');

    // https://www.youtube.com/watch?v=Qp3b-RXtz4w&list=PLiQl43ty5itMxxRIXpTSJzTFktwJaGwDQ&pp=gAQBiAQB
    String currentVideoId = "";
    process.stdout.transform(utf8.decoder).forEach((output) {
      print(output);
      consoleLog.add(output);

      var indexMatch = indexOutOf.firstMatch(output);
      if(indexMatch != null){
        if(indexMatch.group(1) != null){
          currentVideoId = indexMatch.group(1)!;
        }
      }
      var match = downloadProgressRegExp.firstMatch(output);
      // print(output);
      if(match != null){
        double progress = double.parse(match.group(1)!);
        double size = double.parse(match.group(2)!);
        String mb = match.group(3)!;
        double downloadSpeed = double.parse(match.group(4)!);
        String speed = match.group(5)!;
        
        // String example = "[download]   7.1% of   19.13MiB at  783.17KiB/s ETA 00:23";  
        if(videoDescrtiptions[currentVideoId] != null){
          videoDescrtiptions[currentVideoId]!.downloadProgress = "$progress% of $size $mb";
        }
        notifyListeners();
      }
      
      // notifyListeners();
      // }
    }).whenComplete((){
      currentState = AppState.IDLE;
      downloadPID = null;
      notifyListeners();
    });

    process.stderr.transform(utf8.decoder).forEach((output) {
      if(output.contains("ERROR") && output.contains(currentVideoId)){
        String? error = output.split(currentVideoId)[1].replaceAll('\n', '');
        if(error != null){
          if(error.contains("not available")){
            error = "Requested format is not available";
          }
        
          if(videoDescrtiptions[currentVideoId] != null){
            videoDescrtiptions[currentVideoId]!.errorText = error;
          }
          
          downloadPID = null;
        }            
      }

      print(output);
      consoleLog.add(output);     
      notifyListeners();
      // errorText = output;
      //   var snackBar = SnackBar(
      //     content: Text(errorText),
      //   );

      //   // Find the ScaffoldMessenger in the widget tree
      //   // and use it to show a SnackBar.
      //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
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

    if(Platform.isWindows){
      String appPath = Platform.resolvedExecutable;
      String appDir = appPath.substring(0, appPath.lastIndexOf(Platform.pathSeparator));
  
      pathToExe = Directory("$appDir/data/flutter_assets/assets/").listSync()
        .where((element) => element.path
        .endsWith('yt-dlp.exe'))
        .first.path;    
    }

    var result = await Process.run(pathToExe, [...infoArgs, url]);
    
    if (result.stderr.isNotEmpty) {
      print('Error: ${result.stderr}');
      consoleLog.add(result.stderr);
    } 
    List<dynamic> playlistJson = result.stdout.toString().trim().split('\n').map((video) => json.decode(video)).toList();

    for (var jsonDesc in playlistJson) {
      videoDescrtiptions[jsonDesc["id"]] = VideoDescrtiption.fromJSON(jsonDesc);
    }
    

    // print('${result.stdout}');
    // currentState = AppState.IDLE;
    currentState = AppState.LOADED;
    notifyListeners();
    // var process = await Process.start('yt-dlp', [
    //   ...infoArgs,
    //   url,
    // ]);

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