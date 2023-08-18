import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather/weather.dart';
import 'package:weatherapp/weatherdata.dart';
import 'package:intl/intl.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WeatherApp(),
    );
  }
}

//weather call

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  Future<WeatherData>? _futureWeather;
  late double lat;
  late double lon;
  String api = '0c4c7beedea591efd7266409f5d852e9';

  int currentPageIndex = 0;

  List<Weather> forecastData = [];

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    PermissionStatus permissionStatus = await Permission.location.request();
    WeatherFactory ws = WeatherFactory(api);
    if (permissionStatus.isGranted) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _futureWeather =
            WeatherData.fetch(api, position.latitude, position.longitude);
      });
      forecastData = await ws.fiveDayForecastByLocation(
          position.latitude, position.longitude);
    } else {
      setState(() {
        "Please provide location permission";
      });
    }
  }

  Widget currentWeather() {
    return Center(
      child: FutureBuilder<WeatherData?>(
        future: _futureWeather,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final weather = snapshot.data!;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  weather.iconUrl,
                  fit: BoxFit.fill,
                  width: 150,
                  height: 150,
                ),
                Text(
                  weather.locationName,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 10),
                Text(
                  DateFormat.yMMMMd('en_US').format(weather.date),
                  style: const TextStyle(fontSize: 20),
                ),
                Text(
                  weather.description,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  '${weather.temperature}°C',
                  style: const TextStyle(fontSize: 30),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          return const CircularProgressIndicator();
        },
      ),
    );
  }

  Widget widgetForcast() {
    return Center(
      child: ListView.separated(
        itemCount: forecastData.length,
        itemBuilder: (context, index) {
          return ListTile(
              // DateFormat('yyyy-MM-dd – kk:mm').format(forecastData[index].date);item!.date as DateTime
              title: Text(DateFormat('EEEE yyyy-MM-dd – kk:mm')
                  .format(forecastData[index].date as DateTime)),
              subtitle: Text(
                '${forecastData[index].weatherMain} - ${forecastData[index].temperature}',
              ),
              leading: Image.network(
                  'https://openweathermap.org/img/wn/${forecastData[index].weatherIcon}.png'),
              tileColor: const Color.fromARGB(255, 99, 168, 193),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)));
        },
        separatorBuilder: (context, index) {
          return const Divider();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      backgroundColor: Colors.greenAccent,
      appBar: AppBar(
        title: const Text('Weather App'),
        backgroundColor: const Color.fromARGB(255, 57, 61, 59),
      ),
      bottomNavigationBar: NavigationBar(
        animationDuration: const Duration(milliseconds: 1000),
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Current',
          ),
          NavigationDestination(
            icon: Icon(Icons.leaderboard),
            label: 'Forcast',
          ),
          NavigationDestination(
            icon: Icon(Icons.info),
            label: 'About',
          ),
        ],
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
      ),
      body: <Widget>[
        currentWeather(),
        widgetForcast(),
        const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Project Weather App',
                style: TextStyle(fontSize: 30),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'This app is an app that is developed for the course 1DV535 at Linneaus University using flutter and OpneWeatherMap API.',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'Developed by Selomie Kindu Ejigu',
                style: TextStyle(fontSize: 20),
              )
            ],
          ),
        )
      ][currentPageIndex],
    ));
  }
}
