const express = require('express');
const router = express.Router();
const {
    createScheme,
    updateScheme,
    deactivateScheme,
    seedSchemes,
} = require('../controllers/schemeAdminController');
const { protect, protectAdmin } = require('../middleware/auth');
const {
    adminLogin,
    getAllFarmers,
    getFarmerById,
    updateFarmer,
    deleteFarmer
} = require('../controllers/adminUserController');

// Scheme Admin Routes (Protected by farmer token for some reason? Let's leave as is if existing)
router.post('/schemes', protect, createScheme);
router.post('/schemes/seed', protect, seedSchemes);
router.put('/schemes/:id', protect, updateScheme);
router.delete('/schemes/:id', protect, deactivateScheme);

// ─── Super Admin Routes ───
router.post('/login', adminLogin);
router.get('/farmers', protectAdmin, getAllFarmers);
router.get('/farmers/:id', protectAdmin, getFarmerById);
router.put('/farmers/:id', protectAdmin, updateFarmer);
router.delete('/farmers/:id', protectAdmin, deleteFarmer);

module.exports = router;
