import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'dart:async';
import 'package:exam_project/screens/citiesdetails_screen.dart';
import 'package:weather/weather.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  late StreamController<String> _messageController;
  late Stream<String> _messageStream;
  late Timer _timer;
  int _messageIndex = 0;
  bool _isCompleted = false;
  double _progress = 0.0;
  bool _showWeather = false;
  final WeatherFactory _wf = WeatherFactory("abb5b9938f83e05d9d8e3fe54c2d2e74");
  Map<String, Weather?> _weathers = {};
  List<String> _cityNames = ['Grasse', 'Paris', 'Nantes', 'Bordeaux', 'Lyon'];
  int _currentCityIndex = 0;

  @override
  void initState() {
    super.initState();

    _messageController = StreamController<String>();
    _messageStream = _messageController.stream;

    _startProgress();
  }

  void _startProgress() {
    const double durationInSeconds = 60;
    const double updateInterval = 0.1;
    final int totalSteps = (durationInSeconds / updateInterval).ceil();
    int currentStep = 0;

    _timer = Timer.periodic(Duration(milliseconds: (updateInterval * 1000).toInt()), (timer) {
      if (currentStep < totalSteps && mounted) {
        setState(() {
          _progress = currentStep / totalSteps;
          currentStep++;
        });

        if (_progress < 1.0 && (currentStep % 36 == 0)) {
          // Envoyer un message toutes les 6 secondes
          switch (_messageIndex) {
            case 0:
              _messageController.add("Nous téléchargeons les données…");
              break;
            case 1:
              _messageController.add("C’est presque fini…");
              break;
            case 2:
              _messageController.add("Plus que quelques secondes avant d’avoir le résultat…");
              break;
          }
          _messageIndex = (_messageIndex + 1) % 3;
        }
      } else {
        if (mounted) {
          setState(() {
            _progress = 1.0;
            _isCompleted = true;
          });
          _timer.cancel();
          _showWeather =
          true; // Afficher les informations météorologiques une fois la jauge complète
        }
      }
    });
    _messageIndex = 0;

    // Appeler l'API météo pour chaque ville toutes les 10 secondes
    Timer.periodic(Duration(seconds: 10), (timer) {
      _wf.currentWeatherByCityName(_cityNames[_currentCityIndex]).then((w) {
        setState(() {
          _weathers[_cityNames[_currentCityIndex]] = w;
          _currentCityIndex = (_currentCityIndex + 1) % _cityNames.length;
        });
      });
    });
  }

  @override
  void dispose() {
    _messageController.close();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "LA METEO",
          style: TextStyle(
            fontSize: 28, // Taille de la police
            fontWeight: FontWeight.bold, // Poids de la police (en gras)
            fontFamily: 'Arial', // Facultatif: spécifie la police
          ),
        ),
        centerTitle: true,
      ),
    body: Container(
    decoration: const BoxDecoration(
    image: DecorationImage(
    image: AssetImage("assets/images/bbb.jpg"),
      opacity: 0.4,// Chemin de votre image
    fit: BoxFit.cover, // Ajustement de l'image
    ),
    ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Afficher les informations météorologiques uniquement si _showWeather est vrai
            _showWeather ? _buildWeatherUI() : Container(),

            Padding(
              padding: const EdgeInsets.all(10.0),
              child: _progress < 1.0 ? _buildProgressIndicator() : _buildRestartButton(),
            ),

            const SizedBox(height: 20),

            StreamBuilder<String>(
              stream: _messageStream,
              builder: (context, snapshot) {
                if (!_isCompleted && snapshot.hasData) {
                  return Text(
                    snapshot.data!,
                    style: const TextStyle(fontSize: 24),
                  );
                } else {
                  return Container();
                }
              },
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: LinearPercentIndicator(
            width: MediaQuery.of(context).size.width - 30,
            animation: false,
            lineHeight: 50.0,
            percent: _progress,
            center: Text(
              "${(_progress * 100).toInt()}%",
              style: const TextStyle(fontSize: 27.0),
            ),
            linearStrokeCap: LinearStrokeCap.roundAll,
            progressColor: Colors.pink,
            barRadius: const Radius.circular(40.0),
            padding: const EdgeInsets.only(right: 0.0),
          ),
        ),
      ],
    );
  }

  Widget _buildRestartButton() {
    return ElevatedButton(
      onPressed: _restartProgress,
      style: ElevatedButton.styleFrom(
        primary: Colors.blueGrey, // Couleur de fond du bouton
      ),
      child: const Text("Recommencer",
      style: TextStyle(fontSize: 30, color: Colors.black87),),
    );
  }

  void _restartProgress() {
    _messageIndex = 0; // Réinitialise l'index des messages
    _messageController.add(""); // Efface le dernier message ajouté

    // Réinitialise la progression et démarre le processus à nouveau
    setState(() {
      _progress = 0.0;
      _isCompleted = false;
      _showWeather = false;
      _weathers.clear();
    });
    _startProgress();
  }

  Widget _buildWeatherUI() {
    return SingleChildScrollView(
      child: DataTable(
        dataRowHeight: 100, // Ajustez la hauteur de la ligne
        columnSpacing: 17.0,
        columns: const [
          DataColumn(label: Text('Ville', style: TextStyle(fontSize: 20, fontFamily: 'Arial',fontWeight: FontWeight.bold,))),
          DataColumn(label: Text('Temp', style: TextStyle(fontSize: 20, fontFamily: 'Arial',fontWeight: FontWeight.bold,))),
          DataColumn(label: Text('Couv.Nuageuse', style: TextStyle(fontSize: 20, fontFamily: 'Arial',fontWeight: FontWeight.bold,))),
        ],
        rows: _cityNames.map((city) {
          return DataRow(
            onSelectChanged: (_) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CityDetailsScreen(cityName: city, weather: _weathers[city]),
                ),
              );
            },
            cells: [
              DataCell(Text(city, style: const TextStyle(fontSize: 19, fontFamily: 'Arial',fontWeight: FontWeight.bold))),
              DataCell(Text("${_weathers[city]?.temperature?.celsius?.toStringAsFixed(0)}° C", style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold,fontFamily: 'Arial'))),
              DataCell(Column(
                children: [
                  Text(_weathers[city]?.weatherDescription ?? "", style: const TextStyle(fontSize: 18, fontFamily: 'Arial',fontWeight: FontWeight.bold)),
                  _weathers[city] != null
                      ? Image.network(
                    "http://openweathermap.org/img/wn/${_weathers[city]?.weatherIcon}@4x.png",
                    width: 50,
                    height: 50,
                  )
                      : Container(),
                ],
              )),
            ],
          );
        }).toList(),
      ),
    );
  }
}
