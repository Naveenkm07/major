const mongoose = require('mongoose');

const loanSchema = new mongoose.Schema(
    {
        bankName: {
            type: String,
            required: [true, 'Bank name is required'],
            trim: true,
        },
        loanType: {
            type: String,
            required: true,
            enum: ['crop_loan', 'term_loan', 'kcc', 'allied_activities', 'land_purchase'],
        },
        title: { type: String, required: true, trim: true },
        description: { type: String },
        interestRate: {
            min: { type: Number, required: true },
            max: { type: Number, required: true },
        },
        maxAmount: { type: Number },
        tenure: { type: String }, // e.g., "5 years"
        eligibility: [String],
        requiredDocuments: [String],
        features: [String],
        applicationUrl: { type: String },
        subsidyAvailable: { type: Boolean, default: false },
        subsidyDetails: { type: String },
        isActive: { type: Boolean, default: true },
    },
    {
        timestamps: true,
    }
);

module.exports = mongoose.model('Loan', loanSchema);
