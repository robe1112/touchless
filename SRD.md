# Software Requirements Document (SRD)
# Touchless Fingerprint Capture SDK

## 1. Introduction

### 1.1 Purpose

Define requirements for touchless fingerprint capture SDK enabling biometric authentication via hand photos. Users capture fingerprints by photographing hands or supplying existing photos.

### 1.2 Scope

SDK for iOS, Android, and Flutter platforms. Extracts fingerprint data from 2D images, performs liveness detection, matches against enrolled templates.

### 1.3 Definitions

- **Touchless**: No physical contact with sensor
- **Fingerprint Region**: Fingertip area containing ridge patterns
- **Minutiae**: Ridge endings and bifurcations
- **Liveness**: Verification of live hand vs. photo/spoof
- **Template**: Encrypted fingerprint representation

## 2. Overall Description

### 2.1 Product Perspective

Mobile SDK integrated into biometric authentication apps. Replaces traditional contact fingerprint scanners.

### 2.2 User Classes

- **End Users**: Provide fingerprint for authentication
- **App Developers**: Integrate SDK into applications
- **Admins**: Manage fingerprint database

### 2.3 Operating Environment

- **iOS**: 14+, A12+ chip (ARKit requirement)
- **Android**: API 21+, ARCore-compatible devices
- **Flutter**: 3.0+, iOS/Android targets

### 2.4 Design Constraints

- Must use device cameras (no external hardware)
- ARKit/ARCore for distance measurement
- OpenCV for image processing
- Secure storage for templates

## 3. Specific Requirements

### 3.1 Camera Capture Requirements

#### 3.1.1 Photo Capture
- **FR-CAM-001**: SDK shall capture fingerprint image via device camera
- **FR-CAM-002**: SDK shall accept existing photos from gallery
- **FR-CAM-003**: Minimum resolution 640x480 pixels
- **FR-CAM-004**: Support rear-facing camera (higher quality)
- **FR-CAM-005**: Real-time preview with hand detection overlay

#### 3.1.2 AR Guidance
- **FR-AR-001**: SDK shall use ARKit (iOS) / ARCore (Android) for distance measurement
- **FR-AR-002**: Display distance indicator to user
- **FR-AR-003**: Guide user to optimal capture distance (6-12 inches)
- **FR-AR-004**: Detect hand position relative to camera
- **FR-AR-005**: Provide visual feedback for proper hand placement

### 3.2 Hand Detection Requirements

#### 3.2.1 Detection
- **FR-HAND-001**: Detect hands in captured image
- **FR-HAND-002**: Identify individual fingers
- **FR-HAND-003**: Extract hand landmarks (21 points)
- **FR-HAND-004**: Focus on fingertips (indices 8, 12, 16, 20)
- **FR-HAND-005**: Detection accuracy > 95%

#### 3.2.2 Performance
- **FR-HAND-006**: Hand detection < 200ms
- **FR-HAND-007**: Support multiple hands in single image

### 3.3 Fingerprint Extraction Requirements

#### 3.3.1 Image Enhancement
- **FR-PROC-001**: Convert to grayscale
- **FR-PROC-002**: Apply CLAHE (contrast enhancement)
- **FR-PROC-003**: Noise reduction (Gaussian blur)
- **FR-PROC-004**: Ridge sharpening (unsharp masking)
- **FR-PROC-005**: Enhancement quality score > 0.7

#### 3.3.2 Minutiae Extraction
- **FR-PROC-010**: Extract fingerprint ridge patterns
- **FR-PROC-011**: Detect ridge endings
- **FR-PROC-012**: Detect bifurcations
- **FR-PROC-013**: Minimum 50 minutiae points required
- **FR-PROC-014**: Extract orientation for each minutia
- **FR-PROC-015**: Extraction accuracy > 85%

#### 3.3.3 Performance
- **FR-PROC-020**: Enhancement < 500ms
- **FR-PROC-021**: Minutiae extraction < 300ms

### 3.4 Template Requirements

#### 3.4.1 Template Creation
- **FR-TPL-001**: Create fingerprint template from minutiae
- **FR-TPL-002**: Follow ISO/IEC 19794-2 format
- **FR-TPL-003**: Template size < 5KB
- **FR-TPL-004**: Template encryption required

#### 3.4.2 Storage
- **FR-TPL-010**: Store templates in secure storage
- **FR-TPL-011**: iOS: Use Keychain
- **FR-TPL-012**: Android: Use EncryptedSharedPreferences
- **FR-TPL-013**: Templates encrypted at rest

### 3.5 Matching Requirements

#### 3.5.1 Verification
- **FR-MATCH-001**: Compare new fingerprint against enrolled template
- **FR-MATCH-002**: Calculate similarity score (0-1.0)
- **FR-MATCH-003**: Configurable matching threshold (default 0.7)
- **FR-MATCH-004**: Match threshold adjustable per security level
- **FR-MATCH-005**: Matching accuracy > 90%

#### 3.5.2 Enrollment
- **FR-MATCH-010**: Enroll fingerprint from captured image
- **FR-MATCH-011**: Support batch enrollment
- **FR-MATCH-012**: Validate uniqueness during enrollment

#### 3.5.3 Performance
- **FR-MATCH-020**: Template matching < 100ms

### 3.6 Liveness Detection Requirements

#### 3.6.1 Spoof Detection
- **FR-LIVE-001**: Detect photo-based spoofing
- **FR-LIVE-002**: Detect screen replay attacks
- **FR-LIVE-003**: Detect printed fingerprint attacks
- **FR-LIVE-004**: Texture analysis for liveness
- **FR-LIVE-005**: Reflection pattern analysis
- **FR-LIVE-006**: Liveness detection accuracy > 95%

#### 3.6.2 Anti-Spoofing
- **FR-LIVE-010**: Reject non-live fingerprints
- **FR-LIVE-011**: Log spoofing attempts
- **FR-LIVE-012**: Configurable spoof sensitivity

### 3.7 User Interface Requirements

#### 3.7.1 Capture Guidance
- **FR-UI-001**: Show hand detection overlay
- **FR-UI-002**: Display distance indicator
- **FR-UI-003**: Provide visual feedback for proper positioning
- **FR-UI-004**: Show capture progress
- **FR-UI-005**: Display error messages clearly

#### 3.7.2 Results
- **FR-UI-010**: Show enrollment success/failure
- **FR-UI-011**: Show verification result (match/no-match)
- **FR-UI-012**: Display confidence score
- **FR-UI-013**: Provide retry option on failure

### 3.8 Performance Requirements

- **FR-PERF-001**: Hand detection < 200ms
- **FR-PERF-002**: Image enhancement < 500ms
- **FR-PERF-003**: Minutiae extraction < 300ms
- **FR-PERF-004**: Template matching < 100ms
- **FR-PERF-005**: Total enrollment < 2 seconds
- **FR-PERF-006**: Total verification < 1 second
- **FR-PERF-007**: Memory usage < 200MB

### 3.9 Security Requirements

- **FR-SEC-001**: Encrypt all fingerprint templates
- **FR-SEC-002**: Secure key storage (Keychain/Keystore)
- **FR-SEC-003**: No plaintext template storage
- **FR-SEC-004**: Biometric data never transmitted unencrypted
- **FR-SEC-005**: Comply with BIPA/GDPR
- **FR-SEC-006**: User consent required before capture
- **FR-SEC-007**: Option to delete biometric data

### 3.10 Compatibility Requirements

- **FR-COMP-001**: iOS 14+
- **FR-COMP-002**: Android API 21+
- **FR-COMP-003**: ARKit 2.0+ (iOS)
- **FR-COMP-004**: ARCore 1.0+ (Android)
- **FR-COMP-005**: Flutter 3.0+

### 3.11 Reliability Requirements

- **FR-REL-001**: 99% uptime during capture
- **FR-REL-002**: Handle camera errors gracefully
- **FR-REL-003**: Retry on transient failures
- **FR-REL-004**: Log all errors

### 3.12 Usability Requirements

- **FR-USABLE-001**: Intuitive capture guidance
- **FR-USABLE-002**: Clear error messages
- **FR-USABLE-003**: Accessibility support
- **FR-USABLE-004**: Multi-language support

## 4. External Interface Requirements

### 4.1 API Interface

#### iOS
```swift
public class TouchlessFingerprintSDK {
    public func captureAndProcess() async throws -> FingerprintResult
    public func processImage(_ image: UIImage) -> FingerprintResult
    public func enrollFingerprint(from image: UIImage, userId: String) -> EnrollmentResult
    public func verifyFingerprint(from image: UIImage, userId: String) -> VerificationResult
}
```

#### Android
```kotlin
class TouchlessFingerprintSDK {
    suspend fun captureAndProcess(): FingerprintResult
    fun processImage(image: Bitmap): FingerprintResult
    suspend fun enrollFingerprint(image: Bitmap, userId: String): EnrollmentResult
    suspend fun verifyFingerprint(image: Bitmap, userId: String): VerificationResult
}
```

#### Flutter
```dart
class TouchlessFingerprintSDK {
  Future<FingerprintResult> captureAndProcess();
  FingerprintResult processImage(Image image);
  Future<EnrollmentResult> enrollFingerprint(Image image, String userId);
  Future<VerificationResult> verifyFingerprint(Image image, String userId);
}
```

### 4.2 Camera Interface

- **FR-API-001**: AVFoundation (iOS)
- **FR-API-002**: CameraX (Android)
- **FR-API-003**: Image analysis callbacks

### 4.3 AR Interface

- **FR-API-010**: ARKit (iOS)
- **FR-API-011**: ARCore (Android)
- **FR-API-012**: Hand tracking APIs

## 5. Constraints

### 5.1 Technical Constraints

- Must use device cameras only
- ARKit/ARCore required for distance measurement
- OpenCV required for image processing
- No external hardware dependencies

### 5.2 Regulatory Constraints

- BIPA compliance (Illinois biometric law)
- GDPR compliance (EU biometric data)
- CCPA compliance (California privacy)

### 5.3 Performance Constraints

- Hand detection < 200ms
- Total enrollment < 2s
- Total verification < 1s
- Memory < 200MB

## 6. Appendices

### 6.1 References

- ISO/IEC 19794-2: Biometric data interchange
- NIST Biometric Standards
- BIPA Statute (430 ILCS 400)
- GDPR Article 9: Special categories of data

### 6.2 Revision History

| Date | Version | Author | Changes |
|------|---------|--------|---------|
| 2026-10-10 | 1.0 | Initial | Initial SRD |
