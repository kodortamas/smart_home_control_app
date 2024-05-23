import 'package:flutter/material.dart';

class LightSwitchButton extends StatefulWidget {
  final String lightName;
  final String label;
  final ValueNotifier<Map<String, bool>> lightStates;
  final Function(String) sendCommand;
  final bool rgb; // To indicate RGB functionality
  final Function(BuildContext)? pickColor;
  final String rgbName;

  const LightSwitchButton({
    Key? key,
    required this.lightName,
    required this.label,
    required this.lightStates,
    required this.sendCommand,
    this.rgb = false,
    this.pickColor,
    this.rgbName = "",
  }) : super(key: key);

  @override
  _LightSwitchButtonState createState() => _LightSwitchButtonState();
}

class _LightSwitchButtonState extends State<LightSwitchButton> {
  @override
  void initState() {
    super.initState();
    widget.lightStates.addListener(_update);
  }

  @override
  void dispose() {
    widget.lightStates.removeListener(_update);
    super.dispose();
  }

  void _update() => setState(() {});

  void toggleLight() {
    widget.lightStates.value[widget.lightName] = !(widget.lightStates.value[widget.lightName] ?? false);
    widget.lightStates.notifyListeners(); // Notify listeners about the change
    // Accessing the light state
    bool isLightOn = widget.lightStates.value[widget.lightName] ?? false;

    // Sending command
    widget.sendCommand("${widget.lightName}:${isLightOn ? 'ON' : 'OFF'}");

  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final iconSize = constraints.maxHeight * 0.4; // 40% of container height
        final fontSize = constraints.maxHeight * 0.15; // 15% of container height

        return Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: toggleLight,
                  onLongPress: widget.rgb ? () => widget.pickColor?.call(context) : null,
                  borderRadius: BorderRadius.circular(50),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      widget.lightStates.value[widget.lightName] ?? false
                          ? Icons.lightbulb
                          : Icons.lightbulb_outline,
                      color: (widget.lightStates.value[widget.lightName] ?? false)
                          ? Color.fromARGB(255, 211, 211, 211)
                          : Colors.grey,
                      size: iconSize,
                    ),
                  ),
                ),
              ),
              SizedBox(height: constraints.maxHeight * 0.05),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: fontSize,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}



