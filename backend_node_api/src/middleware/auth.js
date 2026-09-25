const jwt = require('jsonwebtoken');
const config = require('../config');
const Farmer = require('../models/Farmer');
const { ApiError, asyncHandler } = require('../utils/helpers');

const supabase = require('../config/supabase');

/**
 * Protect routes – verifies JWT and attaches user/farmer to req.user
 * Supports both MongoDB custom JWT and Supabase Auth.
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
        // Try Supabase verification first if available
        if (supabase) {
            const { data, error } = await supabase.auth.getUser(token);
            if (!error && data?.user) {
                // Attach Supabase user (fallback to Farmer model for backwards compatibility if needed)
                req.user = { id: data.user.id, ...data.user };
                return next();
            }
        }

        // Fallback to existing MongoDB JWT verification
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

const protectAdmin = asyncHandler(async (req, res, next) => {
    let token;
    if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
        token = req.headers.authorization.split(' ')[1];
    }
    if (!token) throw new ApiError(401, 'Not authorized — no token provided');

    try {
        const decoded = jwt.verify(token, config.jwt.secret);
        if (decoded.role !== 'admin') {
            throw new ApiError(403, 'Forbidden — Admin only');
        }
        req.user = decoded;
        next();
    } catch (error) {
        if (error instanceof ApiError) throw error;
        throw new ApiError(401, 'Invalid admin token');
    }
});

module.exports = { protect, protectAdmin };
