import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:jiffy/jiffy.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  Map<String, dynamic>? weatherMap;
  Map<String, dynamic>? forecastMap;

  getWeatherData() async {
    // Unit Default: Kelvin, Metric: Celsius, Imperial: Fahrenheit
    var weather = await http.get(
      Uri.parse(
          "https://api.openweathermap.org/data/2.5/weather?lat=${position!.latitude}&lon=${position!.longitude}&appid=42bbdcdea226d8b602f1516251c04d45&units=metric"), // Unit Default: Kelvin, Metric: Celsius, Imperial: Fahrenheit
    );
    var forecast = await http.get(
      Uri.parse(
          "https://api.openweathermap.org/data/2.5/forecast?lat=${position!.latitude}&lon=${position!.longitude}&appid=42bbdcdea226d8b602f1516251c04d45&units=metric"), // Unit Default: Kelvin, Metric: Celsius, Imperial: Fahrenheit
    );
    // print("Weather Data: ${weather.body}");
    // print("Weather Data: ${forecast.body}");

    var weatherData = jsonDecode(weather.body);
    var forecastData = jsonDecode(forecast.body);

    setState(() {
      weatherMap = Map<String, dynamic>.from(weatherData);
      forecastMap = Map<String, dynamic>.from(forecastData);
    });
  }

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
        padding: EdgeInsets.all(20),
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/rain.jpg"), fit: BoxFit.fill),
          gradient: LinearGradient(
            colors: [
              Colors.blueGrey,
              // Colors.blueAccent,
              Colors.blue
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: weatherMap != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "${weatherMap!['name']}",
                        style: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${Jiffy.parse("${DateTime.now()}").format(pattern: 'MMM do yyyy')}",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      Text(
                        "${Jiffy.parse("${DateTime.now()}").format(pattern: 'EEEE')}",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        height: 160,
                        decoration: BoxDecoration(
                            color: Colors.white70,
                            // borderRadius: BorderRadius.circular(10),
                            shape: BoxShape.circle),
                        child: Column(
                          children: [
                            Image.network(
                              "https://openweathermap.org/img/wn/${weatherMap!['weather'][0]['icon']}@2x.png",
                              width: double.infinity,
                              height: 110,
                              fit: BoxFit.contain,
                            ),
                            Text(
                              "${weatherMap!['weather'][0]['description']}"
                                  .toUpperCase(),
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 115,
                            decoration: BoxDecoration(
                                color: Colors.white30,
                                borderRadius: BorderRadius.circular(10)
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  "Temp",
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "${weatherMap!['main']['temp']}°C",
                                  style: TextStyle(
                                      fontSize: 25, color: Colors.white,),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 115,
                            decoration: BoxDecoration(
                                color: Colors.white30,
                                borderRadius: BorderRadius.circular(10)
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  "Wind",
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "${weatherMap!['wind']['speed']}m/s",
                                  style: TextStyle(
                                      fontSize: 25, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 115,
                            decoration: BoxDecoration(
                              color: Colors.white30,
                              borderRadius: BorderRadius.circular(10)
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  "Humidity",
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "${weatherMap!['main']['humidity']}%",
                                  style: TextStyle(
                                      fontSize: 25, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Column(
                  //   children: [
                  //     Text("Feels Like: ${weatherMap!['main']['feels_like']}°C"),
                  //
                  //     Text("${weatherMap!['weather'][0]['description']}"),
                  //     Text(
                  //         "Pressure: ${weatherMap!['main']['pressure']} hPa"),
                  //     Text(
                  //         "Sunrise: ${Jiffy.parse("${DateTime.fromMillisecondsSinceEpoch(weatherMap!['sys']['sunrise'] * 1000)}").format(pattern: "hh:mm a")}  ||  Sunset: ${Jiffy.parse("${DateTime.fromMillisecondsSinceEpoch(weatherMap!['sys']['sunset'] * 1000)}").format(pattern: "hh:mm a")}"),
                  //
                  //   ],
                  // ),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      itemCount: forecastMap!.length,
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          width: 200,
                          margin: EdgeInsets.only(right: 12),
                          padding: EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Image.network(
                                width: 80,
                                "https://openweathermap.org/img/wn/${forecastMap!['list'][index]['weather'][0]['icon']}@2x.png",
                                fit: BoxFit.contain,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Text(
                                  //   "${Jiffy.parse("${forecastMap!['list'][index]['dt_txt']}").format(pattern: "EEE")}",
                                  //   style: TextStyle(fontSize: 16),
                                  // ),
                                  Text(
                                    "${Jiffy.parse("${forecastMap!['list'][index]['dt_txt']}").format(pattern: "h:mm a")}",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  // Image.network(
                                  //     "https://openweathermap.org/img/wn/${forecastMap!['list'][index]['weather'][0]['icon']}@2x.png"),

                                  // Text(
                                  //     "Min Temp: ${forecastMap!["list"][index]['main']["temp_min"]}°C"),
                                  //
                                  Text(
                                    "${forecastMap!["list"][index]['main']["temp_max"]}°C",
                                    style: TextStyle(fontSize: 25),
                                  ),

                                  // Text(
                                  //     "${forecastMap!["list"][index]['weather'][0]["description"]}"),
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
                child: CircularProgressIndicator(),
              ),
      )),
    );
  }
}
