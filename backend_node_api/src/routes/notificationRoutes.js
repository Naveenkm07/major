const express = require('express');
const router = express.Router();
const {
    sendNotification,
    getNotifications,
    markRead,
    markAllRead,
} = require('../controllers/notificationController');
const { protect, protectAdmin } = require('../middleware/auth');

router.post('/send', protectAdmin, sendNotification);
router.get('/', protect, getNotifications);
router.put('/read-all', protect, markAllRead);
router.put('/:id/read', protect, markRead);

module.exports = router;
