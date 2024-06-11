// ignore_for_file: prefer_const_constructors, use_super_parameters, curly_braces_in_flow_control_structures

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:guya/config_state.dart';
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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(      
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: urlTextController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter video URL...',
              ),
              onChanged: (value){
                config.updateUrl(value);
              },
            ),
           
            const SizedBox(height: 16,),
            
            Row(
              children: [
                IconButton(
                  onPressed: () async{
                    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
                    
                    if (selectedDirectory != null) {
                      config.setDownloadPath(selectedDirectory);                  
                    }
                  },
                  icon: Icon(Icons.folder)
                ),
                
                Text(context.read<ConfigState>().downloadPath),
                
                Expanded(child: SizedBox()),
                
                ElevatedButton(
                  onPressed: (){
                    context.read<ConfigState>().download();
                  }, child: Text("DOWNLOAD")
                )
              ],
            ),
            
            const SizedBox(height: 32,),

            Expanded(child: InfoDisplay())
          ],
        ),
      ),
    );
  }
}

class InfoDisplay extends StatelessWidget{
  const InfoDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // if (context.watch<ConfigState>().currentState == AppState.IDLE)
    //   return Text("IDELING...");
    // ConfigState config = Provider.of<ConfigState>(context);
    
    if (context.select<ConfigState, AppState>((config) => config.currentState) == AppState.LOADING_DATA)
      return Container(
        width: 24,
        height: 24,
        child: CircularProgressIndicator()
      );

    return Selector<ConfigState, List<VideoDescrtiption>>(
      selector: (BuildContext , ConfigState) => ConfigState.videoDescrtiptions,
      builder: (BuildContext context, List<VideoDescrtiption> value, Widget? child) {
        return VideoList();
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
            color: Colors.pink.shade100,
            child: Row(
              children: [
                CachedNetworkImage(
                  imageUrl: context.read<ConfigState>().videoDescrtiptions[index].thumbnaillUrl,
                  progressIndicatorBuilder: (context, url, downloadProgress) => 
                          CircularProgressIndicator(value: downloadProgress.progress),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
                Text(
                  context.watch<ConfigState>().videoDescrtiptions[index].title
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
