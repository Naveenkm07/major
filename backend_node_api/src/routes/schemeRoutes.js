const express = require('express');
const router = express.Router();
const { getSchemes, getScheme } = require('../controllers/schemeController');

router.get('/', getSchemes);
router.get('/:id', getScheme);

module.exports = router;
