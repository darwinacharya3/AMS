import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ems/services/membership_card_services.dart';

/// Provider that fetches and holds the raw membership data
final membershipDataProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  return await MembershipCardService.getRawMembershipData();
});

/// Provider for membership card (extracted from the raw data)
final membershipCardProvider = FutureProvider.autoDispose<Map<String, dynamic>?>((ref) {
  final dataAsyncValue = ref.watch(membershipDataProvider);
  
  return dataAsyncValue.when(
    data: (data) {
      if (data.containsKey('membershipCard') && data['membershipCard'] != null) {
        final card = Map<String, dynamic>.from(data['membershipCard']);
        
        // Add QR code to card data if available
        if (data.containsKey('qr_code')) {
          card['qr_code'] = data['qr_code'];
        }
        
        return card;
      }
      return null;
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Provider for membership types list
final membershipTypesProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  final dataAsyncValue = ref.watch(membershipDataProvider);
  
  return dataAsyncValue.when(
    data: (data) {
      if (data.containsKey('membershipTypes')) {
        return List<Map<String, dynamic>>.from(
          data['membershipTypes'].map((item) => Map<String, dynamic>.from(item))
        );
      }
      return [];
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider for the QR code data
final qrCodeProvider = Provider.autoDispose<String?>((ref) {
  final dataAsyncValue = ref.watch(membershipDataProvider);
  
  return dataAsyncValue.whenData((data) {
    if (data.containsKey('qr_code')) {
      return data['qr_code'] as String?;
    }
    return null;
  }).value;
});

// Form state providers
final selectedMembershipTypeProvider = StateProvider.autoDispose<int?>((ref) => null);
final paidAmountProvider = StateProvider.autoDispose<String>((ref) => '');
final paymentSlipProvider = StateProvider.autoDispose<File?>((ref) => null);
final remarksProvider = StateProvider.autoDispose<String>((ref) => '');
final formSubmissionLoadingProvider = StateProvider.autoDispose<bool>((ref) => false);

/// Provider for submitting membership application
final submitMembershipFormProvider = Provider<Future<bool> Function(Map<String, dynamic>)>((ref) {
  return (Map<String, dynamic> formData) async {
    ref.read(formSubmissionLoadingProvider.notifier).state = true;
    
    try {
      final success = await MembershipCardService.submitMembershipApplication(formData);
      
      // Refresh the data if submission was successful
      if (success) {
        ref.invalidate(membershipDataProvider);
      }
      
      ref.read(formSubmissionLoadingProvider.notifier).state = false;
      return success;
    } catch (e) {
      ref.read(formSubmissionLoadingProvider.notifier).state = false;
      throw e;
    }
  };
});