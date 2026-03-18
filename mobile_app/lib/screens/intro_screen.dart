import 'package:flutter/material.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _introPages = [
    {
      'title': 'Welcome to Ambient AI Scribe',
      'description': 'Your intelligent medical consultation assistant that transforms spoken consultations into structured clinical documentation.',
      'image': '🏥',
    },
    {
      'title': 'Live Transcription',
      'description': 'Real-time speech-to-text conversion powered by advanced AI technology for accurate medical documentation.',
      'image': '🎙️',
    },
    {
      'title': 'Clinical Intelligence',
      'description': 'Automatically extracts SOAP notes and generates FHIR-compliant medical records.',
      'image': '🧠',
    },
    {
      'title': 'Get Started',
      'description': 'Begin your journey to smarter, faster clinical documentation.',
      'image': '✨',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _introPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipIntro() {
    _pageController.animateToPage(
      _introPages.length - 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _introPages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_introPages[index]);
                },
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(Map<String, String> page) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            page['image']!,
            style: const TextStyle(fontSize: 120),
          ),
          const SizedBox(height: 40),
          Text(
            page['title']!,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            page['description']!,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: _currentPage > 0 ? () => _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ) : null,
            child: Text(
              'Skip',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Row(
            children: List.generate(
              _introPages.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 8),
                height: 8,
                width: _currentPage == index ? 24 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index ? Colors.blue[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _currentPage == _introPages.length - 1 
                ? () => Navigator.pushReplacementNamed(context, '/auth')
                : _nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              _currentPage == _introPages.length - 1 ? 'Get Started' : 'Next',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
