/**
 * Scheme Admin Controller
 * Adds admin CRUD operations for government schemes.
 * Existing schemeController.js handles public GET endpoints.
 */
const GovernmentScheme = require('../models/GovernmentScheme');
const notificationService = require('../services/notificationService');
const { ApiError, asyncHandler } = require('../utils/helpers');

// @desc    Create a new government scheme
// @route   POST /api/v1/admin/schemes
// @access  Private (admin)
exports.createScheme = asyncHandler(async (req, res) => {
    const {
        schemeName, description, eligibility, benefits,
        applicationLink, ministry, schemeType, targetState,
    } = req.body;

    if (!schemeName || !description) {
        throw new ApiError(400, 'Scheme name and description are required');
    }

    // Check for duplicate
    const existing = await GovernmentScheme.findOne({ schemeName });
    if (existing) {
        throw new ApiError(409, `Scheme "${schemeName}" already exists`);
    }

    const scheme = await GovernmentScheme.create({
        schemeName,
        description,
        eligibility: eligibility || [],
        benefits: benefits || [],
        applicationLink: applicationLink || '',
        ministry,
        schemeType: schemeType || 'central',
        targetState,
    });

    // Notify all farmers about the new scheme
    try {
        await notificationService.sendSchemeNotification(schemeName, description);
    } catch (err) {
        // Don't fail the API call if notification fails
    }

    res.status(201).json({ success: true, data: scheme });
});

// @desc    Update a government scheme
// @route   PUT /api/v1/admin/schemes/:id
// @access  Private (admin)
exports.updateScheme = asyncHandler(async (req, res) => {
    const scheme = await GovernmentScheme.findByIdAndUpdate(
        req.params.id,
        { ...req.body, lastUpdated: Date.now() },
        { new: true, runValidators: true }
    );

    if (!scheme) throw new ApiError(404, 'Scheme not found');
    res.status(200).json({ success: true, data: scheme });
});

// @desc    Delete (deactivate) a scheme
// @route   DELETE /api/v1/admin/schemes/:id
// @access  Private (admin)
exports.deactivateScheme = asyncHandler(async (req, res) => {
    const scheme = await GovernmentScheme.findByIdAndUpdate(
        req.params.id,
        { isActive: false },
        { new: true }
    );

    if (!scheme) throw new ApiError(404, 'Scheme not found');
    res.status(200).json({ success: true, message: 'Scheme deactivated' });
});

// @desc    Seed initial government schemes
// @route   POST /api/v1/admin/schemes/seed
// @access  Private (admin)
exports.seedSchemes = asyncHandler(async (req, res) => {
    const schemes = [
        {
            schemeName: 'PM Fasal Bima Yojana (PMFBY)',
            description: 'Comprehensive crop insurance scheme providing financial support to farmers in case of crop loss due to natural calamities, pests, and diseases.',
            eligibility: ['All farmers growing notified crops', 'Both loanee and non-loanee farmers', 'Sharecroppers and tenant farmers'],
            benefits: ['Premium subsidy up to 98%', 'Full sum insured coverage', 'Post-harvest losses covered for 14 days'],
            applicationLink: 'https://pmfby.gov.in',
            ministry: 'Ministry of Agriculture & Farmers Welfare',
            schemeType: 'central',
        },
        {
            schemeName: 'PM-KISAN',
            description: 'Direct income support of ₹6,000 per year in three equal installments to small and marginal farmer families.',
            eligibility: ['All land-holding farmer families', 'Subject to exclusion criteria'],
            benefits: ['₹6,000/year in 3 installments of ₹2,000', 'Direct bank transfer', 'No middlemen'],
            applicationLink: 'https://pmkisan.gov.in',
            ministry: 'Ministry of Agriculture & Farmers Welfare',
            schemeType: 'central',
        },
        {
            schemeName: 'Kisan Credit Card (KCC)',
            description: 'Provides farmers with affordable credit for agricultural needs including crop production, post-harvest, and consumption.',
            eligibility: ['All farmers, fishermen, animal husbandry farmers', 'Individuals and joint borrowers', 'Tenant farmers and sharecroppers'],
            benefits: ['Interest rate 4% p.a. (with subvention)', 'Credit limit up to ₹3 lakh', 'Crop insurance included', 'ATM-enabled card'],
            applicationLink: 'https://www.pmkisan.gov.in/KCC',
            ministry: 'Ministry of Finance',
            schemeType: 'central',
        },
        {
            schemeName: 'Soil Health Card Scheme',
            description: 'Provides soil health cards to farmers with crop-wise recommendations on nutrients and fertilizers.',
            eligibility: ['All farmers in India'],
            benefits: ['Free soil testing every 2 years', 'Crop-specific fertilizer recommendations', 'Improved soil health awareness'],
            applicationLink: 'https://soilhealth.dac.gov.in',
            ministry: 'Ministry of Agriculture & Farmers Welfare',
            schemeType: 'central',
        },
        {
            schemeName: 'Raitha Siri (Karnataka)',
            description: 'Karnataka state scheme providing financial assistance for organic farming and crop diversification.',
            eligibility: ['Farmers in Karnataka', 'Must have land records'],
            benefits: ['₹3,000/acre for organic farming', 'Subsidy on bio-inputs', 'Training and capacity building'],
            applicationLink: 'https://raitamitra.karnataka.gov.in',
            ministry: 'Department of Agriculture, Karnataka',
            schemeType: 'state',
            targetState: 'Karnataka',
        },
    ];

    let created = 0;
    for (const s of schemes) {
        const exists = await GovernmentScheme.findOne({ schemeName: s.schemeName });
        if (!exists) {
            await GovernmentScheme.create(s);
            created++;
        }
    }

    res.status(200).json({
        success: true,
        message: `${created} schemes seeded (${schemes.length - created} already existed)`,
    });
});
