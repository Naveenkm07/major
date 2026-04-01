require('dotenv').config();
const app = require('./app');
const config = require('./config');
const connectDB = require('./config/database');
const logger = require('./utils/logger');
const { initCronJobs } = require('./services/cronScheduler');

// Connect to database in background, start server immediately
const startServer = () => {
    // Start listening immediately so Render health checks pass
    const server = app.listen(config.port, () => {
        logger.info(`🌾 KrushikaDhara API running in ${config.env} mode on port ${config.port}`);

        // Start cron jobs
        initCronJobs();
    });

    // Connect to MongoDB asynchronously in the background
    connectDB().catch(err => {
        logger.error(`Initial MongoDB connection failed: ${err.message}`);
    });

    // Handle unhandled promise rejections
    process.on('unhandledRejection', (err) => {
        logger.error(`Unhandled Rejection: ${err.message}`);
        server.close(() => process.exit(1));
    });

    // Handle uncaught exceptions
    process.on('uncaughtException', (err) => {
        logger.error(`Uncaught Exception: ${err.message}`);
        process.exit(1);
    });

    // Graceful shutdown
    process.on('SIGTERM', () => {
        logger.info('SIGTERM received. Shutting down gracefully...');
        server.close(() => {
            logger.info('Process terminated');
        });
    });
};

// Start the server
startServer();
