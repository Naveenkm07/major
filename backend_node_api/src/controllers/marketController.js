/**
 * Market Prices Controller
 * CRUD operations for crop market prices using the MarketPrice model.
 */
const MarketPrice = require('../models/MarketPrice');
const { ApiError, asyncHandler } = require('../utils/helpers');

// @desc    Get market prices (with filters)
// @route   GET /api/v1/market-prices
// @access  Public
exports.getMarketPrices = asyncHandler(async (req, res) => {
    const { commodity, state, district, page = 1, limit = 50 } = req.query;
    const query = {};

    if (commodity) query.cropName = { $regex: commodity, $options: 'i' };
    if (state) query['location.state'] = { $regex: state, $options: 'i' };
    if (district) query['location.district'] = { $regex: district, $options: 'i' };

    const total = await MarketPrice.countDocuments(query);
    const prices = await MarketPrice.find(query)
        .sort({ lastUpdated: -1 })
        .skip((page - 1) * limit)
        .limit(parseInt(limit));

    res.status(200).json({
        success: true,
        count: prices.length,
        total,
        pages: Math.ceil(total / limit),
        data: prices.map((p) => ({
            _id: p._id,
            commodity: p.cropName,
            market: p.marketName,
            district: p.location?.district || '',
            state: p.location?.state || '',
            unit: 'Kg',
            minPrice: p.pricePerKg * 0.9,
            maxPrice: p.pricePerKg * 1.1,
            modalPrice: p.pricePerKg,
            trend: p.trend,
            lastUpdated: p.lastUpdated,
        })),
    });
});

// @desc    Get single market price
// @route   GET /api/v1/market-prices/:id
// @access  Public
exports.getMarketPrice = asyncHandler(async (req, res) => {
    const price = await MarketPrice.findById(req.params.id);
    if (!price) throw new ApiError(404, 'Market price not found');
    res.status(200).json({ success: true, data: price });
});

// @desc    Get nearby market prices (geo query)
// @route   GET /api/v1/market-prices/nearby
// @access  Public
exports.getNearbyPrices = asyncHandler(async (req, res) => {
    const { lng, lat, maxDistance = 100 } = req.query;

    if (!lng || !lat) {
        throw new ApiError(400, 'Please provide lng and lat query parameters');
    }

    const prices = await MarketPrice.find({
        'location.coordinates': {
            $near: {
                $geometry: { type: 'Point', coordinates: [parseFloat(lng), parseFloat(lat)] },
                $maxDistance: parseInt(maxDistance) * 1000,
            },
        },
    }).limit(20);

    res.status(200).json({ success: true, count: prices.length, data: prices });
});
