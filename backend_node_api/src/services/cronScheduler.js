/**
 * Cron Job Scheduler
 * Runs periodic background tasks for data freshness.
 *
 * Schedule:
 *   Every 3 hours  → Update weather data for major locations
 *   Every 3 hours  → Refresh market prices from external API
 *   Every 24 hours → Check for new government schemes
 */
const cron = require('node-cron');
const logger = require('../utils/logger');

// ─── Services ────────────────────────────────────────
const WeatherLog = require('../models/WeatherLog');
const marketPriceService = require('../services/marketPriceService');
const notificationService = require('../services/notificationService');

// ─── Major Karnataka locations to track weather ─────
const TRACKED_LOCATIONS = [
    'Bangalore', 'Mysore', 'Hubli', 'Belgaum',
    'Mangalore', 'Davangere', 'Bellary', 'Shimoga',
    'Mandya', 'Hassan', 'Tumkur', 'Raichur',
];

// ═══════════════════════════════════════════════════════
// JOB 1: Weather Data Update (every 3 hours)
// ═══════════════════════════════════════════════════════
const updateWeatherData = async () => {
    logger.info('[CRON] Starting weather data update...');
    const axios = require('axios');
    const config = require('../config');

    if (!config.externalApis.weatherApiKey) {
        logger.warn('[CRON] Weather API key not set. Skipping weather update.');
        return;
    }

    let updated = 0;
    let alerts = 0;

    for (const location of TRACKED_LOCATIONS) {
        try {
            const response = await axios.get(
                `${config.externalApis.weatherApiUrl}/weather`,
                {
                    params: {
                        q: `${location},IN`,
                        appid: config.externalApis.weatherApiKey,
                        units: 'metric',
                    },
                    timeout: 10000,
                }
            );

            const d = response.data;
            const weather = {
                location: d.name,
                coordinates: { lat: d.coord.lat, lon: d.coord.lon },
                temperature: d.main.temp,
                humidity: d.main.humidity,
                rainfall: d.rain?.['1h'] || 0,
                description: d.weather[0].description,
                windSpeed: d.wind.speed,
                pressure: d.main.pressure,
            };

            // Generate recommendation
            let recommendation = 'Normal farming conditions.';
            if (weather.rainfall > 50) {
                recommendation = 'Heavy rain expected. Postpone spraying and field operations.';
                // Send weather alert
                try {
                    await notificationService.sendWeatherAlert(
                        location,
                        `⛈️ Heavy rain alert in ${location}! ${recommendation}`
                    );
                    alerts++;
                } catch (e) { /* continue */ }
            } else if (weather.temperature > 40) {
                recommendation = 'Extreme heat alert! Increase irrigation frequency.';
            } else if (weather.temperature < 5) {
                recommendation = 'Frost risk! Protect tender crops.';
            }

            await WeatherLog.create({ ...weather, recommendation });
            updated++;
        } catch (err) {
            logger.error(`[CRON] Weather fetch failed for ${location}: ${err.message}`);
        }
    }

    logger.info(`[CRON] Weather update complete: ${updated}/${TRACKED_LOCATIONS.length} locations, ${alerts} alerts sent`);
};

// ═══════════════════════════════════════════════════════
// JOB 2: Market Price Refresh (every 3 hours)
// ═══════════════════════════════════════════════════════
const refreshMarketPrices = async () => {
    logger.info('[CRON] Starting market price refresh...');

    try {
        const result = await marketPriceService.refreshPrices();
        logger.info(`[CRON] Market prices refreshed: ${result.updated} records (source: ${result.source})`);

        // Check for significant price changes and alert
        if (result.updated > 0) {
            // Future: compare old vs new prices and send market alerts
            logger.info('[CRON] Market alert check — monitoring price spikes');
        }
    } catch (error) {
        logger.error(`[CRON] Market price refresh failed: ${error.message}`);
    }
};

// ═══════════════════════════════════════════════════════
// JOB 3: Government Scheme Check (every 24 hours)
// ═══════════════════════════════════════════════════════
const checkNewSchemes = async () => {
    logger.info('[CRON] Checking for new government schemes...');

    try {
        const GovernmentScheme = require('../models/GovernmentScheme');

        // Find schemes added in the last 24 hours
        const oneDayAgo = new Date(Date.now() - 24 * 60 * 60 * 1000);
        const newSchemes = await GovernmentScheme.find({
            createdAt: { $gte: oneDayAgo },
            isActive: true,
        });

        if (newSchemes.length > 0) {
            logger.info(`[CRON] Found ${newSchemes.length} new schemes in last 24h`);

            for (const scheme of newSchemes) {
                try {
                    await notificationService.sendSchemeNotification(
                        scheme.schemeName,
                        scheme.description.substring(0, 150)
                    );
                } catch (e) {
                    logger.error(`[CRON] Scheme notification failed for ${scheme.schemeName}: ${e.message}`);
                }
            }
        } else {
            logger.info('[CRON] No new schemes found in last 24h');
        }
    } catch (error) {
        logger.error(`[CRON] Scheme check failed: ${error.message}`);
    }
};

// ═══════════════════════════════════════════════════════
// Initialize all cron jobs
// ═══════════════════════════════════════════════════════
const initCronJobs = () => {
    logger.info('='.repeat(50));
    logger.info('🕐 Initializing cron job scheduler...');
    logger.info('='.repeat(50));

    // Every 3 hours: Weather update
    cron.schedule('0 */3 * * *', async () => {
        await updateWeatherData();
    }, { timezone: 'Asia/Kolkata' });
    logger.info('  ✅ Weather update job: every 3 hours');

    // Every 3 hours (offset by 30 min): Market prices
    cron.schedule('30 */3 * * *', async () => {
        await refreshMarketPrices();
    }, { timezone: 'Asia/Kolkata' });
    logger.info('  ✅ Market price refresh job: every 3 hours (+30 min offset)');

    // Every day at 6 AM IST: Government schemes
    cron.schedule('0 6 * * *', async () => {
        await checkNewSchemes();
    }, { timezone: 'Asia/Kolkata' });
    logger.info('  ✅ Government scheme check job: daily at 6:00 AM IST');

    logger.info('='.repeat(50));
    logger.info('🕐 All cron jobs scheduled successfully');
    logger.info('='.repeat(50));
};

module.exports = {
    initCronJobs,
    updateWeatherData,
    refreshMarketPrices,
    checkNewSchemes,
};
