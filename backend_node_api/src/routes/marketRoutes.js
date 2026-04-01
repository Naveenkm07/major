const express = require('express');
const router = express.Router();
const { getMarketPrices, getMarketPrice, getNearbyPrices } = require('../controllers/marketController');
const { marketQueryValidation } = require('../middleware/validators');

router.get('/', marketQueryValidation, getMarketPrices);
router.get('/nearby', getNearbyPrices);
router.get('/:id', getMarketPrice);

module.exports = router;
