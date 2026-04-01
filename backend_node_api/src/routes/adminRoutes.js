const express = require('express');
const router = express.Router();
const {
    createScheme,
    updateScheme,
    deactivateScheme,
    seedSchemes,
} = require('../controllers/schemeAdminController');
const { protect } = require('../middleware/auth');

router.post('/schemes', protect, createScheme);
router.post('/schemes/seed', protect, seedSchemes);
router.put('/schemes/:id', protect, updateScheme);
router.delete('/schemes/:id', protect, deactivateScheme);

module.exports = router;
