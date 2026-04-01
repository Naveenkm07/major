const express = require('express');
const router = express.Router();
const {
    getAllEquipment,
    getEquipment,
    addEquipment,
    updateEquipment,
    deleteEquipment
} = require('../controllers/equipmentController');

const { protect } = require('../middleware/auth');

router.route('/')
    .get(getAllEquipment)
    .post(protect, addEquipment);

router.route('/:id')
    .get(getEquipment)
    .put(protect, updateEquipment)
    .delete(protect, deleteEquipment);

module.exports = router;
