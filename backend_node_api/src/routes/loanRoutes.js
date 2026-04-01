const express = require('express');
const router = express.Router();
const { getLoans, getLoan } = require('../controllers/loanController');

router.get('/', getLoans);
router.get('/:id', getLoan);

module.exports = router;
