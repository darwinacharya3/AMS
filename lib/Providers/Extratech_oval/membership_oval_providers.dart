import 'dart:io';
import 'package:flutter/foundation.dart';
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
      
      // Refresh membership card data after submission and properly use the returned value
      final _ = ref.refresh(generalMembershipCardProvider);
      debugPrint('Membership card data refreshed after submission');
      
      return result;
    } catch (e) {
      ref.read(generalFormSubmissionLoadingProvider.notifier).state = false;
      rethrow;
    }
  };
});

// Refresh data provider
final refreshDataProvider = Provider<VoidCallback>((ref) {
  return () {
    GeneralMembershipCardService.clearCache();
    
    // Properly use the returned values from refresh calls
    final _ = ref.refresh(countryListProvider);
    final __ = ref.refresh(generalMembershipTypesProvider);
    final ___ = ref.refresh(generalMembershipCardProvider);
    
    debugPrint('All data providers refreshed');
  };
});

// Form validation state
final formValidationErrorProvider = StateProvider<String>((ref) => '');

// Track whether the form was submitted
final formSubmittedProvider = StateProvider<bool>((ref) => false);











