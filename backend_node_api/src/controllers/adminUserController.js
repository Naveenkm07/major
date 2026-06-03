const Farmer = require('../models/Farmer');
const { ApiError, asyncHandler } = require('../utils/helpers');
const jwt = require('jsonwebtoken');

// Hardcoded admin credentials (in production, use DB or ENV)
const ADMIN_ID = process.env.ADMIN_ID || 'admin';
const ADMIN_PASS = process.env.ADMIN_PASS || 'admin123';

// ═══════════════════════════════════════════════════════
// @desc    Admin Login
// @route   POST /api/v1/admin/login
// @access  Public
// ═══════════════════════════════════════════════════════
exports.adminLogin = asyncHandler(async (req, res) => {
    const { id, password } = req.body;

    if (id !== ADMIN_ID || password !== ADMIN_PASS) {
        throw new ApiError(401, 'Invalid admin credentials');
    }

    const token = jwt.sign({ id: 'admin', role: 'admin' }, process.env.JWT_SECRET, {
        expiresIn: '1d',
    });

    res.status(200).json({
        success: true,
        token,
    });
});

// ═══════════════════════════════════════════════════════
// @desc    Get all farmers
// @route   GET /api/v1/admin/farmers
// @access  Private (Admin)
// ═══════════════════════════════════════════════════════
exports.getAllFarmers = asyncHandler(async (req, res) => {
    // Optional query params for pagination
    const page = parseInt(req.query.page, 10) || 1;
    const limit = parseInt(req.query.limit, 10) || 50;
    const startIndex = (page - 1) * limit;

    const total = await Farmer.countDocuments();
    const farmers = await Farmer.find().skip(startIndex).limit(limit).sort('-createdAt');

    res.status(200).json({
        success: true,
        count: farmers.length,
        total,
        page,
        data: farmers
    });
});

// ═══════════════════════════════════════════════════════
// @desc    Get single farmer by ID
// @route   GET /api/v1/admin/farmers/:id
// @access  Private (Admin)
// ═══════════════════════════════════════════════════════
exports.getFarmerById = asyncHandler(async (req, res) => {
    const farmer = await Farmer.findById(req.params.id);
    if (!farmer) {
        throw new ApiError(404, 'Farmer not found');
    }

    res.status(200).json({
        success: true,
        data: farmer
    });
});

// ═══════════════════════════════════════════════════════
// @desc    Update farmer (Admin)
// @route   PUT /api/v1/admin/farmers/:id
// @access  Private (Admin)
// ═══════════════════════════════════════════════════════
exports.updateFarmer = asyncHandler(async (req, res) => {
    let farmer = await Farmer.findById(req.params.id);
    if (!farmer) {
        throw new ApiError(404, 'Farmer not found');
    }

    farmer = await Farmer.findByIdAndUpdate(req.params.id, req.body, {
        new: true,
        runValidators: true
    });

    res.status(200).json({
        success: true,
        data: farmer
    });
});

// ═══════════════════════════════════════════════════════
// @desc    Delete farmer (Admin)
// @route   DELETE /api/v1/admin/farmers/:id
// @access  Private (Admin)
// ═══════════════════════════════════════════════════════
exports.deleteFarmer = asyncHandler(async (req, res) => {
    const farmer = await Farmer.findById(req.params.id);
    if (!farmer) {
        throw new ApiError(404, 'Farmer not found');
    }

    await farmer.deleteOne();

    res.status(200).json({
        success: true,
        data: {}
    });
});
