const mongoose = require('mongoose');

const communityPostSchema = new mongoose.Schema(
    {
        farmerId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'Farmer',
            required: [true, 'Farmer reference is required'],
            index: true,
        },
        content: {
            type: String,
            required: [true, 'Post content is required'],
            maxlength: [5000, 'Content cannot exceed 5000 characters'],
        },
        imageUrl: {
            type: String,
            default: '',
        },
        location: {
            state: { type: String, trim: true },
            district: { type: String, trim: true },
        },
        likes: [
            {
                type: mongoose.Schema.Types.ObjectId,
                ref: 'Farmer',
            },
        ],
        likeCount: {
            type: Number,
            default: 0,
        },
        commentCount: {
            type: Number,
            default: 0,
        },
        tags: {
            type: [String],
            default: [],
        },
        category: {
            type: String,
            enum: ['general', 'crop_advice', 'market_discussion', 'equipment', 'weather', 'success_story'],
            default: 'general',
        },
        isActive: {
            type: Boolean,
            default: true,
        },
    },
    {
        timestamps: true, // createdAt, updatedAt
        toJSON: { virtuals: true },
        toObject: { virtuals: true },
    }
);

// ─── Indexes for scale ──────────────────────────────
communityPostSchema.index({ farmerId: 1, createdAt: -1 }); // farmer's posts
communityPostSchema.index({ createdAt: -1 }); // feed (newest first)
communityPostSchema.index({ category: 1, createdAt: -1 }); // category feed
communityPostSchema.index({ likeCount: -1 }); // popular posts
communityPostSchema.index({ 'location.state': 1, createdAt: -1 }); // regional feed
communityPostSchema.index({ content: 'text', tags: 'text' }); // full-text search

// ─── Virtual: comments relationship ─────────────────
communityPostSchema.virtual('comments', {
    ref: 'Comment',
    localField: '_id',
    foreignField: 'postId',
    justOne: false,
});

// ─── Pre-save: sync likeCount ───────────────────────
communityPostSchema.pre('save', function (next) {
    if (this.isModified('likes')) {
        this.likeCount = this.likes.length;
    }
    next();
});

module.exports = mongoose.model('CommunityPost', communityPostSchema);
