import 'package:flutter/material.dart';

class ShadeControl extends StatefulWidget {
  final String shadeName;
  final String label;
  final ValueNotifier<Map<String, bool>> shadeStates;
  final Function(String) sendCommand;

  const ShadeControl({
    Key? key,
    required this.shadeName,
    required this.label,
    required this.shadeStates,
    required this.sendCommand,
  }) : super(key: key);

  @override
  _ShadeControlState createState() => _ShadeControlState();
}

class _ShadeControlState extends State<ShadeControl> {

  @override
  void initState() {
    super.initState();
    widget.shadeStates.addListener(_update);
  }

  @override
  void dispose() {
    widget.shadeStates.removeListener(_update);
    super.dispose();
  }

  void _update() => setState(() {});

  void toggleShade(bool isUp) {
    widget.shadeStates.value[widget.shadeName] = isUp;
    widget.shadeStates.notifyListeners();
    widget.sendCommand("${widget.shadeName}:${isUp ? 'UP' : 'DOWN'}");
  }

  @override
  Widget build(BuildContext context) {
    bool isShadeUp = widget.shadeStates.value[widget.shadeName] ?? false;

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      final iconSize = constraints.maxHeight * 0.4; 
      final arrowIconSize = constraints.maxHeight * 0.25;
      final fontSize = constraints.maxHeight * 0.15;

      return Container(
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.all(7),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    isShadeUp ? Icons.blinds : Icons.blinds_closed,
                    color: isShadeUp ? Colors.grey : const Color.fromARGB(255, 211, 211, 211),
                    size: iconSize,
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: fontSize,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_upward),
                    onPressed: isShadeUp ? null : () => toggleShade(true),
                    color: const Color.fromARGB(255, 211, 211, 211),
                    iconSize: arrowIconSize,
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_downward),
                    onPressed: !isShadeUp ? null : () => toggleShade(false),
                    color: const Color.fromARGB(255, 211, 211, 211),
                    iconSize: arrowIconSize,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
