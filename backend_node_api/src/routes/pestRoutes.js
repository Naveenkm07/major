const express = require('express');
const router = express.Router();
const multer = require('multer');
const { detectPest, getScanHistory, getScan } = require('../controllers/pestController');
const { protect } = require('../middleware/auth');

// Multer: store in memory buffer for forwarding to AI service
const upload = multer({
    storage: multer.memoryStorage(),
    limits: { fileSize: 10 * 1024 * 1024 }, // 10 MB
    fileFilter: (req, file, cb) => {
        if (file.mimetype.startsWith('image/')) {
            cb(null, true);
        } else {
            cb(new Error('Only image files are allowed'), false);
        }
    },
});

router.post('/', protect, upload.single('image'), detectPest);
router.get('/history', protect, getScanHistory);
router.get('/:id', protect, getScan);

module.exports = router;
