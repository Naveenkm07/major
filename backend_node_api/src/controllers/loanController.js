/**
 * Loan Controller
 * CRUD for agricultural loans using the Loan model.
 */
const Loan = require('../models/Loan');
const { asyncHandler } = require('../utils/helpers');

// @desc    Get all loan options
// @route   GET /api/v1/loans
// @access  Public
exports.getLoans = asyncHandler(async (req, res) => {
    const { type, bank, page = 1, limit = 50 } = req.query;
    const query = { isActive: true };

    if (type) query.loanType = type;
    if (bank) query.bankName = { $regex: bank, $options: 'i' };

    const total = await Loan.countDocuments(query);
    const loans = await Loan.find(query)
        .sort({ bankName: 1 })
        .skip((page - 1) * limit)
        .limit(parseInt(limit));

    res.status(200).json({
        success: true,
        count: loans.length,
        total,
        data: loans,
    });
});

// @desc    Get single loan
// @route   GET /api/v1/loans/:id
// @access  Public
exports.getLoan = asyncHandler(async (req, res) => {
    const loan = await Loan.findById(req.params.id);
    if (!loan) {
        return res.status(404).json({ success: false, error: 'Loan not found' });
    }
    res.status(200).json({ success: true, data: loan });
});
