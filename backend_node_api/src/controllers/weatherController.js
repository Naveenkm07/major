/**
 * Weather Controller
 * Integrates with OpenWeatherMap API and stores logs in MongoDB.
 * Generates farmer-friendly weather recommendations.
 */
const weatherService = require('../services/weatherService');
const WeatherLog = require('../models/WeatherLog');
const { ApiError, asyncHandler } = require('../utils/helpers');

// ─── Weather recommendation engine ─────────────────
const generateRecommendation = (temp, humidity, rainfall, description) => {
    const tips = [];

    if (rainfall > 50) {
        tips.push('Heavy rain expected. Avoid pesticide spraying and postpone irrigation.');
    } else if (rainfall > 10) {
        tips.push('Moderate rain expected. Delay pesticide spraying by 24 hours.');
    } else if (rainfall > 0) {
        tips.push('Light rain possible. Good time for transplanting and sowing.');
    }

    if (temp > 40) {
        tips.push('Extreme heat alert! Irrigate crops early morning. Provide shade to nurseries.');
    } else if (temp > 35) {
        tips.push('High temperature. Increase irrigation frequency. Apply mulch to retain moisture.');
    } else if (temp < 5) {
        tips.push('Frost risk! Cover tender crops. Irrigate in evening to prevent frost damage.');
    }

    if (humidity > 85) {
        tips.push('High humidity — watch for fungal diseases. Ensure proper ventilation in crops.');
    } else if (humidity < 30) {
        tips.push('Very dry conditions. Increase irrigation. Watch for spider mite infestation.');
    }

    if (description && description.includes('thunderstorm')) {
        tips.push('Thunderstorm warning. Secure farm structures and avoid open fields.');
    }

    return tips.length > 0
        ? tips.join(' ')
        : 'Weather conditions are favorable for farming activities.';
};

// ═══════════════════════════════════════════════════════
// @desc    Get weather for a location (by city name)
// @route   GET /api/v1/weather/:location
// @access  Public
// ═══════════════════════════════════════════════════════
exports.getWeather = asyncHandler(async (req, res) => {
    const { location } = req.params;

    if (!location || location.trim().length === 0) {
        throw new ApiError(400, 'Location parameter is required');
    }

    // Try to get from cache (last 1 hour)
    const cached = await WeatherLog.findOne({
        location: { $regex: `^${location}$`, $options: 'i' },
        timestamp: { $gte: new Date(Date.now() - 3600000) },
    }).sort({ timestamp: -1 });

    if (cached) {
        return res.status(200).json({
            success: true,
            source: 'cache',
            data: {
                location: cached.location,
                temperature: cached.temperature,
                humidity: cached.humidity,
                rainfall: cached.rainfall,
                description: cached.description,
                windSpeed: cached.windSpeed,
                rain_probability: Math.min(Math.round(cached.humidity * 0.8), 100),
                recommendation: cached.recommendation,
                timestamp: cached.timestamp,
            },
        });
    }

    // Fetch from OpenWeatherMap by city name
    let weatherData;
    try {
        const axios = require('axios');
        const config = require('../config');
        const response = await axios.get(
            `${config.externalApis.weatherApiUrl}/weather`,
            {
                params: {
                    q: location,
                    appid: config.externalApis.weatherApiKey,
                    units: 'metric',
                },
            }
        );

        const d = response.data;
        weatherData = {
            location: d.name || location,
            temperature: d.main.temp,
            humidity: d.main.humidity,
            rainfall: d.rain?.['1h'] || d.rain?.['3h'] || 0,
            description: d.weather[0].description,
            windSpeed: d.wind.speed,
            pressure: d.main.pressure,
            coordinates: { lat: d.coord.lat, lon: d.coord.lon },
        };
    } catch (err) {
        if (err.response?.status === 401) {
            throw new ApiError(503, 'Weather API key not configured. Set WEATHER_API_KEY in .env');
        }
        if (err.response?.status === 404) {
            throw new ApiError(404, `Location "${location}" not found`);
        }
        throw new ApiError(503, 'Weather service temporarily unavailable');
    }

    // Generate recommendation
    const recommendation = generateRecommendation(
        weatherData.temperature,
        weatherData.humidity,
        weatherData.rainfall,
        weatherData.description
    );

    // Save to WeatherLog
    await WeatherLog.create({ ...weatherData, recommendation });

    res.status(200).json({
        success: true,
        source: 'api',
        data: {
            ...weatherData,
            rain_probability: Math.min(Math.round(weatherData.humidity * 0.8), 100),
            recommendation,
        },
    });
});

// ═══════════════════════════════════════════════════════
// @desc    Get weather forecast (5-day)
// @route   GET /api/v1/weather/:location/forecast
// @access  Public
// ═══════════════════════════════════════════════════════
exports.getForecast = asyncHandler(async (req, res) => {
    const { location } = req.params;

    const axios = require('axios');
    const config = require('../config');

    const response = await axios.get(
        `${config.externalApis.weatherApiUrl}/forecast`,
        {
            params: {
                q: location,
                appid: config.externalApis.weatherApiKey,
                units: 'metric',
            },
        }
    );

    const forecast = response.data.list.map((item) => ({
        datetime: item.dt_txt,
        temperature: item.main.temp,
        humidity: item.main.humidity,
        description: item.weather[0].description,
        rainfall: item.rain?.['3h'] || 0,
        windSpeed: item.wind.speed,
    }));

    res.status(200).json({
        success: true,
        location: response.data.city?.name || location,
        count: forecast.length,
        data: forecast,
    });
});

// ═══════════════════════════════════════════════════════
// @desc    Get weather history logs
// @route   GET /api/v1/weather/logs
// @access  Public
// ═══════════════════════════════════════════════════════
exports.getWeatherLogs = asyncHandler(async (req, res) => {
    const { location, limit = 24 } = req.query;
    const query = {};
    if (location) query.location = { $regex: location, $options: 'i' };

    const logs = await WeatherLog.find(query)
        .sort({ timestamp: -1 })
        .limit(parseInt(limit));

    res.status(200).json({ success: true, count: logs.length, data: logs });
});
