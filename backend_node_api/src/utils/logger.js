const winston = require('winston');
const fs = require('fs');
const path = require('path');

// Ensure logs directory exists (for local dev)
const logsDir = path.join(process.cwd(), 'logs');
try {
    if (!fs.existsSync(logsDir)) {
        fs.mkdirSync(logsDir, { recursive: true });
    }
} catch (e) {
    // Can't create logs dir — will use console only
}

const transports = [
    // Always log to console (works in Docker/Render)
    new winston.transports.Console({
        format: winston.format.combine(
            winston.format.colorize(),
            winston.format.simple()
        ),
    }),
];

// Add file transports only if logs directory is writable
try {
    if (fs.existsSync(logsDir)) {
        transports.push(
            new winston.transports.File({ filename: 'logs/error.log', level: 'error' }),
            new winston.transports.File({ filename: 'logs/combined.log' })
        );
    }
} catch (e) {
    // File logging not available — console only
}

const logger = winston.createLogger({
    level: process.env.NODE_ENV === 'production' ? 'info' : 'debug',
    format: winston.format.combine(
        winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
        winston.format.errors({ stack: true }),
        winston.format.json()
    ),
    defaultMeta: { service: 'krushikadhara-api' },
    transports,
});

module.exports = logger;

