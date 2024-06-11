// ignore_for_file: prefer_const_constructors, use_super_parameters, curly_braces_in_flow_control_structures

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:guya/config_state.dart';
import 'package:guya/options_menu.dart';
import 'package:guya/video_desc.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(ChangeNotifierProvider(    
    create: (BuildContext context) => ConfigState(),
    child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink, brightness: Brightness.dark),
        textTheme: TextTheme(
          displayMedium: TextStyle(
            fontSize: 42
          ),
        ),

        /* dark theme settings */
      ),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        brightness: Brightness.light,      
        textTheme: TextTheme(
          displayMedium: TextStyle(
            fontSize: 42
          ),
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController urlTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    ConfigState config = Provider.of<ConfigState>(context, listen: false);
    
    return Scaffold(
      body: Center(      
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(                              
                decoration: InputDecoration(
                  hoverColor: Colors.red,
                  // filled: true,                  
                  // fillColor: Colors.grey,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.pink.shade100, // You can change the color here
                      width: 4.0, // You can adjust the thickness here
                    ),
                    borderRadius: BorderRadius.circular(10.0), // You can adjust the border radius here
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.pink.shade200, // You can change the color here
                      width: 4.0, // You can adjust the thickness here
                    ),
                    borderRadius: BorderRadius.circular(10.0), // You can adjust the border radius here
                  ),
                  
                  hintText: 'Enter video URL...',
                ),
                onChanged: (value){
                  config.updateUrl(value);
                },
              ),
            ),
      
            const SizedBox(height: 16,),
            
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16),
              child: Row(
                children: [
                   Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                        Text("Download path"),
                        
                        const SizedBox(height: 8,),
      
                        OutlinedButton.icon(
                        onPressed: () async {
                          String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
                      
                          if (selectedDirectory != null) {
                            config.setDownloadPath(selectedDirectory);                  
                          }
                        }, icon: Icon(Icons.folder),
                        label: Text(context.watch<ConfigState>().downloadPath),
                      ),
                    ],
                  ),
                  // IconButton(
                  //   onPressed: () async{
                  //     String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
                      
                  //     if (selectedDirectory != null) {
                  //       config.setDownloadPath(selectedDirectory);                  
                  //     }
                  //   },
                  //   icon: Icon(Icons.folder)
                  // ),
                  const SizedBox(width: 16,),
              
                  // Text(),
                  
                  Expanded(child: SizedBox()),
                  
                
                ],
              ),
            ),
            
            const SizedBox(height: 32,),
            
            
            Padding(
              padding: const EdgeInsets.only(right: 30.0, left: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(                
                    onPressed: (){
                      context.read<ConfigState>().download();
                    }, label: Text("DOWNLOAD"),
                    icon: Icon(Icons.download),
                  ),
                  DownloadOptions(),
                ],
              ),
            ),
                          
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Center(child: LoadingIndicator()),
            ),
            
            Expanded(child: InfoDisplay())
          ],
        ),
      ),
    );
  }
}
class LoadingIndicator extends StatelessWidget{
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.select<ConfigState, AppState>((config) => config.currentState) == AppState.LOADING_DATA)
      return Container(
        width: 24,
        height: 24,
        child: CircularProgressIndicator()
      );

    return SizedBox.shrink();
  }
  
}
class InfoDisplay extends StatelessWidget{
  const InfoDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<ConfigState, List<VideoDescrtiption>>(
      selector: (BuildContext , ConfigState) => ConfigState.videoDescrtiptions,
      builder: (BuildContext context, List<VideoDescrtiption> value, Widget? child) {
        return Column(
          children: [            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 0.0, right: 0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        width: 4,
                        color: Colors.pink.shade100
                      ),
                      
                      // left: BorderSide(
                      //   width: 1,
                      //   color: Colors.pink.shade100
                      // ),
                      
                      // right: BorderSide(
                      //   width: 1,
                      //   color: Colors.pink.shade100
                      // ),
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12)
                    )
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: VideoList(),
                  )),
              ),
            ),
          ],
        );
      }
    );
  }
}

class VideoList extends StatelessWidget {
  const VideoList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: context.watch<ConfigState>().videoDescrtiptions.length,
      itemBuilder: (context, index){
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Container(
            height: 64,
            // color: Colors.pink.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CachedNetworkImage(
                  imageUrl: context.read<ConfigState>().videoDescrtiptions[index].thumbnaillUrl,
                  progressIndicatorBuilder: (context, url, downloadProgress) => 
                          CircularProgressIndicator(value: downloadProgress.progress),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
                
                SizedBox(width: 12,),
                
                Text(
                  context.watch<ConfigState>().videoDescrtiptions[index].title
                ),
          
                Expanded(child: SizedBox()),
                
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Text(
                    context.watch<ConfigState>().videoDescrtiptions[index].downloadProgress
                  ),
                ),
              ],
            ),
          ),
        );
      }
        // if (context.read<ConfigState>().currentState == AppState.LOADED)
          // Text(
          //     context.watch<ConfigState>().videoDescrtiption.title,
          //     style: Theme.of(context).textTheme.headlineMedium,
          //   ),
            
          // Text(
          //   context.watch<ConfigState>().videoDescrtiption.duration,
          //   style: Theme.of(context).textTheme.headlineMedium,
          // ),    
    );
  }
}

class DownloadOptions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ConfigState config = Provider.of<ConfigState>(context);
    
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [   
          Column(
            children: [
              Text("Audio Cotainer"),
              
              SizedBox(height: 8,),
              
              Container(
                width: 100,
                child: OptionsMenu(
                  value: config.selectedAudioContainer.ext,                
                  entries: AudioContainer.values.map<MenuItemButton>((AudioContainer containerOption) {
                    return MenuItemButton(                                        
                      onPressed: () {
                        config.changeAudioContainer(containerOption);
                      },
                      child: Container(
                        width: 86,
                        child: Text(                  
                          containerOption.ext,
                        ),
                      ),
                    );
                  }).toList()
                ),
              ),
            ],
          ),
          
          SizedBox(width: 12,),
          
          Column(
            children: [
              Text("Video Cotainer"),
              
              SizedBox(height: 8,),
              
              Container(
                width: 100,
                child: OptionsMenu(
                  value: config.selectedVideoContainer.ext,         
                  entries: VideoContainer.values.map<MenuItemButton>((VideoContainer containerOption) {
                    return MenuItemButton(
                      onPressed: () {
                        config.changeVideoContainer(containerOption);
                      },
                      child: Container(
                        width: 86,
                        child: Text(                  
                          containerOption.ext,
                        ),
                      )
                    );
                  }).toList()
                ),
              ),
            ],
          ),

          SizedBox(width: 12,),

          Column(
            children: [
              Text("Video Height"),
              
              SizedBox(height: 8,),
              
              Container(
                width: 100,
                child: OptionsMenu(
                  value: config.selectedVideoHeight.res,         
                  entries: VideoHeight.values.map<MenuItemButton>((VideoHeight resOption) {
                    return MenuItemButton(
                      onPressed: () {
                        config.changeOutputHeigth(resOption);
                      },
                      child: Container(
                        width: 86,
                        child: Text(                  
                          resOption.res,
                        ),
                      )
                    );
                  }).toList()
                ),
              ),
            ],
          ),
          
          SizedBox(width: 24,),

          Column(
            children: [

              Text("Audio"),

              Checkbox(
                // checkColor: Colors.pink,
                // fillColor: MaterialStateProperty.resolveWith(getColor),
                value: config.includeAudio,
                onChanged: (bool? value) {
                  config.toggleAudio();
                },
              ),
            ],
          ),
          
          SizedBox(width: 8,),
          
          Column(
            children: [
              Text("Video"),
              
              Checkbox(
                // checkColor: Colors.pink,
                // fillColor: MaterialStateProperty.resolveWith(getColor),
                value: config.includeVideo,
                onChanged: (bool? value) {
                  config.toggleVideo();
                },
              ),
            ],
          ),
        ],
      );

    // return SizedBox.shrink();
  }
}