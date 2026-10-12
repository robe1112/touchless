# Touchless Fingerprint App Flow

## Main Screens

### 1. Welcome Screen
```
┌─────────────────────────┐
│                         │
│     [App Logo]          │
│                         │
│   Touchless Fingerprint │
│                         │
│   [Enroll Fingerprint]  │
│   [Verify Fingerprint]  │
│                         │
└─────────────────────────┘
```

### 2. Camera Screen (Enrollment)
```
┌─────────────────────────┐
│  [← Back]               │
│                         │
│   ┌─────────────────┐   │
│   │                 │   │
│   │  Camera Preview │   │
│   │                 │   │
│   │   [🖐 Hand]     │   │
│   │   🟢 8 inches   │   │
│   └─────────────────┘   │
│                         │
│   [📸 Capture]          │
│                         │
└─────────────────────────┘
```

### 3. Camera Screen (Verification)
```
┌─────────────────────────┐
│  [← Back]               │
│                         │
│   ┌─────────────────┐   │
│   │                 │   │
│   │  Camera Preview │   │
│   │                 │   │
│   │   [🖐 Hand]     │   │
│   │   🟢 8 inches   │   │
│   └─────────────────┘   │
│                         │
│   [📸 Capture]          │
│                         │
└─────────────────────────┘
```

### 4. Processing Screen
```
┌─────────────────────────┐
│  [← Back]               │
│                         │
│   ┌─────────────────┐   │
│   │                 │   │
│   │  Processing...  │   │
│   │   [⏳ Spinner]  │   │
│   │                 │   │
│   └─────────────────┘   │
│                         │
│   Extracting fingerprint│
│                         │
└─────────────────────────┘
```

### 5. Success Screen (Enrollment)
```
┌─────────────────────────┐
│  [✓]                    │
│                         │
│   Fingerprint Enrolled  │
│                         │
│   Confidence: 85%       │
│                         │
│   [Continue]            │
│                         │
└─────────────────────────┘
```

### 6. Success Screen (Verification)
```
┌─────────────────────────┐
│  [✓] Match!             │
│                         │
│   Fingerprint Verified  │
│                         │
│   Confidence: 92%       │
│                         │
│   [Continue]            │
│                         │
└─────────────────────────┘
```

### 7. Error Screen
```
┌─────────────────────────┐
│  [✗]                    │
│                         │
│   No Hand Detected      │
│                         │
│   Please place hand in  │
│   the frame and try     │
│   again.                │
│                         │
│   [Retry]               │
│                         │
└─────────────────────────┘
```

## Navigation Flow

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
│              │
│  [Enroll]    │
│  [Verify]    │
└──────┬───────┘
       │
       ├──────────────┐
       │              │
       ▼              ▼
┌──────────────┐  ┌──────────────┐
│  Camera      │  │  Camera      │
│  (Enroll)    │  │  (Verify)    │
└──────┬───────┘  └──────┬───────┘
       │                 │
       ▼                 ▼
┌──────────────┐  ┌──────────────┐
│  Processing  │  │  Processing  │
└──────┬───────┘  └──────┬───────┘
       │                 │
       ▼                 ▼
┌──────────────┐  ┌──────────────┐
│  Success     │  │  Match/No    │
│  (Enroll)    │  │  Match Msg   │
└──────┬───────┘  └──────┬───────┘
       │                 │
       ▼                 ▼
┌──────────────┐  ┌──────────────┐
│  Home        │  │  Home        │
└──────────────┘  └──────────────┘
```

## Camera Screen States

### State 1: No Hand Detected
```
┌─────────────────────────┐
│  [🖐 Hand Not Found]    │
│                         │
│   Please place your     │
│   hand in the frame     │
│                         │
│ [📸 Capture] (disabled) │
│                         │
└─────────────────────────┘
```

### State 2: Hand Too Close
```
┌─────────────────────────┐
│   [✗ Hand Too Close]    │
│     🔴 3 inches         │
│                         │
│    Move hand back       │
│                         │
│ [📸 Capture] (disabled) │
│                         │
└─────────────────────────┘
```

### State 3: Hand Too Far
```
┌─────────────────────────┐
│  [✗ Hand Too Far]       │
│   🔴 18 inches          │
│                         │
│   Move hand closer      │
│                         │
│ [📸 Capture] (disabled) │
│                         │
└─────────────────────────┘
```

### State 4: Good Position
```
┌─────────────────────────┐
│  [✓ Hand Detected]      │
│   🟢 8 inches           │
│                         │
│   Ready to capture      │
│                         │
│  [📸 Capture] (enabled) │
│                         │
└─────────────────────────┘
```

## Capture Process Timeline

```
Time    Event
───────────────────────────────────────────────────────────
0.0s    User taps capture button
0.05s   Photo captured (frame 1)
0.06s   Photo captured (frame 2)
0.07s   Photo captured (frame 3)
0.10s   Hand detection starts
0.20s   Hand detected, landmarks extracted
0.25s   Distance measured (8 inches)
0.30s   Fingerprint regions identified
0.35s   Image enhancement starts
0.80s   Enhancement complete
0.85s   Minutiae extraction starts
1.10s   Minutiae extraction complete
1.15s   Template creation starts
1.20s   Template created
1.25s   Display result
───────────────────────────────────────────────────────────
Total:  ~1.25 seconds
```

## Error States

| State           | Trigger              | Action                     |
| --------------- | -------------------- | -------------------------- |
| No hand         | No hand in frame     | Show "Place hand in frame" |
| Too close       | Distance < 6 inches  | Show "Move hand back"      |
| Too far         | Distance > 12 inches | Show "Move hand closer"    |
| Poor quality    | Low resolution       | Show "Improve lighting"    |
| Capture fail    | Camera error         | Show "Retry capture"       |
| Processing fail | Enhancement error    | Show "Retake photo"        |

## Success States

| State                 | Trigger         | Action                       |
| --------------------- | --------------- | ---------------------------- |
| Enrollment success    | Template stored | Show "Enrollment successful" |
| Verification match    | Score >= 70%    | Show "Match confirmed"       |
| Verification no match | Score < 70%     | Show "No match found"        |

## Performance Targets

| Metric               | Target   |
| -------------------- | -------- |
| Hand detection       | <200ms   |
| Distance measurement | <100ms   |
| Image enhancement    | <500ms   |
| Minutiae extraction  | <300ms   |
| Template creation    | <50ms    |
| Total capture        | <1.5s    |
