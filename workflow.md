# Touchless Fingerprint Capture Workflow

## User Flow

### Enrollment Flow

```
1. User opens app → Camera launches
2. App shows hand detection overlay
3. User places hand in frame
4. AR guidance shows distance (6-12 inches)
5. App captures photo
6. Hand detection identifies fingers
7. Fingerprint regions extracted (fingertips)
8. Image enhancement:
   - Grayscale conversion
   - Contrast enhancement (CLAHE)
   - Noise reduction
   - Ridge sharpening
9. Minutiae extraction:
   - Ridge pattern analysis
   - Ending/bifurcation detection
10. Template creation
11. Template stored in secure storage
12. Enrollment confirmed to user
```

### Verification Flow

```
1. User opens app → Camera launches
2. User places hand in frame
3. App captures photo
4. Hand detection identifies fingers
5. Fingerprint regions extracted
6. Image enhancement
7. Minutiae extraction
8. Template matching:
   - Compare new template vs enrolled
   - Calculate similarity score
9. Result displayed:
   - Match (>=70% confidence)
   - No match (<70% confidence)
```

## App Screen Flow

```
┌──────────────┐
│  Welcome     │
│  (Login)     │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  Home        │
│  (Menu)      │
└──────┬───────┘
       │
       ├──────────────┐
       │              │
       ▼              ▼
┌──────────────┐  ┌──────────────┐
│  Enroll      │  │  Verify      │
│  Fingerprint │  │  Fingerprint │
└──────┬───────┘  └──────┬───────┘
       │                 │
       ▼                 ▼
┌──────────────┐  ┌──────────────┐
│  Camera      │  │  Camera      │
│  Capture     │  │  Capture     │
└──────┬───────┘  └──────┬───────┘
       │                 │
       ▼                 ▼
┌──────────────┐  ┌──────────────┐
│  Processing  │  │  Processing  │
│  (Overlay)   │  │  (Overlay)   │
└──────┬───────┘  └──────┬───────┘
       │                 │
       ▼                 ▼
┌──────────────┐  ┌──────────────┐
│  Success     │  │  Match/No    │
│  Message     │  │  Match Msg   │
└──────────────┘  └──────────────┘
```

## Capture Process Details

### Step-by-Step Capture

1. **Camera Preview**
   - Live camera feed shown
   - Hand detection overlay displayed
   - Distance indicator (ARKit/ARCore)

2. **Hand Detection**
   - MediaPipe hand tracking
   - 21 hand landmarks detected
   - Fingertips identified (8, 12, 16, 20)

3. **AR Guidance**
   - Distance measurement from camera
   - Visual feedback (green = good, red = too close/far)
   - Position guidance (center hand)

4. **Photo Capture**
   - User taps capture button
   - Multiple frames captured (burst)
   - Best frame selected

5. **Fingerprint Extraction**
   - Fingertip regions isolated
   - Each region enhanced
   - Ridge patterns extracted

6. **Template Creation**
   - Minutiae points compiled
   - Template encrypted
   - Stored in Keychain/EncryptedSharedPreferences

## Data Flow Diagram

```
┌─────────────┐
│   Camera    │
│   Capture   │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Hand       │
│  Detection  │
│(MediaPipe)  │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  AR         │
│  Distance   │
│ Measurement │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Fingerprint│
│  Region     │
│  Extraction │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Image      │
│  Enhancement│
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Minutiae   │
│  Extraction │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Template   │
│  Creation   │
└──────┬──────┘
       │
       ├──────────────┐
       │              │
       ▼              ▼
┌─────────────┐  ┌─────────────┐
│  Store    │  │  Match      │
│  (DB)     │  │  (Compare)  │
└─────────────┘  └─────────────┘
```

## API Calls

### Enrollment

```
POST /api/enroll
{
  "userId": "user123",
  "fingerprintTemplate": "base64-encoded-template"
}

Response:
{
  "success": true,
  "enrollmentId": "enroll_123",
  "confidence": 0.85
}
```

### Verification

```
POST /api/verify
{
  "userId": "user123",
  "fingerprintTemplate": "base64-encoded-template"
}

Response:
{
  "match": true,
  "confidence": 0.92,
  "timestamp": "2026-10-11T10:30:00Z"
}
```

## Error Handling

### Common Errors

| Error | Cause | Resolution |
|-------|-------|------------|
| No hand detected | Hand out of frame | Guide user to position hand |
| Poor image quality | Low resolution, blur | Retake photo, improve lighting |
| Insufficient minutiae | Fingerprint not captured | Reposition finger |
| Distance too close | <6 inches | Move hand back |
| Distance too far | >12 inches | Move hand closer |

### User Feedback

- Visual overlay (green/red distance indicator)
- Audio feedback (capture sound)
- Haptic feedback (vibration on success)
- Text messages (clear error descriptions)

## Performance Targets

| Step | Target Time |
|------|-------------|
| Hand detection | <200ms |
| AR distance | <100ms |
| Image enhancement | <500ms |
| Minutiae extraction | <300ms |
| Template matching | <100ms |
| Total capture | <1.5s |

## Security Flow

```
┌─────────────┐
│  Liveness   │
│  Detection  │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Template   │
│  Encryption │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Secure     │
│  Storage    │
│(Keychain)   │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Match/     │
│  No Match    │
└─────────────┘
```

## Platform-Specific Workflows

### iOS (Swift)

```swift
// Enrollment
let sdk = TouchlessFingerprintSDK(config: config, database: database)
let result = sdk.enrollFingerprint(from: ciImage, userId: "user123")

// Verification
let result = sdk.verifyFingerprint(from: ciImage, userId: "user123")
```

### Android (Kotlin)

```kotlin
// Enrollment
val sdk = TouchlessFingerprintSDK(config, database)
val result = sdk.enrollFingerprint(bitmap, "user123")

// Verification
val result = sdk.verifyFingerprint(bitmap, "user123")
```

### Flutter (Dart)

```dart
// Enrollment
final sdk = TouchlessFingerprintSDK();
final result = await sdk.enrollFingerprint(imageBytes, "user123");

// Verification
final result = await sdk.verifyFingerprint(imageBytes, "user123");
```

## Next Steps

1. Implement camera capture UI
2. Implement hand detection overlay
3. Implement AR distance guidance
4. Implement fingerprint processing pipeline
5. Test with real fingerprints
6. Tune enhancement parameters
7. Benchmark performance
