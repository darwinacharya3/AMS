import 'package:flutter/material.dart';
// import 'dart:math' as math;
import 'package:ems/core/app_colors.dart';
import 'package:ems/core/app_text_styles.dart';
import '../../data/models/event_model.dart';
import 'package:ems/screens/AMS/login_in/login_screen.dart';
import 'package:ems/screens/extratech-oval/login/login_screen.dart';
// import 'package:ems/screens/extratech-oval/membership/membership_card_oval_screen.dart';

/// Professional responsive breakpoints following Material Design guidelines
class ResponsiveBreakpoints {
  static const double mobile = 600.0;
  static const double tablet = 840.0;
  static const double desktop = 1200.0;
  static const double largeDesktop = 1600.0;
}

/// Industry-standard responsive design system
class ResponsiveDesignSystem {
  final Size screenSize;
  final double width;
  final double height;
  final double devicePixelRatio;
  
  // Device type detection
  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;
  final bool isLargeDesktop;
  final bool isLandscape;
  final bool isPortrait;
  
  ResponsiveDesignSystem(this.screenSize, {this.devicePixelRatio = 1.0})
      : width = screenSize.width,
        height = screenSize.height,
        isMobile = screenSize.width < ResponsiveBreakpoints.mobile,
        isTablet = screenSize.width >= ResponsiveBreakpoints.mobile && 
                   screenSize.width < ResponsiveBreakpoints.desktop,
        isDesktop = screenSize.width >= ResponsiveBreakpoints.desktop && 
                    screenSize.width < ResponsiveBreakpoints.largeDesktop,
        isLargeDesktop = screenSize.width >= ResponsiveBreakpoints.largeDesktop,
        isLandscape = screenSize.width > screenSize.height,
        isPortrait = screenSize.height > screenSize.width;

  /// Professional typography scaling system
  /// Returns larger sizes for larger screens (industry standard)
  double getScaledFontSize(double baseMobileSize) {
    if (isLargeDesktop) {
      return baseMobileSize * 1.8; // 80% larger for large desktop
    } else if (isDesktop) {
      return baseMobileSize * 1.5; // 50% larger for desktop
    } else if (isTablet) {
      return baseMobileSize * 1.25; // 25% larger for tablet
    } else {
      return baseMobileSize; // Base size for mobile
    }
  }

  /// Professional spacing system
  double get baseSpacing {
    if (isLargeDesktop) return 24.0;
    if (isDesktop) return 20.0;
    if (isTablet) return 16.0;
    return 12.0;
  }

  double get contentPadding {
    if (isLargeDesktop) return 48.0;
    if (isDesktop) return 32.0;
    if (isTablet) return 24.0;
    return 16.0;
  }

  /// Professional carousel sizing - INCREASES with screen size
  double get carouselHeight {
    // Base height that INCREASES with screen size
    if (isLargeDesktop) {
      return 320.0; // Largest for large desktop
    } else if (isDesktop) {
      return 280.0; // Large for desktop
    } else if (isTablet) {
      return 240.0; // Medium for tablet
    } else {
      return 200.0; // Base for mobile
    }
  }

  /// Card heights that scale properly
  double get logoCardHeight {
    if (isLargeDesktop) return 200.0;
    if (isDesktop) return 160.0;
    if (isTablet) return 140.0;
    return 120.0;
  }

  /// Icon sizes that scale properly
  double get menuIconSize {
    if (isLargeDesktop) return 80.0;
    if (isDesktop) return 70.0;
    if (isTablet) return 60.0;
    return 50.0;
  }

  /// Maximum content width for readability
  double get maxContentWidth {
    if (isLargeDesktop) return 1400.0;
    if (isDesktop) return 1200.0;
    return double.infinity;
  }

  /// Grid columns for different screen sizes
  int get menuGridColumns {
    if (isLargeDesktop) return 8;
    if (isDesktop) return 6;
    if (isTablet) return 4;
    return 4;
  }

  /// Professional text size definitions
  double get headingLarge => getScaledFontSize(28.0);
  double get headingMedium => getScaledFontSize(24.0);
  double get headingSmall => getScaledFontSize(20.0);
  double get bodyLarge => getScaledFontSize(16.0);
  double get bodyMedium => getScaledFontSize(14.0);
  double get bodySmall => getScaledFontSize(12.0);
  double get caption => getScaledFontSize(10.0);

  /// Carousel-specific text sizes that INCREASE with screen size
  CarouselTextSizes get carouselTextSizes {
    return CarouselTextSizes(
      title: getScaledFontSize(24.0),        // 24px -> 43px on large desktop
      subtitle: getScaledFontSize(16.0),     // 16px -> 29px on large desktop  
      description: getScaledFontSize(14.0),  // 14px -> 25px on large desktop
      icon: getScaledFontSize(80.0),         // 80px -> 144px on large desktop
    );
  }
}

/// Data class for carousel text sizes
class CarouselTextSizes {
  final double title;
  final double subtitle;
  final double description;
  final double icon;

  const CarouselTextSizes({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
  });
}

/// Professional Home Screen Implementation
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController _pageController;
  int _currentCarouselPage = 0;
  late List<EventModel> _events;
  
  static const List<Map<String, String>> _menuItems = [
    {'icon': 'assets/Settiing Icon.png', 'title': 'Services'},
    {'icon': 'assets/event-icon.png', 'title': 'Events'},
    {'icon': 'assets/member-icon.png', 'title': 'Membership'},
    {'icon': 'assets/News Icon.png', 'title': 'Updates'},
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _events = EventModel.getDummyEvents();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showComingSoonMessage() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coming Soon!'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.lightBlueBackground,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final designSystem = ResponsiveDesignSystem(
              Size(constraints.maxWidth, constraints.maxHeight),
              devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
            );
            
            // Debug information
            debugPrint('=== PROFESSIONAL RESPONSIVE DEBUG ===');
            debugPrint('Screen: ${designSystem.width}x${designSystem.height}');
            debugPrint('Device Type: Mobile=${designSystem.isMobile}, Tablet=${designSystem.isTablet}, Desktop=${designSystem.isDesktop}, Large=${designSystem.isLargeDesktop}');
            debugPrint('Carousel Height: ${designSystem.carouselHeight}');
            debugPrint('Text Sizes: Title=${designSystem.carouselTextSizes.title}, Subtitle=${designSystem.carouselTextSizes.subtitle}, Description=${designSystem.carouselTextSizes.description}');
            debugPrint('=====================================');
            
            return _buildMainLayout(designSystem);
          },
        ),
      ),
    );
  }

  Widget _buildMainLayout(ResponsiveDesignSystem designSystem) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: designSystem.maxContentWidth),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCarouselSection(designSystem),
              _buildCarouselIndicators(designSystem),
              SizedBox(height: designSystem.baseSpacing),
              _buildLogoCardsSection(designSystem),
              SizedBox(height: designSystem.baseSpacing),
              _buildMenuSection(designSystem),
              SizedBox(height: designSystem.baseSpacing),
              _buildEventsSection(designSystem),
              SizedBox(height: designSystem.baseSpacing),
            ],
          ),
        ),
      ),
    );
  }

  /// Professional Carousel Implementation
  Widget _buildCarouselSection(ResponsiveDesignSystem designSystem) {
    return Container(
      height: designSystem.carouselHeight,
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: designSystem.contentPadding),
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          if (mounted) {
            setState(() {
              _currentCarouselPage = index;
            });
          }
        },
        itemCount: 2,
        itemBuilder: (context, index) {
          return _buildCarouselItem(designSystem, isSecondPage: index == 1);
        },
      ),
    );
  }

  /// Professional Carousel Item with guaranteed scaling
  Widget _buildCarouselItem(ResponsiveDesignSystem designSystem, {bool isSecondPage = false}) {
    final textSizes = designSystem.carouselTextSizes;
    
    return Container(
      padding: EdgeInsets.all(designSystem.contentPadding * 0.5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Text Content Section
          Expanded(
            flex: 7,
            child: Padding(
              padding: EdgeInsets.all(designSystem.baseSpacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title - GUARANTEED to scale up
                  Text(
                    isSecondPage ? 'Stay Connected' : 'Extratech AMS',
                    style: TextStyle(
                      fontSize: textSizes.title,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  SizedBox(height: designSystem.baseSpacing * 0.5),
                  
                  // Subtitle - GUARANTEED to scale up
                  Text(
                    isSecondPage ? 'With Extratech AMS' : 'Academic Management System',
                    style: TextStyle(
                      fontSize: textSizes.subtitle,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBlue.withOpacity(0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  SizedBox(height: designSystem.baseSpacing * 0.5),
                  
                  // Description - GUARANTEED to scale up
                  Flexible(
                    child: Text(
                      isSecondPage
                          ? 'Access all academic resources on the go'
                          : 'Simplifying enrollment, resources, attendance, quiz and communication',
                      style: TextStyle(
                        fontSize: textSizes.description,
                        color: AppColors.darkGrey,
                        height: 1.4,
                        letterSpacing: 0.2,
                      ),
                      maxLines: designSystem.isDesktop ? 3 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Icon Section - GUARANTEED to scale up
          Expanded(
            flex: 3,
            child: Center(
              child: Container(
                width: textSizes.icon,
                height: textSizes.icon,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryBlue.withOpacity(0.1),
                ),
                child: Padding(
                  padding: EdgeInsets.all(designSystem.baseSpacing),
                  child: Image.asset(
                    'assets/AMS Icon.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselIndicators(ResponsiveDesignSystem designSystem) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: designSystem.baseSpacing),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(2, (index) {
            return Container(
              width: designSystem.isDesktop ? 12.0 : 8.0,
              height: designSystem.isDesktop ? 12.0 : 8.0,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentCarouselPage == index
                    ? AppColors.primaryBlue
                    : AppColors.lightGrey,
              ),
            );
          }),
        ),
      ),
    );
  }

  /// Professional Logo Cards Section
  Widget _buildLogoCardsSection(ResponsiveDesignSystem designSystem) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: designSystem.contentPadding),
      child: Row(
        children: [
          Expanded(child: _buildAMSCard(designSystem)),
          SizedBox(width: designSystem.baseSpacing),
          Expanded(child: _buildExtratechCard(designSystem)),
        ],
      ),
    );
  }

  Widget _buildAMSCard(ResponsiveDesignSystem designSystem) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AmsScreen()),
        );
      },
      child: Container(
        height: designSystem.logoCardHeight,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(designSystem.baseSpacing),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 5,
                child: Image.asset(
                  'assets/AMS Icon.png',
                  fit: BoxFit.contain,
                ),
              ),
              Expanded(
                flex: 2,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'AMS',
                    style: TextStyle(
                      fontSize: designSystem.headingMedium,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Academic Management System',
                    style: TextStyle(
                      fontSize: designSystem.bodySmall,
                      color: const Color(0xFF111213),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExtratechCard(ResponsiveDesignSystem designSystem) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ExtratechOvalScreen()),
          // MaterialPageRoute(builder: (context) => const GeneralMembershipScreen()),
        );
      },
      child: Container(
        height: designSystem.logoCardHeight,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(designSystem.baseSpacing),
          child: Image.asset(
            'assets/Oval Logo.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  /// Professional Menu Section
  Widget _buildMenuSection(ResponsiveDesignSystem designSystem) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: designSystem.contentPadding),
      child: designSystem.isDesktop || designSystem.isTablet
          ? _buildMenuGrid(designSystem)
          : _buildMenuRow(designSystem),
    );
  }

  Widget _buildMenuRow(ResponsiveDesignSystem designSystem) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _menuItems.map((item) => _buildMenuItem(item, designSystem)).toList(),
    );
  }

  Widget _buildMenuGrid(ResponsiveDesignSystem designSystem) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: designSystem.menuGridColumns,
        childAspectRatio: 1.0,
        crossAxisSpacing: designSystem.baseSpacing,
        mainAxisSpacing: designSystem.baseSpacing,
      ),
      itemCount: _menuItems.length,
      itemBuilder: (context, index) {
        return _buildMenuItem(_menuItems[index], designSystem);
      },
    );
  }

  Widget _buildMenuItem(Map<String, String> item, ResponsiveDesignSystem designSystem) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _showComingSoonMessage,
          child: Container(
            width: designSystem.menuIconSize,
            height: designSystem.menuIconSize,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(designSystem.baseSpacing * 0.5),
              child: Image.asset(
                item['icon']!,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        SizedBox(height: designSystem.baseSpacing * 0.25),
        Text(
          item['title']!,
          style: TextStyle(
            fontSize: designSystem.bodyMedium,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// Professional Events Section
  Widget _buildEventsSection(ResponsiveDesignSystem designSystem) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEventsHeader(designSystem),
        SizedBox(height: designSystem.baseSpacing * 0.5),
        _buildEventsList(designSystem),
      ],
    );
  }

  Widget _buildEventsHeader(ResponsiveDesignSystem designSystem) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: designSystem.contentPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.primaryBlue,
                size: designSystem.headingSmall,
              ),
              SizedBox(width: designSystem.baseSpacing * 0.5),
              Text(
                'Events',
                style: AppTextStyles.heading2.copyWith(
                  fontSize: designSystem.headingSmall,
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(40, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'See all',
              style: AppTextStyles.link.copyWith(
                fontSize: designSystem.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList(ResponsiveDesignSystem designSystem) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: _events.length,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.symmetric(
            vertical: designSystem.baseSpacing * 0.25,
            horizontal: designSystem.contentPadding,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(designSystem.baseSpacing),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _events[index].title,
                                style: AppTextStyles.eventTitle.copyWith(
                                  fontSize: designSystem.bodyLarge,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              _events[index].timeRemaining,
                              style: AppTextStyles.eventTimer.copyWith(
                                fontSize: designSystem.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: designSystem.baseSpacing * 0.25),
                        Text(
                          _events[index].venue,
                          style: AppTextStyles.eventSubtitle.copyWith(
                            fontSize: designSystem.bodyMedium,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


















// import 'package:flutter/material.dart';
// import 'package:ems/core/app_colors.dart';
// import 'package:ems/core/app_text_styles.dart';
// import '../../data/models/event_model.dart';
// import 'package:ems/screens/AMS/login_in/login_screen.dart';
// import 'package:ems/screens/extratech-oval/login/login_screen.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({Key? key}) : super(key: key);

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final PageController _pageController = PageController();
//   int _currentCarouselPage = 0;
//   final List<EventModel> _events = EventModel.getDummyEvents();
  
//   final List<Map<String, dynamic>> _menuItems = [
//     {'icon': 'assets/Settiing Icon.png', 'title': 'Services'},
//     {'icon': 'assets/event-icon.png', 'title': 'Events'},
//     {'icon': 'assets/member-icon.png', 'title': 'Membership'},
//     {'icon': 'assets/News Icon.png', 'title': 'Updates'},
//   ];

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   void _showComingSoonMessage() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Coming Soon!'),
//         duration: Duration(seconds: 2),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Get screen dimensions and calculate adaptive sizes
//     final size = MediaQuery.of(context).size;
    
//     // Determine if we're on a small screen to adjust layouts
//     final isSmallScreen = size.height < 600 || size.width < 360;
    
//     // Calculate adaptive spacing
//     final verticalSpacing = isSmallScreen ? 8.0 : 15.0;
//     final horizontalPadding = size.width * 0.04; // 4% of screen width
    
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: AppColors.lightBlueBackground,
//         body: LayoutBuilder(
//           builder: (context, constraints) {
//             final maxWidth = constraints.maxWidth.toDouble();
//             final maxHeight = constraints.maxHeight.toDouble();
            
//             // More adaptive sizing based on actual constraints - explicit double conversion
//             final carouselHeight = isSmallScreen 
//                 ? maxHeight * 0.20 
//                 : maxHeight * 0.22;
                
//             final logoCardHeight = isSmallScreen
//                 ? maxHeight * 0.16
//                 : maxHeight * 0.18;
                
//             final menuIconSize = isSmallScreen 
//                 ? maxWidth * 0.18
//                 : 60.0;
                
//             final adaptiveTextSize = (double size) => isSmallScreen ? size * 0.85 : size;
                
//             return SingleChildScrollView(
//               physics: const ClampingScrollPhysics(),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Carousel Section
//                   SizedBox(
//                     height: carouselHeight,
//                     width: double.infinity,
//                     child: PageView(
//                       controller: _pageController,
//                       onPageChanged: (index) {
//                         setState(() {
//                           _currentCarouselPage = index;
//                         });
//                       },
//                       children: [
//                         _buildCarouselItem(isSmallScreen),
//                         _buildCarouselItem(isSmallScreen, isSecondPage: true),
//                       ],
//                     ),
//                   ),
                  
//                   // Carousel Indicators
//                   Padding(
//                     padding: EdgeInsets.symmetric(vertical: verticalSpacing * 0.5),
//                     child: Center(
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [0, 1].map((index) {
//                           return Container(
//                             width: 8.0,
//                             height: 8.0,
//                             margin: const EdgeInsets.symmetric(horizontal: 4.0),
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: _currentCarouselPage == index
//                                   ? AppColors.primaryBlue
//                                   : AppColors.lightGrey,
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                     ),
//                   ),
                  
//                   SizedBox(height: verticalSpacing),
                  
//                   // Logo Cards Row
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         // AMS Logo Card
//                         Expanded(
//                           child: GestureDetector(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(builder: (context) => const AmsScreen()),
//                               );
//                             },
//                             child: Container(
//                               height: logoCardHeight,
//                               decoration: BoxDecoration(
//                                 color: AppColors.cardBackground,
//                                 borderRadius: BorderRadius.circular(12),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withOpacity(0.05),
//                                     blurRadius: 5,
//                                     offset: const Offset(0, 2),
//                                   ),
//                                 ],
//                               ),
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   // Logo icon
//                                   Expanded(
//                                     flex: 5,
//                                     child: Center(
//                                       child: Image.asset(
//                                         'assets/AMS Icon.png',
//                                         width: maxWidth * 0.12,
//                                         height: maxWidth * 0.12,
//                                         fit: BoxFit.contain,
//                                       ),
//                                     ),
//                                   ),
//                                   // "AMS" text
//                                   Expanded(
//                                     flex: 3,
//                                     child: Center(
//                                       child: Text(
//                                         'AMS',
//                                         style: TextStyle(
//                                           fontSize: adaptiveTextSize(22.0),
//                                           fontWeight: FontWeight.bold,
//                                           color: AppColors.primaryBlue,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   // "Academic Management System" text
//                                   Expanded(
//                                     flex: 2,
//                                     child: Padding(
//                                       padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                                       child: Center(
//                                         child: FittedBox(
//                                           fit: BoxFit.scaleDown,
//                                           child: Text(
//                                             'Academic Management System',
//                                             style: TextStyle(
//                                               fontSize: maxWidth * 0.025,
//                                               color: const Color(0xFF111213),
//                                             ),
//                                             textAlign: TextAlign.center,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(height: 5),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                         SizedBox(width: horizontalPadding * 0.75),
//                         // Extratech Oval Card
//                         Expanded(
//                           child: GestureDetector(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(builder: (context) => const ExtratechOvalScreen()),
//                               );
//                             },
//                             child: Container(
//                               height: logoCardHeight,
//                               decoration: BoxDecoration(
//                                 color: AppColors.cardBackground,
//                                 borderRadius: BorderRadius.circular(12),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withOpacity(0.05),
//                                     blurRadius: 5,
//                                     offset: const Offset(0, 2),
//                                   ),
//                                 ],
//                               ),
//                               child: Center(
//                                 child: Padding(
//                                   padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
//                                   child: Image.asset(
//                                     'assets/Oval Logo.png',
//                                     fit: BoxFit.contain,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
                  
//                   SizedBox(height: verticalSpacing),
                  
//                   // Menu Icons - Responsive sizing
//                   SizedBox(
//                     height: isSmallScreen ? 75.0 : 83.0,
//                     width: double.infinity,
//                     child: Padding(
//                       padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: _buildMenuItems(maxWidth, isSmallScreen, menuIconSize),
//                       ),
//                     ),
//                   ),
                  
//                   SizedBox(height: verticalSpacing * 0.75),
                  
//                   // Events Section Header
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Row(
//                           children: [
//                             Icon(
//                               Icons.info_outline,
//                               color: AppColors.primaryBlue,
//                               size: isSmallScreen ? 16.0 : 20.0,
//                             ),
//                             const SizedBox(width: 8),
//                             Text(
//                               'Events',
//                               style: isSmallScreen 
//                                   ? AppTextStyles.heading2.copyWith(fontSize: 16.0)
//                                   : AppTextStyles.heading2,
//                             ),
//                           ],
//                         ),
//                         TextButton(
//                           onPressed: () {},
//                           style: TextButton.styleFrom(
//                             padding: EdgeInsets.zero,
//                             minimumSize: const Size(40, 30),
//                             tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                           ),
//                           child: Text(
//                             'See all',
//                             style: isSmallScreen
//                                 ? AppTextStyles.link.copyWith(fontSize: 12.0)
//                                 : AppTextStyles.link,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
                  
//                   // Events List - FIXED OVERFLOW ISSUE HERE
//                   ListView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     padding: EdgeInsets.zero,
//                     itemCount: _events.length,
//                     itemBuilder: (context, index) {
//                       return Container(
//                         // Removed fixed height to fix overflow
//                         margin: EdgeInsets.symmetric(
//                           vertical: 4.0, 
//                           horizontal: horizontalPadding
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(8),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.05),
//                               blurRadius: 4,
//                               offset: const Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                         child: IntrinsicHeight(  // Added to adapt to content height
//                           child: Row(
//                             crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch children vertically
//                             children: [
//                               // Blue vertical indicator line
//                               Container(
//                                 width: 4,
//                                 decoration: BoxDecoration(
//                                   color: AppColors.primaryBlue,
//                                   borderRadius: const BorderRadius.only(
//                                     topLeft: Radius.circular(8),
//                                     bottomLeft: Radius.circular(8),
//                                   ),
//                                 ),
//                               ),
//                               Expanded(
//                                 child: Padding(
//                                   padding: EdgeInsets.symmetric(
//                                     horizontal: 12.0,
//                                     vertical: isSmallScreen ? 10.0 : 12.0, // Increased from 8.0 to 10.0
//                                   ),
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     mainAxisSize: MainAxisSize.min, // Use min size to prevent overflow
//                                     children: [
//                                       Row(
//                                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                         crossAxisAlignment: CrossAxisAlignment.start, // Align to top to prevent overlap
//                                         children: [
//                                           Expanded(
//                                             child: Text(
//                                               _events[index].title,
//                                               style: isSmallScreen
//                                                   ? AppTextStyles.eventTitle.copyWith(fontSize: 13.0)
//                                                   : AppTextStyles.eventTitle,
//                                               maxLines: 1,
//                                               overflow: TextOverflow.ellipsis,
//                                             ),
//                                           ),
//                                           Padding(
//                                             padding: const EdgeInsets.only(left: 4.0),
//                                             child: Text(
//                                               _events[index].timeRemaining,
//                                               style: isSmallScreen
//                                                   ? AppTextStyles.eventTimer.copyWith(fontSize: 11.0)
//                                                   : AppTextStyles.eventTimer,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       SizedBox(height: isSmallScreen ? 2.0 : 4.0),
//                                       Text(
//                                         _events[index].venue,
//                                         style: isSmallScreen
//                                             ? AppTextStyles.eventSubtitle.copyWith(fontSize: 11.0)
//                                             : AppTextStyles.eventSubtitle,
//                                         maxLines: 1,
//                                         overflow: TextOverflow.ellipsis,
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   List<Widget> _buildMenuItems(double maxWidth, bool isSmallScreen, double menuIconSize) {
//     return _menuItems.asMap().entries.map((entry) {
//       final item = entry.value;
      
//       // Calculate adaptive sizes - explicit double types
//       final containerWidth = isSmallScreen ? maxWidth * 0.17 : 75.0;
//       final fontSize = isSmallScreen ? 10.0 : 12.0;
      
//       return SizedBox(
//         width: containerWidth,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             GestureDetector(
//               onTap: _showComingSoonMessage,
//               child: Container(
//                 width: menuIconSize,
//                 height: menuIconSize,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.05),
//                       blurRadius: 5,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Center(
//                   child: Image.asset(
//                     item['icon'],
//                     width: menuIconSize * 0.7,
//                     height: menuIconSize * 0.7,
//                     fit: BoxFit.contain,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 4),
//             FittedBox(
//               fit: BoxFit.scaleDown,
//               child: Text(
//                 item['title'],
//                 style: TextStyle(
//                   fontSize: fontSize,
//                   color: Colors.black,
//                   fontWeight: FontWeight.w500,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ],
//         ),
//       );
//     }).toList();
//   }

//   Widget _buildCarouselItem(bool isSmallScreen, {bool isSecondPage = false}) {
//     final size = MediaQuery.of(context).size;
    
//     // Adaptive text sizes - explicit double types
//     final titleSize = isSmallScreen ? size.width * 0.05 : size.width * 0.06;
//     final subtitleSize = isSmallScreen ? size.width * 0.035 : size.width * 0.042;
//     final descriptionSize = isSmallScreen ? size.width * 0.03 : size.width * 0.035;
//     final iconSize = isSmallScreen ? size.width * 0.15 : size.width * 0.18;
    
//     return Container(
//       padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
//       child: Row(
//         children: [
//           Expanded(
//             flex: 3,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // Title text
//                 Text(
//                   isSecondPage ? 'Stay Connected' : 'Extratech AMS',
//                   style: TextStyle(
//                     fontSize: titleSize,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.primaryBlue,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 SizedBox(height: isSmallScreen ? 2.0 : 4.0),
//                 // Subtitle text
//                 Text(
//                   isSecondPage ? 'With Extratech AMS' : 'Academic Management System',
//                   style: TextStyle(
//                     fontSize: subtitleSize,
//                     fontWeight: FontWeight.w500,
//                     color: AppColors.primaryBlue,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 SizedBox(height: isSmallScreen ? 2.0 : 4.0),
//                 // Description text
//                 Text(
//                   isSecondPage 
//                     ? 'Access all academic resources on the go'
//                     : 'Simplifying enrollment, resources, attendance, quiz and communication',
//                   style: TextStyle(
//                     fontSize: descriptionSize,
//                     color: AppColors.darkGrey,
//                   ),
//                   maxLines: isSmallScreen ? 2 : 3,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//           // Logo
//           SizedBox(
//             width: size.width * 0.22,
//             child: Center(
//               child: Image.asset(
//                 'assets/AMS Icon.png',
//                 width: iconSize,
//                 height: iconSize,
//                 fit: BoxFit.contain,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }









// import 'package:flutter/material.dart';
// import 'package:ems/core/app_colors.dart';
// import 'package:ems/core/app_text_styles.dart';
// import '../../data/models/event_model.dart';
// // import 'package:ems/screens/AMS/enrollment/enrollment_screen.dart';
// import 'package:ems/screens/AMS/login_in/login_screen.dart';
// import 'package:ems/screens/extratech-oval/login/login_screen.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({Key? key}) : super(key: key);

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final PageController _pageController = PageController();
//   int _currentCarouselPage = 0;
//   final List<EventModel> _events = EventModel.getDummyEvents();
  
//   final List<Map<String, dynamic>> _menuItems = [
//     {'icon': 'assets/Settiing Icon.png', 'title': 'Services'},
//     {'icon': 'assets/event-icon.png', 'title': 'Events'},
//     {'icon': 'assets/member-icon.png', 'title': 'Membership'},
//     {'icon': 'assets/News Icon.png', 'title': 'Updates'},
//   ];

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   void _showComingSoonMessage() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Coming Soon!'),
//         duration: Duration(seconds: 2),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Get screen dimensions and calculate adaptive sizes
//     final size = MediaQuery.of(context).size;
//     // final padding = MediaQuery.of(context).padding;
//     // final bottomNavHeight = 60.0;
    
//     // Calculate available height
//     // final availableHeight = size.height - padding.top - padding.bottom - bottomNavHeight;
    
//     // Determine if we're on a small screen to adjust layouts
//     final isSmallScreen = size.height < 600 || size.width < 360;
    
//     // Calculate adaptive spacing
//     final verticalSpacing = isSmallScreen ? 8.0 : 15.0;
//     final horizontalPadding = size.width * 0.04; // 4% of screen width
    
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: AppColors.lightBlueBackground,
//         body: LayoutBuilder(
//           builder: (context, constraints) {
//             final maxWidth = constraints.maxWidth.toDouble();
//             final maxHeight = constraints.maxHeight.toDouble();
            
//             // More adaptive sizing based on actual constraints - explicit double conversion
//             final carouselHeight = isSmallScreen 
//                 ? maxHeight * 0.20 
//                 : maxHeight * 0.22;
                
//             final logoCardHeight = isSmallScreen
//                 ? maxHeight * 0.16
//                 : maxHeight * 0.18;
                
//             final menuIconSize = isSmallScreen 
//                 ? maxWidth * 0.18
//                 : 60.0;
                
//             final adaptiveTextSize = (double size) => isSmallScreen ? size * 0.85 : size;
                
//             return SingleChildScrollView(
//               physics: const ClampingScrollPhysics(),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Carousel Section
//                   SizedBox(
//                     height: carouselHeight,
//                     width: double.infinity,
//                     child: PageView(
//                       controller: _pageController,
//                       onPageChanged: (index) {
//                         setState(() {
//                           _currentCarouselPage = index;
//                         });
//                       },
//                       children: [
//                         _buildCarouselItem(isSmallScreen),
//                         _buildCarouselItem(isSmallScreen, isSecondPage: true),
//                       ],
//                     ),
//                   ),
                  
//                   // Carousel Indicators
//                   Padding(
//                     padding: EdgeInsets.symmetric(vertical: verticalSpacing * 0.5),
//                     child: Center(
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [0, 1].map((index) {
//                           return Container(
//                             width: 8.0,
//                             height: 8.0,
//                             margin: const EdgeInsets.symmetric(horizontal: 4.0),
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: _currentCarouselPage == index
//                                   ? AppColors.primaryBlue
//                                   : AppColors.lightGrey,
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                     ),
//                   ),
                  
//                   SizedBox(height: verticalSpacing),
                  
//                   // Logo Cards Row
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         // AMS Logo Card
//                         Expanded(
//                           child: GestureDetector(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(builder: (context) => const AmsScreen()),
//                               );
//                             },
//                             child: Container(
//                               height: logoCardHeight,
//                               decoration: BoxDecoration(
//                                 color: AppColors.cardBackground,
//                                 borderRadius: BorderRadius.circular(12),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withOpacity(0.05),
//                                     blurRadius: 5,
//                                     offset: const Offset(0, 2),
//                                   ),
//                                 ],
//                               ),
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   // Logo icon
//                                   Expanded(
//                                     flex: 5,
//                                     child: Center(
//                                       child: Image.asset(
//                                         'assets/AMS Icon.png',
//                                         width: maxWidth * 0.12,
//                                         height: maxWidth * 0.12,
//                                         fit: BoxFit.contain,
//                                       ),
//                                     ),
//                                   ),
//                                   // "AMS" text
//                                   Expanded(
//                                     flex: 3,
//                                     child: Center(
//                                       child: Text(
//                                         'AMS',
//                                         style: TextStyle(
//                                           fontSize: adaptiveTextSize(22.0),
//                                           fontWeight: FontWeight.bold,
//                                           color: AppColors.primaryBlue,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   // "Academic Management System" text
//                                   Expanded(
//                                     flex: 2,
//                                     child: Padding(
//                                       padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                                       child: Center(
//                                         child: FittedBox(
//                                           fit: BoxFit.scaleDown,
//                                           child: Text(
//                                             'Academic Management System',
//                                             style: TextStyle(
//                                               fontSize: maxWidth * 0.025,
//                                               color: const Color(0xFF111213),
//                                             ),
//                                             textAlign: TextAlign.center,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(height: 5),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                         SizedBox(width: horizontalPadding * 0.75),
//                         // Extratech Oval Card
//                         Expanded(
//                           child: GestureDetector(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(builder: (context) => const ExtratechOvalScreen()),
//                               );
//                             },
//                             child: Container(
//                               height: logoCardHeight,
//                               decoration: BoxDecoration(
//                                 color: AppColors.cardBackground,
//                                 borderRadius: BorderRadius.circular(12),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withOpacity(0.05),
//                                     blurRadius: 5,
//                                     offset: const Offset(0, 2),
//                                   ),
//                                 ],
//                               ),
//                               child: Center(
//                                 child: Padding(
//                                   padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
//                                   child: Image.asset(
//                                     'assets/Oval Logo.png',
//                                     fit: BoxFit.contain,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
                  
//                   SizedBox(height: verticalSpacing),
                  
//                   // Menu Icons - Responsive sizing
//                   SizedBox(
//                     height: isSmallScreen ? 75.0 : 83.0,
//                     width: double.infinity,
//                     child: Padding(
//                       padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: _buildMenuItems(maxWidth, isSmallScreen, menuIconSize),
//                       ),
//                     ),
//                   ),
                  
//                   SizedBox(height: verticalSpacing * 0.75),
                  
//                   // Events Section Header
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Row(
//                           children: [
//                             Icon(
//                               Icons.info_outline,
//                               color: AppColors.primaryBlue,
//                               size: isSmallScreen ? 16.0 : 20.0,
//                             ),
//                             const SizedBox(width: 8),
//                             Text(
//                               'Events',
//                               style: isSmallScreen 
//                                   ? AppTextStyles.heading2.copyWith(fontSize: 16.0)
//                                   : AppTextStyles.heading2,
//                             ),
//                           ],
//                         ),
//                         TextButton(
//                           onPressed: () {},
//                           style: TextButton.styleFrom(
//                             padding: EdgeInsets.zero,
//                             minimumSize: const Size(40, 30),
//                             tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                           ),
//                           child: Text(
//                             'See all',
//                             style: isSmallScreen
//                                 ? AppTextStyles.link.copyWith(fontSize: 12.0)
//                                 : AppTextStyles.link,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
                  
//                   // Events List - Adaptive height for events
//                   ListView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     padding: EdgeInsets.zero,
//                     itemCount: _events.length,
//                     itemBuilder: (context, index) {
//                       return Container(
//                         height: isSmallScreen ? 60.0 : 70.0,
//                         margin: EdgeInsets.symmetric(
//                           vertical: 4.0, 
//                           horizontal: horizontalPadding
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(8),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.05),
//                               blurRadius: 4,
//                               offset: const Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                         child: Row(
//                           children: [
//                             // Blue vertical indicator line
//                             Container(
//                               width: 4,
//                               decoration: BoxDecoration(
//                                 color: AppColors.primaryBlue,
//                                 borderRadius: const BorderRadius.only(
//                                   topLeft: Radius.circular(8),
//                                   bottomLeft: Radius.circular(8),
//                                 ),
//                               ),
//                             ),
//                             Expanded(
//                               child: Padding(
//                                 padding: EdgeInsets.symmetric(
//                                   horizontal: 12.0,
//                                   vertical: isSmallScreen ? 8.0 : 12.0,
//                                 ),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Row(
//                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Expanded(
//                                           child: Text(
//                                             _events[index].title,
//                                             style: isSmallScreen
//                                                 ? AppTextStyles.eventTitle.copyWith(fontSize: 13.0)
//                                                 : AppTextStyles.eventTitle,
//                                             maxLines: 1,
//                                             overflow: TextOverflow.ellipsis,
//                                           ),
//                                         ),
//                                         Text(
//                                           _events[index].timeRemaining,
//                                           style: isSmallScreen
//                                               ? AppTextStyles.eventTimer.copyWith(fontSize: 11.0)
//                                               : AppTextStyles.eventTimer,
//                                         ),
//                                       ],
//                                     ),
//                                     SizedBox(height: isSmallScreen ? 2.0 : 4.0),
//                                     Text(
//                                       _events[index].venue,
//                                       style: isSmallScreen
//                                           ? AppTextStyles.eventSubtitle.copyWith(fontSize: 11.0)
//                                           : AppTextStyles.eventSubtitle,
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   List<Widget> _buildMenuItems(double maxWidth, bool isSmallScreen, double menuIconSize) {
//     return _menuItems.asMap().entries.map((entry) {
//       final item = entry.value;
      
//       // Calculate adaptive sizes - explicit double types
//       final containerWidth = isSmallScreen ? maxWidth * 0.17 : 75.0;
//       final fontSize = isSmallScreen ? 10.0 : 12.0;
      
//       return SizedBox(
//         width: containerWidth,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             GestureDetector(
//               onTap: _showComingSoonMessage,
//               child: Container(
//                 width: menuIconSize,
//                 height: menuIconSize,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.05),
//                       blurRadius: 5,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Center(
//                   child: Image.asset(
//                     item['icon'],
//                     width: menuIconSize * 0.7,
//                     height: menuIconSize * 0.7,
//                     fit: BoxFit.contain,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 4),
//             FittedBox(
//               fit: BoxFit.scaleDown,
//               child: Text(
//                 item['title'],
//                 style: TextStyle(
//                   fontSize: fontSize,
//                   color: Colors.black,
//                   fontWeight: FontWeight.w500,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ],
//         ),
//       );
//     }).toList();
//   }

//   Widget _buildCarouselItem(bool isSmallScreen, {bool isSecondPage = false}) {
//     final size = MediaQuery.of(context).size;
    
//     // Adaptive text sizes - explicit double types
//     final titleSize = isSmallScreen ? size.width * 0.05 : size.width * 0.06;
//     final subtitleSize = isSmallScreen ? size.width * 0.035 : size.width * 0.042;
//     final descriptionSize = isSmallScreen ? size.width * 0.03 : size.width * 0.035;
//     final iconSize = isSmallScreen ? size.width * 0.15 : size.width * 0.18;
    
//     return Container(
//       padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
//       child: Row(
//         children: [
//           Expanded(
//             flex: 3,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // Title text
//                 Text(
//                   isSecondPage ? 'Stay Connected' : 'Extratech AMS',
//                   style: TextStyle(
//                     fontSize: titleSize,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.primaryBlue,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 SizedBox(height: isSmallScreen ? 2.0 : 4.0),
//                 // Subtitle text
//                 Text(
//                   isSecondPage ? 'With Extratech AMS' : 'Academic Management System',
//                   style: TextStyle(
//                     fontSize: subtitleSize,
//                     fontWeight: FontWeight.w500,
//                     color: AppColors.primaryBlue,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 SizedBox(height: isSmallScreen ? 2.0 : 4.0),
//                 // Description text
//                 Text(
//                   isSecondPage 
//                     ? 'Access all academic resources on the go'
//                     : 'Simplifying enrollment, resources, attendance, quiz and communication',
//                   style: TextStyle(
//                     fontSize: descriptionSize,
//                     color: AppColors.darkGrey,
//                   ),
//                   maxLines: isSmallScreen ? 2 : 3,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//           // Logo
//           SizedBox(
//             width: size.width * 0.22,
//             child: Center(
//               child: Image.asset(
//                 'assets/AMS Icon.png',
//                 width: iconSize,
//                 height: iconSize,
//                 fit: BoxFit.contain,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


















// // import 'package:flutter/material.dart';
// // import 'package:ems/core/app_colors.dart';
// // import 'package:ems/core/app_text_styles.dart';
// // import '../../data/models/event_model.dart';
// // import 'package:ems/screens/AMS/enrollment/enrollment_screen.dart';
// // import 'package:ems/screens/extratech-oval/login/login_screen.dart';
// // // import 'package:ems/screens/AMS/sign_in/signin_screen.dart';

// // class HomeScreen extends StatefulWidget {
// //   @override
// //   _HomeScreenState createState() => _HomeScreenState();
// // }

// // class _HomeScreenState extends State<HomeScreen> {
// //   final PageController _pageController = PageController();
// //   int _currentCarouselPage = 0;
// //   final List<EventModel> _events = EventModel.getDummyEvents();
  
// //   final List<Map<String, dynamic>> _menuItems = [
// //     {'icon': 'assets/Settiing Icon.png', 'title': 'Services'},
// //     {'icon': 'assets/event-icon.png', 'title': 'Events'},
// //     {'icon': 'assets/member-icon.png', 'title': 'Membership'},
// //     {'icon': 'assets/News Icon.png', 'title': 'Updates'},
// //   ];

// //   @override
// //   void dispose() {
// //     _pageController.dispose();
// //     super.dispose();
// //   }

// //   void _showComingSoonMessage() {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text('Coming Soon!'),
// //         duration: Duration(seconds: 2),
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     // Get screen size to make layout responsive
// //     final size = MediaQuery.of(context).size;
// //     final padding = MediaQuery.of(context).padding;
    
// //     // Calculate available height (subtract status bar and bottom nav)
// //     final availableHeight = size.height - padding.top - padding.bottom - 60; // 60 for bottom nav
    
// //     return SafeArea(
// //       child: Scaffold(
// //         backgroundColor: AppColors.lightBlueBackground, // #FAFCFF
// //         body: SingleChildScrollView(
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               // Carousel Section - Fixed height to prevent overflow
// //               Container(
// //                 height: availableHeight * 0.22, // Proportional height
// //                 width: double.infinity,
// //                 child: PageView(
// //                   controller: _pageController,
// //                   onPageChanged: (index) {
// //                     setState(() {
// //                       _currentCarouselPage = index;
// //                     });
// //                   },
// //                   children: [
// //                     _buildCarouselItem(),
// //                     _buildCarouselItem(isSecondPage: true),
// //                   ],
// //                 ),
// //               ),
              
// //               // Carousel Indicators
// //               Center(
// //                 child: Row(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [0, 1].map((index) {
// //                     return Container(
// //                       width: 8.0,
// //                       height: 8.0,
// //                       margin: EdgeInsets.symmetric(horizontal: 4.0),
// //                       decoration: BoxDecoration(
// //                         shape: BoxShape.circle,
// //                         color: _currentCarouselPage == index
// //                             ? AppColors.primaryBlue
// //                             : AppColors.lightGrey,
// //                       ),
// //                     );
// //                   }).toList(),
// //                 ),
// //               ),
// //               SizedBox(height: 15),
              
// //               // Logo Cards Row - Adaptive width based on screen size
// //               Padding(
// //                 padding: EdgeInsets.symmetric(horizontal: 16.0),
// //                 child: Row(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [
// //                     // AMS Logo Card
// //                     Expanded(
// //                       child: GestureDetector(
// //                         onTap: () {
// //                           Navigator.push(
// //                             context,
// //                             MaterialPageRoute(builder: (context) => EnrollmentScreen()),
// //                           );
// //                         },
// //                         child: Container(
// //                           height: availableHeight * 0.18, // Proportional height
// //                           decoration: BoxDecoration(
// //                             color: AppColors.cardBackground, // #ECF1FA
// //                             borderRadius: BorderRadius.circular(12),
// //                             boxShadow: [
// //                               BoxShadow(
// //                                 color: Colors.black.withOpacity(0.05),
// //                                 blurRadius: 5,
// //                                 offset: Offset(0, 2),
// //                               ),
// //                             ],
// //                           ),
// //                           child: Column(
// //                             mainAxisAlignment: MainAxisAlignment.center,
// //                             children: [
// //                               // Logo icon - Using asset image instead of icon
// //                               Expanded(
// //                                 flex: 5,
// //                                 child: Center(
// //                                   child: Image.asset(
// //                                     'assets/AMS Icon.png',
// //                                     width: size.width * 0.14,
// //                                     height: size.width * 0.14,
// //                                     fit: BoxFit.contain,
// //                                   ),
// //                                 ),
// //                               ),
// //                               // "AMS" text
// //                               Expanded(
// //                                 flex: 3,
// //                                 child: Center(
// //                                   child: Text(
// //                                     'AMS',
// //                                     style: TextStyle(
// //                                       fontSize: 22,
// //                                       fontWeight: FontWeight.bold,
// //                                       color: AppColors.primaryBlue,
// //                                     ),
// //                                   ),
// //                                 ),
// //                               ),
// //                               // "Academic Management System" text
// //                               Expanded(
// //                                 flex: 2,
// //                                 child: Padding(
// //                                   padding: EdgeInsets.symmetric(horizontal: 8.0),
// //                                   child: Center(
// //                                     child: Text(
// //                                       'Academic Management System',
// //                                       style: TextStyle(
// //                                         fontSize: size.width * 0.025,
// //                                         color: Color(0xFF111213),
// //                                       ),
// //                                       textAlign: TextAlign.center,
// //                                       overflow: TextOverflow.ellipsis,
// //                                     ),
// //                                   ),
// //                                 ),
// //                               ),
// //                               SizedBox(height: 5),
// //                             ],
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                     SizedBox(width: 12),
// //                     // Extratech Oval Card - Now using the full logo image
// //                     Expanded(
// //                       child: GestureDetector(
// //                         onTap: (){
// //                           Navigator.push(
// //                             context,
// //                             MaterialPageRoute(builder: (context) => ExtratechOvalScreen()),
// //                           );
// //                         },
// //                         child: Container(
// //                           height: availableHeight * 0.18, // Proportional height
// //                           decoration: BoxDecoration(
// //                             color: AppColors.cardBackground, // #ECF1FA
// //                             borderRadius: BorderRadius.circular(12),
// //                             boxShadow: [
// //                               BoxShadow(
// //                                 color: Colors.black.withOpacity(0.05),
// //                                 blurRadius: 5,
// //                                 offset: Offset(0, 2),
// //                               ),
// //                             ],
// //                           ),
// //                           child: Center(
// //                             child: Padding(
// //                               padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
// //                               child: Image.asset(
// //                                 'assets/Oval Logo.png',
// //                                 fit: BoxFit.contain,
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               SizedBox(height: 15),
              
// //               // Menu Icons - With exact dimensions and updated colors
// //               Container(
// //                 height: 83, // Fixed exact height of 83
// //                 width: double.infinity,
// //                 child: Padding(
// //                   padding: EdgeInsets.symmetric(horizontal: 16.0),
// //                   child: Row(
// //                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //                     children: _menuItems.asMap().entries.map((entry) {
// //                       // final index = entry.key;
// //                       final item = entry.value;
// //                       return Container(
// //                         width: 75, // Exact width of 75
// //                         height: 83, // Exact height of 83
// //                         // Removed blue background color from 75x83 container
// //                         child: Column(
// //                           mainAxisAlignment: MainAxisAlignment.center,
// //                           children: [
// //                             GestureDetector(
// //                               onTap: _showComingSoonMessage,
// //                               child: Container(
// //                                 width: 60, // Exact width of 60
// //                                 height: 60, // Exact height of 60
// //                                 decoration: BoxDecoration(
// //                                   color: Colors.white, // 60x60 container remains white (#FFFFFF)
// //                                   borderRadius: BorderRadius.circular(12),
// //                                   boxShadow: [
// //                                     BoxShadow(
// //                                       color: Colors.black.withOpacity(0.05),
// //                                       blurRadius: 5,
// //                                       offset: Offset(0, 2),
// //                                     ),
// //                                   ],
// //                                 ),
// //                                 child: Center(
// //                                   child: Image.asset(
// //                                     item['icon'],
// //                                     width: 40, // Exact width of 40
// //                                     height: 40, // Exact height of 40
// //                                     fit: BoxFit.contain,
// //                                   ),
// //                                 ),
// //                               ),
// //                             ),
// //                             SizedBox(height: 6),
// //                             Text(
// //                               item['title'],
// //                               style: TextStyle(
// //                                 fontSize: 12,
// //                                 color: Colors.black, // Menu item text color remains black (#000000)
// //                                 fontWeight: FontWeight.w500,
// //                               ),
// //                               textAlign: TextAlign.center,
// //                             ),
// //                           ],
// //                         ),
// //                       );
// //                     }).toList(),
// //                   ),
// //                 ),
// //               ),
// //               SizedBox(height: 10),
              
// //               // Events Section Header
// //               Padding(
// //                 padding: EdgeInsets.symmetric(horizontal: 16.0),
// //                 child: Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                   children: [
// //                     Row(
// //                       children: [
// //                         Icon(
// //                           Icons.info_outline,
// //                           color: AppColors.primaryBlue,
// //                           size: 20,
// //                         ),
// //                         SizedBox(width: 8),
// //                         Text(
// //                           'Events',
// //                           style: AppTextStyles.heading2,
// //                         ),
// //                       ],
// //                     ),
// //                     TextButton(
// //                       onPressed: () {},
// //                       child: Text(
// //                         'See all',
// //                         style: AppTextStyles.link,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
              
// //               // Events List
// //               ListView.builder(
// //                 shrinkWrap: true,
// //                 physics: NeverScrollableScrollPhysics(),
// //                 padding: EdgeInsets.zero,
// //                 itemCount: _events.length,
// //                 itemBuilder: (context, index) {
// //                   return Container(
// //                     height: 70,
// //                     margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
// //                     decoration: BoxDecoration(
// //                       color: Colors.white,
// //                       borderRadius: BorderRadius.circular(8),
// //                       boxShadow: [
// //                         BoxShadow(
// //                           color: Colors.black.withOpacity(0.05),
// //                           blurRadius: 4,
// //                           offset: Offset(0, 2),
// //                         ),
// //                       ],
// //                     ),
// //                     child: Row(
// //                       children: [
// //                         // Blue vertical indicator line
// //                         Container(
// //                           width: 4,
// //                           decoration: BoxDecoration(
// //                             color: AppColors.primaryBlue,
// //                             borderRadius: BorderRadius.only(
// //                               topLeft: Radius.circular(8),
// //                               bottomLeft: Radius.circular(8),
// //                             ),
// //                           ),
// //                         ),
// //                         Expanded(
// //                           child: Padding(
// //                             padding: const EdgeInsets.all(12.0),
// //                             child: Column(
// //                               crossAxisAlignment: CrossAxisAlignment.start,
// //                               mainAxisAlignment: MainAxisAlignment.center,
// //                               children: [
// //                                 Row(
// //                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                                   children: [
// //                                     Expanded(
// //                                       child: Text(
// //                                         _events[index].title,
// //                                         style: AppTextStyles.eventTitle,
// //                                         maxLines: 1,
// //                                         overflow: TextOverflow.ellipsis,
// //                                       ),
// //                                     ),
// //                                     Text(
// //                                       _events[index].timeRemaining,
// //                                       style: AppTextStyles.eventTimer,
// //                                     ),
// //                                   ],
// //                                 ),
// //                                 SizedBox(height: 4),
// //                                 Text(
// //                                   _events[index].venue,
// //                                   style: AppTextStyles.eventSubtitle,
// //                                   maxLines: 1,
// //                                   overflow: TextOverflow.ellipsis,
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   );
// //                 },
// //               ),
// //               SizedBox(height: 16),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildCarouselItem({bool isSecondPage = false}) {
// //     final size = MediaQuery.of(context).size;
    
// //     return Container(
// //       padding: EdgeInsets.all(16),
// //       child: Row(
// //         children: [
// //           Expanded(
// //             flex: 3,
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 // Title text
// //                 Text(
// //                   isSecondPage ? 'Stay Connected' : 'Extratech AMS',
// //                   style: TextStyle(
// //                     fontSize: size.width * 0.06,
// //                     fontWeight: FontWeight.bold,
// //                     color: AppColors.primaryBlue,
// //                   ),
// //                 ),
// //                 SizedBox(height: 4),
// //                 // Subtitle text
// //                 Text(
// //                   isSecondPage ? 'With Extratech AMS' : 'Academic Management System',
// //                   style: TextStyle(
// //                     fontSize: size.width * 0.042,
// //                     fontWeight: FontWeight.w500,
// //                     color: AppColors.primaryBlue,
// //                   ),
// //                   maxLines: 1,
// //                   overflow: TextOverflow.ellipsis,
// //                 ),
// //                 SizedBox(height: 4),
// //                 // Description text
// //                 Text(
// //                   isSecondPage 
// //                     ? 'Access all academic resources on the go'
// //                     : 'Simplifying enrollment, resources, attendance, quiz and communication',
// //                   style: TextStyle(
// //                     fontSize: size.width * 0.035,
// //                     color: AppColors.darkGrey,
// //                   ),
// //                   maxLines: 2,
// //                   overflow: TextOverflow.ellipsis,
// //                 ),
// //               ],
// //             ),
// //           ),
// //           // Logo - Using asset image instead of icon
// //           Container(
// //             width: size.width * 0.22,
// //             child: Center(
// //               child: Image.asset(
// //                 'assets/AMS Icon.png',
// //                 width: size.width * 0.18,
// //                 height: size.width * 0.18,
// //                 fit: BoxFit.contain,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }


















// // import 'package:flutter/material.dart';
// // import 'package:ems/core/app_colors.dart';
// // import 'package:ems/core/app_text_styles.dart';
// // import '../../data/models/event_model.dart';

// // class HomeScreen extends StatefulWidget {
// //   @override
// //   _HomeScreenState createState() => _HomeScreenState();
// // }

// // class _HomeScreenState extends State<HomeScreen> {
// //   final PageController _pageController = PageController();
// //   int _currentCarouselPage = 0;
// //   final List<EventModel> _events = EventModel.getDummyEvents();
  
// //   final List<Map<String, dynamic>> _menuItems = [
// //     {'icon': Icons.build_outlined, 'title': 'Services'},
// //     {'icon': Icons.calendar_today_outlined, 'title': 'Events'},
// //     {'icon': Icons.card_membership_outlined, 'title': 'Membership'},
// //     {'icon': Icons.article_outlined, 'title': 'Updates'},
// //   ];

// //   @override
// //   void dispose() {
// //     _pageController.dispose();
// //     super.dispose();
// //   }

// //   void _showComingSoonMessage() {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text('Coming Soon!'),
// //         duration: Duration(seconds: 2),
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     // Get screen size to make layout responsive
// //     final size = MediaQuery.of(context).size;
// //     final padding = MediaQuery.of(context).padding;
    
// //     // Calculate available height (subtract status bar and bottom nav)
// //     final availableHeight = size.height - padding.top - padding.bottom - 60; // 60 for bottom nav
    
// //     return SafeArea(
// //       child: Scaffold(
// //         backgroundColor: AppColors.lightBlueBackground,
// //         body: SingleChildScrollView(
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               // Carousel Section - Fixed height to prevent overflow
// //               Container(
// //                 height: availableHeight * 0.22, // Proportional height
// //                 width: double.infinity,
// //                 child: PageView(
// //                   controller: _pageController,
// //                   onPageChanged: (index) {
// //                     setState(() {
// //                       _currentCarouselPage = index;
// //                     });
// //                   },
// //                   children: [
// //                     _buildCarouselItem(),
// //                     _buildCarouselItem(isSecondPage: true),
// //                   ],
// //                 ),
// //               ),
              
// //               // Carousel Indicators
// //               Center(
// //                 child: Row(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [0, 1].map((index) {
// //                     return Container(
// //                       width: 8.0,
// //                       height: 8.0,
// //                       margin: EdgeInsets.symmetric(horizontal: 4.0),
// //                       decoration: BoxDecoration(
// //                         shape: BoxShape.circle,
// //                         color: _currentCarouselPage == index
// //                             ? AppColors.primaryBlue
// //                             : AppColors.lightGrey,
// //                       ),
// //                     );
// //                   }).toList(),
// //                 ),
// //               ),
// //               SizedBox(height: 15),
              
// //               // Logo Cards Row - Adaptive width based on screen size
// //               Padding(
// //                 padding: EdgeInsets.symmetric(horizontal: 16.0),
// //                 child: Row(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [
// //                     // AMS Logo Card
// //                     Expanded(
// //                       child: Container(
// //                         height: availableHeight * 0.18, // Proportional height
// //                         decoration: BoxDecoration(
// //                           color: Colors.white,
// //                           borderRadius: BorderRadius.circular(12),
// //                           boxShadow: [
// //                             BoxShadow(
// //                               color: Colors.black.withOpacity(0.05),
// //                               blurRadius: 5,
// //                               offset: Offset(0, 2),
// //                             ),
// //                           ],
// //                         ),
// //                         child: Column(
// //                           mainAxisAlignment: MainAxisAlignment.center,
// //                           children: [
// //                             // Logo icon - Using asset image instead of icon
// //                             Expanded(
// //                               flex: 5,
// //                               child: Center(
// //                                 child: Image.asset(
// //                                   'assets/AMS Icon.png',
// //                                   width: size.width * 0.12, // Responsive size
// //                                   height: size.width * 0.12,
// //                                   fit: BoxFit.contain,
// //                                 ),
// //                               ),
// //                             ),
// //                             // "AMS" text
// //                             Expanded(
// //                               flex: 3,
// //                               child: Center(
// //                                 child: Text(
// //                                   'AMS',
// //                                   style: TextStyle(
// //                                     fontSize: 20, // Responsive
// //                                     fontWeight: FontWeight.bold,
// //                                     color: AppColors.primaryBlue,
// //                                   ),
// //                                 ),
// //                               ),
// //                             ),
// //                             // "Academic Management System" text
// //                             Expanded(
// //                               flex: 2,
// //                               child: Padding(
// //                                 padding: EdgeInsets.symmetric(horizontal: 8.0),
// //                                 child: Center(
// //                                   child: Text(
// //                                     'Academic Management System',
// //                                     style: TextStyle(
// //                                       fontSize: size.width * 0.025, // Responsive
// //                                       color: Color(0xFF111213),
// //                                     ),
// //                                     textAlign: TextAlign.center,
// //                                     overflow: TextOverflow.ellipsis,
// //                                   ),
// //                                 ),
// //                               ),
// //                             ),
// //                             SizedBox(height: 5), // Prevent bottom overflow
// //                           ],
// //                         ),
// //                       ),
// //                     ),
// //                     SizedBox(width: 12),
// //                     // Extratech Oval Card - Now using the full logo image
// //                     Expanded(
// //                       child: GestureDetector(
// //                         onTap: _showComingSoonMessage,
// //                         child: Container(
// //                           height: availableHeight * 0.18, // Proportional height
// //                           decoration: BoxDecoration(
// //                             color: Colors.white,
// //                             borderRadius: BorderRadius.circular(12),
// //                             boxShadow: [
// //                               BoxShadow(
// //                                 color: Colors.black.withOpacity(0.05),
// //                                 blurRadius: 5,
// //                                 offset: Offset(0, 2),
// //                               ),
// //                             ],
// //                           ),
// //                           // Center the Oval Logo and make it fill most of the card
// //                           child: Center(
// //                             child: Padding(
// //                               padding: EdgeInsets.all(12.0),
// //                               child: Image.asset(
// //                                 'assets/Oval Logo.png',
// //                                 fit: BoxFit.contain,
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               SizedBox(height: 15),
              
// //               // Menu Icons - Scrollable row to prevent overflow
// //               Container(
// //                 height: availableHeight * 0.15, // Proportional height
// //                 width: double.infinity,
// //                 child: SingleChildScrollView(
// //                   scrollDirection: Axis.horizontal,
// //                   child: Padding(
// //                     padding: EdgeInsets.symmetric(horizontal: 16.0),
// //                     child: Row(
// //                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //                       children: _menuItems.map((item) {
// //                         return Container(
// //                           width: 75,
// //                           margin: EdgeInsets.symmetric(horizontal: 6),
// //                           child: GestureDetector(
// //                             onTap: _showComingSoonMessage,
// //                             child: Column(
// //                               mainAxisSize: MainAxisSize.min, // Prevent overflow
// //                               mainAxisAlignment: MainAxisAlignment.center,
// //                               children: [
// //                                 Container(
// //                                   width: 58,
// //                                   height: 58,
// //                                   decoration: BoxDecoration(
// //                                     color: Colors.white,
// //                                     borderRadius: BorderRadius.circular(12),
// //                                     boxShadow: [
// //                                       BoxShadow(
// //                                         color: Colors.black.withOpacity(0.05),
// //                                         blurRadius: 5,
// //                                         offset: Offset(0, 2),
// //                                       ),
// //                                     ],
// //                                   ),
// //                                   child: Icon(
// //                                     item['icon'],
// //                                     color: AppColors.primaryBlue,
// //                                     size: 32,
// //                                   ),
// //                                 ),
// //                                 SizedBox(height: 6),
// //                                 Text(
// //                                   item['title'],
// //                                   style: TextStyle(
// //                                     fontSize: 12,
// //                                     color: Colors.black87,
// //                                     fontWeight: FontWeight.w500,
// //                                   ),
// //                                   textAlign: TextAlign.center,
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                         );
// //                       }).toList(),
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //               SizedBox(height: 10),
              
// //               // Events Section Header
// //               Padding(
// //                 padding: EdgeInsets.symmetric(horizontal: 16.0),
// //                 child: Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                   children: [
// //                     Row(
// //                       children: [
// //                         Icon(
// //                           Icons.info_outline,
// //                           color: AppColors.primaryBlue,
// //                           size: 20,
// //                         ),
// //                         SizedBox(width: 8),
// //                         Text(
// //                           'Events',
// //                           style: AppTextStyles.heading2,
// //                         ),
// //                       ],
// //                     ),
// //                     TextButton(
// //                       onPressed: () {},
// //                       child: Text(
// //                         'See all',
// //                         style: AppTextStyles.link,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
              
// //               // Events List - Each item with fixed height to prevent overflow
// //               ListView.builder(
// //                 shrinkWrap: true,
// //                 physics: NeverScrollableScrollPhysics(),
// //                 padding: EdgeInsets.zero, // Remove default padding
// //                 itemCount: _events.length,
// //                 itemBuilder: (context, index) {
// //                   return Container(
// //                     height: 70, // Fixed height
// //                     margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
// //                     decoration: BoxDecoration(
// //                       color: Colors.white,
// //                       borderRadius: BorderRadius.circular(8),
// //                       boxShadow: [
// //                         BoxShadow(
// //                           color: Colors.black.withOpacity(0.05),
// //                           blurRadius: 4,
// //                           offset: Offset(0, 2),
// //                         ),
// //                       ],
// //                     ),
// //                     child: Row(
// //                       children: [
// //                         // Blue vertical indicator line
// //                         Container(
// //                           width: 4,
// //                           decoration: BoxDecoration(
// //                             color: AppColors.primaryBlue,
// //                             borderRadius: BorderRadius.only(
// //                               topLeft: Radius.circular(8),
// //                               bottomLeft: Radius.circular(8),
// //                             ),
// //                           ),
// //                         ),
// //                         Expanded(
// //                           child: Padding(
// //                             padding: const EdgeInsets.all(12.0),
// //                             child: Column(
// //                               crossAxisAlignment: CrossAxisAlignment.start,
// //                               mainAxisAlignment: MainAxisAlignment.center,
// //                               children: [
// //                                 Row(
// //                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                                   children: [
// //                                     Expanded(
// //                                       child: Text(
// //                                         _events[index].title,
// //                                         style: AppTextStyles.eventTitle,
// //                                         maxLines: 1,
// //                                         overflow: TextOverflow.ellipsis,
// //                                       ),
// //                                     ),
// //                                     Text(
// //                                       _events[index].timeRemaining,
// //                                       style: AppTextStyles.eventTimer,
// //                                     ),
// //                                   ],
// //                                 ),
// //                                 SizedBox(height: 4),
// //                                 Text(
// //                                   _events[index].venue,
// //                                   style: AppTextStyles.eventSubtitle,
// //                                   maxLines: 1,
// //                                   overflow: TextOverflow.ellipsis,
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   );
// //                 },
// //               ),
// //               // Add extra space at the bottom to avoid overlap with bottom nav
// //               SizedBox(height: 16),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildCarouselItem({bool isSecondPage = false}) {
// //     final size = MediaQuery.of(context).size;
    
// //     return Container(
// //       padding: EdgeInsets.all(16),
// //       child: Row(
// //         children: [
// //           Expanded(
// //             flex: 3,
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 // Title text
// //                 Text(
// //                   isSecondPage ? 'Stay Connected' : 'Extratech AMS',
// //                   style: TextStyle(
// //                     fontSize: size.width * 0.055,
// //                     fontWeight: FontWeight.bold,
// //                     color: AppColors.primaryBlue,
// //                   ),
// //                 ),
// //                 SizedBox(height: 4),
// //                 // Subtitle text
// //                 Text(
// //                   isSecondPage ? 'With Extratech AMS' : 'Academic Management System',
// //                   style: TextStyle(
// //                     fontSize: size.width * 0.04,
// //                     fontWeight: FontWeight.w500,
// //                     color: AppColors.primaryBlue,
// //                   ),
// //                   maxLines: 1,
// //                   overflow: TextOverflow.ellipsis,
// //                 ),
// //                 SizedBox(height: 4),
// //                 // Description text
// //                 Text(
// //                   isSecondPage 
// //                     ? 'Access all academic resources on the go'
// //                     : 'Simplifying enrollment, resources, attendance, quiz and communication',
// //                   style: TextStyle(
// //                     fontSize: size.width * 0.033,
// //                     color: AppColors.darkGrey,
// //                   ),
// //                   maxLines: 2,
// //                   overflow: TextOverflow.ellipsis,
// //                 ),
// //               ],
// //             ),
// //           ),
// //           // Logo - Using asset image instead of icon
// //           Container(
// //             width: size.width * 0.20,
// //             child: Center(
// //               child: Image.asset(
// //                 'assets/AMS Icon.png',
// //                 width: size.width * 0.15,
// //                 height: size.width * 0.15,
// //                 fit: BoxFit.contain,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }













// // import 'package:flutter/material.dart';
// // import 'package:ems/core/app_colors.dart';
// // import 'package:ems/core/app_text_styles.dart';
// // import '../../data/models/event_model.dart';
// // // import 'package:ems/widgets/carousel_item.dart';

// // class HomeScreen extends StatefulWidget {
// //   @override
// //   _HomeScreenState createState() => _HomeScreenState();
// // }

// // class _HomeScreenState extends State<HomeScreen> {
// //   final PageController _pageController = PageController();
// //   int _currentCarouselPage = 0;
// //   final List<EventModel> _events = EventModel.getDummyEvents();
  
// //   final List<Map<String, dynamic>> _menuItems = [
// //     {'icon': Icons.build_outlined, 'title': 'Services'},
// //     {'icon': Icons.calendar_today_outlined, 'title': 'Events'},
// //     {'icon': Icons.card_membership_outlined, 'title': 'Membership'},
// //     {'icon': Icons.article_outlined, 'title': 'Updates'},
// //   ];

// //   @override
// //   void dispose() {
// //     _pageController.dispose();
// //     super.dispose();
// //   }

// //   void _showComingSoonMessage() {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text('Coming Soon!'),
// //         duration: Duration(seconds: 2),
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     // Get screen size to make layout responsive
// //     final size = MediaQuery.of(context).size;
// //     final padding = MediaQuery.of(context).padding;
    
// //     // Calculate available height (subtract status bar and bottom nav)
// //     final availableHeight = size.height - padding.top - padding.bottom - 60; // 60 for bottom nav
    
// //     return SafeArea(
// //       child: Scaffold(
// //         backgroundColor: AppColors.lightBlueBackground,
// //         body: SingleChildScrollView(
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               // Carousel Section - Fixed height to prevent overflow
// //               Container(
// //                 height: availableHeight * 0.22, // Proportional height
// //                 width: double.infinity,
// //                 child: PageView(
// //                   controller: _pageController,
// //                   onPageChanged: (index) {
// //                     setState(() {
// //                       _currentCarouselPage = index;
// //                     });
// //                   },
// //                   children: [
// //                     _buildCarouselItem(),
// //                     _buildCarouselItem(isSecondPage: true),
// //                   ],
// //                 ),
// //               ),
              
// //               // Carousel Indicators
// //               Center(
// //                 child: Row(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [0, 1].map((index) {
// //                     return Container(
// //                       width: 8.0,
// //                       height: 8.0,
// //                       margin: EdgeInsets.symmetric(horizontal: 4.0),
// //                       decoration: BoxDecoration(
// //                         shape: BoxShape.circle,
// //                         color: _currentCarouselPage == index
// //                             ? AppColors.primaryBlue
// //                             : AppColors.lightGrey,
// //                       ),
// //                     );
// //                   }).toList(),
// //                 ),
// //               ),
// //               SizedBox(height: 15),
              
// //               // Logo Cards Row - Adaptive width based on screen size
// //               Padding(
// //                 padding: EdgeInsets.symmetric(horizontal: 16.0),
// //                 child: Row(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [
// //                     // AMS Logo Card
// //                     Expanded(
// //                       child: Container(
// //                         height: availableHeight * 0.18, // Proportional height
// //                         decoration: BoxDecoration(
// //                           color: Colors.white,
// //                           borderRadius: BorderRadius.circular(12),
// //                           boxShadow: [
// //                             BoxShadow(
// //                               color: Colors.black.withOpacity(0.05),
// //                               blurRadius: 5,
// //                               offset: Offset(0, 2),
// //                             ),
// //                           ],
// //                         ),
// //                         child: Column(
// //                           mainAxisAlignment: MainAxisAlignment.center,
// //                           children: [
// //                             // Logo icon - Using asset image instead of icon
// //                             Expanded(
// //                               flex: 5,
// //                               child: Center(
// //                                 child: Image.asset(
// //                                   'assets/AMS Icon.png',
// //                                   width: size.width * 0.12, // Responsive size
// //                                   height: size.width * 0.12,
// //                                   fit: BoxFit.contain,
// //                                 ),
// //                               ),
// //                             ),
// //                             // "AMS" text
// //                             Expanded(
// //                               flex: 3,
// //                               child: Center(
// //                                 child: Text(
// //                                   'AMS',
// //                                   style: TextStyle(
// //                                     fontSize: 20, // Responsive
// //                                     fontWeight: FontWeight.bold,
// //                                     color: AppColors.primaryBlue,
// //                                   ),
// //                                 ),
// //                               ),
// //                             ),
// //                             // "Academic Management System" text
// //                             Expanded(
// //                               flex: 2,
// //                               child: Padding(
// //                                 padding: EdgeInsets.symmetric(horizontal: 8.0),
// //                                 child: Center(
// //                                   child: Text(
// //                                     'Academic Management System',
// //                                     style: TextStyle(
// //                                       fontSize: size.width * 0.025, // Responsive
// //                                       color: Color(0xFF111213),
// //                                     ),
// //                                     textAlign: TextAlign.center,
// //                                     overflow: TextOverflow.ellipsis,
// //                                   ),
// //                                 ),
// //                               ),
// //                             ),
// //                             SizedBox(height: 5), // Prevent bottom overflow
// //                           ],
// //                         ),
// //                       ),
// //                     ),
// //                     SizedBox(width: 12),
// //                     // Extratech Oval Card
// //                     Expanded(
// //                       child: GestureDetector(
// //                         onTap: _showComingSoonMessage,
// //                         child: Container(
// //                           height: availableHeight * 0.18, // Proportional height
// //                           decoration: BoxDecoration(
// //                             color: Colors.white,
// //                             borderRadius: BorderRadius.circular(12),
// //                             boxShadow: [
// //                               BoxShadow(
// //                                 color: Colors.black.withOpacity(0.05),
// //                                 blurRadius: 5,
// //                                 offset: Offset(0, 2),
// //                               ),
// //                             ],
// //                           ),
// //                           child: Column(
// //                             mainAxisAlignment: MainAxisAlignment.center,
// //                             children: [
// //                               // Use a placeholder icon until actual asset is provided
// //                               Expanded(
// //                                 flex: 5,
// //                                 child: Center(
// //                                   child: Icon(
// //                                     Icons.sports_cricket,
// //                                     color: AppColors.primaryBlue,
// //                                     size: size.width * 0.12, // Responsive size
// //                                   ),
// //                                 ),
// //                               ),
// //                               Expanded(
// //                                 flex: 3,
// //                                 child: Center(
// //                                   child: Text(
// //                                     'EXTRATECH OVAL',
// //                                     style: TextStyle(
// //                                       fontSize: size.width * 0.03, // Responsive
// //                                       fontWeight: FontWeight.bold,
// //                                       color: AppColors.primaryBlue,
// //                                     ),
// //                                     textAlign: TextAlign.center,
// //                                   ),
// //                                 ),
// //                               ),
// //                               Expanded(
// //                                 flex: 2,
// //                                 child: Padding(
// //                                   padding: EdgeInsets.symmetric(horizontal: 8.0),
// //                                   child: Center(
// //                                     child: Text(
// //                                       'Connecting Nepal with Sports',
// //                                       style: TextStyle(
// //                                         fontSize: size.width * 0.025, // Responsive
// //                                         color: AppColors.darkGrey,
// //                                       ),
// //                                       textAlign: TextAlign.center,
// //                                       overflow: TextOverflow.ellipsis,
// //                                     ),
// //                                   ),
// //                                 ),
// //                               ),
// //                               SizedBox(height: 5), // Prevent bottom overflow
// //                             ],
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               SizedBox(height: 15),
              
// //               // Menu Icons - Scrollable row to prevent overflow
// //               Container(
// //                 height: availableHeight * 0.15, // Proportional height
// //                 width: double.infinity,
// //                 child: SingleChildScrollView(
// //                   scrollDirection: Axis.horizontal,
// //                   child: Padding(
// //                     padding: EdgeInsets.symmetric(horizontal: 16.0),
// //                     child: Row(
// //                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //                       children: _menuItems.map((item) {
// //                         return Container(
// //                           width: 75,
// //                           margin: EdgeInsets.symmetric(horizontal: 6),
// //                           child: GestureDetector(
// //                             onTap: _showComingSoonMessage,
// //                             child: Column(
// //                               mainAxisSize: MainAxisSize.min, // Prevent overflow
// //                               mainAxisAlignment: MainAxisAlignment.center,
// //                               children: [
// //                                 Container(
// //                                   width: 58,
// //                                   height: 58,
// //                                   decoration: BoxDecoration(
// //                                     color: Colors.white,
// //                                     borderRadius: BorderRadius.circular(12),
// //                                     boxShadow: [
// //                                       BoxShadow(
// //                                         color: Colors.black.withOpacity(0.05),
// //                                         blurRadius: 5,
// //                                         offset: Offset(0, 2),
// //                                       ),
// //                                     ],
// //                                   ),
// //                                   child: Icon(
// //                                     item['icon'],
// //                                     color: AppColors.primaryBlue,
// //                                     size: 32,
// //                                   ),
// //                                 ),
// //                                 SizedBox(height: 6),
// //                                 Text(
// //                                   item['title'],
// //                                   style: TextStyle(
// //                                     fontSize: 12,
// //                                     color: Colors.black87,
// //                                     fontWeight: FontWeight.w500,
// //                                   ),
// //                                   textAlign: TextAlign.center,
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                         );
// //                       }).toList(),
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //               SizedBox(height: 10),
              
// //               // Events Section Header
// //               Padding(
// //                 padding: EdgeInsets.symmetric(horizontal: 16.0),
// //                 child: Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                   children: [
// //                     Row(
// //                       children: [
// //                         Icon(
// //                           Icons.info_outline,
// //                           color: AppColors.primaryBlue,
// //                           size: 20,
// //                         ),
// //                         SizedBox(width: 8),
// //                         Text(
// //                           'Events',
// //                           style: AppTextStyles.heading2,
// //                         ),
// //                       ],
// //                     ),
// //                     TextButton(
// //                       onPressed: () {},
// //                       child: Text(
// //                         'See all',
// //                         style: AppTextStyles.link,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
              
// //               // Events List - Each item with fixed height to prevent overflow
// //               ListView.builder(
// //                 shrinkWrap: true,
// //                 physics: NeverScrollableScrollPhysics(),
// //                 padding: EdgeInsets.zero, // Remove default padding
// //                 itemCount: _events.length,
// //                 itemBuilder: (context, index) {
// //                   return Container(
// //                     height: 70, // Fixed height
// //                     margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
// //                     decoration: BoxDecoration(
// //                       color: Colors.white,
// //                       borderRadius: BorderRadius.circular(8),
// //                       boxShadow: [
// //                         BoxShadow(
// //                           color: Colors.black.withOpacity(0.05),
// //                           blurRadius: 4,
// //                           offset: Offset(0, 2),
// //                         ),
// //                       ],
// //                     ),
// //                     child: Row(
// //                       children: [
// //                         // Blue vertical indicator line
// //                         Container(
// //                           width: 4,
// //                           decoration: BoxDecoration(
// //                             color: AppColors.primaryBlue,
// //                             borderRadius: BorderRadius.only(
// //                               topLeft: Radius.circular(8),
// //                               bottomLeft: Radius.circular(8),
// //                             ),
// //                           ),
// //                         ),
// //                         Expanded(
// //                           child: Padding(
// //                             padding: const EdgeInsets.all(12.0),
// //                             child: Column(
// //                               crossAxisAlignment: CrossAxisAlignment.start,
// //                               mainAxisAlignment: MainAxisAlignment.center,
// //                               children: [
// //                                 Row(
// //                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                                   children: [
// //                                     Expanded(
// //                                       child: Text(
// //                                         _events[index].title,
// //                                         style: AppTextStyles.eventTitle,
// //                                         maxLines: 1,
// //                                         overflow: TextOverflow.ellipsis,
// //                                       ),
// //                                     ),
// //                                     Text(
// //                                       _events[index].timeRemaining,
// //                                       style: AppTextStyles.eventTimer,
// //                                     ),
// //                                   ],
// //                                 ),
// //                                 SizedBox(height: 4),
// //                                 Text(
// //                                   _events[index].venue,
// //                                   style: AppTextStyles.eventSubtitle,
// //                                   maxLines: 1,
// //                                   overflow: TextOverflow.ellipsis,
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   );
// //                 },
// //               ),
// //               // Add extra space at the bottom to avoid overlap with bottom nav
// //               SizedBox(height: 16),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildCarouselItem({bool isSecondPage = false}) {
// //     final size = MediaQuery.of(context).size;
    
// //     return Container(
// //       padding: EdgeInsets.all(16),
// //       child: Row(
// //         children: [
// //           Expanded(
// //             flex: 3,
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 // Title text
// //                 Text(
// //                   isSecondPage ? 'Stay Connected' : 'Extratech AMS',
// //                   style: TextStyle(
// //                     fontSize: size.width * 0.055,
// //                     fontWeight: FontWeight.bold,
// //                     color: AppColors.primaryBlue,
// //                   ),
// //                 ),
// //                 SizedBox(height: 4),
// //                 // Subtitle text
// //                 Text(
// //                   isSecondPage ? 'With Extratech AMS' : 'Academic Management System',
// //                   style: TextStyle(
// //                     fontSize: size.width * 0.04,
// //                     fontWeight: FontWeight.w500,
// //                     color: AppColors.primaryBlue,
// //                   ),
// //                   maxLines: 1,
// //                   overflow: TextOverflow.ellipsis,
// //                 ),
// //                 SizedBox(height: 4),
// //                 // Description text
// //                 Text(
// //                   isSecondPage 
// //                     ? 'Access all academic resources on the go'
// //                     : 'Simplifying enrollment, resources, attendance, quiz and communication',
// //                   style: TextStyle(
// //                     fontSize: size.width * 0.033,
// //                     color: AppColors.darkGrey,
// //                   ),
// //                   maxLines: 2,
// //                   overflow: TextOverflow.ellipsis,
// //                 ),
// //               ],
// //             ),
// //           ),
// //           // Logo - Using asset image instead of icon
// //           Container(
// //             width: size.width * 0.20,
// //             child: Center(
// //               child: Image.asset(
// //                 'assets/AMS Icon.png',
// //                 width: size.width * 0.15,
// //                 height: size.width * 0.15,
// //                 fit: BoxFit.contain,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }













// // import 'package:flutter/material.dart';
// // import 'package:ems/core/app_colors.dart';
// // import 'package:ems/core/app_text_styles.dart';
// // import '../../data/models/event_model.dart';
// // // import 'package:ems/widgets/carousel_item.dart';

// // class HomeScreen extends StatefulWidget {
// //   @override
// //   _HomeScreenState createState() => _HomeScreenState();
// // }

// // class _HomeScreenState extends State<HomeScreen> {
// //   final PageController _pageController = PageController();
// //   int _currentCarouselPage = 0;
// //   final List<EventModel> _events = EventModel.getDummyEvents();
  
// //   final List<Map<String, dynamic>> _menuItems = [
// //     {'icon': Icons.build_outlined, 'title': 'Services'},
// //     {'icon': Icons.calendar_today_outlined, 'title': 'Events'},
// //     {'icon': Icons.card_membership_outlined, 'title': 'Membership'},
// //     {'icon': Icons.article_outlined, 'title': 'Updates'},
// //   ];

// //   @override
// //   void dispose() {
// //     _pageController.dispose();
// //     super.dispose();
// //   }

// //   void _showComingSoonMessage() {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text('Coming Soon!'),
// //         duration: Duration(seconds: 2),
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     // Get screen size to make layout responsive
// //     final size = MediaQuery.of(context).size;
// //     final padding = MediaQuery.of(context).padding;
    
// //     // Calculate available height (subtract status bar and bottom nav)
// //     final availableHeight = size.height - padding.top - padding.bottom - 60; // 60 for bottom nav
    
// //     return SafeArea(
// //       child: Scaffold(
// //         backgroundColor: AppColors.lightBlueBackground,
// //         body: SingleChildScrollView(
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               // Carousel Section - Fixed height to prevent overflow
// //               Container(
// //                 height: availableHeight * 0.22, // Proportional height
// //                 width: double.infinity,
// //                 child: PageView(
// //                   controller: _pageController,
// //                   onPageChanged: (index) {
// //                     setState(() {
// //                       _currentCarouselPage = index;
// //                     });
// //                   },
// //                   children: [
// //                     _buildCarouselItem(),
// //                     _buildCarouselItem(isSecondPage: true),
// //                   ],
// //                 ),
// //               ),
              
// //               // Carousel Indicators
// //               Center(
// //                 child: Row(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [0, 1].map((index) {
// //                     return Container(
// //                       width: 8.0,
// //                       height: 8.0,
// //                       margin: EdgeInsets.symmetric(horizontal: 4.0),
// //                       decoration: BoxDecoration(
// //                         shape: BoxShape.circle,
// //                         color: _currentCarouselPage == index
// //                             ? AppColors.primaryBlue
// //                             : AppColors.lightGrey,
// //                       ),
// //                     );
// //                   }).toList(),
// //                 ),
// //               ),
// //               SizedBox(height: 15),
              
// //               // Logo Cards Row - Adaptive width based on screen size
// //               Padding(
// //                 padding: EdgeInsets.symmetric(horizontal: 16.0),
// //                 child: Row(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [
// //                     // AMS Logo Card
// //                     Expanded(
// //                       child: Container(
// //                         height: availableHeight * 0.18, // Proportional height
// //                         decoration: BoxDecoration(
// //                           color: Colors.white,
// //                           borderRadius: BorderRadius.circular(12),
// //                           boxShadow: [
// //                             BoxShadow(
// //                               color: Colors.black.withOpacity(0.05),
// //                               blurRadius: 5,
// //                               offset: Offset(0, 2),
// //                             ),
// //                           ],
// //                         ),
// //                         child: Column(
// //                           mainAxisAlignment: MainAxisAlignment.center,
// //                           children: [
// //                             // Logo icon
// //                             Expanded(
// //                               flex: 5,
// //                               child: Center(
// //                                 child: Icon(
// //                                   Icons.school,
// //                                   color: AppColors.accentPink,
// //                                   size: size.width * 0.12, // Responsive size
// //                                 ),
// //                               ),
// //                             ),
// //                             // "AMS" text
// //                             Expanded(
// //                               flex: 3,
// //                               child: Center(
// //                                 child: Text(
// //                                   'AMS',
// //                                   style: TextStyle(
// //                                     fontSize: 20, // Responsive
// //                                     fontWeight: FontWeight.bold,
// //                                     color: AppColors.primaryBlue,
// //                                   ),
// //                                 ),
// //                               ),
// //                             ),
// //                             // "Academic Management System" text
// //                             Expanded(
// //                               flex: 2,
// //                               child: Padding(
// //                                 padding: EdgeInsets.symmetric(horizontal: 8.0),
// //                                 child: Center(
// //                                   child: Text(
// //                                     'Academic Management System',
// //                                     style: TextStyle(
// //                                       fontSize: size.width * 0.025, // Responsive
// //                                       color: Color(0xFF111213),
// //                                     ),
// //                                     textAlign: TextAlign.center,
// //                                     overflow: TextOverflow.ellipsis,
// //                                   ),
// //                                 ),
// //                               ),
// //                             ),
// //                             SizedBox(height: 5), // Prevent bottom overflow
// //                           ],
// //                         ),
// //                       ),
// //                     ),
// //                     SizedBox(width: 12),
// //                     // Extratech Oval Card
// //                     Expanded(
// //                       child: GestureDetector(
// //                         onTap: _showComingSoonMessage,
// //                         child: Container(
// //                           height: availableHeight * 0.18, // Proportional height
// //                           decoration: BoxDecoration(
// //                             color: Colors.white,
// //                             borderRadius: BorderRadius.circular(12),
// //                             boxShadow: [
// //                               BoxShadow(
// //                                 color: Colors.black.withOpacity(0.05),
// //                                 blurRadius: 5,
// //                                 offset: Offset(0, 2),
// //                               ),
// //                             ],
// //                           ),
// //                           child: Column(
// //                             mainAxisAlignment: MainAxisAlignment.center,
// //                             children: [
// //                               // Use a placeholder icon until actual asset is provided
// //                               Expanded(
// //                                 flex: 5,
// //                                 child: Center(
// //                                   child: Icon(
// //                                     Icons.sports_cricket,
// //                                     color: AppColors.primaryBlue,
// //                                     size: size.width * 0.12, // Responsive size
// //                                   ),
// //                                 ),
// //                               ),
// //                               Expanded(
// //                                 flex: 3,
// //                                 child: Center(
// //                                   child: Text(
// //                                     'EXTRATECH OVAL',
// //                                     style: TextStyle(
// //                                       fontSize: size.width * 0.03, // Responsive
// //                                       fontWeight: FontWeight.bold,
// //                                       color: AppColors.primaryBlue,
// //                                     ),
// //                                     textAlign: TextAlign.center,
// //                                   ),
// //                                 ),
// //                               ),
// //                               Expanded(
// //                                 flex: 2,
// //                                 child: Padding(
// //                                   padding: EdgeInsets.symmetric(horizontal: 8.0),
// //                                   child: Center(
// //                                     child: Text(
// //                                       'Connecting Nepal with Sports',
// //                                       style: TextStyle(
// //                                         fontSize: size.width * 0.025, // Responsive
// //                                         color: AppColors.darkGrey,
// //                                       ),
// //                                       textAlign: TextAlign.center,
// //                                       overflow: TextOverflow.ellipsis,
// //                                     ),
// //                                   ),
// //                                 ),
// //                               ),
// //                               SizedBox(height: 5), // Prevent bottom overflow
// //                             ],
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               SizedBox(height: 15),
              
// //               // Menu Icons - Scrollable row to prevent overflow
// //               Container(
// //                 height: availableHeight * 0.15, // Proportional height
// //                 width: double.infinity,
// //                 child: SingleChildScrollView(
// //                   scrollDirection: Axis.horizontal,
// //                   child: Padding(
// //                     padding: EdgeInsets.symmetric(horizontal: 16.0),
// //                     child: Row(
// //                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //                       children: _menuItems.map((item) {
// //                         return Container(
// //                           width: 75,
// //                           margin: EdgeInsets.symmetric(horizontal: 6),
// //                           child: GestureDetector(
// //                             onTap: _showComingSoonMessage,
// //                             child: Column(
// //                               mainAxisSize: MainAxisSize.min, // Prevent overflow
// //                               mainAxisAlignment: MainAxisAlignment.center,
// //                               children: [
// //                                 Container(
// //                                   width: 58,
// //                                   height: 58,
// //                                   decoration: BoxDecoration(
// //                                     color: Colors.white,
// //                                     borderRadius: BorderRadius.circular(12),
// //                                     boxShadow: [
// //                                       BoxShadow(
// //                                         color: Colors.black.withOpacity(0.05),
// //                                         blurRadius: 5,
// //                                         offset: Offset(0, 2),
// //                                       ),
// //                                     ],
// //                                   ),
// //                                   child: Icon(
// //                                     item['icon'],
// //                                     color: AppColors.primaryBlue,
// //                                     size: 32,
// //                                   ),
// //                                 ),
// //                                 SizedBox(height: 6),
// //                                 Text(
// //                                   item['title'],
// //                                   style: TextStyle(
// //                                     fontSize: 12,
// //                                     color: Colors.black87,
// //                                     fontWeight: FontWeight.w500,
// //                                   ),
// //                                   textAlign: TextAlign.center,
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                         );
// //                       }).toList(),
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //               SizedBox(height: 10),
              
// //               // Events Section Header
// //               Padding(
// //                 padding: EdgeInsets.symmetric(horizontal: 16.0),
// //                 child: Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                   children: [
// //                     Row(
// //                       children: [
// //                         Icon(
// //                           Icons.info_outline,
// //                           color: AppColors.primaryBlue,
// //                           size: 20,
// //                         ),
// //                         SizedBox(width: 8),
// //                         Text(
// //                           'Events',
// //                           style: AppTextStyles.heading2,
// //                         ),
// //                       ],
// //                     ),
// //                     TextButton(
// //                       onPressed: () {},
// //                       child: Text(
// //                         'See all',
// //                         style: AppTextStyles.link,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
              
// //               // Events List - Each item with fixed height to prevent overflow
// //               ListView.builder(
// //                 shrinkWrap: true,
// //                 physics: NeverScrollableScrollPhysics(),
// //                 padding: EdgeInsets.zero, // Remove default padding
// //                 itemCount: _events.length,
// //                 itemBuilder: (context, index) {
// //                   return Container(
// //                     height: 70, // Fixed height
// //                     margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
// //                     decoration: BoxDecoration(
// //                       color: Colors.white,
// //                       borderRadius: BorderRadius.circular(8),
// //                       boxShadow: [
// //                         BoxShadow(
// //                           color: Colors.black.withOpacity(0.05),
// //                           blurRadius: 4,
// //                           offset: Offset(0, 2),
// //                         ),
// //                       ],
// //                     ),
// //                     child: Row(
// //                       children: [
// //                         // Blue vertical indicator line
// //                         Container(
// //                           width: 4,
// //                           decoration: BoxDecoration(
// //                             color: AppColors.primaryBlue,
// //                             borderRadius: BorderRadius.only(
// //                               topLeft: Radius.circular(8),
// //                               bottomLeft: Radius.circular(8),
// //                             ),
// //                           ),
// //                         ),
// //                         Expanded(
// //                           child: Padding(
// //                             padding: const EdgeInsets.all(12.0),
// //                             child: Column(
// //                               crossAxisAlignment: CrossAxisAlignment.start,
// //                               mainAxisAlignment: MainAxisAlignment.center,
// //                               children: [
// //                                 Row(
// //                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                                   children: [
// //                                     Expanded(
// //                                       child: Text(
// //                                         _events[index].title,
// //                                         style: AppTextStyles.eventTitle,
// //                                         maxLines: 1,
// //                                         overflow: TextOverflow.ellipsis,
// //                                       ),
// //                                     ),
// //                                     Text(
// //                                       _events[index].timeRemaining,
// //                                       style: AppTextStyles.eventTimer,
// //                                     ),
// //                                   ],
// //                                 ),
// //                                 SizedBox(height: 4),
// //                                 Text(
// //                                   _events[index].venue,
// //                                   style: AppTextStyles.eventSubtitle,
// //                                   maxLines: 1,
// //                                   overflow: TextOverflow.ellipsis,
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   );
// //                 },
// //               ),
// //               // Add extra space at the bottom to avoid overlap with bottom nav
// //               SizedBox(height: 16),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildCarouselItem({bool isSecondPage = false}) {
// //     final size = MediaQuery.of(context).size;
    
// //     return Container(
// //       padding: EdgeInsets.all(16),
// //       child: Row(
// //         children: [
// //           Expanded(
// //             flex: 3,
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 // Title text
// //                 Text(
// //                   isSecondPage ? 'Stay Connected' : 'Extratech AMS',
// //                   style: TextStyle(
// //                     fontSize: size.width * 0.055,
// //                     fontWeight: FontWeight.bold,
// //                     color: AppColors.primaryBlue,
// //                   ),
// //                 ),
// //                 SizedBox(height: 4),
// //                 // Subtitle text
// //                 Text(
// //                   isSecondPage ? 'With Extratech AMS' : 'Academic Management',
// //                   style: TextStyle(
// //                     fontSize: size.width * 0.04,
// //                     fontWeight: FontWeight.w500,
// //                     color: AppColors.primaryBlue,
// //                   ),
// //                   maxLines: 1,
// //                   overflow: TextOverflow.ellipsis,
// //                 ),
// //                 SizedBox(height: 4),
// //                 // Description text
// //                 Text(
// //                   isSecondPage 
// //                     ? 'Access all academic resources on the go'
// //                     : 'Simplifying enrollment, resources, attendance, quiz and communication',
// //                   style: TextStyle(
// //                     fontSize: size.width * 0.033,
// //                     color: AppColors.darkGrey,
// //                   ),
// //                   maxLines: 2,
// //                   overflow: TextOverflow.ellipsis,
// //                 ),
// //               ],
// //             ),
// //           ),
// //           // Logo
// //           Container(
// //             width: size.width * 0.20,
// //             child: Center(
// //               child: Icon(
// //                 Icons.school,
// //                 color: AppColors.accentPink,
// //                 size: size.width * 0.15,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }