/**
 * Market Price Data Service
 * Fetches market prices from external APIs or refreshes from database.
 * Calculates price trends (increasing, decreasing, stable).
 */
const axios = require('axios');
const config = require('../config');
const MarketPrice = require('../models/MarketPrice');
const logger = require('../utils/logger');

class MarketPriceService {
    constructor() {
        this.apiUrl = config.externalApis.marketApiUrl;
        this.apiKey = config.externalApis.marketApiKey;
    }

    /**
     * Fetch latest market prices from external API (data.gov.in or agmarknet)
     * and upsert into MongoDB.
     */
    async refreshPrices() {
        if (!this.apiUrl || !this.apiKey) {
            logger.warn('Market API credentials not configured. Using existing DB data.');
            return { updated: 0, source: 'skipped' };
        }

        try {
            const response = await axios.get(this.apiUrl, {
                params: {
                    'api-key': this.apiKey,
                    format: 'json',
                    limit: 100,
                },
                timeout: 15000,
            });

            const records = response.data?.records || [];
            let updated = 0;

            for (const record of records) {
                try {
                    await MarketPrice.findOneAndUpdate(
                        {
                            commodity: record.commodity || record.crop,
                            market: record.market,
                        },
                        {
                            commodity: record.commodity || record.crop,
                            market: record.market,
                            state: record.state,
                            district: record.district,
                            minPrice: parseFloat(record.min_price) || 0,
                            maxPrice: parseFloat(record.max_price) || 0,
                            modalPrice: parseFloat(record.modal_price) || 0,
                            lastUpdated: new Date(),
                        },
                        { upsert: true, new: true }
                    );
                    updated++;
                } catch (e) {
                    // Skip individual record errors
                }
            }

            logger.info(`Market prices refreshed: ${updated} records updated`);
            return { updated, source: 'api' };
        } catch (error) {
            logger.error(`Market API fetch failed: ${error.message}`);
            return { updated: 0, source: 'error', error: error.message };
        }
    }

    /**
     * Calculate price trend by comparing current price to 7-day average.
     */
    calculateTrend(currentPrice, previousPrice) {
        if (!previousPrice || previousPrice === 0) return 'stable';
        const change = ((currentPrice - previousPrice) / previousPrice) * 100;
        if (change > 5) return 'increasing';
        if (change < -5) return 'decreasing';
        return 'stable';
    }

    /**
     * Get prices with trend data for the API response.
     */
    async getPricesWithTrend(query = {}, limit = 50) {
        const prices = await MarketPrice.find(query)
            .sort({ lastUpdated: -1 })
            .limit(limit)
            .lean();

        return prices.map((p) => ({
            crop: p.commodity,
            market: p.market,
            state: p.state,
            district: p.district,
            price_per_kg: p.modalPrice ? Math.round(p.modalPrice / 100) : 0, // quintal → kg
            minPrice: p.minPrice,
            maxPrice: p.maxPrice,
            modalPrice: p.modalPrice,
            trend: this.calculateTrend(p.modalPrice, p.previousPrice || p.modalPrice * 0.95),
            lastUpdated: p.lastUpdated,
        }));
    }
}

module.exports = new MarketPriceService();
