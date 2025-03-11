import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CareerController extends StateNotifier<WebViewController> {
  CareerController() : super(WebViewController()) {
    // Using a local variable for clarity
    final controller = state;
    
    controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    controller.setNavigationDelegate(
      NavigationDelegate(
        onPageFinished: (String url) async {
          // Initial script to hide navigation elements
          await controller.runJavaScript('''
            console.log('Page loaded, running initial hiding script');
            
            // Function to hide navbar and other navigation elements
            function hideNavElements() {
              // Try multiple different selectors to ensure we catch the navbar
              const navSelectors = [
                '.light-blue.navbar.default-layout-navbar',
                'nav.light-blue',
                'nav.default-layout-navbar',
                '.navbar.fixed-top',
                'nav.fixed-top',
                'nav.col-lg-12.col-12.p-0.fixed-top',
                '.navbar-brand-wrapper',
                '.navbar-menu-wrapper'
              ];
              
              let navFound = false;
              
              navSelectors.forEach(selector => {
                const elements = document.querySelectorAll(selector);
                if (elements.length > 0) {
                  navFound = true;
                  console.log('Found navbar elements with selector: ' + selector + ', count: ' + elements.length);
                  elements.forEach(el => {
                    el.style.display = 'none';
                    el.style.visibility = 'hidden';
                    el.style.height = '0';
                    el.style.overflow = 'hidden';
                    el.style.position = 'absolute';
                    el.style.top = '-9999px';
                  });
                }
              });
              
              // Hide the middle section navigation (General, Attendance, Quiz, Career)
              const middleNavSelectors = [
                // Look for divs containing these navigation items
                'div:has(a:contains("General"), a:contains("Attendance"), a:contains("Quiz"), a:contains("Career"))',
                // Try by container classes
                '.nav-tabs',
                '.tabs-container',
                '.menu-container',
                // Try by flex or grid containers
                '.row:has(.col:has(a))',
                '.d-flex:has(a)',
              ];
              
              // Using a different approach to find the middle navigation
              try {
                // Find elements containing these specific text items
                const textContents = ['General', 'Attendance', 'Quiz', 'Career'];
                const allLinks = document.querySelectorAll('a');
                let middleNavParent = null;
                
                allLinks.forEach(link => {
                  if (textContents.some(text => link.textContent.includes(text))) {
                    console.log('Found nav link: ' + link.textContent);
                    // Find the parent container
                    let parent = link.parentElement;
                    // Go up 2-3 levels to find the container of all links
                    for (let i = 0; i < 3; i++) {
                      if (parent) {
                        if (parent.querySelectorAll('a').length >= 2) {
                          middleNavParent = parent;
                          break;
                        }
                        parent = parent.parentElement;
                      }
                    }
                  }
                });
                
                if (middleNavParent) {
                  console.log('Found middle navigation container');
                  middleNavParent.style.display = 'none';
                }
              } catch (e) {
                console.error('Error hiding middle navigation: ' + e);
              }
              
              // Handle any extra padding
              document.body.style.paddingTop = '0';
              document.body.style.marginTop = '0';
              
              // Look for specific div elements that might contain the navbar
              document.querySelectorAll('.fixed-top, header, .header, .top-bar').forEach(el => {
                el.style.display = 'none';
                el.style.visibility = 'hidden';
              });
              
              return navFound;
            }
            
            // First attempt immediately
            const initialHide = hideNavElements();
            console.log('Initial elements hiding attempt: ' + (initialHide ? 'found elements' : 'no elements found'));
            
            // Then set up repeated attempts to handle delayed loading
            let attempts = 0;
            const maxAttempts = 5;
            const hideInterval = setInterval(() => {
              attempts++;
              const found = hideNavElements();
              console.log('Attempt ' + attempts + ': ' + (found ? 'found elements' : 'no elements found'));
              
              if (attempts >= maxAttempts) {
                console.log('Reached maximum hide attempts');
                clearInterval(hideInterval);
              }
            }, 1000);
          ''');
          
          // Handle tab selection after a delay
          await Future.delayed(const Duration(seconds: 2));
          await controller.runJavaScript('''
            try {
              // One last attempt to hide the navigation elements
              hideNavElements();
              
              // Find Career tab explicitly by text content
              const tabs = Array.from(document.querySelectorAll('a[role="tab"]'));
              console.log('Found ' + tabs.length + ' tabs');
              
              // Look for the career tab by checking content and click it
              const careerTab = tabs.find(tab => 
                tab.textContent.includes('Career') ||
                tab.querySelector('h1')?.textContent.includes('Career')
              );
              
              if (careerTab) {
                console.log('Found career tab, clicking it');
                careerTab.click();
              } else {
                console.error('Could not find career tab');
                // Fallback to ID or data-bs-target if available
                document.getElementById('nav-performance-tab')?.click() || 
                document.querySelector('a[data-bs-target="#nav-performance"]')?.click();
              }
              
              // Hide profile sections
              document.querySelectorAll('.profile, .profile-section, .user-profile, .nav-profile').forEach(el => {
                console.log('Hiding profile section');
                el.style.display = 'none';
              });
              
              // Add CSS via stylesheet to ensure elements stay hidden
              const style = document.createElement('style');
              style.textContent = `
                /* Hide main navbar */
                nav.light-blue.navbar.default-layout-navbar,
                .light-blue.navbar.default-layout-navbar,
                nav.fixed-top,
                .navbar.fixed-top,
                .fixed-top,
                header, 
                .header,
                .navbar-brand-wrapper,
                .navbar-menu-wrapper {
                  display: none !important;
                  visibility: hidden !important;
                  height: 0 !important;
                  overflow: hidden !important;
                  position: absolute !important;
                  top: -9999px !important;
                }
                
                /* Hide middle navigation section */
                a[href*="general"],
                a[href*="attendance"],
                a[href*="quiz"],
                a:not([role="tab"]):contains("General"),
                a:not([role="tab"]):contains("Attendance"),
                a:not([role="tab"]):contains("Quiz"),
                a:not([role="tab"]):contains("Career") {
                  display: none !important;
                }
                
                /* Hide container of middle navigation links */
                .nav-tabs:not([id]),
                .d-flex:has(a[href*="general"]),
                .d-flex:has(a:contains("General")),
                .row:has(a:contains("General")) {
                  display: none !important;
                }
                
                body {
                  padding-top: 0 !important;
                  margin-top: 0 !important;
                }
              `;
              document.head.appendChild(style);
              console.log('Added persistent CSS to hide navbar and navigation');
              
              // Extra attempt to find and hide the middle navigation
              setTimeout(() => {
                // Look for links with specific texts
                document.querySelectorAll('a').forEach(link => {
                  if (['General', 'Attendance', 'Quiz', 'Career'].some(text => link.textContent.includes(text))) {
                    // Hide the link itself
                    link.style.display = 'none';
                    
                    // Try to find and hide the parent container
                    let parent = link.parentElement;
                    for (let i = 0; i < 3; i++) {
                      if (parent) {
                        // Check if this is likely the container of all nav links
                        if (parent.querySelectorAll('a').length >= 2) {
                          parent.style.display = 'none';
                          console.log('Hiding middle nav container');
                          break;
                        }
                        parent = parent.parentElement;
                      }
                    }
                  }
                });
              }, 2000);
              
            } catch (e) {
              console.error('Error in tab processing: ' + e);
            }
          ''');
        },
        onPageStarted: (String url) async {
          // Inject CSS as early as possible
          await controller.runJavaScript('''
            // Create and add a style element to hide navbar elements immediately
            const earlyStyle = document.createElement('style');
            earlyStyle.textContent = `
              /* Hide main nav elements */
              nav, .navbar, .fixed-top, .light-blue, .navbar-brand-wrapper, .navbar-menu-wrapper, header, .header {
                display: none !important;
                visibility: hidden !important;
              }
              
              /* Early attempt to hide middle navigation */
              a:contains("General"), a:contains("Attendance"), a:contains("Quiz"), a:contains("Career"),
              div:has(a:contains("General")), div:has(a:contains("Attendance")), div:has(a:contains("Quiz")), div:has(a:contains("Career")) {
                display: none !important;
              }
            `;
            document.head.appendChild(earlyStyle);
            console.log('Early CSS injection to hide navigation elements');
          ''');
        },
      ),
    );
    controller.loadRequest(Uri.parse('https://extratech.extratechweb.com/student'));
  }

  Future<bool> canGoBack() async {
    return await state.canGoBack();
  }

  void goBack() {
    state.goBack();
  }
}

final careerControllerProvider = StateNotifierProvider<CareerController, WebViewController>((ref) {
  return CareerController();
});










