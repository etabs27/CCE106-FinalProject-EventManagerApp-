import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:event_manager_application_finalproject/auth/login.dart'; 

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  late PageController _pageController;
  int _currentPage = 0;

  
  final List<String> _imageAssets = [
    'assets/images/MEETRIX.jpg',
    'assets/images/GridView1.png',
    'assets/images/GridView2.jpg',
    'assets/images/GridView3.png',
  ];

  
  final List<String> _titles = [
    '',
    'Plan Events with Ease',
    'Connect & Engage',
    'Ready to Get Started?',
  ];

  
  final List<String> _descriptions = [
    '',
    'Create, organize, and manage events effortlessly with our intuitive tools',
    'Build memorable experiences and connect with your attendees like never before',
    'Join thousands of event organizers creating unforgettable moments',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_currentPage < _imageAssets.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    } else {
      
      _navigateToLogin();
    }
  }

  void _skipOnboarding() {
    
    _navigateToLogin();
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()), 
    );
  }

  @override
  Widget build(BuildContext context) {
    
    final double oneInchBorder = 96.0;

    return Scaffold(

      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            
            Positioned(
              top: 16,
              right: 16,
              child: TextButton(
                onPressed: _skipOnboarding,
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            PageView(
              controller: _pageController,
              scrollDirection: Axis.horizontal,
              children: List.generate(_imageAssets.length, (index) {
                return Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Stack(
                    children: [
                      
                      if (index == 0)
                        
                        Image.asset(
                          _imageAssets[index],
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.fitWidth,
                          alignment: Alignment.center,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Theme.of(context).colorScheme.surfaceVariant,
                              child: Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                  size: 50,
                                ),
                              ),
                            );
                          },
                        )
                      else
                        
                        Container(
                          margin: EdgeInsets.only(
                            top: oneInchBorder,
                            bottom: oneInchBorder,
                          ),
                          child: Image.asset(
                            _imageAssets[index],
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Theme.of(context).colorScheme.surfaceVariant,
                                child: Center(
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                    size: 50,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      
                      
                      if (index > 0)
                        Container(
                          margin: EdgeInsets.only(
                            top: oneInchBorder,
                            bottom: oneInchBorder,
                          ),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Color.fromRGBO(0, 0, 0, 0.7),
                              ],
                            ),
                          ),
                        ),
                      
                      
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedOpacity(
                              opacity: _currentPage == index ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 500),
                              child: Text(
                                _titles[index],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            AnimatedOpacity(
                              opacity: _currentPage == index ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 700),
                              child: Text(
                                _descriptions[index],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  height: 1.5,
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
            
            
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 100),
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: _imageAssets.length, 
                  effect: ExpandingDotsEffect(
                    spacing: 8,
                    radius: 8,
                    dotWidth: 8,
                    dotHeight: 8,
                    dotColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.6),
                    activeDotColor: Theme.of(context).colorScheme.onPrimary,
                    paintStyle: PaintingStyle.fill,
                  ),
                  onDotClicked: (index) {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.ease,
                    );
                  },
                ),
              ),
            ),
            
            
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32, left: 24, right: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _goToNextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                    ),
                    child: Text(
                      _currentPage == _imageAssets.length - 1 
                          ? 'Get Started' 
                          : 'Continue',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}