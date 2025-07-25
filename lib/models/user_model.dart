// lib/core/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class UserModel {
  final String? id;
  final String email;
  final String name;
  final String? profilePictureUrl;
  final List<String> meditationGoals;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;
  final List<String> favoriteMeditationIds;

  UserModel({
    this.id,
    required this.email,
    required this.name,
    this.profilePictureUrl,
    this.meditationGoals = const [],
    this.createdAt,
    this.lastLoginAt,
    this.favoriteMeditationIds = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String?,
      email: json['email'] as String,
      name: json['name'] as String,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      meditationGoals: (json['meditationGoals'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      createdAt: (json['createdAt'] as Timestamp?)?.toDate(),
      lastLoginAt: (json['lastLoginAt'] as Timestamp?)?.toDate(),
      favoriteMeditationIds: (json['favoriteMeditationIds'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'profilePictureUrl': profilePictureUrl,
      'meditationGoals': meditationGoals,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'favoriteMeditationIds': favoriteMeditationIds,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? profilePictureUrl,
    List<String>? meditationGoals,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    List<String>? favoriteMeditationIds,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      meditationGoals: meditationGoals ?? this.meditationGoals,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      favoriteMeditationIds: favoriteMeditationIds ?? this.favoriteMeditationIds,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, favoriteMeditations: ${favoriteMeditationIds.length})';
  }
}