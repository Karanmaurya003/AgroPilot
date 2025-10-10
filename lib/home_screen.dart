import 'package:flutter/material.dart'; 
import 'services/location_service.dart';
import 'services/weather_service.dart';
import 'services/district_mapping.dart';
import 'screens/lab_report_input_screen.dart';
import 'screens/hybrid_input_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _locationName = 'Fetching location...';
  double _temperature = 0.0;
  int _humidity = 0;
  double _rainfall = 0.0;
  bool _isLoading = false;
  String _errorMessage = '';

  // Make district and state part of state
  String district = 'Unknown District';
  String state = 'Unknown State';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      
    });

    try {
      final position = await LocationService().getCurrentLocation();
      final lat = position.latitude;
      final lon = position.longitude;

      // Fetch weather data from backend
      Map<String, dynamic> backendData = {};
      try {
        backendData = await WeatherService().fetchWeather(lat, lon);
      } catch (e) {
        debugPrint('Weather fetch failed: $e');
        backendData = {
          'weather': {'temperature': 0.0, 'humidity': 0, 'rainfall': 0.0},
          'location': {'district': 'Unknown District', 'state': 'Unknown State'}
        };
      }
      debugPrint('Backend response: $backendData');

      // Use backend-provided location directly
      final rawDistrict = backendData['location']?['district'] ?? 'Unknown District';
      state = backendData['location']?['state'] ?? 'Unknown State';
      district = districtMapping[rawDistrict] ?? rawDistrict;

      debugPrint('District: $district, State: $state');

      if (!mounted) return;
      setState(() {
         _locationName = "$district, $state";  
        _rainfall = (backendData['weather']?['rainfall'] as num?)?.toDouble() ?? 0.0;
        _temperature = (backendData['weather']?['temperature'] as num?)?.toDouble() ?? 0.0;
        _humidity = (backendData['weather']?['humidity'] as num?)?.toInt() ?? 0;
      });
    } on Exception catch (e) {
      if (e.toString().contains('permission_denied') ||
          e.toString().contains('deniedForever')) {
        _errorMessage =
            'Location permissions are permanently denied. Please enable them manually in your app settings.';
      } else if (e.toString().contains('services are disabled')) {
        _errorMessage =
            'Location services are disabled. Please enable them manually in your device settings.';
      } else {
        _errorMessage = 'Failed to load data: ${e.toString()}';
      }
      if (!mounted) return;
    } finally {
      // Removed 'return' from finally
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AgroPilot- Your All in One Crop Recommender',
          style: TextStyle(color: Color.fromARGB(255, 17, 17, 17), fontWeight: FontWeight.bold),
          
        ),
        backgroundColor: const Color.fromARGB(255, 239, 126, 5),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Image.asset(
            'assets/images/farm_background.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: const [
                  Color.fromARGB(102, 0, 0, 0),
                  Color.fromARGB(153, 0, 0, 0),
                ],
              ),
            ),
          ),
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white))
              : _errorMessage.isNotEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.redAccent, fontSize: 16),
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Card(
                            color: const Color.fromARGB(204, 255, 255, 255),
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Location:',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[800],
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    _locationName.isEmpty ? 'Fetching details…' : _locationName,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildWeatherIcon(
                                icon: Icons.thermostat_outlined,
                                label: 'Temp',
                                value: '${_temperature.toStringAsFixed(1)}°C',
                                color: Colors.orange,
                              ),
                              _buildWeatherIcon(
                                icon: Icons.water_drop_outlined,
                                label: 'Humidity',
                                value: '$_humidity%',
                                color: Colors.blue,
                              ),
                              _buildWeatherIcon(
                                icon: Icons.cloudy_snowing,
                                label: 'Rain (5-Day)',
                                value: '${_rainfall.toStringAsFixed(1)} mm',
                                color: Colors.indigo,
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          const Spacer(),
                          Center(
                            child: Column(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    if (!mounted) return;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => LabReportScreen(
                                          temperature: _temperature,
                                          humidity: _humidity.toDouble(),
                                          rainfall: _rainfall,
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(255, 125, 229, 7),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 40, vertical: 15),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                  child: const Text(
                                    'I have Soil Test Reports',
                                    style: TextStyle(
                                        fontSize: 16, color: Color.fromARGB(255, 9, 9, 9)),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                ElevatedButton(
                                  onPressed: () {
                                    if (!mounted) return;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => NoLabReportScreen(
                                          district: district,
                                          state: state,
                                          temperature: _temperature,
                                          rainfall: _rainfall,
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(255, 247, 147, 6),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 40, vertical: 15),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                  child: const Text(
                                    'I don\'t have Soil Test Reports',
                                    style: TextStyle(
                                        fontSize: 16, color: Color.fromARGB(255, 15, 15, 15)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(flex: 2),
                        ],
                      ),
                    ),
        ],
      ),
    );
  }

  Widget _buildWeatherIcon({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 40, color: color),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey[300]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
