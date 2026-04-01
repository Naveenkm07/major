const express = require('express');
const router = express.Router();
const { getPosts, getPost, createPost, toggleLike, addComment, deletePost } = require('../controllers/communityController');
const { protect } = require('../middleware/auth');
const { createPostValidation, addCommentValidation } = require('../middleware/validators');

router.get('/posts', protect, getPosts);
router.get('/posts/:id', protect, getPost);
router.post('/posts', protect, createPostValidation, createPost);
router.put('/posts/:id/like', protect, toggleLike);
router.post('/posts/:id/comments', protect, addCommentValidation, addComment);
router.delete('/posts/:id', protect, deletePost);

module.exports = router;
