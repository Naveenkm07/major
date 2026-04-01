/**
 * Notification Controller
 * Send notifications and manage notification history.
 */
const Notification = require('../models/Notification');
const notificationService = require('../services/notificationService');
const { ApiError, asyncHandler } = require('../utils/helpers');

// @desc    Send notification to a farmer or broadcast
// @route   POST /api/v1/notifications/send
// @access  Private (admin or system)
exports.sendNotification = asyncHandler(async (req, res) => {
    const { farmerId, title, message, type = 'system' } = req.body;

    if (!title || !message) {
        throw new ApiError(400, 'Title and message are required');
    }

    let result;
    if (farmerId) {
        // Send to specific farmer
        result = await notificationService.sendToFarmer(farmerId, title, message, type);
    } else {
        // Broadcast to all farmers
        result = await notificationService.broadcast(title, message, type);
    }

    res.status(200).json({ success: true, data: result });
});

// @desc    Get farmer's notifications
// @route   GET /api/v1/notifications
// @access  Private
exports.getNotifications = asyncHandler(async (req, res) => {
    const { page = 1, limit = 20, unreadOnly } = req.query;
    const query = { farmerId: req.user.id };
    if (unreadOnly === 'true') query.readStatus = false;

    const total = await Notification.countDocuments(query);
    const notifications = await Notification.find(query)
        .sort({ createdAt: -1 })
        .skip((page - 1) * limit)
        .limit(parseInt(limit));

    const unreadCount = await Notification.getUnreadCount(req.user.id);

    res.status(200).json({
        success: true,
        count: notifications.length,
        total,
        unreadCount,
        data: notifications,
    });
});

// @desc    Mark notification as read
// @route   PUT /api/v1/notifications/:id/read
// @access  Private
exports.markRead = asyncHandler(async (req, res) => {
    const notif = await Notification.findOneAndUpdate(
        { _id: req.params.id, farmerId: req.user.id },
        { readStatus: true },
        { new: true }
    );

    if (!notif) throw new ApiError(404, 'Notification not found');
    res.status(200).json({ success: true, data: notif });
});

// @desc    Mark all notifications as read
// @route   PUT /api/v1/notifications/read-all
// @access  Private
exports.markAllRead = asyncHandler(async (req, res) => {
    await Notification.markAllRead(req.user.id);
    res.status(200).json({ success: true, message: 'All notifications marked as read' });
});
