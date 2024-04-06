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
    var weather = await http.get(
      Uri.parse(
          "https://api.openweathermap.org/data/2.5/weather?lat=${position!.latitude}&lon=${position!.longitude}&appid=42bbdcdea226d8b602f1516251c04d45&units=metric"),
    );
    var forecast = await http.get(
      Uri.parse(
          "https://api.openweathermap.org/data/2.5/forecast?lat=${position!.latitude}&lon=${position!.longitude}&appid=42bbdcdea226d8b602f1516251c04d45&units=metric"),
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
        body: weatherMap != null
            ? Container(
                padding: EdgeInsets.all(20),
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "${Jiffy.parse("${DateTime.now()}").format(pattern: 'MMM do yyyy')}",
                          ),
                          Text("${weatherMap!['name']}"),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Image.network(
                            "https://openweathermap.org/img/wn/${weatherMap!['weather'][0]['icon']}@2x.png"),
                        Text(
                          "${weatherMap!['main']['temp']}°C",
                          style: TextStyle(fontSize: 35),
                        ),
                        Text("Feels Like: ${weatherMap!['main']['feels_like']}"),
                        Text("${weatherMap!['weather'][0]['description']}"),
                      ],
                    ),

                    Column(
                      children: [
                        Text(
                            "Humidity: ${weatherMap!['main']['humidity']}  ||  Pressure: ${weatherMap!['main']['pressure']}"),
                        Text(
                            "Sunrise: ${Jiffy.parse("${DateTime.fromMillisecondsSinceEpoch(weatherMap!['sys']['sunrise'] * 1000)}").format(pattern: "hh:mm a")}  ||  Sunset: ${Jiffy.parse("${DateTime.fromMillisecondsSinceEpoch(weatherMap!['sys']['sunset'] * 1000)}").format(pattern: "hh:mm a")}"),
                      ],
                    ),


                    SizedBox(
                      height: 250,
                      child: ListView.builder(
                        itemCount: forecastMap!.length,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index){
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              width: 150,
                              margin: EdgeInsets.only(right: 12),
                              padding: EdgeInsets.all(8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("${Jiffy.parse("${forecastMap!['list'][index]['dt_txt']}").format(pattern: "EEE h:mm")}"),
                                  Image.network(
                                      "https://openweathermap.org/img/wn/${forecastMap!['list'][index]['weather'][0]['icon']}@2x.png"),
                                  Text("Min Temp: ${forecastMap!["list"][index]['main']["temp_min"]}°C"),
                                  Text("Max Temp: ${forecastMap!["list"][index]['main']["temp_max"]}°C"),
                                  Text("${forecastMap!["list"][index]['weather'][0]["description"]}"),
                                ],
                              ),
                            );
                          },
                      ),
                    ),
                  ],
                ),
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }
}