// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'lab_report_results_page.dart';

class LabReportScreen extends StatefulWidget {
  final double temperature;
  final double humidity;
  final double rainfall;

  const LabReportScreen({
    super.key,
    required this.temperature,
    required this.humidity,
    required this.rainfall,
  });

  @override
  State<LabReportScreen> createState() => _LabReportScreenState();
}

class _LabReportScreenState extends State<LabReportScreen>
    with TickerProviderStateMixin {
  double n = 50;
  double p = 50;
  double k = 50;
  double ph = 6.5;

  bool _isLoading = false;
  List<dynamic> topCrops = [];

  late AnimationController _gradientController;
  late AnimationController _buttonController;

  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();

    _buttonController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  Future<void> fetchTopCrops() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/predict_lab_report'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'N': n,
          'P': p,
          'K': k,
          'ph': ph,
          'temperature': widget.temperature,
          'humidity': widget.humidity,
          'rainfall': widget.rainfall,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (mounted) {
          if (data['recommendations'] is List) {
            topCrops = data['recommendations'];

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LabReportResultsPage(
                  recommendations: topCrops,
                  inputData: {
                    'N': n,
                    'P': p,
                    'K': k,
                    'ph': ph,
                    'temperature': widget.temperature,
                    'humidity': widget.humidity,
                    'rainfall': widget.rainfall,
                  },
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Unexpected response from server')),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to fetch crops')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget buildModernSlider(
    String label,
    double value,
    Function(double) onChanged, {
    double min = 0,
    double max = 100,
    String unit = '',
    IconData? icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D4FF).withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 4),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF00D4FF).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: const Color(0xFF00D4FF), size: 20),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF00D4FF).withOpacity(0.15),
                      const Color(0xFF66FF66).withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${value.toStringAsFixed(1)}$unit',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00D4FF),
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: const Color(0xFF00D4FF),
              inactiveTrackColor: Colors.grey.shade300,
              thumbColor: Colors.white,
              overlayColor: const Color(0xFF00D4FF).withOpacity(0.2),
              trackHeight: 5,
              thumbShape: RoundSliderThumbShape(
                enabledThumbRadius: 8,
                elevation: 4,
              ),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1A3A4E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Lab Report Input',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/lab_report_input_page.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Card with Environmental Data
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                margin: EdgeInsets.all(isMobile ? 12 : 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF1A6B3E).withOpacity(0.9),
                      const Color(0xFF2D9B6E).withOpacity(0.9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF00FF88).withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00FF88).withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: 3,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: Colors.white70, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Palghar, Maharashtra',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const Text(
                                'RABI Season',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isMobile ? 16 : 20),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return isMobile
                            ? Column(
                                children: [
                                  _buildWeatherCard(
                                    Icons.thermostat,
                                    '${widget.temperature.toStringAsFixed(1)}°C',
                                    'Temperature',
                                    Colors.orange,
                                  ),
                                  const SizedBox(height: 10),
                                  _buildWeatherCard(
                                    Icons.water_drop,
                                    '${widget.rainfall.toStringAsFixed(1)} mm',
                                    'Rainfall',
                                    Colors.blue,
                                  ),
                                  const SizedBox(height: 10),
                                  _buildWeatherCard(
                                    Icons.opacity,
                                    '${widget.humidity.toStringAsFixed(1)}%',
                                    'Humidity',
                                    Colors.cyan,
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildWeatherCard(
                                    Icons.thermostat,
                                    '${widget.temperature.toStringAsFixed(1)}°C',
                                    'Temperature',
                                    Colors.orange,
                                  ),
                                  _buildWeatherCard(
                                    Icons.water_drop,
                                    '${widget.rainfall.toStringAsFixed(1)} mm',
                                    'Rainfall',
                                    Colors.blue,
                                  ),
                                  _buildWeatherCard(
                                    Icons.opacity,
                                    '${widget.humidity.toStringAsFixed(1)}%',
                                    'Humidity',
                                    Colors.cyan,
                                  ),
                                ],
                              );
                      },
                    ),
                  ],
                ),
              ),

              // Soil Parameters Section
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 24,
                  vertical: isMobile ? 16 : 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Heading with better contrast
                    Container(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: const Text(
                        'Soil Nutrient Levels',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFFFFF),
                          fontFamily: 'Poppins',
                          shadows: [
                            Shadow(
                              offset: Offset(0, 2),
                              blurRadius: 4,
                              color: Color(0xFF00D4FF),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: isMobile ? 14 : 18),
                    isMobile
                        ? Column(
                            children: [
                              buildModernSlider(
                                'Nitrogen (N)',
                                n,
                                (v) => setState(() => n = v),
                                icon: Icons.eco,
                              ),
                              buildModernSlider(
                                'Phosphorus (P)',
                                p,
                                (v) => setState(() => p = v),
                                icon: Icons.grain,
                              ),
                              buildModernSlider(
                                'Potassium (K)',
                                k,
                                (v) => setState(() => k = v),
                                icon: Icons.spa,
                              ),
                              buildModernSlider(
                                'pH Level',
                                ph,
                                (v) => setState(() => ph = v),
                                min: 3.0,
                                max: 9.0,
                                icon: Icons.science,
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: buildModernSlider(
                                      'Nitrogen (N)',
                                      n,
                                      (v) => setState(() => n = v),
                                      icon: Icons.eco,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: buildModernSlider(
                                      'Phosphorus (P)',
                                      p,
                                      (v) => setState(() => p = v),
                                      icon: Icons.grain,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: buildModernSlider(
                                      'Potassium (K)',
                                      k,
                                      (v) => setState(() => k = v),
                                      icon: Icons.spa,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: buildModernSlider(
                                      'pH Level',
                                      ph,
                                      (v) => setState(() => ph = v),
                                      min: 3.0,
                                      max: 9.0,
                                      icon: Icons.science,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                    SizedBox(height: isMobile ? 16 : 24),
                    // Submit Button with glow effect
                    AnimatedBuilder(
                      animation: _buttonController,
                      builder: (context, child) {
                        double glowOpacity = 0.3 + (_buttonController.value * 0.3);
                        return SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFF00D4FF),
                                  const Color(0xFF66FF66),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00D4FF)
                                      .withOpacity(glowOpacity),
                                  blurRadius: 20,
                                  offset: const Offset(0, 0),
                                  spreadRadius: 4,
                                ),
                                BoxShadow(
                                  color: const Color(0xFF66FF66)
                                      .withOpacity(glowOpacity * 0.6),
                                  blurRadius: 15,
                                  offset: const Offset(0, 0),
                                  spreadRadius: 2,
                                ),
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : fetchTopCrops,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Text(
                                      'Get Crop Recommendations',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                            ),
                          ),
                        );
                      },
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

  Widget _buildWeatherCard(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.25),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00D4FF).withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 11,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}