/**
 * Crop Controller
 * Crop calendar and crop information using CropCalendar model.
 */
const CropCalendar = require('../models/CropCalendar');
const { asyncHandler } = require('../utils/helpers');

// @desc    Get crops (optionally by season/search)
// @route   GET /api/v1/crops
// @access  Public
exports.getCrops = asyncHandler(async (req, res) => {
    const { season, search, month } = req.query;
    const query = {};

    if (season) query.season = season;
    if (month) query.month = parseInt(month);
    if (search) query.cropName = { $regex: search, $options: 'i' };

    const crops = await CropCalendar.find(query).sort({ cropName: 1, month: 1 });

    // Group by crop name for calendar view
    const grouped = {};
    for (const entry of crops) {
        if (!grouped[entry.cropName]) {
            grouped[entry.cropName] = {
                _id: entry._id,
                name: entry.cropName,
                category: entry.season,
                season: entry.season,
                calendar: [],
            };
        }
        grouped[entry.cropName].calendar.push({
            stage: entry.stage,
            startWeek: entry.month * 4 - 3,
            endWeek: entry.month * 4,
            activities: [entry.recommendedAction, entry.fertilizerAdvice, entry.irrigationAdvice].filter(Boolean),
        });
    }

    res.status(200).json({
        success: true,
        count: Object.keys(grouped).length,
        data: Object.values(grouped),
    });
});

// @desc    Get crop calendar for a specific crop
// @route   GET /api/v1/crops/:cropName/calendar
// @access  Public
exports.getCropCalendar = asyncHandler(async (req, res) => {
    const entries = await CropCalendar.find({
        cropName: { $regex: req.params.cropName, $options: 'i' },
    }).sort({ month: 1 });

    res.status(200).json({
        success: true,
        count: entries.length,
        data: entries,
    });
});
