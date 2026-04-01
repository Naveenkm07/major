const mongoose = require('mongoose');

const commentSchema = new mongoose.Schema(
    {
        postId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'CommunityPost',
            required: [true, 'Post reference is required'],
            index: true,
        },
        farmerId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'Farmer',
            required: [true, 'Farmer reference is required'],
            index: true,
        },
        commentText: {
            type: String,
            required: [true, 'Comment text is required'],
            maxlength: [2000, 'Comment cannot exceed 2000 characters'],
        },
    },
    {
        timestamps: true, // createdAt, updatedAt
    }
);

// ─── Indexes for scale ──────────────────────────────
commentSchema.index({ postId: 1, createdAt: -1 }); // post's comments (newest first)
commentSchema.index({ farmerId: 1, createdAt: -1 }); // farmer's comments

// ─── Post-save: increment commentCount on parent post ─
commentSchema.post('save', async function () {
    const CommunityPost = mongoose.model('CommunityPost');
    const count = await mongoose.model('Comment').countDocuments({ postId: this.postId });
    await CommunityPost.findByIdAndUpdate(this.postId, { commentCount: count });
});

// ─── Post-remove: decrement commentCount on parent post ─
commentSchema.post('findOneAndDelete', async function (doc) {
    if (doc) {
        const CommunityPost = mongoose.model('CommunityPost');
        const count = await mongoose.model('Comment').countDocuments({ postId: doc.postId });
        await CommunityPost.findByIdAndUpdate(doc.postId, { commentCount: count });
    }
});

module.exports = mongoose.model('Comment', commentSchema);
