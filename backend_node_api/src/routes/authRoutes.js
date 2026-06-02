const express = require('express');
const router = express.Router();
const { register, login, getMe, updateProfile, updateFcmToken, firebaseSync } = require('../controllers/authController');
const { protect } = require('../middleware/auth');
const { registerValidation, loginValidation } = require('../middleware/validators');

router.post('/register', registerValidation, register);
router.post('/login', loginValidation, login);
router.post('/firebase-sync', firebaseSync);
router.get('/me', protect, getMe);
router.put('/update-profile', protect, updateProfile);
router.put('/fcm-token', protect, updateFcmToken);
const { toggleSchemeBookmark, toggleEquipmentBookmark } = require('../controllers/authController');
router.post('/bookmarks/schemes/:id', protect, toggleSchemeBookmark);
router.post('/bookmarks/equipment/:id', protect, toggleEquipmentBookmark);

module.exports = router;
