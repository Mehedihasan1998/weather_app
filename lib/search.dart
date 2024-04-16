import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jiffy/jiffy.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _cityName = TextEditingController();

  Future<void> getWeatherData() async {
    var apiKey = '42bbdcdea226d8b602f1516251c04d45';
    var url = Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?q=${_cityName.text}&appid=$apiKey&units=metric");
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
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: EdgeInsets.all(10),
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/sunset.jpg"), fit: BoxFit.fill),
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
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "City Weather",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Provide the city and see the current weather details of that particular location.",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _cityName,
                style: TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                enabled: true,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              MaterialButton(
                color: Colors.white.withOpacity(0.8),
                onPressed: () {
                  getWeatherData();
                },
                child: Text("Find"),
              ),
              SizedBox(
                height: 20,
              ),
              weatherMap == null
                  ? Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      "City Name",
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              "Today's Date",
                              style: TextStyle(
                                  fontSize: 18, color: Colors.white),
                            ),
                            Text(
                              "Day",
                              style: TextStyle(
                                  fontSize: 18, color: Colors.white),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Image.network(
                              "https://openweathermap.org/img/wn/03d@2x.png",
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                            Text(
                              "T°C",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 25),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              )
                  : Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "${weatherMap!['name']}".toUpperCase(),
                            style: TextStyle(color: Colors.white, fontSize: 25),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    "${Jiffy.parse("${DateTime.now()}").format(pattern: 'MMM do yyyy')}",
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white),
                                  ),
                                  Text(
                                    "${Jiffy.parse("${DateTime.now()}").format(pattern: 'EEEE')}",
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Image.network(
                                    "https://openweathermap.org/img/wn/${weatherMap!['weather'][0]['icon']}@2x.png",
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                  Text(
                                    "${weatherMap!['main']['temp']}°C",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 25),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
