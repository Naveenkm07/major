const jwt = require('jsonwebtoken');
const config = require('../config');
const Farmer = require('../models/Farmer');
const { ApiError, asyncHandler } = require('../utils/helpers');

/**
 * Protect routes – verifies JWT and attaches farmer to req.user
 */
const protect = asyncHandler(async (req, res, next) => {
    let token;

    if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
        token = req.headers.authorization.split(' ')[1];
    }

    if (!token) {
        throw new ApiError(401, 'Not authorized — no token provided');
    }

    try {
        const decoded = jwt.verify(token, config.jwt.secret);
        const farmer = await Farmer.findById(decoded.id);

        if (!farmer) {
            throw new ApiError(401, 'Farmer account not found');
        }

        if (!farmer.isActive) {
            throw new ApiError(403, 'Account has been deactivated');
        }

        req.user = farmer;
        next();
    } catch (error) {
        if (error instanceof ApiError) throw error;
        throw new ApiError(401, 'Invalid token');
    }
});

module.exports = { protect };
