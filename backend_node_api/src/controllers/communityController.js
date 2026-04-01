/**
 * Community Controller
 * CRUD for posts and comments using CommunityPost + Comment models.
 */
const CommunityPost = require('../models/CommunityPost');
const Comment = require('../models/Comment');
const { ApiError, asyncHandler } = require('../utils/helpers');

// @desc    Get all posts
// @route   GET /api/v1/community/posts
// @access  Private
exports.getPosts = asyncHandler(async (req, res) => {
    const { category, search, state, page = 1, limit = 20 } = req.query;
    const query = { isActive: true };

    if (category) query.category = category;
    if (state) query['location.state'] = state;
    if (search) query.$text = { $search: search };

    const total = await CommunityPost.countDocuments(query);
    const posts = await CommunityPost.find(query)
        .populate('farmerId', 'name village district state')
        .sort({ createdAt: -1 })
        .skip((page - 1) * limit)
        .limit(parseInt(limit));

    res.status(200).json({
        success: true,
        count: posts.length,
        total,
        pages: Math.ceil(total / limit),
        data: posts.map((p) => ({
            _id: p._id,
            content: p.content,
            imageUrl: p.imageUrl,
            category: p.category,
            tags: p.tags,
            likeCount: p.likeCount,
            commentCount: p.commentCount,
            likes: p.likes,
            location: p.location,
            author: p.farmerId, // populated farmer ref
            createdAt: p.createdAt,
        })),
    });
});

// @desc    Get single post with comments
// @route   GET /api/v1/community/posts/:id
// @access  Private
exports.getPost = asyncHandler(async (req, res) => {
    const post = await CommunityPost.findById(req.params.id)
        .populate('farmerId', 'name village district');

    if (!post) throw new ApiError(404, 'Post not found');

    const comments = await Comment.find({ postId: post._id })
        .populate('farmerId', 'name village')
        .sort({ createdAt: -1 });

    res.status(200).json({
        success: true,
        data: { ...post.toJSON(), comments },
    });
});

// @desc    Create a new post
// @route   POST /api/v1/community/posts
// @access  Private
exports.createPost = asyncHandler(async (req, res) => {
    const post = await CommunityPost.create({
        farmerId: req.user.id,
        content: req.body.content,
        category: req.body.category || 'general',
        tags: req.body.tags || [],
        location: {
            state: req.user.state,
            district: req.user.district,
        },
    });

    res.status(201).json({ success: true, data: post });
});

// @desc    Like / unlike a post
// @route   PUT /api/v1/community/posts/:id/like
// @access  Private
exports.toggleLike = asyncHandler(async (req, res) => {
    const post = await CommunityPost.findById(req.params.id);
    if (!post) throw new ApiError(404, 'Post not found');

    const idx = post.likes.indexOf(req.user.id);
    if (idx === -1) {
        post.likes.push(req.user.id);
    } else {
        post.likes.splice(idx, 1);
    }

    await post.save(); // pre-save hook syncs likeCount
    res.status(200).json({ success: true, data: post });
});

// @desc    Add comment to a post
// @route   POST /api/v1/community/posts/:id/comments
// @access  Private
exports.addComment = asyncHandler(async (req, res) => {
    const post = await CommunityPost.findById(req.params.id);
    if (!post) throw new ApiError(404, 'Post not found');

    const comment = await Comment.create({
        postId: post._id,
        farmerId: req.user.id,
        commentText: req.body.text,
    });

    // post-save hook in Comment model auto-updates commentCount

    const populatedComment = await Comment.findById(comment._id)
        .populate('farmerId', 'name village');

    res.status(201).json({ success: true, data: populatedComment });
});

// @desc    Delete a post (only by author)
// @route   DELETE /api/v1/community/posts/:id
// @access  Private
exports.deletePost = asyncHandler(async (req, res) => {
    const post = await CommunityPost.findById(req.params.id);
    if (!post) throw new ApiError(404, 'Post not found');

    if (post.farmerId.toString() !== req.user.id) {
        throw new ApiError(403, 'You can only delete your own posts');
    }

    post.isActive = false;
    await post.save();

    res.status(200).json({ success: true, message: 'Post deleted' });
});
