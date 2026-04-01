/**
 * express-validator middleware collections for request validation.
 */
const { body, param, query } = require('express-validator');
const { validationResult } = require('express-validator');

// ─── Validation result checker middleware ─────────
const validate = (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({
            success: false,
            errors: errors.array().map((e) => ({
                field: e.path,
                message: e.msg,
            })),
        });
    }
    next();
};

// ─── Auth Validations ────────────────────────────
const registerValidation = [
    body('name')
        .trim()
        .notEmpty().withMessage('Name is required')
        .isLength({ min: 2, max: 100 }).withMessage('Name must be 2–100 characters'),
    body('phoneNumber')
        .trim()
        .notEmpty().withMessage('Phone number is required')
        .matches(/^[6-9]\d{9}$/).withMessage('Enter a valid 10-digit Indian mobile number'),
    body('email')
        .optional()
        .isEmail().withMessage('Enter a valid email'),
    body('passwordHash')
        .notEmpty().withMessage('Password is required')
        .isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),
    body('village').optional().trim(),
    body('district').optional().trim(),
    body('state').optional().trim(),
    body('farmSize')
        .optional()
        .isFloat({ min: 0 }).withMessage('Farm size must be a positive number'),
    body('cropTypes')
        .optional()
        .isArray().withMessage('Crop types must be an array'),
    body('preferredLanguage')
        .optional()
        .isIn(['en', 'hi', 'kn', 'te', 'ta', 'mr', 'gu', 'pa', 'bn', 'or'])
        .withMessage('Unsupported language code'),
    validate,
];

const loginValidation = [
    body('email')
        .optional()
        .isEmail().withMessage('Enter a valid email'),
    body('phoneNumber')
        .optional()
        .matches(/^[6-9]\d{9}$/).withMessage('Enter a valid 10-digit mobile number'),
    body('password')
        .notEmpty().withMessage('Password is required'),
    validate,
];

// ─── Community Post Validations ──────────────────
const createPostValidation = [
    body('content')
        .trim()
        .notEmpty().withMessage('Post content is required')
        .isLength({ max: 5000 }).withMessage('Content cannot exceed 5000 characters'),
    body('category')
        .optional()
        .isIn(['general', 'crop_advice', 'market_discussion', 'equipment', 'weather', 'success_story'])
        .withMessage('Invalid category'),
    body('tags')
        .optional()
        .isArray().withMessage('Tags must be an array'),
    validate,
];

const addCommentValidation = [
    param('id').isMongoId().withMessage('Invalid post ID'),
    body('text')
        .trim()
        .notEmpty().withMessage('Comment text is required')
        .isLength({ max: 2000 }).withMessage('Comment cannot exceed 2000 characters'),
    validate,
];

// ─── Chat Validation ─────────────────────────────
const chatValidation = [
    body('question')
        .trim()
        .notEmpty().withMessage('Question is required')
        .isLength({ max: 2000 }).withMessage('Question cannot exceed 2000 characters'),
    body('language')
        .optional()
        .isIn(['en', 'hi', 'kn', 'te', 'ta', 'mr', 'gu', 'pa', 'bn', 'or'])
        .withMessage('Unsupported language code'),
    validate,
];

// ─── Market Price Query Validation ───────────────
const marketQueryValidation = [
    query('commodity').optional().trim(),
    query('state').optional().trim(),
    query('page').optional().isInt({ min: 1 }).withMessage('Page must be ≥ 1'),
    query('limit').optional().isInt({ min: 1, max: 100 }).withMessage('Limit must be 1–100'),
    validate,
];

module.exports = {
    validate,
    registerValidation,
    loginValidation,
    createPostValidation,
    addCommentValidation,
    chatValidation,
    marketQueryValidation,
};
