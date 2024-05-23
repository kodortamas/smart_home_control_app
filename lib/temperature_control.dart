import 'package:flutter/material.dart';

class TemperatureControlWidget extends StatefulWidget {
  final String name;
  final String label;
  final ValueNotifier<Map<String, String>> desiredTemperatures;
  final String tempName;
  final Function(String) sendCommand;

  const TemperatureControlWidget({
    Key? key,
    required this.name,
    required this.label,
    required this.desiredTemperatures,
    required this.tempName,
    required this.sendCommand,
  }) : super(key: key);

  @override
  _TemperatureControlWidgetState createState() => _TemperatureControlWidgetState();
}

class _TemperatureControlWidgetState extends State<TemperatureControlWidget> {
  @override
  void initState() {
    super.initState();
    widget.desiredTemperatures.addListener(_update);
  }

  @override
  void dispose() {
    widget.desiredTemperatures.removeListener(_update);
    super.dispose();
  }

  void _update() => setState(() {});

  void adjustTemperature(String direction) {
    widget.sendCommand("${widget.name}:$direction");
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final iconSize = constraints.maxHeight * 0.3; 
        final fontSize = constraints.maxHeight * 0.15; 

        return Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove, size: iconSize),
                    onPressed: () => adjustTemperature("DOWN"),
                    color: const Color.fromARGB(255, 211, 211, 211),
                  ),
                  ValueListenableBuilder<Map<String, String>>(
                    valueListenable: widget.desiredTemperatures,
                    builder: (context, temps, child) {
                      return Text(
                        '${temps[widget.tempName]}°C',
                        style: Theme.of(context).textTheme.headline4?.copyWith(
                            color: const Color.fromARGB(255, 211, 211, 211),
                            fontSize: iconSize),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.add, size: iconSize),
                    onPressed: () => adjustTemperature("UP"),
                    color: const Color.fromARGB(255, 211, 211, 211),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: constraints.maxHeight * 0.05),
                child: Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: fontSize * 0.9,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

