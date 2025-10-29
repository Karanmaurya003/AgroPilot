// ignore_for_file: avoid_print, sized_box_for_whitespace, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LabReportDetailScreen extends StatefulWidget {
  final String cropName;
  final Map<String, dynamic> inputData;

  const LabReportDetailScreen({
    super.key,
    required this.cropName,
    required this.inputData,
  });

  @override
  State<LabReportDetailScreen> createState() => _LabReportDetailScreenState();
}

// ======= NEW THEME COLORS =======
const Color primaryDark = Color(0xFF001F3F); // Deep navy
const Color emeraldAccent = Color(0xFF00C853); // Emerald green
const Color accentCyan = Color(0xFF00E5FF); // Electric cyan
const Color warningOrange = Color(0xFFFF7043); // Vibrant orange
const Color textLight = Color(0xFFFFFFFF); // Pure white
const Color textSubtle = Color(0xFFB0BEC5); // Soft gray

class _LabReportDetailScreenState extends State<LabReportDetailScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _cropDetails;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCropDetails();
  }

  Future<void> _fetchCropDetails() async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/get_crop_details'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'N': widget.inputData['N'],
          'P': widget.inputData['P'],
          'K': widget.inputData['K'],
          'ph': widget.inputData['ph'],
          'temperature': widget.inputData['temperature'],
          'humidity': widget.inputData['humidity'],
          'rainfall': widget.inputData['rainfall'],
          'crop_name': widget.cropName,
        }),
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          if (data.containsKey('error')) {
            _error = data['error'];
          } else {
            _cropDetails = data;
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Server error: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Connection error: $e';
        _isLoading = false;
      });
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return emeraldAccent;
    if (score >= 60) return accentCyan;
    if (score >= 40) return warningOrange;
    return Colors.redAccent;
  }

  String _getMatchLabel(double score) {
    if (score >= 80) return 'Excellent Match';
    if (score >= 60) return 'Good Match';
    if (score >= 40) return 'Fair Match';
    return 'Low Match';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingOrErrorScreen(
          isError: false, message: 'Loading Crop Analysis...');
    }
    if (_error != null) {
      return _buildLoadingOrErrorScreen(isError: true, message: _error!);
    }

    final score = _cropDetails!['confidence_score'] ?? 0.0;
    final cropName = _cropDetails!['crop'] ?? 'Unknown';
    final emoji = _cropDetails!['emoji'] ?? '🌾';
    final positiveContributions =
        List<String>.from(_cropDetails!['positive_contributions'] ?? []);
    final negativeContributions =
        List<String>.from(_cropDetails!['negative_contributions'] ?? []);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryDark, emeraldAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Crop Analysis',
          style: TextStyle(
            color: textLight,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: textLight),
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: const Color(0xFF0D1117),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 100, 16, 32),
        child: Column(
          children: [
            _buildHeaderWithScore(cropName, emoji, score),
            const SizedBox(height: 32),
            _buildFeatureAnalysisCard(
                positiveContributions, negativeContributions),
            const SizedBox(height: 40),
            _buildGetRecommendationButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOrErrorScreen(
      {required bool isError, required String message}) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryDark, emeraldAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Crop Analysis',
          style: TextStyle(
            color: textLight,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: textLight),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isError)
              const CircularProgressIndicator(color: emeraldAccent)
            else
              const Icon(Icons.error_outline, color: warningOrange, size: 60),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: isError ? warningOrange : textSubtle,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: emeraldAccent.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
Widget _buildHeaderWithScore(String cropName, String emoji, double score) {
  return _buildCard(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Section – Crop Info
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [emeraldAccent, accentCyan],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 45)),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  cropName.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textLight,
                    letterSpacing: 1.1,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: emeraldAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Text(
                    'Recommended Based on the Lab Report',
                    style: TextStyle(
                      color: accentCyan,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 24),

          // Right Section – Confidence Score
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Confidence Score',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textLight,
                  ),
                ),
                const SizedBox(height: 16),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: score / 100,
                        strokeWidth: 9,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getScoreColor(score),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          score.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: _getScoreColor(score),
                          ),
                        ),
                        const Text(
                          'Score',
                          style: TextStyle(
                            fontSize: 14,
                            color: textSubtle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getScoreColor(score).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getMatchLabel(score),
                    style: TextStyle(
                      color: _getScoreColor(score),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}


  Widget _buildFeatureAnalysisCard(
      List<String> positiveContributions, List<String> negativeContributions) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Feature Analysis',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textLight,
            ),
          ),
          const SizedBox(height: 20),
          if (positiveContributions.isNotEmpty) ...[
            const Text(
              'Factors That Lead To Positive Prediction',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: emeraldAccent,
              ),
            ),
            const SizedBox(height: 12),
            ...positiveContributions.map((c) => _buildFeatureBar(c, true)),
          ],
          if (positiveContributions.isNotEmpty &&
              negativeContributions.isNotEmpty)
            const SizedBox(height: 20),
          if (negativeContributions.isNotEmpty) ...[
            const Text(
              'Factor That Lead To Negative Prediction',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: warningOrange,
              ),
            ),
            const SizedBox(height: 12),
            ...negativeContributions.map((c) => _buildFeatureBar(c, false)),
          ],
        ],
      ),
    );
  }

  Widget _buildFeatureBar(String feature, bool isPositive) {
    final value = feature.contains('(')
        ? feature.split('(')[1].replaceAll(')', '')
        : '';
    final name = feature.split(' (')[0];
    final color = isPositive ? emeraldAccent : warningOrange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textLight,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Icon(
            isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            color: color,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildGetRecommendationButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryDark, emeraldAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: emeraldAccent.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 5),
          ),
        ],
      ),
    );
  }
}
