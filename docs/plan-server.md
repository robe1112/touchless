# Automated Biometric Server (ABIS) Plan

## Overview

Server for testing touchless fingerprint system with multiple matcher backends and biometric fusion support.

## Architecture

### Components

**Server Core**
- REST API for fingerprint capture, enrollment, verification
- WebSocket for real-time video stream processing
- Matcher selection via query params or config
- Fusion engine combining multiple matchers

**Matcher Interface**
- Abstract `BiometricMatcher` base class
- Concrete implementations:
  - `SVNView2Matcher` (Hand_GET-EPITA)
  - `NISTMatcher` (Fingerprint_NIST)
  - `NBISMatcher` (bozorth3)
- Fusion strategies: weighted voting, score fusion, meta-classifier

**Future Modalities**
- Face recognition
- Iris scanning
- Palm vein
- Keystroke dynamics

### API Endpoints

```
POST /capture          - Capture fingerprint image
POST /enroll          - Enroll new fingerprint template
POST /verify          - Verify fingerprint against template
GET  /matchers        - List available matchers
POST /fusion          - Multi-matcher verification
GET  /status          - Server health
```

### Data Flow

```
Input Image -> Preprocessing -> Matcher 1 -> Score 1
                         -> Matcher 2 -> Score 2
                         -> Matcher N -> Score N
                    -> Fusion Engine
              Final Decision
```

## Implementation Plan

### Phase 1: Core Server
- [ ] Set up Flask/FastAPI server
- [ ] Implement basic fingerprint endpoints
- [ ] Add image preprocessing pipeline

### Phase 2: Matcher Integration
- [ ] Create abstract matcher interface
- [ ] Implement SVNView2 wrapper
- [ ] Implement NIST wrapper
- [ ] Implement NBIS wrapper
- [ ] Add matcher selection logic

### Phase 3: Fusion Engine
- [ ] Design fusion interface
- [ ] Implement score-level fusion
- [ ] Implement decision-level fusion
- [ ] Add configurable fusion weights

### Phase 4: Video Processing
- [ ] WebSocket server for streaming
- [ ] Real-time frame processing
- [ ] Liveness detection integration

### Phase 5: Multi-Modal Support
- [ ] Abstract modality interface
- [ ] Face recognition module
- [ ] Iris scanning module
- [ ] Multi-modal fusion

## Third-Party Matcher Integration

### SVNView2 (Hand_GET-EPITA)
- Location: `/Users/rob/algorithimartistry/touchless/third-party/svnview2-eph/ref_syst/Hand_GET-EPITA`
- Extract minutiae from fingerprint images
- Generate feature vectors for matching

### NIST (Fingerprint_NIST)
- Location: `/Users/rob/algorithimartistry/touchless/third-party/svnview2-eph/ref_syst/Fingerprint_NIST`
- NIST-standard fingerprint processing
- COMPAD algorithm support

### NBIS (bozorth3)
- Location: `/Users/rob/algorithimartistry/touchless/third-party/NBIS_5.0.0/bozorth3`
- NIST Biometric Image Software
- Minutiae-based matching
- Support for NIST IAFIS format

## Configuration

```yaml
matchers:
  enabled:
    - svnview2
    - nist
    - nbis
  default: nbis
  fusion:
    strategy: weighted_score
    weights:
      svnview2: 0.3
      nist: 0.3
      nbis: 0.4
video:
  enabled: true
  fps: 30
  resolution: 1280x720
```

## Testing Strategy

- Unit tests for each matcher
- Integration tests for fusion engine
- Performance benchmarks
- Accuracy validation against FIDELIS database

## Deployment

- Docker containerization
- Configurable matcher selection via environment variables
- Health check endpoints
- Logging and monitoring
