const express = require('express');
const router = express.Router();
const { register, login, getMe, updateProfile, updateFcmToken } = require('../controllers/authController');
const { protect } = require('../middleware/auth');
const { registerValidation, loginValidation } = require('../middleware/validators');

router.post('/register', registerValidation, register);
router.post('/login', loginValidation, login);
router.get('/me', protect, getMe);
router.put('/update-profile', protect, updateProfile);
router.put('/fcm-token', protect, updateFcmToken);

module.exports = router;
