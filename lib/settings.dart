import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:jiffy/jiffy.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    position = await Geolocator.getCurrentPosition();
    getWeatherData();
    print(
        "My lat is: ${position!.latitude} My long is: ${position!.longitude}");
  }

  Position? position;

  Future<void> getWeatherData() async {
    var apiKey = '42bbdcdea226d8b602f1516251c04d45';
    var url = Uri.parse(
        "http://api.openweathermap.org/data/2.5/forecast?lat=${position!.latitude}&lon=${position!.longitude}&appid=$apiKey&units=metric");
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        print("Data fetched successfully: ${response.body}");
        var weatherData = jsonDecode(response.body);

        setState(() {
          weatherMap = Map<String, dynamic>.from(weatherData);
        });
      } else {
        print("Error fetching data: ${response.statusCode}");
        print("Response body: ${response.body}");
      }
    } catch (e) {
      print("Exception thrown: $e");
    }
  }

  Map<String, dynamic>? weatherMap;

  @override
  void initState() {
    super.initState();
    determinePosition();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/sunset.jpg"), fit: BoxFit.fill),
          gradient: LinearGradient(
            colors: [
              Colors.blueGrey,
              Colors.blue,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: weatherMap != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "${weatherMap!['city']['name']}",
                    style: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Weather forecast of the next 5 days.",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 10,),
                  Expanded(
                    child: ListView.builder(
                      itemCount: weatherMap!['list'].length,
                      itemBuilder: (context, index) {
                        return Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          height: 260,
                          margin: EdgeInsets.all(8),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: [
                              /// Date, Day
                              Container(
                                height: 50,
                                width: 140,
                                // decoration: BoxDecoration(
                                //   color: Colors.blue,
                                //   borderRadius: BorderRadius.circular(10)
                                // ),
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${Jiffy.parse("${weatherMap!['list'][index]['dt_txt']}").format(pattern: "MMM do yyyy")}",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black),
                                    ),
                                    Text(
                                      "${Jiffy.parse("${weatherMap!['list'][index]['dt_txt']}").format(pattern: "EEEE")}",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      /// Time, Image, description
                                      Container(
                                        height: 175,
                                        width: 140,
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius:
                                                BorderRadius.circular(10),),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              "${Jiffy.parse("${weatherMap!['list'][index]['dt_txt']}").format(pattern: "h:mm a")}",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white),
                                            ),
                                            Image.network(
                                              "https://openweathermap.org/img/wn/${weatherMap!['list'][index]['weather'][0]['icon']}@2x.png",
                                              width: 100,
                                              height: 80,
                                              fit: BoxFit.cover,
                                            ),
                                            Text("${weatherMap!['list'][index]['weather'][0]['description']}", style: TextStyle(color: Colors.white, fontSize: 17,),),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      /// Temp
                                      Container(
                                        height: 100,
                                        width: 180,
                                        // decoration: BoxDecoration(
                                        //   color: Colors.blue,
                                        //   borderRadius: BorderRadius.circular(10)
                                        // ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Text(
                                              "Temp",
                                              style: TextStyle(
                                                  fontSize: 17,
                                                  color: Colors.black),
                                            ),
                                            Text(
                                              "${weatherMap!['list'][index]['main']['temp']}°C",
                                              style: TextStyle(
                                                  fontSize: 40,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),

                                      /// Humidity, Wind
                                      Container(
                                        height: 70,
                                        width: 140,
                                        // decoration: BoxDecoration(
                                        //   color: Colors.blue,
                                        //   borderRadius: BorderRadius.circular(10)
                                        // ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Humidity: ${weatherMap!['list'][index]['main']['humidity']}%",
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text(
                                              "Wind: ${weatherMap!['list'][index]['wind']['speed']}m/s",
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )
            : Center(
                child: Container(
                  padding: EdgeInsets.all(25),
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                  ),
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.blue,
                  ),
                ),
              ),
      ),
    ));
  }
}
