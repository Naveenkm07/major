const express = require('express');
const router = express.Router();
const { getNearbyFarmers } = require('../controllers/farmerController');
const { protect } = require('../middleware/auth');

router.get('/nearby', protect, getNearbyFarmers);

module.exports = router;
