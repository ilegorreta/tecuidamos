import 'package:flutter/material.dart';
import 'package:tecuidamos/services/location.dart';
import 'package:tecuidamos/services/networking.dart';

const apiKey = '7078f2c1ff8257d96035e021179a3c0f';
const openWeatherMapURL = 'http://api.openweathermap.org/data/2.5/weather';

class WeatherModel {
  TimeOfDay time = TimeOfDay.now();

  Future<dynamic> getLocationWeather() async {
    Location location = Location();
    await location.getCurrentLocationLow();
    NetworkHelper networkHelper = NetworkHelper(
        '$openWeatherMapURL?lat=${location.latitude}&lon=${location.longitude}&appid=$apiKey&units=metric');

    var weatherData = await networkHelper.getData();
    return weatherData;
  }

  String getWeatherIcon(int condition) {
    if (condition < 300) {
      return '🌩';
    } else if (condition < 400) {
      return '🌧';
    } else if (condition < 600) {
      return '☔️';
    } else if (condition < 700) {
      return '☃️';
    } else if (condition < 800) {
      return '🌫';
    } else if (condition == 800) {
      if (time.hour > 7 && time.hour < 19) {
        return '☀️';
      } else {
        return '🌙️';
      }
    } else if (condition <= 804) {
      return '☁️';
    } else {
      return '🤷‍';
    }
  }

  String getMessage(int temp) {
    if (temp > 25) {
      return 'Hace calorcito. ¡No olvides mantenerte hidratado! 💦';
    } else if (temp > 15) {
      if (time.hour > 7 && time.hour < 19) {
        return '¡Aprovecha este gran clima! 🙌';
      } else {
        return '¡Que disfrutes tu noche! 🙌';
      }
    } else if (temp < 10) {
      return 'Hace frío, deberías taparte 🧣 🧤';
    } else {
      return 'Deberías llevar algo para taparte 🧥';
    }
  }
}
