const mongoose = require('mongoose');
const logger = require('../utils/logger');

// Keep bufferCommands ON (default) so queries wait for the connection
// This is needed because the server starts before MongoDB connects

const connectDB = async () => {
    const uri = process.env.MONGODB_URI;

    if (!uri) {
        logger.error('MONGODB_URI environment variable is NOT set! Check Render environment variables.');
        await new Promise(resolve => setTimeout(resolve, 5000));
        return connectDB();
    }

    logger.info(`Connecting to MongoDB... (URI set: YES, host: ${uri.split('@')[1]?.split('/')[0] || 'unknown'})`);

    try {
        const conn = await mongoose.connect(uri, {
            maxPoolSize: 10,
            serverSelectionTimeoutMS: 30000,
            socketTimeoutMS: 45000,
        });

        logger.info(`✅ MongoDB Connected: ${conn.connection.host}`);
    } catch (error) {
        logger.error(`MongoDB connection error: ${error.message}`);
        logger.info('Retrying MongoDB connection in 5 seconds...');
        await new Promise(resolve => setTimeout(resolve, 5000));
        return connectDB();
    }
};

mongoose.connection.on('disconnected', () => {
    logger.warn('MongoDB disconnected. Attempting to reconnect...');
});

mongoose.connection.on('error', (err) => {
    logger.error(`MongoDB error: ${err.message}`);
});

module.exports = connectDB;
