const mongoose = require('mongoose');

const postSchema = new mongoose.Schema(
    {
        author: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'User',
            required: true,
        },
        title: {
            type: String,
            required: [true, 'Post title is required'],
            trim: true,
            maxlength: [200, 'Title cannot exceed 200 characters'],
        },
        content: {
            type: String,
            required: [true, 'Post content is required'],
        },
        category: {
            type: String,
            enum: ['general', 'crop_advice', 'market_discussion', 'equipment', 'weather', 'success_story'],
            default: 'general',
        },
        images: [{ type: String }],
        likes: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
        comments: [
            {
                user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
                text: { type: String, required: true },
                createdAt: { type: Date, default: Date.now },
            },
        ],
        tags: [String],
        isActive: { type: Boolean, default: true },
    },
    {
        timestamps: true,
        toJSON: { virtuals: true },
        toObject: { virtuals: true },
    }
);

postSchema.virtual('likeCount').get(function () {
    return this.likes.length;
});

postSchema.virtual('commentCount').get(function () {
    return this.comments.length;
});

postSchema.index({ title: 'text', content: 'text', tags: 'text' });

module.exports = mongoose.model('Post', postSchema);
