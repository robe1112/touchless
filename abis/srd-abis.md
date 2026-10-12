# Software Requirements Document (SRD) - Automated Biometric Identification System (ABIS)

## 1. Introduction

### 1.1 Purpose
This document specifies the requirements for the Automated Biometric Identification System (ABIS), an enterprise-scale biometric system for touchless fingerprint authentication with multi-modal support.

### 1.2 Scope
ABIS provides fingerprint capture, enrollment, verification, and identification capabilities using multiple matcher backends (SVNView2, NIST, NBIS) with fusion engine support. Future modalities include face recognition, iris scanning, and palm vein.

### 1.3 Definitions
- **ABIS**: Automated Biometric Identification System
- **Matcher**: Biometric matching algorithm (SVNView2, NIST, NBIS)
- **Fusion**: Combination of multiple matcher outputs
- **Minutiae**: Fingerprint features (ridge endings, bifurcations)
- **ROI**: Region of Interest (fingerprint area)

## 2. Overall Description

### 2.1 Product Perspective
ABIS is a server-based biometric system that integrates with touchless fingerprint capture hardware/software. It provides REST API and WebSocket interfaces for client applications.

### 2.2 Product Functions
- Fingerprint image capture and preprocessing
- Multi-matcher fingerprint verification
- 1:N fingerprint identification
- Multi-modal biometric fusion
- Video stream processing for liveness detection
- Template management and storage

### 2.3 User Classes
- **Administrators**: System configuration, user management
- **Enrollment Officers**: Fingerprint enrollment, person registration
- **End Users**: Verification/identification requests
- **Auditors**: Audit log access

### 2.4 Operating Environment
- Linux/Unix server environment
- Docker/Kubernetes containerization
- PostgreSQL database with pgvector extension
- REST API over HTTPS
- WebSocket for streaming

## 3. Specific Requirements

### 3.1 Biometric Capture Requirements

#### 3.1.1 Fingerprint Capture
- **REQ-CAP-001**: System shall accept fingerprint images from multiple camera sources
- **REQ-CAP-002**: System shall support JPEG, PNG, and raw image formats
- **REQ-CAP-003**: System shall assess image quality (score 0-100)
- **REQ-CAP-004**: System shall reject images below quality threshold (configurable)
- **REQ-CAP-005**: System shall extract fingerprint ROI from hand images
- **REQ-CAP-006**: Feature extraction shall occur on mobile device (PREFERRED)
- **REQ-CAP-007**: Server shall receive templates only, not raw images
- **REQ-CAP-008**: Mobile constraints: min 500x500 resolution, max 5MB file size

#### 3.1.2 Video Processing
- **REQ-VID-001**: System shall accept real-time video streams via WebSocket
- **REQ-VID-002**: System shall process video at configurable FPS (default 30)
- **REQ-VID-003**: System shall perform liveness detection on video frames
- **REQ-VID-004**: System shall detect spoofing attempts (photo, screen, print)

### 3.2 Matcher Requirements

#### 3.2.1 SVNView2 Matcher
- **REQ-MAT-001**: System shall integrate SVNView2 (Hand_GET-EPITA) matcher
- **REQ-MAT-002**: SVNView2 shall extract minutiae features (ridge endings, bifurcations)
- **REQ-MAT-003**: SVNView2 shall output match scores 0-100
- **REQ-MAT-004**: SVNView2 threshold shall be configurable (default 65)

#### 3.2.2 NIST Matcher
- **REQ-MAT-005**: System shall integrate NIST Fingerprint System
- **REQ-MAT-006**: NIST shall support COMPAD algorithm
- **REQ-MAT-007**: NIST shall output NIST IAFIS format
- **REQ-MAT-008**: NIST threshold shall be configurable (default 60)

#### 3.2.3 NBIS Matcher
- **REQ-MAT-009**: System shall integrate NBIS bozorth3 matcher
- **REQ-MAT-010**: NBIS shall perform minutiae-based matching
- **REQ-MAT-011**: NBIS shall support NIST IAFIS format
- **REQ-MAT-012**: NBIS threshold shall be configurable (default 55)

#### 3.2.4 Matcher Orchestration
- **REQ-MAT-013**: System shall support single matcher selection
- **REQ-MAT-014**: System shall support parallel multi-matcher execution
- **REQ-MAT-015**: System shall support sequential fallback on matcher failure
- **REQ-MAT-016**: System shall aggregate matcher results

### 3.3 Fusion Requirements

#### 3.3.1 Score-Level Fusion
- **REQ-FUS-001**: System shall implement weighted score fusion
- **REQ-FUS-002**: System shall normalize matcher scores to common scale
- **REQ-FUS-003**: Fusion weights shall be configurable per matcher
- **REQ-FUS-004**: System shall support adaptive learning for weights

#### 3.3.2 Decision-Level Fusion
- **REQ-FUS-005**: System shall implement majority voting
- **REQ-FUS-006**: System shall support weighted voting
- **REQ-FUS-007**: System shall support rule-based fusion
- **REQ-FUS-008**: Rules shall be configurable (e.g., "accept if NBIS > 80 OR (SVNView2 > 70 AND NIST > 75)")

#### 3.3.3 Feature-Level Fusion
- **REQ-FUS-009**: System shall support feature vector concatenation
- **REQ-FUS-010**: System shall support dimensionality reduction (PCA, LDA)
- **REQ-FUS-011**: System shall support learned fusion (neural network)

### 3.4 Enrollment Requirements

#### 3.4.1 Person Enrollment
- **REQ-ENR-001**: System shall enroll persons with unique person_id
- **REQ-ENR-002**: System shall store person metadata (external_id, status)
- **REQ-ENR-003**: System shall support person status (active, inactive, watchlist)
- **REQ-ENR-004**: System shall track enrollment timestamps

#### 3.4.2 Fingerprint Enrollment
- **REQ-ENR-005**: System shall enroll 10 fingerprints per person
- **REQ-ENR-006**: System shall identify finger (left_index, right_pinky, etc.)
- **REQ-ENR-007**: System shall store ISO/IEC 19794-2 templates
- **REQ-ENR-008**: System shall store segmented fingerprint ROI images
- **REQ-ENR-009**: System shall track matcher type per fingerprint
- **REQ-ENR-010**: Feature extraction shall occur on mobile device
- **REQ-ENR-011**: Server shall receive templates only (not raw images)

### 3.5 Verification Requirements

#### 3.5.1 1:1 Verification
- **REQ-VER-001**: System shall verify fingerprint against enrolled template
- **REQ-VER-002**: System shall support single matcher verification
- **REQ-VER-003**: System shall support multi-matcher fusion verification
- **REQ-VER-004**: System shall return match decision (match/no_match/uncertain)
- **REQ-VER-005**: System shall return match score (0-100)
- **REQ-VER-006**: Threshold shall be configurable per request

#### 3.5.2 1:N Identification
- **REQ-IDN-001**: System shall identify fingerprint against person database
- **REQ-IDN-002**: System shall return top-k candidates (configurable)
- **REQ-IDN-003**: System shall return candidate scores and ranks
- **REQ-IDN-004**: System shall apply threshold filtering

### 3.6 Database Requirements

#### 3.6.1 Data Storage
- **REQ-DAT-001**: System shall store person records in persons table
- **REQ-DAT-002**: System shall store face images in faces table
- **REQ-DAT-003**: System shall store fingerprint templates in fingerprints table
- **REQ-DAT-004**: System shall store match results in match_results table
- **REQ-DAT-005**: System shall store audit logs in audit_log table

#### 3.6.2 Data Indexing
- **REQ-DAT-006**: System shall index persons by external_id
- **REQ-DAT-007**: System shall index faces by person_id
- **REQ-DAT-008**: System shall use IVFFlat index for face encoding similarity
- **REQ-DAT-009**: System shall index fingerprints by person_id and finger_identifier

#### 3.6.3 Data Types
- **REQ-DAT-010**: Person photos shall be stored as BYTEA
- **REQ-DAT-011**: Face images shall be stored as BYTEA
- **REQ-DAT-012**: Face encodings shall be stored as vectors (pgvector)
- **REQ-DAT-013**: Fingerprint templates shall be stored as BYTEA
- **REQ-DAT-014**: Segmented images shall be stored as BYTEA

### 3.7 API Requirements

#### 3.7.1 REST API
- **REQ-API-001**: System shall provide REST API over HTTPS
- **REQ-API-002**: System shall use JSON request/response format
- **REQ-API-003**: System shall return appropriate HTTP status codes
- **REQ-API-004**: System shall support OAuth2/JWT authentication

#### 3.7.2 API Endpoints
- **REQ-API-005**: POST /api/v1/capture - Capture fingerprint image
- **REQ-API-006**: POST /api/v1/enroll - Enroll new fingerprint
- **REQ-API-007**: POST /api/v1/verify - Verify fingerprint
- **REQ-API-008**: POST /api/v1/identify - Identify fingerprint (1:N)
- **REQ-API-009**: POST /api/v1/fusion - Multi-matcher fusion
- **REQ-API-010**: GET /api/v1/status - System health check

#### 3.7.3 WebSocket API
- **REQ-API-011**: System shall provide WebSocket for video streaming
- **REQ-API-012**: WebSocket shall support real-time frame processing
- **REQ-API-013**: WebSocket shall return liveness detection results

### 3.8 Security Requirements

#### 3.8.1 Data Protection
- **REQ-SEC-001**: System shall encrypt data at rest (AES-256)
- **REQ-SEC-002**: System shall encrypt data in transit (TLS 1.3)
- **REQ-SEC-003**: System shall support template obfuscation (cancelable biometrics)
- **REQ-SEC-004**: System shall use HSM/KMS for key management

#### 3.8.2 Access Control
- **REQ-SEC-005**: System shall implement RBAC
- **REQ-SEC-006**: System shall require OAuth2/JWT for API access
- **REQ-SEC-007**: System shall log all operations for audit
- **REQ-SEC-008**: System shall implement rate limiting

#### 3.8.3 Privacy
- **REQ-SEC-009**: System shall enforce data retention policies
- **REQ-SEC-010**: System shall support right to deletion
- **REQ-SEC-011**: System shall manage consent
- **REQ-SEC-012**: System shall minimize biometric data collection

### 3.9 Performance Requirements

#### 3.9.1 Latency
- **REQ-PER-001**: Verification latency shall be < 500ms
- **REQ-PER-002**: Identification (10K) shall be < 5s
- **REQ-PER-003**: Identification (1M) shall be < 30s

#### 3.9.2 Accuracy
- **REQ-PER-004**: False Acceptance Rate shall be < 0.01%
- **REQ-PER-005**: False Rejection Rate shall be < 1%

#### 3.9.3 Availability
- **REQ-PER-006**: System availability shall be 99.9%

### 3.10 Scalability Requirements

- **REQ-SCA-001**: System shall support horizontal matcher scaling
- **REQ-SCA-002**: System shall support database read replicas
- **REQ-SCA-003**: System shall support load-balanced capture endpoints
- **REQ-SCA-004**: System shall support queue-based processing

### 3.11 Future Modalities

#### 3.11.1 Face Recognition
- **REQ-FAC-001**: System shall support face recognition
- **REQ-FAC-002**: System shall perform liveness detection for face
- **REQ-FAC-003**: System shall support 3D face recognition
- **REQ-FAC-004**: System shall handle partial faces

#### 3.11.2 Iris Recognition
- **REQ-IRI-001**: System shall support iris recognition
- **REQ-IRI-002**: System shall extract iris codes
- **REQ-IRI-003**: System shall support rotation-invariant matching
- **REQ-IRI-004**: System shall support eye tracking

#### 3.11.3 Palm Vein
- **REQ-PAL-001**: System shall support palm vein recognition
- **REQ-PAL-002**: System shall use near-infrared imaging
- **REQ-PAL-003**: System shall extract vein patterns
- **REQ-PAL-004**: System shall detect liveness via blood flow

#### 3.11.4 Multi-Modal Fusion
- **REQ-MUL-001**: System shall support face + fingerprint fusion
- **REQ-MUL-002**: System shall support iris + fingerprint fusion
- **REQ-MUL-003**: System shall support cross-modal matching

## 4. External Interface Requirements

### 4.1 User Interfaces
- Web-based administrative console
- Mobile application for enrollment
- REST API for programmatic access

### 4.2 Hardware Interfaces
- Fingerprint cameras (touchless)
- Video cameras for liveness detection
- Storage arrays for templates

### 4.3 Network Interfaces
- HTTPS for REST API
- WebSocket for video streaming
- Internal mesh for service communication

## 5. Non-Functional Requirements

### 5.1 Reliability
- System shall maintain 99.9% availability
- Automatic recovery from matcher failures
- Database replication for disaster recovery

### 5.2 Maintainability
- Modular matcher architecture
- Configurable fusion strategies
- Comprehensive logging and monitoring

### 5.3 Portability
- Containerized deployment (Docker)
- Kubernetes orchestration
- Support for Linux/Unix environments

### 5.4 Compliance
- ISO/IEC 19794 biometric data format
- NIST IAFIS standards
- GDPR privacy requirements

## 6. Constraints

### 6.1 Technical Constraints
- Matchers must be open-source (SVNView2, NIST, NBIS)
- Database must support vector similarity search
- API must use REST/JSON standards
- **Mobile extraction preferred**: Raw images processed on device, templates sent to server
- **Concerns**: Mobile compute limits, inconsistent quality across devices, need robust on-device enhancement

### 6.2 Operational Constraints
- High-resolution images required (minimum 500 DPI equivalent)
- Lighting conditions affect quality
- Liveness detection maturing for photo-based systems

### 6.3 Regulatory Constraints
- Biometric data retention limits
- Consent management requirements
- Right to deletion enforcement

## 7. Appendices

### 7.1 Matcher Paths
- SVNView2: `/Users/rob/algorithimartistry/touchless/third-party/svnview2-eph/ref_syst/Hand_GET-EPITA`
- NIST: `/Users/rob/algorithimartistry/touchless/third-party/svnview2-eph/ref_syst/Fingerprint_NIST`
- NBIS: `/Users/rob/algorithimartistry/touchless/third-party/NBIS_5.0.0/bozorth3`

### 7.2 Finger Identifier Codes
- left_index, left_middle, left_ring, left_pinky, left_thumb
- right_index, right_middle, right_ring, right_pinky, right_thumb
- left_palm, right_palm

### 7.3 Configuration Defaults
- SVNView2 threshold: 65
- NIST threshold: 60
- NBIS threshold: 55
- Fusion weights: svnview2=0.3, nist=0.3, nbis=0.4
