import 'package:flutter/material.dart';

class OptionsMenu extends StatefulWidget {
  const OptionsMenu({
    super.key,
    required this.value,
    required this.entries
  });

  final List<Widget> entries;
  final dynamic value;

  @override
  State<OptionsMenu> createState() => _OptionsMenuState();
}

class _OptionsMenuState extends State<OptionsMenu> {
  final FocusNode _buttonFocusNode = FocusNode(debugLabel: 'Menu Button');

  @override
  void dispose() {
    _buttonFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(        
      childFocusNode: _buttonFocusNode,
      menuChildren: <Widget>[
        ...Iterable.generate(widget.entries.length, (index){
          return  widget.entries[index];
        })
             
      ],
      builder: (BuildContext context, MenuController controller, Widget? child) {
        return OutlinedButton(
          focusNode: _buttonFocusNode,
          onPressed: () async {
              if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },         
          // icon: Icon(Icons.arrow_downward_sharp),
          child: Text(widget.value, style: TextStyle(fontSize: 20),)
        );
      },
    );
  }
}