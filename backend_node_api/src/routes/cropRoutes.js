const express = require('express');
const router = express.Router();
const { getCrops, getCropCalendar } = require('../controllers/cropController');

router.get('/', getCrops);
router.get('/:cropName/calendar', getCropCalendar);

module.exports = router;
