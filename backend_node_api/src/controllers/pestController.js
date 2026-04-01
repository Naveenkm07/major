/**
 * Pest Detection Controller
 * Proxies image uploads from the mobile app to the Python AI microservice.
 *
 * Flow:
 *   Mobile App → Node.js (multer) → Python FastAPI (/api/v1/detect_pest) → Result
 *   Node.js also saves the scan result to MongoDB (PestScan collection).
 *
 * Example:
 *   POST /api/v1/pest-detect
 *   Headers: Authorization: Bearer <jwt>
 *   Body: multipart/form-data { image: <file> }
 *
 * Response:
 *   {
 *     "success": true,
 *     "data": {
 *       "scanId": "65f...",
 *       "pest": "rust",
 *       "confidence": 0.92,
 *       "description": "Rust appears as...",
 *       "treatment": ["Spray Propiconazole..."],
 *       "prevention": ["Plant resistant varieties..."],
 *       "imageUrl": "https://...s3.amazonaws.com/..."
 *     }
 *   }
 */

const axios = require('axios');
const FormData = require('form-data');
const config = require('../config');
const PestScan = require('../models/PestScan');
const { ApiError, asyncHandler } = require('../utils/helpers');

// ═══════════════════════════════════════════════════════
// @desc    Detect pest/disease from uploaded crop image
// @route   POST /api/v1/pest-detect
// @access  Private (JWT required)
// ═══════════════════════════════════════════════════════
exports.detectPest = asyncHandler(async (req, res) => {
    // ─── Validate image upload ──────────────────────
    if (!req.file) {
        throw new ApiError(400, 'Please upload a crop image');
    }

    const allowedTypes = ['image/jpeg', 'image/png', 'image/webp'];
    if (!allowedTypes.includes(req.file.mimetype)) {
        throw new ApiError(400, `Unsupported file type: ${req.file.mimetype}. Allowed: JPEG, PNG, WebP`);
    }

    if (req.file.size > 10 * 1024 * 1024) {
        throw new ApiError(413, 'Image too large. Maximum size is 10 MB');
    }

    // ─── Forward image to Python AI service ─────────
    // Build multipart form data with the image buffer
    const formData = new FormData();
    formData.append('image', req.file.buffer, {
        filename: req.file.originalname,
        contentType: req.file.mimetype,
    });

    let aiResult;
    try {
        const aiResponse = await axios.post(
            `${config.aiService.url}/api/v1/detect_pest`,
            formData,
            {
                headers: {
                    ...formData.getHeaders(),
                    Authorization: req.headers.authorization, // Forward JWT
                },
                timeout: 30000, // 30 second timeout for ML inference
                maxContentLength: 20 * 1024 * 1024,
            }
        );
        aiResult = aiResponse.data;
    } catch (err) {
        // Distinguish between AI service errors and network errors
        if (err.response) {
            throw new ApiError(
                err.response.status,
                `AI Service error: ${err.response.data?.detail || 'Detection failed'}`
            );
        }
        throw new ApiError(503, 'AI Service is unavailable. Please try again later.');
    }

    // ─── Save scan result to MongoDB ────────────────
    const scan = await PestScan.create({
        farmerId: req.user.id,
        imageUrl: aiResult.image_url || '',
        cropType: req.body.cropType || 'unknown',
        diseaseDetected: aiResult.pest,
        confidenceScore: aiResult.confidence,
        treatmentSuggestion: (aiResult.treatment || []).join('\n'),
        scanDate: new Date(),
    });

    // ─── Return enriched result ─────────────────────
    res.status(200).json({
        success: true,
        data: {
            scanId: scan._id,
            pest: aiResult.pest,
            confidence: aiResult.confidence,
            description: aiResult.description || '',
            treatment: aiResult.treatment || [],
            prevention: aiResult.prevention || [],
            imageUrl: aiResult.image_url || '',
        },
    });
});

// ═══════════════════════════════════════════════════════
// @desc    Get farmer's scan history
// @route   GET /api/v1/pest-detect/history
// @access  Private
// ═══════════════════════════════════════════════════════
exports.getScanHistory = asyncHandler(async (req, res) => {
    const { page = 1, limit = 20 } = req.query;

    const total = await PestScan.countDocuments({ farmerId: req.user.id });
    const scans = await PestScan.find({ farmerId: req.user.id })
        .sort({ scanDate: -1 })
        .skip((page - 1) * limit)
        .limit(parseInt(limit));

    res.status(200).json({
        success: true,
        count: scans.length,
        total,
        pages: Math.ceil(total / limit),
        data: scans,
    });
});

// ═══════════════════════════════════════════════════════
// @desc    Get single scan by ID
// @route   GET /api/v1/pest-detect/:id
// @access  Private
// ═══════════════════════════════════════════════════════
exports.getScan = asyncHandler(async (req, res) => {
    const scan = await PestScan.findOne({ _id: req.params.id, farmerId: req.user.id });

    if (!scan) {
        throw new ApiError(404, 'Scan not found');
    }

    res.status(200).json({ success: true, data: scan });
});
