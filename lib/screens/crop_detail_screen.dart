// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class CropDetailScreen extends StatelessWidget {
  final Map<String, dynamic> crop;
  final String district;
  final String state;
  final double temperature;
  final double rainfall;
  final String season;

  const CropDetailScreen({
    super.key,
    required this.crop,
    required this.district,
    required this.state,
    required this.temperature,
    required this.rainfall,
    required this.season,
  });

  @override
  Widget build(BuildContext context) {
    final score = (crop['final_score'] ?? 0.0).toDouble();
    final explanation = crop['explanation'] ?? 'No explanation available.';

    final mq = MediaQuery.of(context);
    final width = mq.size.width;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'Crop Analysis',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              width: double.infinity,
              child: TabBar(
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withOpacity(0.2),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Features'),
                  Tab(text: 'Environment'),
                ],
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1B5E20),
                    Color(0xFF2E7D32),
                    Color(0xFF388E3C),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    _HeaderCard(crop: crop, season: season),
                    const SizedBox(height: 12),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildOverviewTab(score, explanation, width),
                          _buildFeatureTab(temperature, rainfall, season),
                          _buildEnvironmentTab(district, state, temperature, rainfall, season),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(double score, String explanation, double width) {
    if (width > 800) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _ConfidenceCard(score: score)),
          const SizedBox(width: 12),
          Expanded(child: _ExplanationCard(explanation: explanation)),
        ],
      );
    } else {
      return SingleChildScrollView(
        child: Column(
          children: [
            _ConfidenceCard(score: score),
            const SizedBox(height: 12),
            _ExplanationCard(explanation: explanation),
          ],
        ),
      );
    }
  }

  Widget _buildFeatureTab(double temperature, double rainfall, String season) {
    return SingleChildScrollView(
      child: _FeatureContributionsCard(
        temperature: temperature,
        rainfall: rainfall,
        season: season,
      ),
    );
  }

  Widget _buildEnvironmentTab(String district, String state, double temperature, double rainfall, String season) {
    return SingleChildScrollView(
      child: _EnvironmentCard(
        district: district,
        state: state,
        temperature: temperature,
        rainfall: rainfall,
        season: season,
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.15),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
  );
}

class _HeaderCard extends StatelessWidget {
  final Map<String, dynamic> crop;
  final String season;
  const _HeaderCard({
    required this.crop,
    required this.season,
  });

  @override
  Widget build(BuildContext context) {
    final emoji = crop['emoji'] ?? '🌱';
    final name = (crop['crop'] ?? 'Unknown').toString().toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8E9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 40)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Recommended for $season',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfidenceCard extends StatelessWidget {
  final double score;
  const _ConfidenceCard({required this.score});

  Color _getScoreColor(double percentage) {
    if (percentage >= 80) return const Color(0xFF2E7D32);
    if (percentage >= 60) return const Color(0xFF558B2F);
    if (percentage >= 40) return const Color(0xFFF57C00);
    return const Color(0xFFD84315);
  }

  @override
  Widget build(BuildContext context) {
    final percentage = score.clamp(0.0, 100.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFB74D), Color(0xFFFF9800)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.analytics_outlined, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Confidence Score',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 130,
                  height: 130,
                  child: CircularProgressIndicator(
                    value: percentage / 100,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor(percentage)),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      score.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: _getScoreColor(percentage),
                      ),
                    ),
                    const Text(
                      'Score',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _ScoreIndicator(percentage: percentage),
        ],
      ),
    );
  }
}

class _ScoreIndicator extends StatelessWidget {
  final double percentage;
  const _ScoreIndicator({required this.percentage});

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;

    if (percentage >= 80) {
      label = 'Excellent Match';
      color = const Color(0xFF2E7D32);
    } else if (percentage >= 60) {
      label = 'Good Match';
      color = const Color(0xFF558B2F);
    } else if (percentage >= 40) {
      label = 'Fair Match';
      color = const Color(0xFFF57C00);
    } else {
      label = 'Low Match';
      color = const Color(0xFFD84315);
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExplanationCard extends StatelessWidget {
  final String explanation;
  const _ExplanationCard({required this.explanation});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.lightbulb_outline, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Why This Crop?',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            explanation,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF424242),
              height: 1.6,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureContributionsCard extends StatelessWidget {
  final double temperature;
  final double rainfall;
  final String season;

  const _FeatureContributionsCard({
    required this.temperature,
    required this.rainfall,
    required this.season,
  });

  @override
  Widget build(BuildContext context) {
    // Dummy data for features
    final features = [
      {'name': 'Temperature', 'contribution': 0.85, 'isPositive': true, 'value': '${temperature.toStringAsFixed(1)}°C'},
      {'name': 'Rainfall', 'contribution': 0.70, 'isPositive': true, 'value': '${rainfall.toStringAsFixed(1)} mm'},
      {'name': 'Season', 'contribution': 0.90, 'isPositive': true, 'value': season},
      {'name': 'Historical Yield', 'contribution': 0.75, 'isPositive': true, 'value': 'High'},
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFAB47BC), Color(0xFF8E24AA)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.insights, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Feature Contributions',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...features.map((f) {
            return _FeatureBarRow(
              name: f['name'] as String,
              contribution: f['contribution'] as double,
              isPositive: f['isPositive'] as bool,
              value: f['value']?.toString() ?? '',
            );
          }),
        ],
      ),
    );
  }
}

class _FeatureBarRow extends StatelessWidget {
  final String name;
  final double contribution;
  final bool isPositive;
  final String value;

  const _FeatureBarRow({
    required this.name,
    required this.contribution,
    required this.isPositive,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final color = isPositive ? const Color(0xFF2E7D32) : const Color(0xFFD84315);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B5E20),
                ),
              ),
              Text(
                '${(contribution * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: contribution,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isPositive
                              ? [const Color(0xFF66BB6A), const Color(0xFF2E7D32)]
                              : [const Color(0xFFEF5350), const Color(0xFFD84315)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 70,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF424242),
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EnvironmentCard extends StatelessWidget {
  final String district;
  final String state;
  final double temperature;
  final double rainfall;
  final String season;

  const _EnvironmentCard({
    required this.district,
    required this.state,
    required this.temperature,
    required this.rainfall,
    required this.season,
  });

  @override
  Widget build(BuildContext context) {
    final rows = [
      {'icon': Icons.location_on, 'label': 'Location', 'value': '$district, $state', 'color': const Color(0xFF1E88E5)},
      {'icon': Icons.thermostat, 'label': 'Temperature', 'value': '${temperature.toStringAsFixed(1)}°C', 'color': const Color(0xFFFF6F00)},
      {'icon': Icons.water_drop, 'label': 'Rainfall', 'value': '${rainfall.toStringAsFixed(1)} mm', 'color': const Color(0xFF0288D1)},
      {'icon': Icons.calendar_today, 'label': 'Season', 'value': season.toUpperCase(), 'color': const Color(0xFF2E7D32)},
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF26A69A), Color(0xFF00897B)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.eco, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Environmental Factors',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...rows.map((r) => _EnvRow(
            icon: r['icon'] as IconData,
            label: r['label'] as String,
            value: r['value'] as String,
            color: r['color'] as Color,
          )),
        ],
      ),
    );
  }
}

class _EnvRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _EnvRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.2), width: 1),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}