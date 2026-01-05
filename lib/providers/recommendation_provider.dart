// lib/providers/recommendation_provider.dart
import 'package:dhyana/core/services/recommendation_service.dart';
import 'package:dhyana/models/recommendation_model.dart';
import 'package:dhyana/models/user_model.dart';
import 'package:dhyana/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final recommendationServiceProvider = Provider((ref) => RecommendationService());

final recommendationProvider =
FutureProvider<List<Recommendation>>((ref) async {
  final userProfile = await ref.watch(currentUserProfileProvider.future);
  if (userProfile != null) {
    return ref.read(recommendationServiceProvider).getRecommendations(userProfile);
  }
  return [];
});