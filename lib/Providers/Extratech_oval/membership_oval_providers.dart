import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ems/services/Extratech_oval/membership_card_oval_services.dart';
import 'package:ems/services/secure_storage_service.dart';

// Provider for membership types with better error handling
final generalMembershipTypesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  try {
    final types = await GeneralMembershipCardService.getMembershipTypes();
    if (types.isEmpty) {
      debugPrint('Retrieved empty membership types list');
    } else {
      debugPrint('Retrieved ${types.length} membership types');
    }
    return types;
  } catch (e, stack) {
    debugPrint('Error in generalMembershipTypesProvider: $e');
    debugPrint('Stack trace: $stack');
    throw e; // Re-throw to let the UI handle it
  }
});

// Provider for membership card data
final generalMembershipCardProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  try {
    final cardData = await GeneralMembershipCardService.getMembershipCard();
    if (cardData != null) {
      debugPrint('Retrieved membership card data');
    } else {
      debugPrint('No membership card data found');
    }
    return cardData;
  } catch (e, stack) {
    debugPrint('Error in generalMembershipCardProvider: $e');
    debugPrint('Stack trace: $stack');
    throw e;
  }
});

// Provider for country list using the new combined endpoint
final countryListProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  try {
    final countries = await GeneralMembershipCardService.getCountryList();
    debugPrint('Retrieved ${countries.length} countries');
    return countries;
  } catch (e, stack) {
    debugPrint('Error in countryListProvider: $e');
    debugPrint('Stack trace: $stack');
    throw e;
  }
});

// Provider for state list by country using the new combined endpoint
final stateListProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, countryId) async {
  try {
    final states = await GeneralMembershipCardService.getStateList(countryId);
    debugPrint('Retrieved ${states.length} states for country $countryId');
    return states;
  } catch (e, stack) {
    debugPrint('Error in stateListProvider for country $countryId: $e');
    debugPrint('Stack trace: $stack');
    throw e;
  }
});

// User data provider
final userEmailProvider = FutureProvider<String?>((ref) async {
  try {
    final email = await SecureStorageService.getUserEmail();
    return email;
  } catch (e) {
    debugPrint('Error in userEmailProvider: $e');
    return null;
  }
});

// Authentication state provider
final isAuthenticatedProvider = FutureProvider<bool>((ref) async {
  try {
    final token = await SecureStorageService.getToken();
    return token != null;
  } catch (e) {
    debugPrint('Error in isAuthenticatedProvider: $e');
    return false;
  }
});

// Form state providers
final selectedGeneralMembershipTypeProvider = StateProvider<int?>((ref) => null);
final firstNameProvider = StateProvider<String>((ref) => '');
final middleNameProvider = StateProvider<String>((ref) => '');
final lastNameProvider = StateProvider<String>((ref) => '');
final dobProvider = StateProvider<String>((ref) => '');
final selectedCountryIdProvider = StateProvider<int?>((ref) => null);
final selectedStateIdProvider = StateProvider<int?>((ref) => null);
final addressProvider = StateProvider<String>((ref) => '');
final emailProvider = StateProvider<String>((ref) => '');
final phoneProvider = StateProvider<String>((ref) => '');
final generalPaidAmountProvider = StateProvider<String>((ref) => '');
final commentsProvider = StateProvider<String>((ref) => '');

// File upload providers
final photoProvider = StateProvider<File?>((ref) => null);
final generalPaymentSlipProvider = StateProvider<File?>((ref) => null);
final citizenshipFrontProvider = StateProvider<File?>((ref) => null);
final citizenshipBackProvider = StateProvider<File?>((ref) => null);

// Submission loading state
final generalFormSubmissionLoadingProvider = StateProvider<bool>((ref) => false);

// Submit form provider
final submitGeneralMembershipFormProvider = Provider<Future<bool> Function(Map<String, dynamic>)>((ref) {
  return (Map<String, dynamic> formData) async {
    ref.read(generalFormSubmissionLoadingProvider.notifier).state = true;
    
    try {
      final result = await GeneralMembershipCardService.submitMembershipApplication(formData);
      ref.read(generalFormSubmissionLoadingProvider.notifier).state = false;
      
      // Refresh membership card data after submission
      final refreshedCardData = ref.refresh(generalMembershipCardProvider);
      debugPrint('Membership card data refreshed after submission: ${refreshedCardData.hashCode}');
      
      return result;
    } catch (e) {
      ref.read(generalFormSubmissionLoadingProvider.notifier).state = false;
      rethrow;
    }
  };
});

// Utility function to reset all form data - using Ref instead of WidgetRef
void resetAllFormData(Ref ref) {
  // Reset personal details
  ref.read(firstNameProvider.notifier).state = '';
  ref.read(middleNameProvider.notifier).state = '';
  ref.read(lastNameProvider.notifier).state = '';
  ref.read(dobProvider.notifier).state = '';
  ref.read(emailProvider.notifier).state = '';
  ref.read(phoneProvider.notifier).state = '';
  ref.read(addressProvider.notifier).state = '';
  ref.read(selectedCountryIdProvider.notifier).state = null;
  ref.read(selectedStateIdProvider.notifier).state = null;
  ref.read(selectedGeneralMembershipTypeProvider.notifier).state = null;
  ref.read(generalPaidAmountProvider.notifier).state = '';
  
  // Reset documents and comments
  ref.read(photoProvider.notifier).state = null;
  ref.read(generalPaymentSlipProvider.notifier).state = null;
  ref.read(citizenshipFrontProvider.notifier).state = null;
  ref.read(citizenshipBackProvider.notifier).state = null;
  ref.read(commentsProvider.notifier).state = '';
  
  debugPrint('All form data has been reset using the utility function');
}

// Provider for resetting form data
final resetFormDataProvider = Provider<VoidCallback>((ref) {
  return () => resetAllFormData(ref);
});

// Refresh data provider - FIXED to use the refresh result values
final refreshDataProvider = Provider<VoidCallback>((ref) {
  return () {
    GeneralMembershipCardService.clearCache();
    
    // Refresh all data providers and store the results
    final countriesRefresh = ref.refresh(countryListProvider);
    debugPrint('Countries data refreshed: ${countriesRefresh.hashCode}');
    
    final typesRefresh = ref.refresh(generalMembershipTypesProvider);
    debugPrint('Membership types refreshed: ${typesRefresh.hashCode}');
    
    final cardRefresh = ref.refresh(generalMembershipCardProvider);
    debugPrint('Membership card refreshed: ${cardRefresh.hashCode}');
    
    // Reset form data
    resetAllFormData(ref);
    
    debugPrint('All data providers refreshed and form data reset');
  };
});

// Form validation state
final formValidationErrorProvider = StateProvider<String>((ref) => '');

// Track whether the form was submitted
final formSubmittedProvider = StateProvider<bool>((ref) => false);

// Add a provider to check if reset is needed (useful when navigating between screens)
final resetNeededProvider = StateProvider<bool>((ref) => false);

// Provider for global app status (e.g., authentication changes)
final appStatusProvider = StateProvider<String>((ref) => 'initialized');

// Provider to manage a user's session lifecycle
final sessionManagerProvider = Provider<SessionManager>((ref) {
  return SessionManager(ref);
});

// Session manager class to handle session-related operations
class SessionManager {
  final Ref ref; // Using Ref instead of ProviderRef

  SessionManager(this.ref);

  // Call this when user logs in
  void onLogin(String email) {
    // Reset all previous user data
    resetAllFormData(ref);
    ref.read(appStatusProvider.notifier).state = 'logged_in';
    debugPrint('User logged in: $email - all data reset');
  }

  // Call this when user logs out
  void onLogout() {
    resetAllFormData(ref);
    ref.read(appStatusProvider.notifier).state = 'logged_out';
    debugPrint('User logged out - all data reset');
  }

  // Call this on app startup to check session
  Future<void> checkSession() async {
    final isAuthenticated = await ref.read(isAuthenticatedProvider.future);
    if (isAuthenticated) {
      ref.read(appStatusProvider.notifier).state = 'logged_in';
    } else {
      ref.read(appStatusProvider.notifier).state = 'logged_out';
    }
  }
}