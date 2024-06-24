import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dougamoe/config_state.dart';
import 'package:dougamoe/options_menu.dart';
import 'package:dougamoe/video_desc.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(ChangeNotifierProvider(    
    create: (BuildContext context) => ConfigState(),
    child: const DougaMoe()));
}

class DougaMoe extends StatelessWidget {
  const DougaMoe({super.key});
  @override
  Widget build(BuildContext context) {
    return Selector<ConfigState, bool>(
      selector: (BuildContext , ConfigState) => ConfigState.darkMode,
      builder: (BuildContext context, bool darkMode, Widget? child) {
        return MaterialApp(
          title: 'Douga Moe',
          themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink, brightness: Brightness.dark),
            textTheme: const TextTheme(
              displayMedium: TextStyle(
                fontSize: 42
              ),
            ),
          ),
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
            brightness: Brightness.light,      
            textTheme: const TextTheme(
              displayMedium: TextStyle(
                fontSize: 42
              ),
            ),
            useMaterial3: true,
          ),
          home: const HomaPage(title: 'Flutter Demo Home Page'),
        );
      }
    );
  }
}

class HomaPage extends StatefulWidget {
  const HomaPage({super.key, required this.title});

  final String title;

  @override
  State<HomaPage> createState() => _HomaPageState();
}

class _HomaPageState extends State<HomaPage> {
  TextEditingController urlTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    ConfigState config = Provider.of<ConfigState>(context, listen: false);

    return Scaffold(
      // floatingActionButton: Container(
      //   width: 48,
      //   height: 48,
      //   child: FloatingActionButton(
      //     child: Icon(Icons.settings),        
      //     onPressed: (){
      //       String include = "";
      //       int endIndex = config.videoDescrtiptions.length;
      //       int startIndex = 1;
      //       List<int> exlude = [];
      //       // 0, 1, 1, 1, 1
      //       // -I 1:2, 4:5
      //       String section = "";

      //       for(int i = 0; i < config.videoDescrtiptions.length; ++i){              
      //         if(!config.videoDescrtiptions[i].include){
      //           if(section.isNotEmpty){
      //             if(include.length > 2){
      //               include += ",$section";
      //             } else {
      //               include += "-I $section";
      //             }
      //           }
                  
      //           section = "";
      //           startIndex = endIndex = i + 2;
      //         } else {
      //           endIndex = i + 1;
      //           if(startIndex == endIndex){
      //             section = "$startIndex";
      //           } else {
      //             section = "$startIndex:$endIndex";
      //           }
      //         }
      //       }
            
      //       if(include.isEmpty){
      //         print("-I $section");
      //       } else {
      //         print(include += ",$section");
      //       }


      //       // showModalBottomSheet(
      //       //   context: context,
      //       //   barrierColor: Colors.black.withOpacity(0.2),
      //       //   builder: (context){
      //       //     return Container(
      //       //       width: MediaQuery.of(context).size.width,
      //       //       color: Colors.green.shade100,
      //       //       child: Column(
      //       //         children: [
      //       //           Text("Dark mode"),
      //       //           CupertinoSwitch(
      //       //             value: context.read<ConfigState>().darkMode,
      //       //             onChanged: (value){
      //       //               context.read<ConfigState>().setDarkMode(value);
      //       //             })
      //       //         ]
      //       //       ),
      //       //     );
      //       //   },
      //       // );
      //     }
      //   ),
      // ),
      body: DefaultTextStyle(
        style: TextStyle(
          inherit: true,
          color: Theme.of(context).textTheme.bodyMedium!.color,
          fontSize: 18          
        ),
        child: Center(      
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(                              
                  decoration: InputDecoration(
                    suffixIcon: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: LoadingIndicator(),
                    ),
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
                    // hintStyle: TextStyle(fontSize: 18)
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
                          const Text("Download path"),
                          
                          const SizedBox(height: 8,),
        
                          OutlinedButton.icon(
                          onPressed: () async {
                            String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
                        
                            if (selectedDirectory != null) {
                              config.setDownloadPath(selectedDirectory);                  
                            }
                          }, icon: const Icon(Icons.folder),
                          label: Text(context.watch<ConfigState>().downloadPath, style: TextStyle(
                            fontSize: 16
                          ),),
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
                    
                    const Expanded(child: SizedBox()),                                  
                  ],
                ),
              ),
              
              const SizedBox(height: 32,),
                                          
              Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [                    
                    Expanded(child: DownloadBtnAndOptions()),
                  ],
                ),
              ),
                            
              const SizedBox(height: 16,),
            
              const Expanded(child: InfoDisplay()),
            
            ],
          ),
        ),
      ),
    );
  }
}

class VideoCount extends StatelessWidget{
   const VideoCount({
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    int total = context.watch<ConfigState>().videoDescrtiptions.entries.length;
    int included = context.watch<ConfigState>().videoDescrtiptions.values.where((element) {
      return element.include == true;
    }).toList().length;

    return Center(child: Text("$included / $total"));
  }
}

class DownloadBtnAndOptions extends StatelessWidget {
  const DownloadBtnAndOptions({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    bool disabled = context.watch<ConfigState>().currentState == AppState.DOWNLOADING;
    return Padding(
      padding: const EdgeInsets.only(right: 16.0, left: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton.icon(                            
            onPressed: (){
              if(disabled){
                context.read<ConfigState>().stopDownload();
              } else {
                context.read<ConfigState>().download();
              }
            }, label: Text(disabled ? "STOP" : "DOWNLOAD", style: TextStyle(fontSize: 18),),
            icon: Icon(disabled ? Icons.cancel : Icons.download),
          ),
          DownloadOptions(),
        ],
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
        child: const CircularProgressIndicator()
      );

    return const SizedBox.shrink();
  }
  
}
class InfoDisplay extends StatelessWidget{
  const InfoDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<ConfigState, Map<String, VideoDescrtiption>>(
      selector: (BuildContext , ConfigState) => ConfigState.videoDescrtiptions,
      builder: (BuildContext context, Map<String, VideoDescrtiption> value, Widget? child) {
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
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12)
                    )
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
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
    final List<VideoDescrtiption> vds = context.watch<ConfigState>().videoDescrtiptions.values.toList();
    
    return ListView.builder(
      itemCount: vds.length,
      itemBuilder: (context, index){
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Container(
            height: 64,
            // color: Colors.pink.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CachedNetworkImage(
                  imageUrl: vds[index].thumbnaillUrl,
                  progressIndicatorBuilder: (context, url, downloadProgress) => 
                          CircularProgressIndicator(value: downloadProgress.progress),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
                
                const SizedBox(width: 12,),
                
                SelectableText(
                  vds[index].title
                ),

                const Expanded(child: SizedBox()),
                
                
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Text(
                      vds[index].errorText, style: TextStyle(
                        color: Colors.red
                      ),
                    ),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Text(
                    vds[index].downloadProgress
                  ),
                ),
            
                Checkbox(
                  value: vds[index].include,
                  onChanged: (value){
                    if(value != null){
                      context.read<ConfigState>().toggleIncludeVideo(index, value);
                    }
                  }
                ),

                const SizedBox(width: 32,)
              ],
            ),
          ),
        );
      }       
    );
  }
}

class DownloadOptions extends StatelessWidget {
  const DownloadOptions({super.key});

  @override
  Widget build(BuildContext context) {
    ConfigState config = Provider.of<ConfigState>(context);
    
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [   
          Column(
            children: [
              const Text("Audio Cotainer"),
              
              const SizedBox(height: 8,),
              
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
          
          const SizedBox(width: 12,),
          
          Column(
            children: [
              const Text("Video Cotainer"),
              
              const SizedBox(height: 8,),
              
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

          const SizedBox(width: 12,),

          Column(
            children: [
              const Text("Video Height"),
              
              const SizedBox(height: 8,),
              
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
          
          const SizedBox(width: 24,),

          Column(
            children: [

              const Text("Audio"),

              Checkbox(
                value: config.includeAudio,
                onChanged: (bool? value) {
                  config.toggleAudio();
                },
              ),
            ],
          ),
          
          const SizedBox(width: 8,),
          
          Column(
            children: [
              const Text("Video"),
              
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
          
          const SizedBox(width: 42,),

          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text("Include all"),
              Checkbox(
                value: config.includeAll,
                onChanged: (value){
                  if(value != null){
                    context.read<ConfigState>().toggleIncludeForAll(value);
                  }
                }
              ),
              
              const SizedBox(height: 4,),
              
              VideoCount(),
            ],
          ),
        ],
      );

    // return SizedBox.shrink();
  }
}