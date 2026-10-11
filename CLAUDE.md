# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Touchless fingerprint capturing system. Users capture fingerprints by taking photos of their hands or supplying existing photos containing hands. System extracts fingerprint data from 2D images for biometric authentication.

## Architecture

### Core Components

- **`fingerprint_capture.py`** - Main fingerprint capture engine. Handles fingerprint extraction from photos, image enhancement, and minutiae detection.
- **`hand_detector.py`** - Detects hands in images using MediaPipe, isolates fingerprint regions (fingertips).
- **`fingerprint_processor.py`** - Processes fingerprint images: enhancement, ridge extraction, feature extraction.
- **`fingerprint_matcher.py`** - Compares extracted fingerprints against enrolled templates.
- **`liveness_detector.py`** - Detects spoofing attempts (photos, prints, screens).
- **`image_enhancer.py`** - Enhances fingerprint quality from photos (contrast, noise reduction, super-resolution).

### Key Design Patterns

- **Pipeline pattern** - Sequential processing: capture → detect → enhance → extract → match
- **Strategy pattern** - Swappable enhancement and matching algorithms
- **Singleton pattern** - Fingerprint database and matcher instances
- **Observer pattern** - Capture progress callbacks

### Data Flow

```
Input Photo → Hand Detection → Fingerprint Region Isolation → Image Enhancement → Ridge Extraction → Minutiae Detection → Template Creation → Database Match
```

## Development Commands

### Running the Application

```bash
# Run main application
python main.py

# Capture from camera
python main.py --capture

# Process existing photo
python main.py --process image.jpg

# Batch process directory
python main.py --batch /path/to/images/
```

### Testing

```bash
# Run all tests
python -m pytest tests/ -v

# Run fingerprint-specific tests
python -m pytest tests/test_fingerprint_capture.py -v

# Run with coverage
python -m pytest tests/ --cov=. --cov-report=html
```

### Linting

```bash
# Run flake8
flake8 .

# Run black formatter
black .

# Run mypy type checking
mypy .
```

## Configuration

Configuration files:
- `config.yaml` - Main application configuration
- `fingerprint_config.yaml` - Fingerprint parameters (resolution, enhancement settings)
- `database_config.yaml` - Fingerprint database connection settings

## Common Tasks

### Adding Fingerprint Capture Support

1. Implement capture method in `fingerprint_capture.py`
2. Add enhancement algorithm to `image_enhancer.py`
3. Update `fingerprint_config.yaml` with new parameters
4. Add test in `tests/test_fingerprint_capture.py`

### Modifying Fingerprint Processing

- Update `fingerprint_processor.py` for extraction changes
- Modify `image_enhancer.py` for enhancement algorithm changes
- Adjust thresholds in `fingerprint_config.yaml`

### Enrolling New Fingerprints

```bash
# Enroll fingerprint from photo
python enroll.py --fingerprint image.jpg --user user_id

# Batch enroll directory
python enroll.py --batch /path/to/images/ --user user_id
```

## Documentation

- `plan.md` - Development plan with phases and deliverables
- `SRD.md` - Software Requirements Document
- `docs/touchless-fingerprint-research.md` - Touchless fingerprint research

## Dependencies

Core dependencies in `requirements.txt`:
- `opencv-python` - Image processing and enhancement
- `mediapipe` - Hand detection
- `scikit-image` - Feature extraction
- `numpy` - Numerical operations
- `pyyaml` - Configuration parsing
- `torch` or `tensorflow` - Deep learning enhancement (optional)

## Known Issues

- Fingerprint extraction from photos has lower accuracy than contact scanners
- Lighting conditions significantly affect quality
- Requires high-resolution input images (minimum 500 DPI equivalent)
- Liveness detection still maturing for photo-based systems
