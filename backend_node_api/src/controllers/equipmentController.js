const Equipment = require('../models/Equipment');
const { ApiError, asyncHandler } = require('../utils/helpers');

// @desc    Get all equipment
// @route   GET /api/v1/equipment
// @access  Public
exports.getAllEquipment = asyncHandler(async (req, res) => {
    const { type, district } = req.query;
    const query = { availability: true };
    
    if (type) query.type = type;
    if (district) query['location.district'] = { $regex: district, $options: 'i' };

    const equipment = await Equipment.find(query).sort({ createdAt: -1 });

    res.status(200).json({
        success: true,
        count: equipment.length,
        data: equipment
    });
});

// @desc    Get single equipment
// @route   GET /api/v1/equipment/:id
// @access  Public
exports.getEquipment = asyncHandler(async (req, res) => {
    const equipment = await Equipment.findById(req.params.id);

    if (!equipment) {
        throw new ApiError(404, 'Equipment not found');
    }

    res.status(200).json({
        success: true,
        data: equipment
    });
});

// @desc    Add new equipment
// @route   POST /api/v1/equipment
// @access  Private
exports.addEquipment = asyncHandler(async (req, res) => {
    // Add user to req.body
    req.body.owner = req.user.id;
    req.body.ownerName = req.user.name;
    req.body.contactPhone = req.user.phoneNumber || req.body.contactPhone;

    const equipment = await Equipment.create(req.body);

    res.status(201).json({
        success: true,
        data: equipment
    });
});

// @desc    Update equipment
// @route   PUT /api/v1/equipment/:id
// @access  Private
exports.updateEquipment = asyncHandler(async (req, res) => {
    let equipment = await Equipment.findById(req.params.id);

    if (!equipment) {
        throw new ApiError(404, 'Equipment not found');
    }

    // Make sure user is owner
    if (equipment.owner.toString() !== req.user.id && req.user.role !== 'admin') {
        throw new ApiError(403, 'Not authorized to update this equipment');
    }

    equipment = await Equipment.findByIdAndUpdate(req.params.id, req.body, {
        new: true,
        runValidators: true
    });

    res.status(200).json({
        success: true,
        data: equipment
    });
});

// @desc    Delete equipment
// @route   DELETE /api/v1/equipment/:id
// @access  Private
exports.deleteEquipment = asyncHandler(async (req, res) => {
    const equipment = await Equipment.findById(req.params.id);

    if (!equipment) {
        throw new ApiError(404, 'Equipment not found');
    }

    // Make sure user is owner
    if (equipment.owner.toString() !== req.user.id && req.user.role !== 'admin') {
        throw new ApiError(403, 'Not authorized to delete this equipment');
    }

    await equipment.deleteOne();

    res.status(200).json({
        success: true,
        data: {}
    });
});
