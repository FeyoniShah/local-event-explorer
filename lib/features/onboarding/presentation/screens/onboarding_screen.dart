import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../routing/app_router.dart';
 
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}
 
class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
 
  final List<Map<String, dynamic>> _pages = [
    {
      'icon': Icons.explore,
      'title': 'Discover Events',
      'subtitle': 'Find exciting events happening near you',
    },
    {
      'icon': Icons.map,
      'title': 'Explore on Map',
      'subtitle': 'See events pinned on an interactive map',
    },
    {
      'icon': Icons.notifications_active,
      'title': 'Never Miss Out',
      'subtitle': 'Get notified 1 hour before events start',
    },
  ];
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(page["icon"] as IconData, size: 100,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(height: 32),
                        Text(page["title"] as String,
                            style: const TextStyle(fontSize: 28,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Text(page["subtitle"] as String,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16,
                                color: Colors.grey)),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == i ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: _currentPage == i
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                ),
              )),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut);
                    } else {
                      context.go(AppRoutes.login);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: Text(_currentPage < _pages.length - 1
                      ? "Next" : "Get Started"),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
