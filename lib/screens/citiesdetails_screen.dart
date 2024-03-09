import 'package:flutter/material.dart';
import 'package:weather/weather.dart';

class CityDetailsScreen extends StatelessWidget {
  final String cityName;
  final Weather? weather;

  const CityDetailsScreen({Key? key, required this.cityName, required this.weather}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Détails",
        style: TextStyle(fontSize: 30),),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              cityName,
              style: TextStyle(fontSize: 30),
            ),
            SizedBox(height: 20),
            Text(
              "Température: ${weather?.temperature?.celsius?.toStringAsFixed(0)}° C",
              style: TextStyle(fontSize: 30),
            ),
            SizedBox(height: 20),
            Text(
              "Description: ${weather?.weatherDescription}",
              style: TextStyle(fontSize: 30),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Retour à la page précédente
              },
              child: Text("Retour",
              style: TextStyle(fontSize: 30),),

            ),
          ],
        ),
      ),
    );
  }
}
