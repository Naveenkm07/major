const express = require('express');
const router = express.Router();
const droneController = require('../controllers/droneController');
const { protect } = require('../middlewares/auth');

router.post('/analyze', protect, droneController.analyzeDroneFlight);

module.exports = router;
