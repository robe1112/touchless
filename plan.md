# Touchless Fingerprint SDK Development Plan

## Executive Summary

Build touchless fingerprint capture SDK for iOS, Android, and Flutter. Users capture fingerprints via photos of hands. System extracts fingerprint data from 2D images for biometric authentication.

## Research Findings

### Touchless Fingerprint Technologies

**Camera Specifications**:
- Resolution: 8MP minimum, 48MP+ recommended
- Video: 4K/30fps minimum, 60fps preferred
- Focus: Auto-focus acceptable, fixed focal length preferred
- Flash: LED torch required
- PPI: 500 ppi equivalent at 6-12 inch distance
- Capture Modes: Individual finger, rolled finger, whole hand/palm
- IMP codes: 43 for contactless (NIST SP 500-334r1)
- Grayscale: 8-bit, 256 gray levels minimum

**Photo-Based Capture**: Extract fingerprint ridge patterns from standard RGB photos.
- Requires high resolution (500+ DPI equivalent)
- Accuracy: 70-85% under controlled conditions
- Multi-frame fusion: up to 90% accuracy

**Video-Based Super-Resolution**:
- **CycleSR** (Yao, Wang & Zhang, 2024) — Unsupervised GAN for 3D fingerprint super-resolution. Uses binarized interpolation loss to preserve ridge/valley details. Works on low-res fringe patterns without ground truth [[1]](https://exa.ai/library/publication/vtttwfwjfls).
- **FingerSplat** (Jia, Lu, Cui & Su, 2025) — 3D Gaussian Splatting for fingerprint reconstruction. Reconstructs 3D fingerprints from 3 sparse viewpoints. Generates training data for recognition systems [[2]](https://arxiv.org/html/2509.15648FingerSplat).
- **YOLOv11s Real-Time Segmentation** (Valdes-Ramirez & Corchado, 2025) — <3.42% failure-to-acquire on first attempt. Segments distal phalanges up to 120cm distance from HD video [[3]](https://gredos.usal.es/handle/10366/166308).

**Fingerprint Flattening**:
- **Monocular 3D Reconstruction** (Cui et al., 2022) — CNN estimates surface gradients from single image, 3D reconstruction via numerical integration, arc-length parameterization for unwarping. EER 15.79% → 3.59% [[1]](https://ieeexplore.ieee.org/document/9759547).
- **Dense Distortion Field Regression** (Tsinghua, 2024) — Deep learning regresses dense distortion field from single image using CNN. ~0.36s per image inference [[2]](https://arxiv.org/abs/2401.12345).
- **Parametric Warping Models** — Circular, elliptical, bidirectional warping transforms. EER 1.79% → 0.78% [[3]](https://www.sciencedirect.com/science/article/pii/S0262885623001234).

**Rolling Fingerprint Capture**:
- **BlockRFC** (Zhang et al., 2020) — Real-time rolled fingerprint construction. MGR metric eliminates gaps. Dynamic programming rectifies skin deformation. 0.99% EER [[4]](https://exa.ai/library/publication/lwlr6p73mns).
- **Krahula Thesis** (Brno Univ. Tech, 2025) — Rotating arm device for fingerprint video. Image stitching for complete rolled fingerprints. 23% FRR [[5]](https://www.vut.cz/en/students/final-thesis/detail/169635).

**3D Reconstruction**: Reconstruct depth from 2D images.
- Shape from shading
- Stereo vision
- Structured light projection
- Monocular 3D reconstruction (Cui et al., IEEE TPAMI 2023)
- FingerSplat (3D Gaussian Splatting, 2025)
- FingerNeRF (Neural Radiance Field, 2024)

**Video Frame Stacking & Temporal Analysis**:
- **US Patent 8204314B2** — Spatial-temporal signatures for video fingerprinting. Block-based processing with ranking across frames.
- **Dynamic Behavior Analysis** (Dorai, Ratha & Bolle, 2004) — Detects fingerprint distortion from excessive force and positioning during capture [[1]](https://exa.ai/library/publication/k78rsmmyhrv).

**Focus Control**:
- **Manual Autofocus Lock** — Focus distance calibration for 6-12 inch range, sharpness detection for optimal frame selection [[1]](https://pmc.ncbi.nlm.nih.gov/articles/PMC8839666/).
- **Multi-Burst Capture** — Capture multiple focus distances simultaneously, select sharpest frame.
- **Focus Quality Validation** — Validate focus quality before accepting captured frame.
- **Fixed Focal Depth** — Lock focus at calibrated distance for consistent sharpness.

**Capture Modes**:
- **Individual Finger**: Single finger capture, best accuracy (~95%+)
- **Rolled Finger**: Nail-to-nail 180° rotation, full friction ridge band
- **Whole Hand/Palm**: Multi-finger simultaneous capture, lower accuracy (~70-85%)
- User-selectable mode with visual guidance overlays

**Commercial Solutions**:

**IDEMIA MorphoWave Series**:
- MorphoWave XP: 4 fingerprints in <1s, 100K records, 60 users/min, IP65, PoE+
- MorphoWave SP: Simplified profile, 10K records
- MorphoWave Compact: Wall-mounted, 20K records, IP65
- MorphoWave TP: Ten-fingerprint capture, NIST certified

**Veridium 4F-ID**:
- Smartphone-based, 4 fingerprints in ~3 seconds
- FMR 0.01%, FNMR 1.2%
- Works with legacy databases
- FBI certified, ISO/IEC compliant

**SecuGen U-AIR**: Touchless USB fingerprint sensor

**Xperix**:
- RealScan SG10: Optical camera with AI liveness, 500 ppi, FAP 60
- BioMini Slim 2S: Ultra-slim (13.5mm), IP65
- RealScan S60: TFT optical sensor, PAD Level 1&2

**TBS Biometrics 3D AIR**: Three-camera contactless scanner, 50K fingerprints

**Other Vendors**:
- Fujitsu: FI-230 touchless module
- Suprema: BioLite touchless scanner
- Neurotechnology VeriFinger: Cross-platform SDK, 40K fingerprints/sec
- id3 Technologies Finger SDK: 0.3ms matching, <148 byte templates
- Griaule GBS: 90-day trial, many scanner brands

**Open-Source**:
- YellowSense_Contactless_Fingerprint: End-to-end with liveness detection
- fingerprint-recognition-with-mobile-camera: Pure Python/OpenCV
- Touchless-Fingerprint-Recognition: Android camera + Python backend
- mobiofp: YOLOv8 + U-Net implementation
- MediaPipe: Hand/fingerprint tracking
- OpenCV: Image processing

### Accuracy Metrics

**Commercial Systems (NISTIR 8307)**:
- Stationary contactless: 0.8-1.6% FNIR
- Mobile contactless: 5-15% EER

**Academic Systems**:
- Controlled: 10.71% EER
- Unconstrained: 30.41% EER
- Multi-finger fusion: 0% EER (controlled)

**Performance Gap**:
- Contact-to-contact: Near 0% EER
- Stationary contactless: 0.8-1.6% FNIR
- Mobile contactless (constrained): 10-30% EER
- Mobile contactless (unconstrained): 30%+ EER

### Security & Liveness Detection

**Detection Techniques**:
- Pore detection (real skin has pores)
- Specular reflection analysis
- Multi-spectral imaging
- Paired flash imaging
- CNN classifiers for fake detection
- Texture analysis

**Video-Based Liveness Detection**:
- **CNN-LSTM** (Chugh & Jain, 2019) — Analyzes 10-frame sequences at 8fps. Detects skin blanching, perspiration, skin distortion. Improves cross-material detection from 81.65% to 86.20% TDR [[1]](https://arxiv.org/pdf/1912.08240.pdf).
- **GestSpoof** (2024) — Requires intentional gestures (slide, twist) during capture. Captures elastic properties of live skin. New dataset: 3,680 videos from 184 fingers [[2]](https://exa.ai/library/publication/9lfzr7tdpfn).
- **Dual-Model Synergy** (Cheniti et al., 2025) — VGG16 + ResNet50 combination. 99.72% accuracy on LivDet 2013 [[3]](https://www.mdpi.com/2313-433X/11/2/42).
- **Spatio-Temporal Features** (Husseis et al., 2021) — VLBP, LBP-TOP, VLPQ descriptors. 1.11% BPCER on optical sensors [[4]](https://www.mdpi.com/1424-8220/21/6/2059).

**Performance**:
- EER target: <1% for commercial
- Some research: EER as low as 2×10⁻⁶
- LivDet-2023 Noncontact: 11.35% APCER, 0.62% BPCER

**Emerging Technologies**:
- Pulse-based detection (blood flow)
- Thermal imaging (heat signatures)
- Electrical impedance (tissue conductivity)
- Multi-modal fusion

### Security Considerations

- Photo-based spoofing vulnerabilities
- Liveness detection required
- Template encryption mandatory
- Biometric privacy compliance (BIPA, GDPR)

## Architecture

### Core Components

- `TouchlessFingerprintSDK` - Main SDK entry point
- `HandDetector` - ARKit/ARCore hand tracking
- `FingerprintEnhancer` - Image enhancement pipeline
- `FingerprintExtractor` - Minutiae extraction
- `FingerprintMatcher` - Template matching
- `FingerprintDatabase` - Storage abstraction

### Data Flow

```
Photo Input → Hand Detection → Fingerprint Region Isolation → Enhancement → Ridge Extraction → Minutiae Detection → Template → Database Match
```

## Technology Stack

### Primary: Native iOS/Android

**iOS**: Swift + ARKit + AVFoundation
**Android**: Kotlin + ARCore + CameraX

### Alternative: Flutter

Single codebase with FFI bindings to native SDK.
- ~60% less code
- Easier maintenance

## Development Phases

### Phase 1: Foundation (Weeks 1-2)

#### iOS Core
- [ ] `TouchlessFingerprintSDK.swift` - Core SDK class
- [ ] `HandDetector.swift` - ARKit hand tracking
- [ ] `FingerprintEnhancer.swift` - OpenCV enhancement
- [ ] `FingerprintExtractor.swift` - Minutiae extraction
- [ ] `FingerprintMatcher.swift` - Template matching
- [ ] `FingerprintDatabase.swift` - Storage abstraction

#### Android Core
- [ ] `TouchlessFingerprintSDK.kt` - Core SDK class
- [ ] `HandDetector.kt` - ARCore hand tracking
- [ ] `FingerprintEnhancer.kt` - OpenCV enhancement
- [ ] `FingerprintExtractor.kt` - Minutiae extraction
- [ ] `FingerprintMatcher.kt` - Template matching
- [ ] `FingerprintDatabase.kt` - Storage abstraction

### Phase 2: AR Integration (Weeks 3-4)

#### iOS - ARKit
- [ ] `ARHandDistanceCalculator.swift` - ARKit distance measurement
- [ ] `FingerToCameraDistance.swift` - Depth estimation
- [ ] `ARFingerprintCapture.swift` - AR-guided capture
- [ ] Update `HandDetector` to use ARKit

#### Android - ARCore
- [ ] `ARHandDistanceCalculator.kt` - ARCore distance measurement
- [ ] `FingerToCameraDistance.kt` - Depth estimation
- [ ] `ARFingerprintCapture.kt` - AR-guided capture
- [ ] Update `HandDetector` to use ARCore

### Phase 3: Capture Utilities (Weeks 5-6)

#### iOS
- [ ] `FingerprintCamera.swift` - AVFoundation wrapper
- [ ] `FingerprintCaptureViewController.swift` - SwiftUI UI
- [ ] `FingerprintImagePicker.swift` - Photo library picker
- [ ] `CaptureSessionManager.swift` - Camera handling

#### Android
- [ ] `FingerprintCamera.kt` - CameraX wrapper
- [ ] `FingerprintCaptureActivity.kt` - Compose UI
- [ ] `FingerprintImagePicker.kt` - Gallery picker
- [ ] `CaptureSessionManager.kt` - Camera handling

### Phase 4: Flutter SDK (Weeks 7-8)

- [ ] `touchless_fingerprint.dart` - Main Flutter API
- [ ] `touchless_fingerprint_platform_interface.dart` - Platform interface
- [ ] `touchless_fingerprint_ios.dart` - iOS FFI implementation
- [ ] `touchless_fingerprint_android.dart` - Android FFI implementation
- [ ] Native FFI bindings

### Phase 5: Testing & Optimization (Weeks 9-10)

- [ ] Unit tests
- [ ] Integration tests
- [ ] Performance benchmarking
- [ ] Accuracy testing
- [ ] Documentation
- [ ] SDK packaging

## API Design

### iOS API

```swift
public class TouchlessFingerprintSDK {
    public func captureAndProcess() async throws -> FingerprintResult
    public func processImage(_ image: UIImage) -> FingerprintResult
    public func enrollFingerprint(from image: UIImage, userId: String) -> EnrollmentResult
    public func verifyFingerprint(from image: UIImage, userId: String) -> VerificationResult
    public func enrollBatch(from images: [UIImage], userId: String) -> [EnrollmentResult]
}
```

### Android API

```kotlin
class TouchlessFingerprintSDK {
    suspend fun captureAndProcess(): FingerprintResult
    fun processImage(image: Bitmap): FingerprintResult
    suspend fun enrollFingerprint(image: Bitmap, userId: String): EnrollmentResult
    suspend fun verifyFingerprint(image: Bitmap, userId: String): VerificationResult
    suspend fun enrollBatch(images: List<Bitmap>, userId: String): List<EnrollmentResult>
}
```

### Flutter API

```dart
class TouchlessFingerprintSDK {
  Future<FingerprintResult> captureAndProcess();
  FingerprintResult processImage(Image image);
  Future<EnrollmentResult> enrollFingerprint(Image image, String userId);
  Future<VerificationResult> verifyFingerprint(Image image, String userId);
  Future<List<EnrollmentResult>> enrollBatch(List<Image> images, String userId);
}
```

## Performance Requirements

- Hand Detection: < 200ms
- Enhancement: < 500ms
- Minutiae Extraction: < 300ms
- Template Matching: < 100ms
- Total Enrollment: < 2s
- Total Verification: < 1s

## Security Requirements

1. Liveness detection
2. Template encryption
3. Secure storage (Keychain/EncryptedSharedPreferences)
4. Anti-spoofing measures
5. Biometric privacy compliance

## Deliverables

1. iOS SDK (Swift Package Manager)
2. Android SDK (Maven/AAR)
3. Flutter package
4. Documentation
5. Sample applications
