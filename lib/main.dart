import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'info_display.dart';
import 'ip_selection_screen.dart';
import 'light_switch_button.dart';
import 'shade_control.dart';
import 'temperature_control.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: IPSelectionScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  final String ipAddress;

  MainScreen({required this.ipAddress});

  @override
  State<StatefulWidget> createState() {
    return SmartHomeMainScreen();
  }
}

class SmartHomeMainScreen extends State<MainScreen> {
  
  ValueNotifier<Map<String, bool>> lightStates = ValueNotifier<Map<String, bool>>({
   // 'kitchenMain': false,
    //'kitchenBar': false,
    //'bathroomMain': false,
    //'bedroomMain': false,
  });

  ValueNotifier<Map<String, bool>> shadeStates = ValueNotifier<Map<String, bool>>({
    //'bedroomShade': false,
  });

  ValueNotifier<Map<String, String>> desiredTemperatures = ValueNotifier<Map<String, String>>({
    //'bed': "",
    //'bat': "",
  });

  ValueNotifier<Map<String, String>> temperatures = ValueNotifier<Map<String, String>>({
   // 'main': "",
  });

  ValueNotifier<Map<String, String>> humidities = ValueNotifier<Map<String, String>>({
    //'main': "",
  });

  Map<String, Color> colors = {'BL': Colors.black};

  late WebSocketChannel channel;
  bool connected = false;
  late String ipAddress;

  List<Widget> controlWidgets = [];

  Set<int> selectedIndexes = Set();
  bool isDeleteMode = false;

  void addNewWidget(Widget widget) {
    setState(() {
      controlWidgets.add(widget);
    });
  }

  @override
  void initState() {
    super.initState();
    ipAddress = widget.ipAddress;
    /*lightStates.value['kitchenMain'] = false;
    lightStates.value['kitchenBar'] = false;
    lightStates.value['bathroomMain'] = false;
    lightStates.value['bedroomMain'] = false;
    lightStates.notifyListeners();
    shadeStates.value['bedroomShade'] = false;
    shadeStates.notifyListeners();
    desiredTemperatures.value['bed'] = "22.50";
    desiredTemperatures.value['bat'] = "21.00";
    desiredTemperatures.notifyListeners();
    temperatures.value['main'] = "22.5";
    temperatures.notifyListeners();
    humidities.value['main'] = "56.5";
    humidities.notifyListeners();
    connected = false;
    colors['BL'] = Colors.black;*/

    Future.delayed(Duration.zero, () async {
      channelconnect(widget.ipAddress);
      setupControlWidgets();
      setState(() {});
    });
  }

  void channelconnect(String ipAddress) {
    try {
      channel = WebSocketChannel.connect(
        Uri.parse("ws://$ipAddress:81"),
      );
      channel.stream.listen(
        (message) {
          print(message);
          setState(() {
            if (message == "connected") {
              connected = true;
            } else if (message.startsWith("t")) {
              String key = message.substring(1, 4);
              String value = message.substring(4);
              desiredTemperatures.value[key] = value;
              desiredTemperatures.notifyListeners();
            } else if (RegExp(r'^[A-Z]{3}\d+$').hasMatch(message)) {
              String colorKey = message.substring(0, 2);
              String channel = message.substring(2, 3);
              int value = int.parse(message.substring(3));

              switch (channel) {
                case "R":
                  colors[colorKey] = Color.fromARGB(255, value,
                      colors[colorKey]!.green, colors[colorKey]!.blue);
                  break;
                case "G":
                  colors[colorKey] = Color.fromARGB(255, colors[colorKey]!.red,
                      value, colors[colorKey]!.blue);
                  break;
                case "B":
                  colors[colorKey] = Color.fromARGB(255, colors[colorKey]!.red,
                      colors[colorKey]!.green, value);
                  break;
              }
            } else if (message.contains(':')) {
              List<String> parts = message.split(':');
              String name = parts[0];
              String command = parts[1];

              if (command == "ON" || command == "OFF") {
                lightStates.value[name] = (command == "ON");
                lightStates.notifyListeners();
              } else if (command == "UP" || command == "DOWN") {
                shadeStates.value[name] = (command == "UP");
                shadeStates.notifyListeners();
              }
            } else if (message.startsWith("T")) {
              String key = message.substring(1, 5);
              String value = message.substring(5);
              temperatures.value[key] = value;
              temperatures.notifyListeners();
            } else if (message.startsWith("H")) {
              String key = message.substring(1, 5);
              String value = message.substring(5);
              humidities.value[key] = value;
              humidities.notifyListeners();
            }
          });
        },
        onDone: () {
          print("Web socket is closed");
          setState(() {
            connected = false;
          });
        },
        onError: (error) {
          print(error.toString());
        },
      );
    } catch (_) {
      print("error on connecting to websocket.");
    }
  }

  Future<void> sendcmd(String cmd) async {
    if (connected == true) {
      channel.sink.add(cmd);
    } else {
      channelconnect(ipAddress);
      print(cmd);
    }
  }

  void setupControlWidgets() {
    controlWidgets = [
      /*LightSwitchButton(
        lightName: "kitchenMain",
        label: "Kitchen Main",
        lightStates: lightStates,
        sendCommand: sendcmd,
      ),
      LightSwitchButton(
        lightName: "kitchenBar",
        label: "Kitchen Bar",
        lightStates: lightStates,
        sendCommand: sendcmd,
      ),
      LightSwitchButton(
        lightName: "bathroomMain",
        label: "Bathroom Main",
        lightStates: lightStates,
        sendCommand: sendcmd,
      ),
      TemperatureDisplay(
        temperatures: temperatures,
        tempName: "main",
      ),
      HumidityDisplay(
        humidities: humidities,
        humidName: "main",
      ),
      TemperatureControlWidget(
        name: "bedroomTemp",
        label: "Bedroom desired temperature",
        desiredTemperatures: desiredTemperatures,
        tempName: "bed",
        sendCommand: sendcmd,
      ),
      TemperatureControlWidget(
        name: "bathroomTemp",
        label: "Bathroom desired temperature",
        desiredTemperatures: desiredTemperatures,
        tempName: "bat",
        sendCommand: sendcmd,
      ),
      ShadeControl(
        shadeName: "bedroomShade",
        shadeStates: shadeStates,
        label: "Bedroom Shade",
        sendCommand: sendcmd,
      ),
      LightSwitchButton(
        lightName: "bedroomMain",
        label: "Bedroom Main",
        lightStates: lightStates,
        sendCommand: sendcmd,
        rgb: true,
        pickColor: (context) => pickColor(context, "BL"),
      ),*/
    ];
  }

  void addWidgetTypePopup(BuildContext context) {
    // Initial selected value for dropdown
    String selectedType = "light";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Widget Type'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: selectedType,
                hint: Text("Select a widget type"),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    // Ensure newValue is not null before assignment and action
                    selectedType = newValue;
                    Navigator.of(context).pop();
                    addWidgetDetailsPopup(context,
                        widgetType:
                            selectedType); // Now we know selectedType is not null here
                  }
                },
                items: <String>[
                  'light',
                  'shade',
                  'tempDisplay',
                  'humidityDisplay',
                  'tempControl'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value == 'light'
                        ? 'Add Light Switch'
                        : value == 'shade'
                            ? 'Add Shade Control'
                            : value == 'tempDisplay'
                                ? 'Add Temperature Display'
                                : value == 'humidityDisplay'
                                    ? 'Add Humidity Display'
                                    : 'Add Temperature Control'),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  void addWidgetDetailsPopup(BuildContext context,
      {required String widgetType}) {
    TextEditingController nameController = TextEditingController();
    TextEditingController labelController = TextEditingController();
    TextEditingController rgbNameController =
        TextEditingController(); // Only relevant for RGB lights
    bool isRgb = false; // Only relevant for lights

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add $widgetType'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(hintText: "Enter name"),
                    ),
                    TextField(
                      controller: labelController,
                      decoration: InputDecoration(hintText: "Enter label"),
                    ),
                    if (widgetType == 'light') // Additional options for lights
                      Column(
                        children: [
                          SwitchListTile(
                            title: Text("RGB Light"),
                            value: isRgb,
                            onChanged: (bool value) {
                              setState(() => isRgb = value);
                            },
                          ),
                          if (isRgb)
                            TextField(
                              controller: rgbNameController,
                              decoration:
                                  InputDecoration(hintText: "Enter RGB name"),
                            ),
                        ],
                      ),
                  ],
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Add'),
              onPressed: () {
                String name = nameController.text.trim();
                String label = labelController.text.trim();

                switch (widgetType) {
                  case 'light':
                    lightStates.value[name] = false;
                    lightStates.notifyListeners();
                    addNewWidget(LightSwitchButton(
                      lightName: name,
                      label: label,
                      lightStates: lightStates,
                      sendCommand: sendcmd,
                      rgb: isRgb,
                      rgbName: rgbNameController.text.trim(),
                      pickColor: isRgb
                          ? (context) =>
                              pickColor(context, rgbNameController.text.trim())
                          : null,
                    ));
                    break;
                  case 'shade':
                    shadeStates.value[name] = false;
                    shadeStates.notifyListeners();
                    addNewWidget(ShadeControl(
                      shadeName: name,
                      shadeStates: shadeStates,
                      label: label,
                      sendCommand: sendcmd,
                    ));
                    break;
                  case 'tempDisplay':
                    temperatures.value[name] = "0";
                    temperatures.notifyListeners(); // Example, set initial temp
                    addNewWidget(TemperatureDisplay(
                      temperatures: temperatures,
                      tempName: name,
                    ));
                    break;
                  case 'humidityDisplay':
                    humidities.value[name] = "0";
                    humidities.notifyListeners(); // Example, set initial humidity
                    addNewWidget(HumidityDisplay(
                      humidities: humidities,
                      humidName: name,
                    ));
                    break;
                  case 'tempControl':
                    desiredTemperatures.value[name] = "22"; // Example, set a desired temperature
                    desiredTemperatures.notifyListeners();
                    addNewWidget(TemperatureControlWidget(
                      name: name,
                      label: label,
                      desiredTemperatures: desiredTemperatures,
                      tempName: name.toLowerCase(),
                      sendCommand: sendcmd,
                    ));
                    break;
                }

                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void pickColor(BuildContext context, String colorName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          Color currentColor = colors[colorName] ??
              Colors.black; // Default to black if not found.

          return AlertDialog(
            title: Text(
                'Pick a color for $colorName'), // Show the color name in the title.
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: currentColor,
                onColorChanged: (Color newColor) {
                  setState(() {
                    // Update the color in the map.
                    colors[colorName] = newColor;

                    // Send command with the updated RGB values.
                    sendcmd("${colorName}R" + newColor.red.toString());
                    sendcmd("${colorName}G" + newColor.green.toString());
                    sendcmd("${colorName}B" + newColor.blue.toString());
                  });
                },
                pickerAreaHeightPercent: 0.8,
                enableAlpha: false, // Disable the alpha slider
                showLabel: false, // Hide HSV, RGB labels if unnecessary
                displayThumbColor: true,
                portraitOnly: true, // Adjust layout for better RGB display
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Done'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Smart Home"),
        backgroundColor: Color.fromARGB(255, 100, 128, 255),
        actions: <Widget>[
          if (isDeleteMode)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  controlWidgets.removeWhere((element) => selectedIndexes
                      .contains(controlWidgets.indexOf(element)));
                  selectedIndexes.clear();
                  isDeleteMode = false;
                });
              },
            ),
          IconButton(
            icon: Icon(isDeleteMode ? Icons.cancel : Icons.more_vert),
            onPressed: () {
              setState(() {
                isDeleteMode = !isDeleteMode;
                selectedIndexes.clear();
              });
            },
          )
        ],
      ),
      body: Container(
        color: Color.fromARGB(255, 61, 61, 61),
        padding: EdgeInsets.all(20),
        child: GridView.count(
          key: ValueKey(controlWidgets.length),
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2,
          children: List.generate(controlWidgets.length, (index) {
            return GestureDetector(
              onTap: () {
                if (isDeleteMode) {
                  setState(() {
                    if (selectedIndexes.contains(index)) {
                      selectedIndexes.remove(index);
                    } else {
                      selectedIndexes.add(index);
                    }
                  });
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: selectedIndexes.contains(index) && isDeleteMode
                      ? Colors.red.withOpacity(0.5)
                      : Color.fromARGB(255, 61, 61, 61),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: controlWidgets[index],
              ),
            );
          }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addWidgetTypePopup(context),
        tooltip: 'Add Widget',
        child: Icon(Icons.add),
      ),
    );
  }
}
