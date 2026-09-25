const express = require('express');
const router = express.Router();
const {
    getAllEquipment,
    getEquipment,
    addEquipment,
    updateEquipment,
    deleteEquipment,
    syncBluetoothMesh
} = require('../controllers/equipmentController');

const { protect } = require('../middleware/auth');

router.route('/')
    .get(getAllEquipment)
    .post(addEquipment);

router.post('/sync-bluetooth', syncBluetoothMesh);

router.route('/:id')
    .get(getEquipment)
    .put(protect, updateEquipment)
    .delete(protect, deleteEquipment);

module.exports = router;
