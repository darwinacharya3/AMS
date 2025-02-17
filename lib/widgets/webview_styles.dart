import 'package:webview_flutter/webview_flutter.dart';

class WebViewStyles {
  static const String _customCSS = '''
    /* Original CSS stays the same */
    .navbar-brand-wrapper {
      display: none !important;
    }
    
    .navbar-menu-wrapper .navbar-toggler {
      display: none !important;
    }
    
    .profile-top.profile-top-flex-2 {
      position: relative !important;
      padding-right: 60px !important;
      cursor: pointer !important;
    }
    
    .profile-top.profile-top-flex-2::after {
      content: "" !important;
      position: absolute !important;
      right: 15px !important;
      top: 50% !important;
      transform: translateY(-50%) !important;
      width: 30px !important;
      height: 30px !important;
      background-image: url('https://extratech.extratechweb.com/images/navigation-bar.png') !important;
      background-size: contain !important;
      background-repeat: no-repeat !important;
      background-position: center !important;
      z-index: 100 !important;
      
    }

     /* Add styles for clickable area */
    .hamburger-click-area {
      position: absolute !important;
      right: 0 !important;
      top: 0 !important;
      width: 60px !important;
      height: 100% !important;
      z-index: 101 !important;
      cursor: pointer !important;
    }
    
    .profile-general {
      display: flex !important;
      align-items: center !important;
      gap: 15px !important;
    }
    
    .profile-desc {
      margin-left: 10px !important;
    }
    
    @media (max-width: 768px) {
      .profile-top.profile-top-flex-2 {
        padding-right: 50px !important;
      }
      
      .profile-top.profile-top-flex-2::after {
        right: 10px !important;
      }
      
      .hamburger-click-area {
        width: 50px !important;
      }
    }
    
    
    .course-col, .student-dash-col {
      position: relative !important;
      z-index: 1 !important;
    }
  ''';

   static Future<void> injectCustomStyles(WebViewController controller) async {
    const String jsCode = '''
      // Immediately execute when page loads
      (function() {
        // Block alert dialogs and other popup-related code stays the same...
        
        // Add custom styles
        var style = document.createElement('style');
        style.textContent = `${_customCSS}`;
        document.head.appendChild(style);
        
        // Enhanced hamburger menu functionality
        function setupHamburgerMenu() {
          const profileTop = document.querySelector('.profile-top.profile-top-flex-2');
          if (!profileTop) return;
          
          // Remove any existing click handlers
          const oldClickArea = profileTop.querySelector('.hamburger-click-area');
          if (oldClickArea) oldClickArea.remove();
          
          // Create new click area
          const clickArea = document.createElement('div');
          clickArea.className = 'hamburger-click-area';
          profileTop.appendChild(clickArea);
          
          // Add click handler to the new area
          clickArea.addEventListener('click', function(e) {
            e.stopPropagation(); // Prevent event bubbling
            const navbarToggler = document.querySelector('.navbar-toggler');
            if (navbarToggler) {
              // Simulate a real click
              const clickEvent = new MouseEvent('click', {
                view: window,
                bubbles: true,
                cancelable: true
              });
              navbarToggler.dispatchEvent(clickEvent);
              
              // Additional fallback to trigger menu toggle
              const sidebar = document.querySelector('.sidebar');
              if (sidebar) {
                sidebar.classList.toggle('active');
              }
            }
          });
        }
        
        // Initial setup
        setupHamburgerMenu();
        
        // Setup observer for dynamic content
        const observer = new MutationObserver(function(mutations) {
          setupHamburgerMenu();
        });
        
        observer.observe(document.body, {
          childList: true,
          subtree: true
        });
      })();
    ''';

    try {
      // Execute the JavaScript immediately when page starts loading
      await controller.runJavaScript(jsCode);
      print('Debug: Custom styles and hamburger menu handler injected successfully');
      
      // Add a delayed second injection to catch any late-loading elements
      await Future.delayed(const Duration(milliseconds: 500));
      await controller.runJavaScript(jsCode);
      
      // Add another delayed injection for better reliability
      await Future.delayed(const Duration(seconds: 2));
      await controller.runJavaScript(jsCode);
    } catch (e) {
      print('Error injecting custom styles and hamburger menu handler: $e');
    }
  }

  
}











// import 'package:webview_flutter/webview_flutter.dart';

// class WebViewStyles {
//   static const String _customCSS = '''
//     /* Original CSS remains the same */
//     .navbar-brand-wrapper {
//       display: none !important;
//     }
    
//     .navbar-menu-wrapper .navbar-toggler {
//       display: none !important;
//     }
    
//     .profile-top.profile-top-flex-2 {
//       position: relative !important;
//       padding-right: 60px !important;
//     }
    
//     .profile-top.profile-top-flex-2::after {
//       content: "" !important;
//       position: absolute !important;
//       right: 15px !important;
//       top: 50% !important;
//       transform: translateY(-50%) !important;
//       width: 30px !important;
//       height: 30px !important;
//       background-image: url('https://extratech.extratechweb.com/images/navigation-bar.png') !important;
//       background-size: contain !important;
//       background-repeat: no-repeat !important;
//       background-position: center !important;
//       cursor: pointer !important;
//     }
    
//     .profile-general {
//       display: flex !important;
//       align-items: center !important;
//       gap: 15px !important;
//     }
    
//     .profile-desc {
//       margin-left: 10px !important;
//     }
    
//     @media (max-width: 768px) {
//       .profile-top.profile-top-flex-2 {
//         padding-right: 50px !important;
//       }
      
//       .profile-top.profile-top-flex-2::after {
//         right: 10px !important;
//       }
//     }
    
//     .course-col, .student-dash-col {
//       position: relative !important;
//       z-index: 1 !important;
//     }

//     /* Hide error popup dialog */
//     .swal2-container {
//       display: none !important;
//     }
//     .swal2-backdrop-show {
//       display: none !important;
//     }
//     .sweet-alert {
//       display: none !important;
//     }
//   ''';

//   static Future<void> injectCustomStyles(WebViewController controller) async {
//     const String jsCode = '''
//       // Add custom styles
//       var style = document.createElement('style');
//       style.textContent = `${_customCSS}`;
//       document.head.appendChild(style);
      
//       // Add click handler to new hamburger menu
//       document.querySelector('.profile-top.profile-top-flex-2')?.addEventListener('click', function(e) {
//         const rect = this.getBoundingClientRect();
//         const clickX = e.clientX - rect.left;
        
//         if (clickX > rect.width - 60) {
//           document.querySelector('.navbar-toggler')?.click();
//         }
//       });

//       // Override the default alert function
//       window.alert = function(msg) {
//         console.log('Alert suppressed:', msg);
//         return;
//       };

//       // Handle SweetAlert if it exists
//       if (window.Swal) {
//         window.Swal.fire = function() {
//           console.log('SweetAlert suppressed');
//           return Promise.resolve();
//         };
//       }

//       // Override any existing error popup handlers
//       const observer = new MutationObserver(function(mutations) {
//         mutations.forEach(function(mutation) {
//           mutation.addedNodes.forEach(function(node) {
//             if (node.classList && 
//                (node.classList.contains('swal2-container') || 
//                 node.classList.contains('sweet-alert'))) {
//               node.remove();
//             }
//           });
//         });
//       });

//       observer.observe(document.body, {
//         childList: true,
//         subtree: true
//       });
//     ''';

//     try {
//       await controller.runJavaScript(jsCode);
//       print('Debug: Custom styles and popup handlers injected successfully');
//     } catch (e) {
//       print('Error injecting custom styles and popup handlers: $e');
//     }
//   }
// }














// // import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// class WebViewStyles {
//   static const String _customCSS = '''
//     /* Hide original navbar and logo */
//     .navbar-brand-wrapper {
//       display: none !important;
//     }
    
//     /* Hide original hamburger menu from navbar */
//     .navbar-menu-wrapper .navbar-toggler {
//       display: none !important;
//     }
    
//     /* Adjust profile section to accommodate hamburger menu */
//     .profile-top.profile-top-flex-2 {
//       position: relative !important;
//       padding-right: 60px !important;
//     }
    
//     /* Create new hamburger menu in profile section */
//     .profile-top.profile-top-flex-2::after {
//       content: "" !important;
//       position: absolute !important;
//       right: 15px !important;
//       top: 50% !important;
//       transform: translateY(-50%) !important;
//       width: 30px !important;
//       height: 30px !important;
//       background-image: url('https://extratech.extratechweb.com/images/navigation-bar.png') !important;
//       background-size: contain !important;
//       background-repeat: no-repeat !important;
//       background-position: center !important;
//       cursor: pointer !important;
//     }
    
//     /* Ensure profile section layout */
//     .profile-general {
//       display: flex !important;
//       align-items: center !important;
//       gap: 15px !important;
//     }
    
//     .profile-desc {
//       margin-left: 10px !important;
//     }
    
//     /* Mobile responsive adjustments */
//     @media (max-width: 768px) {
//       .profile-top.profile-top-flex-2 {
//         padding-right: 50px !important;
//       }
      
//       .profile-top.profile-top-flex-2::after {
//         right: 10px !important;
//       }
//     }
    
//     /* Ensure other elements maintain their position */
//     .course-col, .student-dash-col {
//       position: relative !important;
//       z-index: 1 !important;
//     }
//   ''';

//   static Future<void> injectCustomStyles(WebViewController controller) async {
//     const String jsCode = '''
//       // Add custom styles
//       var style = document.createElement('style');
//       style.textContent = `${_customCSS}`;
//       document.head.appendChild(style);
      
//       // Add click handler to new hamburger menu
//       document.querySelector('.profile-top.profile-top-flex-2').addEventListener('click', function(e) {
//         // Check if click was on the hamburger menu area
//         const rect = this.getBoundingClientRect();
//         const clickX = e.clientX - rect.left;
        
//         if (clickX > rect.width - 60) { // If click is in hamburger menu area
//           // Trigger original navbar toggle
//           document.querySelector('.navbar-toggler').click();
//         }
//       });
//     ''';

//     try {
//       await controller.runJavaScript(jsCode);
//       print('Debug: Custom styles and click handler injected successfully');
//     } catch (e) {
//       print('Error injecting custom styles: $e');
//     }
//   }
// }