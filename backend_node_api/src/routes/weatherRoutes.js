const express = require('express');
const router = express.Router();
const { getWeather, getForecast, getWeatherLogs } = require('../controllers/weatherController');

router.get('/logs', getWeatherLogs);
router.get('/:location/forecast', getForecast);
router.get('/:location', getWeather);

module.exports = router;
