/**
 * Auth Controller
 * Handles farmer registration, login, profile retrieval, and profile updates.
 * Uses the Farmer model from Prompt 2 with bcrypt hashing and JWT generation.
 */
const Farmer = require('../models/Farmer');
const { ApiError, asyncHandler } = require('../utils/helpers');

// ═══════════════════════════════════════════════════════
// @desc    Register a new farmer
// @route   POST /api/v1/auth/register
// @access  Public
// ═══════════════════════════════════════════════════════
exports.register = asyncHandler(async (req, res) => {
    const {
        name, phoneNumber, email, passwordHash,
        village, district, state,
        farmSize, cropTypes, preferredLanguage,
    } = req.body;

    // Check if phone already exists
    const existingFarmer = await Farmer.findOne({ phoneNumber });
    if (existingFarmer) {
        throw new ApiError(409, 'A farmer with this phone number already exists');
    }

    // Check if email already exists (if provided)
    if (email) {
        const emailExists = await Farmer.findOne({ email });
        if (emailExists) {
            throw new ApiError(409, 'A farmer with this email already exists');
        }
    }

    const farmer = await Farmer.create({
        name,
        phoneNumber,
        email,
        passwordHash, // pre-save hook hashes this
        village,
        district,
        state,
        farmSize,
        cropTypes,
        preferredLanguage,
    });

    sendTokenResponse(farmer, 201, res);
});

// ═══════════════════════════════════════════════════════
// @desc    Login farmer
// @route   POST /api/v1/auth/login
// @access  Public
// ═══════════════════════════════════════════════════════
exports.login = asyncHandler(async (req, res) => {
    const { email, phoneNumber, password } = req.body;

    if (!email && !phoneNumber) {
        throw new ApiError(400, 'Please provide email or phone number');
    }
    if (!password) {
        throw new ApiError(400, 'Please provide password');
    }

    // Find by email or phone
    const query = email ? { email } : { phoneNumber };
    const farmer = await Farmer.findOne(query).select('+passwordHash');

    if (!farmer) {
        throw new ApiError(401, 'Invalid credentials');
    }

    // Match password (uses bcrypt.compare from Farmer model)
    const isMatch = await farmer.matchPassword(password);
    if (!isMatch) {
        throw new ApiError(401, 'Invalid credentials');
    }

    sendTokenResponse(farmer, 200, res);
});

// ═══════════════════════════════════════════════════════
// @desc    Sync Phone Auth user to Node backend
// @route   POST /api/v1/auth/phone-sync
// @access  Public
// ═══════════════════════════════════════════════════════
exports.phoneSync = asyncHandler(async (req, res, next) => {
    const { phoneNumber } = req.body;

    if (!phoneNumber) {
        throw new ApiError(400, 'Please provide phone number');
    }

    // Try to find the farmer
    let farmer = await Farmer.findOne({ phoneNumber });

    // If not found, create a new one without a password
    if (!farmer) {
        farmer = await Farmer.create({
            name: 'Farmer',
            phoneNumber,
            isVerified: true
        });
    } else {
        // Update last login
        farmer.lastLoginAt = Date.now();
        await farmer.save();
    }

    sendTokenResponse(farmer, 200, res);
});

// ═══════════════════════════════════════════════════════
// @desc    Sync Google Auth user to Node backend
// @route   POST /api/v1/auth/google-sync
// @access  Public
// ═══════════════════════════════════════════════════════
exports.googleSync = asyncHandler(async (req, res, next) => {
    const { email, name, avatar } = req.body;

    if (!email) {
        throw new ApiError(400, 'Please provide email');
    }

    // Try to find the farmer
    let farmer = await Farmer.findOne({ email });

    // If not found, create a new one without a password
    if (!farmer) {
        farmer = await Farmer.create({
            name: name || 'Google Farmer',
            email,
            avatar: avatar || 'default-avatar.png',
            isVerified: true
        });
    } else {
        // Update last login
        farmer.lastLoginAt = Date.now();
        if (avatar) farmer.avatar = avatar;
        if (name && farmer.name === 'Google Farmer') farmer.name = name;
        await farmer.save();
    }

    sendTokenResponse(farmer, 200, res);
});

// ═══════════════════════════════════════════════════════
// @desc    Get current farmer profile
// @route   GET /api/v1/auth/me
// @access  Private
// ═══════════════════════════════════════════════════════
exports.getMe = asyncHandler(async (req, res) => {
    const farmer = await Farmer.findById(req.user.id)
        .populate('savedSchemes')
        .populate('savedEquipment');
    
    // Fetch dynamic stats for the farmer
    const PestScan = require('../models/PestScan');
    const CommunityPost = require('../models/CommunityPost');
    
    const pestScanCount = await PestScan.countDocuments({ farmerId: req.user.id });
    const postCount = await CommunityPost.countDocuments({ farmerId: req.user.id });

    res.status(200).json({
        success: true,
        data: {
            ...farmer.toObject(),
            stats: {
                diseaseScans: pestScanCount,
                communityPosts: postCount,
                marketAlerts: 48, // hardcoded or from a real alerts collection
                schemesApplied: 2 // hardcoded or from a real applications collection
            }
        },
    });
});

// ═══════════════════════════════════════════════════════
// @desc    Update farmer profile
// @route   PUT /api/v1/auth/update-profile
// @access  Private
// ═══════════════════════════════════════════════════════
exports.updateProfile = asyncHandler(async (req, res) => {
    const fieldsToUpdate = {};
    const allowed = ['name', 'village', 'district', 'state', 'farmSize', 'cropTypes', 'soilType', 'irrigationType', 'preferredLanguage', 'farmDetails', 'avatar'];

    for (const field of allowed) {
        if (req.body[field] !== undefined) {
            fieldsToUpdate[field] = req.body[field];
        }
    }

    const farmer = await Farmer.findByIdAndUpdate(req.user.id, fieldsToUpdate, {
        new: true,
        runValidators: true,
    });

    res.status(200).json({ success: true, data: farmer });
});

// ═══════════════════════════════════════════════════════
// @desc    Update FCM token for push notifications
// @route   PUT /api/v1/auth/fcm-token
// @access  Private
// ═══════════════════════════════════════════════════════
exports.updateFcmToken = asyncHandler(async (req, res) => {
    await Farmer.findByIdAndUpdate(req.user.id, { fcmToken: req.body.fcmToken });
    res.status(200).json({ success: true, message: 'FCM token updated' });
});

// ═══════════════════════════════════════════════════════
// @desc    Toggle Scheme Bookmark
// @route   POST /api/v1/auth/bookmarks/schemes/:id
// @access  Private
// ═══════════════════════════════════════════════════════
exports.toggleSchemeBookmark = asyncHandler(async (req, res) => {
    const schemeId = req.params.id;
    const farmer = await Farmer.findById(req.user.id);
    
    const index = farmer.savedSchemes.indexOf(schemeId);
    if (index === -1) {
        farmer.savedSchemes.push(schemeId);
    } else {
        farmer.savedSchemes.splice(index, 1);
    }
    await farmer.save();
    
    res.status(200).json({
        success: true,
        data: farmer.savedSchemes
    });
});

// ═══════════════════════════════════════════════════════
// @desc    Toggle Equipment Bookmark
// @route   POST /api/v1/auth/bookmarks/equipment/:id
// @access  Private
// ═══════════════════════════════════════════════════════
exports.toggleEquipmentBookmark = asyncHandler(async (req, res) => {
    const equipmentId = req.params.id;
    const farmer = await Farmer.findById(req.user.id);
    
    const index = farmer.savedEquipment.indexOf(equipmentId);
    if (index === -1) {
        farmer.savedEquipment.push(equipmentId);
    } else {
        farmer.savedEquipment.splice(index, 1);
    }
    await farmer.save();
    
    res.status(200).json({
        success: true,
        data: farmer.savedEquipment
    });
});

// ─── Helper: Create JWT token and send response ─────
const sendTokenResponse = (farmer, statusCode, res) => {
    const token = farmer.getSignedJwtToken();

    res.status(statusCode).json({
        success: true,
        token,
        user: {
            _id: farmer._id,
            name: farmer.name,
            email: farmer.email,
            phoneNumber: farmer.phoneNumber,
            village: farmer.village,
            district: farmer.district,
            state: farmer.state,
            farmSize: farmer.farmSize,
            cropTypes: farmer.cropTypes,
            preferredLanguage: farmer.preferredLanguage,
        },
    });
};
