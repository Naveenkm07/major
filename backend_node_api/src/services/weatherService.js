const axios = require('axios');
const config = require('../config');
const logger = require('../utils/logger');

class WeatherService {
    constructor() {
        this.baseUrl = config.externalApis.weatherApiUrl;
        this.apiKey = config.externalApis.weatherApiKey;
    }

    async getCurrentWeather(lat, lon) {
        try {
            const response = await axios.get(`${this.baseUrl}/weather`, {
                params: { lat, lon, appid: this.apiKey, units: 'metric' },
            });
            return {
                temperature: response.data.main.temp,
                humidity: response.data.main.humidity,
                description: response.data.weather[0].description,
                windSpeed: response.data.wind.speed,
                rainfall: response.data.rain?.['1h'] || 0,
                icon: response.data.weather[0].icon,
            };
        } catch (error) {
            logger.error(`Weather API error: ${error.message}`);
            throw error;
        }
    }

    async getForecast(lat, lon) {
        try {
            const response = await axios.get(`${this.baseUrl}/forecast`, {
                params: { lat, lon, appid: this.apiKey, units: 'metric' },
            });
            return response.data.list.map((item) => ({
                datetime: item.dt_txt,
                temperature: item.main.temp,
                humidity: item.main.humidity,
                description: item.weather[0].description,
                rainfall: item.rain?.['3h'] || 0,
            }));
        } catch (error) {
            logger.error(`Weather forecast API error: ${error.message}`);
            throw error;
        }
    }
}

module.exports = new WeatherService();
