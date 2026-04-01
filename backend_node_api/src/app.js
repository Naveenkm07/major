const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const compression = require('compression');
const mongoSanitize = require('express-mongo-sanitize');
const hpp = require('hpp');
const rateLimit = require('express-rate-limit');
const config = require('./config');
const errorHandler = require('./middleware/errorHandler');

// Route imports
const authRoutes = require('./routes/authRoutes');
const pestRoutes = require('./routes/pestRoutes');
const cropRoutes = require('./routes/cropRoutes');
const marketRoutes = require('./routes/marketRoutes');
const schemeRoutes = require('./routes/schemeRoutes');
const loanRoutes = require('./routes/loanRoutes');
const communityRoutes = require('./routes/communityRoutes');
const chatRoutes = require('./routes/chatRoutes');
const weatherRoutes = require('./routes/weatherRoutes');
const notificationRoutes = require('./routes/notificationRoutes');
const adminRoutes = require('./routes/adminRoutes');
const equipmentRoutes = require('./routes/equipmentRoutes');

const app = express();

// ─── Security Middleware ───────────────────────────
app.use(helmet());
app.use(cors());
app.use(mongoSanitize());
app.use(hpp());

// ─── Rate Limiting ─────────────────────────────────
const limiter = rateLimit({
    windowMs: config.rateLimit.windowMs,
    max: config.rateLimit.max,
    message: { success: false, error: 'Too many requests, please try again later' },
});
app.use('/api/', limiter);

// ─── Body Parsing ──────────────────────────────────
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));
app.use(compression());

// ─── Logging ───────────────────────────────────────
if (config.env === 'development') {
    app.use(morgan('dev'));
}

// ─── Health Check ──────────────────────────────────
app.get('/api/v1/health', (req, res) => {
    res.status(200).json({
        success: true,
        message: 'KrushikaDhara API is running',
        environment: config.env,
        timestamp: new Date().toISOString(),
    });
});

// ─── API Routes ────────────────────────────────────
const apiPrefix = `/api/${config.apiVersion}`;
const farmerRoutes = require('./routes/farmerRoutes');
app.use(`${apiPrefix}/auth`, authRoutes);
app.use(`${apiPrefix}/farmers`, farmerRoutes);
app.use(`${apiPrefix}/pest-detect`, pestRoutes);
app.use(`${apiPrefix}/crops`, cropRoutes);
app.use(`${apiPrefix}/market-prices`, marketRoutes);
app.use(`${apiPrefix}/schemes`, schemeRoutes);
app.use(`${apiPrefix}/loans`, loanRoutes);
app.use(`${apiPrefix}/community`, communityRoutes);
app.use(`${apiPrefix}/chat`, chatRoutes);
app.use(`${apiPrefix}/weather`, weatherRoutes);
app.use(`${apiPrefix}/notifications`, notificationRoutes);
app.use(`${apiPrefix}/admin`, adminRoutes);
app.use(`${apiPrefix}/equipment`, equipmentRoutes);

// ─── 404 Handler ───────────────────────────────────
app.use('*', (req, res) => {
    res.status(404).json({
        success: false,
        error: `Route ${req.originalUrl} not found`,
    });
});

// ─── Error Handler ─────────────────────────────────
app.use(errorHandler);

module.exports = app;
