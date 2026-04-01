// ─── Model Index ─────────────────────────────────────
// Central export for all Mongoose models
// Import from here: const { Farmer, PestScan } = require('./models');

const Farmer = require('./Farmer');
const PestScan = require('./PestScan');
const MarketPrice = require('./MarketPrice');
const CropCalendar = require('./CropCalendar');
const GovernmentScheme = require('./GovernmentScheme');
const CommunityPost = require('./CommunityPost');
const Comment = require('./Comment');
const Notification = require('./Notification');
const FarmerLocation = require('./FarmerLocation');
const ChatHistory = require('./ChatHistory');

module.exports = {
    Farmer,
    PestScan,
    MarketPrice,
    CropCalendar,
    GovernmentScheme,
    CommunityPost,
    Comment,
    Notification,
    FarmerLocation,
    ChatHistory,
};
