/**
 * Scheme Controller
 * CRUD for Government Schemes using the GovernmentScheme model.
 */
const GovernmentScheme = require('../models/GovernmentScheme');
const { ApiError, asyncHandler } = require('../utils/helpers');

// @desc    Get all schemes (with filters)
// @route   GET /api/v1/schemes
// @access  Public
exports.getSchemes = asyncHandler(async (req, res) => {
    const { type, search, state, page = 1, limit = 50 } = req.query;
    const query = { isActive: true };

    if (type && type !== 'all') query.schemeType = type;
    if (state) query.$or = [{ targetState: state }, { schemeType: 'central' }];
    if (search) query.$text = { $search: search };

    const total = await GovernmentScheme.countDocuments(query);
    const schemes = await GovernmentScheme.find(query)
        .sort({ lastUpdated: -1 })
        .skip((page - 1) * limit)
        .limit(parseInt(limit));

    res.status(200).json({
        success: true,
        count: schemes.length,
        total,
        data: schemes,
    });
});

// @desc    Get single scheme
// @route   GET /api/v1/schemes/:id
// @access  Public
exports.getScheme = asyncHandler(async (req, res) => {
    const scheme = await GovernmentScheme.findById(req.params.id);
    if (!scheme) throw new ApiError(404, 'Scheme not found');
    res.status(200).json({ success: true, data: scheme });
});
