/**
 * Chat Controller
 * Proxies chat questions to the Python AI microservice and saves history.
 */
const axios = require('axios');
const config = require('../config');
const ChatHistory = require('../models/ChatHistory');
const { ApiError, asyncHandler } = require('../utils/helpers');
const { v4: uuidv4 } = require('uuid');

// @desc    Send a chat message to AI assistant
// @route   POST /api/v1/chat
// @access  Private
exports.sendMessage = asyncHandler(async (req, res) => {
    const { question, language = 'en', context, sessionId } = req.body;

    if (!question || question.trim().length === 0) {
        throw new ApiError(400, 'Question is required');
    }

    // Generate session ID if not provided
    const chatSessionId = sessionId || `session_${uuidv4().slice(0, 8)}`;

    let aiResult;
    try {
        const response = await axios.post(
            `${config.aiService.url}/api/v1/chat`,
            { question, language, context },
            {
                headers: {
                    'Content-Type': 'application/json',
                    Authorization: req.headers.authorization,
                },
                timeout: 15000,
            }
        );
        aiResult = response.data;
    } catch (err) {
        if (err.response) {
            throw new ApiError(err.response.status, `AI Service: ${err.response.data?.detail || 'Chat failed'}`);
        }
        throw new ApiError(503, 'AI Service unavailable');
    }

    // Save to chat history
    await ChatHistory.create({
        farmerId: req.user.id,
        question,
        answer: aiResult.answer,
        intent: aiResult.intent,
        confidence: aiResult.confidence,
        language,
        sessionId: chatSessionId,
    });

    res.status(200).json({
        success: true,
        data: {
            answer: aiResult.answer,
            intent: aiResult.intent,
            confidence: aiResult.confidence,
            suggestions: aiResult.suggestions || [],
            source: aiResult.source || 'rule_based',
            sessionId: chatSessionId,
        },
    });
});

// @desc    Get chat history
// @route   GET /api/v1/chat/history
// @access  Private
exports.getChatHistory = asyncHandler(async (req, res) => {
    const { sessionId, page = 1, limit = 50 } = req.query;
    const query = { farmerId: req.user.id };
    if (sessionId) query.sessionId = sessionId;

    const total = await ChatHistory.countDocuments(query);
    const chats = await ChatHistory.find(query)
        .sort({ timestamp: -1 })
        .skip((page - 1) * limit)
        .limit(parseInt(limit));

    res.status(200).json({
        success: true,
        count: chats.length,
        total,
        data: chats,
    });
});

// @desc    Get recent sessions
// @route   GET /api/v1/chat/sessions
// @access  Private
exports.getSessions = asyncHandler(async (req, res) => {
    const sessions = await ChatHistory.getRecentSessions(req.user.id, 10);
    res.status(200).json({ success: true, data: sessions });
});
