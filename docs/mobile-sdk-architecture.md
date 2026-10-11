# Touchless Fingerprint Mobile SDK Architecture

## Target Platforms

- **iOS** (14+) - Swift/SwiftUI
- **Android** (API 21+) - Kotlin/Jetpack Compose
- **Cross-platform** - Flutter/Dart or React Native (optional)

## Recommended Technology Stack

### Option 1: Native iOS/Android

**iOS**: Swift + Vision Framework
- AVFoundation for camera access
- Vision framework for hand tracking (VNHandPoseRequest)
- CoreML for fingerprint enhancement models
- Metal for GPU-accelerated processing

**Android**: Kotlin + ML Kit
- CameraX for camera access
- ML Kit Hand Tracking API
- TensorFlow Lite for fingerprint models
- GPU Delegate for accelerated inference

### Option 2: Cross-Platform

**Flutter** + native plugins
- `media_pipe` package for hand tracking
- Custom camera plugins for device access
- FFI for native fingerprint processing
- Shared UI codebase

**React Native** + native modules
- `react-native-vision-camera` for camera
- MediaPipe React Native bindings
- Native fingerprint processing modules

## Core SDK Components

### 1. Camera Module

**iOS (Swift)**:
```swift
class FingerprintCamera {
    func startCapture() -> AsyncStream<UIImage>
    func captureFingerprint() -> UIImage?
}
```

**Android (Kotlin)**:
```kotlin
class FingerprintCamera {
    fun startCapture(): Flow<Bitmap>
    fun captureFingerprint(): Bitmap?
}
```

### 2. Hand Detection Module

**MediaPipe Integration**:
```swift
class HandDetector {
    func detectHands(image: UIImage) -> HandLandmarks?
    func extractFingerprintRegions(landmarks: HandLandmarks) -> [FingerprintRegion]
}
```

**Android**:
```kotlin
class HandDetector {
    fun detectHands(image: Bitmap): HandLandmarks?
    fun extractFingerprintRegions(landmarks: HandLandmarks): List<FingerprintRegion>
}
```

### 3. Fingerprint Enhancement Module

**CoreML/TFLite Model**:
- Super-resolution upscaling
- Contrast enhancement
- Noise reduction
- Ridge sharpening

### 4. Fingerprint Extraction Module

**Algorithm**:
- Gabor filter for ridge extraction
- Orientation field estimation
- Minutiae point detection
- Template creation (ISO/IEC 19794-2)

### 5. Matching Module

**Comparison**:
- Template matching against enrolled fingerprints
- Minutiae-based comparison
- Confidence scoring
- Threshold-based acceptance

## SDK API Design

### Swift (iOS)

```swift
public class TouchlessFingerprintSDK {
    
    public init(config: SDKConfig)
    
    public func enrollFingerprint(from image: UIImage, userId: String) throws -> EnrollmentResult
    
    public func verifyFingerprint(from image: UIImage, userId: String) throws -> VerificationResult
    
    public func captureAndProcess() async throws -> FingerprintResult
    
    public func enrollBatch(from images: [UIImage], userId: String) throws -> [EnrollmentResult]
}

public struct SDKConfig {
    var minImageResolution: CGSize
    var enhancementLevel: EnhancementLevel
    var matchingThreshold: Double
}

public struct FingerprintResult {
    let isValid: Bool
    let confidence: Double
    let fingerprintTemplate: Data?
    let errors: [String]
}

public struct EnrollmentResult: FingerprintResult {}
public struct VerificationResult: FingerprintResult {
    let isMatch: Bool
}
```

### Kotlin (Android)

```kotlin
class TouchlessFingerprintSDK constructor(config: SDKConfig) {
    
    suspend fun enrollFingerprint(
        image: Bitmap, 
        userId: String
    ): EnrollmentResult
    
    suspend fun verifyFingerprint(
        image: Bitmap, 
        userId: String
    ): VerificationResult
    
    suspend fun captureAndProcess(): FingerprintResult
    
    suspend fun enrollBatch(
        images: List<Bitmap>, 
        userId: String
    ): List<EnrollmentResult>
}

data class SDKConfig(
    val minImageResolution: CGSize,
    val enhancementLevel: EnhancementLevel,
    val matchingThreshold: Double
)

data class FingerprintResult(
    val isValid: Boolean,
    val confidence: Float,
    val fingerprintTemplate: ByteArray?,
    val errors: List<String>
)

data class EnrollmentResult: FingerprintResult()
data class VerificationResult: FingerprintResult(
    val isMatch: Boolean
)
```

## Camera Integration

### iOS Camera Implementation

```swift
import AVFoundation

class FingerprintCaptureSession: NSObject, AVCaptureSessionDelegate {
    private let session = AVCaptureSession()
    private var outputBuffer: [CVPixelBuffer] = []
    
    func setupCamera() {
        session.beginConfiguration()
        
        // Use back camera with highest resolution
        let cameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, 
                                                   for: .video, 
                                                   position: .back)
        
        let input = try? AVCaptureDeviceInput(device: cameraDevice)
        session.addInput(input)
        
        let pixelBufferOutput = AVCaptureVideoDataOutput()
        pixelBufferOutput.setSampleBufferDelegate(self, queue: captureQueue)
        session.addOutput(pixelBufferOutput)
        
        session.commitConfiguration()
    }
    
    func captureFrame() -> UIImage? {
        // Return latest captured frame
        return outputBuffer.last?.toUIImage()
    }
}
```

### Android Camera Implementation

```kotlin
import androidx.camera.core.*
import androidx.camera.lifecycle.CameraXLifecycle
import androidx.camera.view.PreviewView

class FingerprintCameraBinding {
    private val cameraProvider = LocalCameraProvider.get(this)
    private val imageAnalyzer = ImageAnalysis.Builder()
        .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
        .build()
        .also { analyzer ->
            analyzer.setImageConsumer { imageProxy ->
                val bitmap = imageProxy.toBitmap()
                onFrameCaptured(bitmap)
            }
        }
    
    fun bindToLifecycle() {
        cameraProvider.bindToLifecycle(
            lifecycleOwner,
            CameraSelector.DEFAULT_BACK_CAMERA,
            imageAnalyzer
        )
    }
}
```

## Hand Detection with MediaPipe

### MediaPipe Hand Tracking Setup

**iOS**:
```swift
import MediaPipe

class HandDetector {
    private var handLandmarksDetector: HandLandmarksDetector
    
    init() {
        let options = HandLandmarksDetectorOptions(
            baseOptions: BaseOptions(modelAssetPath: "hand_landmarker.task"),
            outputSegmentationMask: false,
            runningMode: .image,
            resultCallback: handleHandLandmarksResult
        )
        handLandmarksDetector = HandLandmarksDetector(options: options)
    }
    
    func detectHands(image: UIImage) -> [HandLandmark]? {
        let mpImage = MPImage(cvImageBuffer: image.toCVPixelBuffer()!)
        return handLandmarksDetector.detect(image: mpImage).landmarks
    }
    
    func extractFingerprintRegions(landmarks: [HandLandmark]) -> [FingerprintRegion] {
        // Extract fingertip regions (landmarks 8, 12, 16, 20 for fingers)
        let fingerTips = [8, 12, 16, 20].map { landmarks[$0] }
        return fingerTips.map { FingerprintRegion(center: $0, radius: 50) }
    }
}
```

**Android**:
```kotlin
class HandDetector {
    private val handLandmarksDetector: HandLandmarksDetector
    
    init() {
        val options = HandLandmarksDetectorOptions.Builder()
            .setBaseOptions(BaseOptions.builder().setModelAssetName("hand_landmarker.task").build())
            .setOutputSegmentationMask(false)
            .setRunningMode(RunningMode.IMAGE)
            .build()
        
        handLandmarksDetector = HandLandmarksDetector(options)
    }
    
    fun detectHands(image: Bitmap): List<HandLandmark>? {
        val mpImage = MPImage.Builder().setImage(image).build()
        return handLandmarksDetector.detect(mpImage).landmarks
    }
    
    fun extractFingerprintRegions(landmarks: List<HandLandmark>): List<FingerprintRegion> {
        val fingerTips = listOf(8, 12, 16, 20).map { landmarks[it] }
        return fingerTips.map { FingerprintRegion(it.x, it.y, 50f) }
    }
}
```

## Fingerprint Enhancement Pipeline

### Image Enhancement Steps

1. **Grayscale Conversion**
2. **Contrast Limited Adaptive Histogram Equalization (CLAHE)**
3. **Gaussian Blur for Noise Reduction**
4. **Unsharp Masking for Ridge Sharpening**
5. **Super-Resolution Upscaling** (optional ML model)

### Swift Implementation

```swift
import Accelerate
import CoreImage

class FingerprintEnhancer {
    
    func enhance(image: UIImage) -> UIImage {
        // Step 1: Convert to CIImage
        var ciImage = CIImage(image: image)
        
        // Step 2: Grayscale
        ciImage = ciImage.applyingFilter("CIColorControls", parameters: ["saturation": 0])
        
        // Step 3: CLAHE
        ciImage = ciImage.applyingFilter("CIHistogramEqualization", parameters: [:])
        
        // Step 4: Sharpen
        ciImage = ciImage.applyingFilter("CISharpenLuminance", parameters: [
            "inputSharpening": 2.0
        ])
        
        // Step 5: Convert back to UIImage
        let renderer = UIGraphicsImageRenderer(size: ciImage.extent.size)
        return renderer.image {
            UIColor.white.setFill()
            UIRenderer.current.fill(ciImage.extent)
            UIColor.black.setFill()
            UIRenderer.current.draw(ciImage, in: ciImage.extent)
        }
    }
}
```

### Kotlin Implementation

```kotlin
class FingerprintEnhancer {
    
    fun enhance(bitmap: Bitmap): Bitmap {
        val config = Bitmap.Config.ARGB_8888
        val enhanced = Bitmap.createBitmap(bitmap.width, bitmap.height, config)
        val canvas = Canvas(enhanced)
        
        // Step 1: Grayscale
        val grayscale = Bitmap.createBitmap(bitmap.width, bitmap.height, config)
        val paint = Paint().apply { colorFilter = ColorFilterEffect(ColorMatrixColorFilter(floatArrayOf(
            0.212f, 0.715f, 0.072f, 0f, 0f,
            0.212f, 0.715f, 0.072f, 0f, 0f,
            0.212f, 0.715f, 0.072f, 0f, 0f,
            0f, 0f, 0f, 1f, 0f
        ))) }
        val canvasGray = Canvas(grayscale)
        canvasGray.drawBitmap(bitmap, 0f, 0f, paint)
        
        // Step 2: CLAHE
        val clahe = Imgproc.createCLAHE(2.0, Size(8.0, 8.0))
        val gray = Mat()
        Imgproc.cvtColor(grayscale, gray, Imgproc.COLOR_BGR2GRAY)
        clahe.apply(gray, gray)
        Imgproc.cvtColor(gray, grayscale, Imgproc.COLOR_GRAY2BGR)
        
        // Step 3: Sharpen
        val kernel = Mat.eye(3, 3, CvType.CV_32F)
        kernel.put(1, 1, 5f)
        kernel.put(0, 1, -1f)
        kernel.put(2, 1, -1f)
        kernel.put(1, 0, -1f)
        kernel.put(1, 2, -1f)
        kernel.put(1, 1, 1f)
        Imgproc.filter2D(grayscale, grayscale, -1, kernel)
        
        return grayscale
    }
}
```

## Fingerprint Extraction

### Minutiae Detection

```swift
class FingerprintExtractor {
    
    func extractMinutiae(image: UIImage) -> [MinutiaePoint]? {
        let cgImage = image.cgImage!
        let width = cgImage.width
        let height = cgImage.height
        
        // Convert to grayscale and enhance
        let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width,
            space: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        )!
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        // Gabor filter for ridge enhancement
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(context.makeImage(), forKey: "inputImage")
        filter?.setValue(2.0, forKey: "inputRadius")
        
        // Ridge orientation estimation
        // Minutiae detection (ridge endings, bifurcations)
        // Return minutiae points with coordinates and orientation
        return extractMinutiaeFromEnhancedImage()
    }
}

struct MinutiaePoint {
    let x: Float
    let y: Float
    let orientation: Float  // radians
    let type: MinutiaeType  // ending, bifurcation
}
```

## Enrollment Flow

```swift
class FingerprintEnrollment {
    
    func enrollFingerprint(
        from image: UIImage,
        userId: String,
        database: FingerprintDatabase
    ) throws -> EnrollmentResult {
        
        // Step 1: Detect hands in image
        let handDetector = HandDetector()
        guard let landmarks = handDetector.detectHands(image: image) else {
            return EnrollmentResult(isValid: false, confidence: 0, errors: ["No hand detected"])
        }
        
        // Step 2: Extract fingerprint regions
        let regions = handDetector.extractFingerprintRegions(landmarks: landmarks)
        
        // Step 3: Enhance each region
        let enhancer = FingerprintEnhancer()
        let enhancedRegions = regions.map { enhancer.enhance(image: image.crop(to: $0)) }
        
        // Step 4: Extract minutiae
        let extractor = FingerprintExtractor()
        let minutiaeSets = enhancedRegions.map { extractor.extractMinutiae(image: $0) ?? [] }
        
        // Step 5: Aggregate and create template
        let aggregatedMinutiae = minutiaeSets.flatMap { $0 }
        let template = createTemplate(minutiae: aggregatedMinutiae, userId: userId)
        
        // Step 6: Store in database
        try database.store(userId: userId, template: template)
        
        return EnrollmentResult(
            isValid: true,
            confidence: calculateConfidence(minutiaeCount: aggregatedMinutiae.count),
            fingerprintTemplate: template.data,
            errors: []
        )
    }
}
```

## Verification Flow

```swift
class FingerprintVerification {
    
    func verifyFingerprint(
        from image: UIImage,
        userId: String,
        database: FingerprintDatabase
    ) throws -> VerificationResult {
        
        // Step 1: Extract fingerprint from new image
        let enroller = FingerprintEnrollment()
        let result = try enroller.enrollFingerprint(from: image, userId: userId, database: database)
        
        // Step 2: Retrieve stored template
        guard let storedTemplate = database.getTemplate(userId: userId) else {
            return VerificationResult(isValid: false, isMatch: false, confidence: 0, errors: ["No template found"])
        }
        
        // Step 3: Compare templates
        let matcher = FingerprintMatcher()
        let score = matcher.compare(storedTemplate: storedTemplate, newTemplate: result.fingerprintTemplate!)
        
        // Step 4: Determine match based on threshold
        let isMatch = score > 0.7  // 70% similarity threshold
        
        return VerificationResult(
            isValid: true,
            isMatch: isMatch,
            confidence: score,
            errors: []
        )
    }
}
```

## Error Handling

```swift
public enum FingerprintError: Error, LocalizedError {
    case noHandDetected
    case poorImageQuality
    case insufficientMinutiae
    case templateCreationFailed
    case databaseError
    
    public var errorDescription: String? {
        switch self {
        case .noHandDetected: return "No hand detected in image"
        case .poorImageQuality: return "Image quality too low for fingerprint extraction"
        case .insufficientMinutiae: return "Insufficient fingerprint features for matching"
        case .templateCreationFailed: return "Failed to create fingerprint template"
        case .databaseError: return "Database error occurred"
        }
    }
}
```

## Performance Requirements

- **Hand Detection**: < 200ms on mobile device
- **Fingerprint Enhancement**: < 500ms
- **Minutiae Extraction**: < 300ms
- **Template Matching**: < 100ms
- **Total Enrollment**: < 2 seconds
- **Total Verification**: < 1 second

## Security Considerations

1. **Liveness Detection**: Verify photo is from live hand, not printed image
2. **Template Protection**: Encrypt stored fingerprint templates
3. **Secure Storage**: Use Keychain (iOS) / EncryptedSharedPreferences (Android)
4. **Anti-Spoofing**: Detect screen replay attacks
5. **Biometric Data**: Comply with biometric privacy laws (BIPA, GDPR)

## SDK Distribution

**iOS**:
- Swift Package Manager
- CocoaPods
- Pre-built .framework

**Android**:
- Maven Central
- JitPack
- AAR distribution

## Example Usage

### iOS App Integration

```swift
import TouchlessFingerprintSDK

class ViewController: UIViewController {
    
    @IBAction func captureFingerprint(_ sender: UIButton) {
        Task {
            do {
                let sdk = TouchlessFingerprintSDK(config: defaultConfig)
                let result = try await sdk.captureAndProcess()
                
                if result.isValid {
                    print("Fingerprint captured: \(result.confidence)")
                }
            } catch {
                print("Error: \(error)")
            }
        }
    }
}
```

### Android App Integration

```kotlin
class MainActivity : AppCompatActivity() {
    
    private val fingerprintSdk = TouchlessFingerprintSDK(config = defaultConfig)
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        lifecycleScope.launch {
            try {
                val result = fingerprintSdk.captureAndProcess()
                if (result.isValid) {
                    Log.d("Fingerprint", "Captured: ${result.confidence}")
                }
            } catch (e: Exception) {
                Log.e("Fingerprint", "Error: ${e.message}")
            }
        }
    }
}
```

---

*Architecture document created 2026-10-10*
