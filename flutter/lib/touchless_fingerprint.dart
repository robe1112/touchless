import 'dart:ffi';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Touchless Fingerprint SDK for Flutter
///
/// Provides touchless fingerprint capture, enhancement, and matching
/// for iOS and Android platforms.
class TouchlessFingerprintSDK {
  final String? _userId;
  final Map<String, dynamic> _config;
  final Map<String, dynamic> _database;

  TouchlessFingerprintSDK({
    String? userId,
    Map<String, dynamic>? config,
    Map<String, dynamic>? database,
  })  : _userId = userId,
        _config = config ?? {},
        _database = database ?? {};

  /// Configuration options
  Map<String, dynamic> get config => Map.from(_config);

  /// Database storage
  Map<String, dynamic> get database => Map.from(_database);

  /// Capture fingerprint from camera and process
  Future<FingerprintResult> captureAndProcess() async {
    try {
      final result = await _platform.captureAndProcess();
      return FingerprintResult.fromMap(result);
    } catch (e) {
      return FingerprintResult(
        isValid: false,
        confidence: 0,
        errors: ['Capture failed: $e'],
      );
    }
  }

  /// Process an image for fingerprint extraction
  Future<FingerprintResult> processImage(List<int> imageBytes) async {
    try {
      final result = await _platform.processImage(imageBytes);
      return FingerprintResult.fromMap(result);
    } catch (e) {
      return FingerprintResult(
        isValid: false,
        confidence: 0,
        errors: ['Processing failed: $e'],
      );
    }
  }

  /// Enroll fingerprint for a user
  Future<EnrollmentResult> enrollFingerprint(
    List<int> imageBytes,
    String userId,
  ) async {
    try {
      final result = await _platform.enrollFingerprint(
        imageBytes,
        userId,
      );
      return EnrollmentResult.fromMap(result);
    } catch (e) {
      return EnrollmentResult(
        isValid: false,
        confidence: 0,
        userId: userId,
        errors: ['Enrollment failed: $e'],
      );
    }
  }

  /// Verify fingerprint against enrolled template
  Future<VerificationResult> verifyFingerprint(
    List<int> imageBytes,
    String userId,
  ) async {
    try {
      final result = await _platform.verifyFingerprint(
        imageBytes,
        userId,
      );
      return VerificationResult.fromMap(result);
    } catch (e) {
      return VerificationResult(
        isValid: false,
        isMatch: false,
        confidence: 0,
        errors: ['Verification failed: $e'],
      );
    }
  }

  /// Batch enroll from multiple images
  Future<List<EnrollmentResult>> enrollBatch(
    List<List<int>> imageBytesList,
    String userId,
  ) async {
    try {
      final results = await _platform.enrollBatch(
        imageBytesList,
        userId,
      );
      return results
          .map((r) => EnrollmentResult.fromMap(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return imageBytesList.map((_) => EnrollmentResult(
            isValid: false,
            confidence: 0,
            userId: userId,
            errors: ['Batch enrollment failed: $e'],
          )).toList();
    }
  }

  /// Get platform instance
  static TouchlessFingerprintPlatform get _platform {
    return TouchlessFingerprintPlatform.instance;
  }
}

/// Fingerprint capture result
class FingerprintResult {
  final bool isValid;
  final double confidence;
  final List<int>? fingerprintTemplate;
  final List<HandLandmark>? handLandmarks;
  final List<String> errors;

  FingerprintResult({
    required this.isValid,
    required this.confidence,
    this.fingerprintTemplate,
    this.handLandmarks,
    this.errors = const [],
  });

  factory FingerprintResult.fromMap(Map<String, dynamic> map) {
    return FingerprintResult(
      isValid: map['isValid'] ?? false,
      confidence: (map['confidence'] ?? 0).toDouble(),
      fingerprintTemplate: map['fingerprintTemplate'] != null
          ? List<int>.from(map['fingerprintTemplate'])
          : null,
      handLandmarks: map['handLandmarks'] != null
          ? (map['handLandmarks'] as List)
              .map((l) => HandLandmark.fromMap(l as Map<String, dynamic>))
              .toList()
          : null,
      errors: (map['errors'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  @override
  String toString() {
    return 'FingerprintResult(isValid: $isValid, confidence: $confidence, errors: $errors)';
  }
}

/// Enrollment result
class EnrollmentResult extends FingerprintResult {
  final String userId;

  EnrollmentResult({
    required super.isValid,
    required super.confidence,
    super.fingerprintTemplate,
    super.handLandmarks,
    required this.userId,
    super.errors,
  });

  factory EnrollmentResult.fromMap(Map<String, dynamic> map) {
    return EnrollmentResult(
      isValid: map['isValid'] ?? false,
      confidence: (map['confidence'] ?? 0).toDouble(),
      fingerprintTemplate: map['fingerprintTemplate'] != null
          ? List<int>.from(map['fingerprintTemplate'])
          : null,
      handLandmarks: map['handLandmarks'] != null
          ? (map['handLandmarks'] as List)
              .map((l) => HandLandmark.fromMap(l as Map<String, dynamic>))
              .toList()
          : null,
      userId: map['userId'] ?? '',
      errors: (map['errors'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  @override
  String toString() {
    return 'EnrollmentResult(isValid: $isValid, confidence: $confidence, userId: $userId, errors: $errors)';
  }
}

/// Verification result
class VerificationResult extends FingerprintResult {
  final bool isMatch;

  VerificationResult({
    required super.isValid,
    required this.isMatch,
    super.confidence,
    super.fingerprintTemplate,
    super.handLandmarks,
    super.errors,
  });

  factory VerificationResult.fromMap(Map<String, dynamic> map) {
    return VerificationResult(
      isValid: map['isValid'] ?? false,
      isMatch: map['isMatch'] ?? false,
      confidence: (map['confidence'] ?? 0).toDouble(),
      fingerprintTemplate: map['fingerprintTemplate'] != null
          ? List<int>.from(map['fingerprintTemplate'])
          : null,
      handLandmarks: map['handLandmarks'] != null
          ? (map['handLandmarks'] as List)
              .map((l) => HandLandmark.fromMap(l as Map<String, dynamic>))
              .toList()
          : null,
      errors: (map['errors'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  @override
  String toString() {
    return 'VerificationResult(isValid: $isValid, isMatch: $isMatch, confidence: $confidence, errors: $errors)';
  }
}

/// Hand landmark point
class HandLandmark {
  final int index;
  final double x;
  final double y;
  final double z;

  HandLandmark({
    required this.index,
    required this.x,
    required this.y,
    required this.z,
  });

  factory HandLandmark.fromMap(Map<String, dynamic> map) {
    return HandLandmark(
      index: map['index'] ?? 0,
      x: (map['x'] ?? 0).toDouble(),
      y: (map['y'] ?? 0).toDouble(),
      z: (map['z'] ?? 0).toDouble(),
    );
  }

  @override
  String toString() {
    return 'HandLandmark(index: $index, x: $x, y: $y, z: $z)';
  }
}

/// Fingerprint region
class FingerprintRegion {
  final double centerX;
  final double centerY;
  final double radius;
  final String fingerType;

  FingerprintRegion({
    required this.centerX,
    required this.centerY,
    required this.radius,
    required this.fingerType,
  });

  factory FingerprintRegion.fromMap(Map<String, dynamic> map) {
    return FingerprintRegion(
      centerX: (map['centerX'] ?? 0).toDouble(),
      centerY: (map['centerY'] ?? 0).toDouble(),
      radius: (map['radius'] ?? 0).toDouble(),
      fingerType: map['fingerType'] ?? 'unknown',
    );
  }

  @override
  String toString() {
    return 'FingerprintRegion(centerX: $centerX, centerY: $centerY, radius: $radius, fingerType: $fingerType)';
  }
}

/// Minutiae point
class MinutiaePoint {
  final double x;
  final double y;
  final double orientation;
  final MinutiaeType type;

  MinutiaePoint({
    required this.x,
    required this.y,
    required this.orientation,
    required this.type,
  });

  factory MinutiaePoint.fromMap(Map<String, dynamic> map) {
    return MinutiaePoint(
      x: (map['x'] ?? 0).toDouble(),
      y: (map['y'] ?? 0).toDouble(),
      orientation: (map['orientation'] ?? 0).toDouble(),
      type: MinutiaeType.values.firstWhere(
        (t) => t.toString() == 'MinutiaeType.${map['type']}',
        orElse: () => MinutiaeType.ending,
      ),
    );
  }

  @override
  String toString() {
    return 'MinutiaePoint(x: $x, y: $y, orientation: $orientation, type: $type)';
  }
}

/// Minutiae type enum
enum MinutiaeType {
  ending,
  bifurcation,
}

/// Platform interface for Touchless Fingerprint SDK
abstract class TouchlessFingerprintPlatform {
  static TouchlessFingerprintPlatform? _instance;

  static TouchlessFingerprintPlatform get instance {
    return _instance ??= DefaultTouchlessFingerprintPlatform();
  }

  static set instance(TouchlessFingerprintPlatform? value) {
    _instance = value;
  }

  /// Capture fingerprint from camera
  Future<Map<String, dynamic>> captureAndProcess();

  /// Process an image
  Future<Map<String, dynamic>> processImage(List<int> imageBytes);

  /// Enroll fingerprint
  Future<Map<String, dynamic>> enrollFingerprint(
    List<int> imageBytes,
    String userId,
  );

  /// Verify fingerprint
  Future<Map<String, dynamic>> verifyFingerprint(
    List<int> imageBytes,
    String userId,
  );

  /// Batch enroll
  Future<List<Map<String, dynamic>>> enrollBatch(
    List<List<int>> imageBytesList,
    String userId,
  );
}

/// Default platform implementation
class DefaultTouchlessFingerprintPlatform extends TouchlessFingerprintPlatform {
  @override
  Future<Map<String, dynamic>> captureAndProcess() async {
    throw UnimplementedError('captureAndProcess() is not implemented');
  }

  @override
  Future<Map<String, dynamic>> processImage(List<int> imageBytes) async {
    throw UnImplementedError('processImage() is not implemented');
  }

  @override
  Future<Map<String, dynamic>> enrollFingerprint(
    List<int> imageBytes,
    String userId,
  ) async {
    throw UnimplementedError('enrollFingerprint() is not implemented');
  }

  @override
  Future<Map<String, dynamic>> verifyFingerprint(
    List<int> imageBytes,
    String userId,
  ) async {
    throw UnimplementedError('verifyFingerprint() is not implemented');
  }

  @override
  Future<List<Map<String, dynamic>>> enrollBatch(
    List<List<int>> imageBytesList,
    String userId,
  ) async {
    throw UnimplementedError('enrollBatch() is not implemented');
  }
}
