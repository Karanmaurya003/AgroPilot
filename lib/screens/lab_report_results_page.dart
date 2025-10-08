// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'lab_report_detail_screen.dart';

class LabReportResultsPage extends StatefulWidget {
  final List<dynamic> recommendations;
  final Map<String, dynamic> inputData;

  const LabReportResultsPage({
    super.key,
    required this.recommendations,
    required this.inputData,
  });

  @override
  State<LabReportResultsPage> createState() => _LabReportResultsPageState();
}

class _LabReportResultsPageState extends State<LabReportResultsPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Color _getScoreColor(double score) {
    if (score >= 30) return const Color(0xFF66FF66); // Bright green
    if (score >= 20) return const Color(0xFFFFAA00); // Orange
    return const Color(0xFFFF5544); // Red
  }

  Widget _buildCropCard(
      BuildContext context, Map<String, dynamic> crop, int index) {
    final score = crop['confidence_score'] ?? 0.0;
    final cropName = crop['crop'] ?? 'Unknown';
    final emoji = crop['emoji'] ?? '🌾';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LabReportDetailScreen(
              cropName: cropName,
              inputData: widget.inputData,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00D4FF).withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 4),
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: const Color(0xFF00D4FF).withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Index Badge
            Container(
              width: 40,
              height: 40,
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
                    color: const Color(0xFF00D4FF).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Emoji Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF00D4FF).withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00D4FF).withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Crop Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cropName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        size: 16,
                        color: Color(0xFF00D4FF),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Match: ${score.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF00D4FF),
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Score Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _getScoreColor(score),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _getScoreColor(score).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    score.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF00D4FF),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    // Filter out crops with 0 or negative confidence scores
    final validRecommendations = widget.recommendations
        .where((crop) => (crop['confidence_score'] ?? 0.0) > 1)
        .toList();

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
          'Crop Prediction',
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
            image: const AssetImage('assets/images/lab_report_result_page.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: validRecommendations.isEmpty
            ? Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    'No recommendations available',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF1A1A1A),
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section with Gradient
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
                              const Icon(
                                Icons.location_on,
                                color: Colors.white70,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Palghar, Maharashtra',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    Text(
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
                          SizedBox(height: isMobile ? 12 : 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.25),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.eco,
                                  color: Colors.white70,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${validRecommendations.length} Crops Recommended',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Recommended Crops Section
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16 : 24,
                        vertical: isMobile ? 16 : 24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Recommended Crops',
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
                          SizedBox(height: isMobile ? 14 : 18),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: validRecommendations.length,
                            itemBuilder: (context, index) {
                              return _buildCropCard(
                                context,
                                validRecommendations[index],
                                index,
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
}