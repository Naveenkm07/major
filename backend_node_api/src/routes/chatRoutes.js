const express = require('express');
const router = express.Router();
const { sendMessage, getChatHistory, getSessions } = require('../controllers/chatController');
const { protect } = require('../middleware/auth');
const { chatValidation } = require('../middleware/validators');

router.post('/', protect, chatValidation, sendMessage);
router.get('/history', protect, getChatHistory);
router.get('/sessions', protect, getSessions);

module.exports = router;
