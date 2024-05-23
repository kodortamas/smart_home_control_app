import 'package:flutter/material.dart';

class TemperatureDisplay extends StatelessWidget {
  final ValueNotifier<Map<String, String>> temperatures;
  final String tempName;

  const TemperatureDisplay({
    Key? key,
    required this.temperatures,
    required this.tempName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, String>>(
      valueListenable: temperatures,
      builder: (_, tempMap, __) {
        return InfoDisplay(
          label: "Current temperature:",
          value: "${tempMap[tempName]} °C",
          icon: Icons.thermostat,
        );
      },
    );
  }
}

class HumidityDisplay extends StatelessWidget {
  final ValueNotifier<Map<String, String>> humidities;
  final String humidName;

  const HumidityDisplay({
    Key? key,
    required this.humidities,
    required this.humidName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, String>>(
      valueListenable: humidities,
      builder: (_, humidMap, __) {
        return InfoDisplay(
          label: "Current humidity:",
          value: "${humidMap[humidName]}%",
          icon: Icons.water_drop,
        );
      },
    );
  }
}

class InfoDisplay extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const InfoDisplay({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final iconSize = constraints.maxHeight * 0.3; 
        final fontSize = constraints.maxHeight * 0.14; 

        return Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.all(constraints.maxHeight * 0.1), 
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: iconSize,
                color: const Color.fromARGB(255, 211, 211, 211),
              ),
              SizedBox(width: constraints.maxWidth * 0.05),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: fontSize,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: fontSize,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

