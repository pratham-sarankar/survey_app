const express = require('express');
const { body, validationResult } = require('express-validator');
const { v4: uuidv4 } = require('uuid');
const pool = require('../config/database');
const { authenticateToken } = require('../middleware/auth');
const router = express.Router();

// Apply authentication middleware to all routes
router.use(authenticateToken);

// Get all survey entries (admin only)
router.get('/', async (req, res) => {
  try {
    if (req.user.role !== 'admin') {
      return res.status(403).json({ error: 'Access denied. Admin role required.' });
    }

    const [entries] = await pool.execute(`
      SELECT 
        se.*,
        u.username as created_by_username
      FROM survey_entries se
      JOIN users u ON se.user_id = u.id
      ORDER BY se.created_at DESC
    `);

    // Parse JSON images field
    const parsedEntries = entries.map(entry => ({
      ...entry,
      images: entry.images ? JSON.parse(entry.images) : []
    }));

    res.json(parsedEntries);

  } catch (error) {
    console.error('Error fetching all entries:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get survey entries for a specific user
router.get('/user/:userId', async (req, res) => {
  try {
    const { userId } = req.params;

    // Users can only access their own entries, admins can access any user's entries
    if (req.user.role !== 'admin' && req.user.userId !== userId) {
      return res.status(403).json({ error: 'Access denied' });
    }

    const [entries] = await pool.execute(
      'SELECT * FROM survey_entries WHERE user_id = ? ORDER BY created_at DESC',
      [userId]
    );

    // Parse JSON images field
    const parsedEntries = entries.map(entry => ({
      ...entry,
      images: entry.images ? JSON.parse(entry.images) : []
    }));

    res.json(parsedEntries);

  } catch (error) {
    console.error('Error fetching user entries:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get a specific survey entry
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const [entries] = await pool.execute(
      'SELECT * FROM survey_entries WHERE id = ?',
      [id]
    );

    if (entries.length === 0) {
      return res.status(404).json({ error: 'Survey entry not found' });
    }

    const entry = entries[0];

    // Check access permissions
    if (req.user.role !== 'admin' && req.user.userId !== entry.user_id) {
      return res.status(403).json({ error: 'Access denied' });
    }

    // Parse JSON images field
    entry.images = entry.images ? JSON.parse(entry.images) : [];

    res.json(entry);

  } catch (error) {
    console.error('Error fetching survey entry:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Create a new survey entry
router.post('/', [
  body('uid').notEmpty().withMessage('UID is required'),
  body('areaCode').notEmpty().withMessage('Area code is required'),
  body('qrPlateHouseNumber').notEmpty().withMessage('QR plate house number is required'),
  body('ownerNameHindi').notEmpty().withMessage('Owner name (Hindi) is required'),
  body('ownerNameEnglish').notEmpty().withMessage('Owner name (English) is required'),
  body('mobileNumber').isMobilePhone().withMessage('Valid mobile number is required'),
  body('whatsappNumber').isMobilePhone().withMessage('Valid WhatsApp number is required'),
  body('latitude').isFloat({ min: -90, max: 90 }).withMessage('Valid latitude is required'),
  body('longitude').isFloat({ min: -180, max: 180 }).withMessage('Valid longitude is required'),
], async (req, res) => {
  try {
    // Check validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const {
      uid,
      areaCode,
      qrPlateHouseNumber,
      ownerNameHindi,
      ownerNameEnglish,
      mobileNumber,
      whatsappNumber,
      latitude,
      longitude,
      notes,
      propertyStatus,
      images = []
    } = req.body;

    const entryId = uuidv4();
    const userId = req.user.userId;

    await pool.execute(`
      INSERT INTO survey_entries (
        id, uid, area_code, qr_plate_house_number, owner_name_hindi, 
        owner_name_english, mobile_number, whatsapp_number, latitude, longitude,
        notes, property_status, images, user_id
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `, [
      entryId, uid, areaCode, qrPlateHouseNumber, ownerNameHindi,
      ownerNameEnglish, mobileNumber, whatsappNumber, latitude, longitude,
      notes, propertyStatus, JSON.stringify(images), userId
    ]);

    // Fetch the created entry
    const [newEntry] = await pool.execute(
      'SELECT * FROM survey_entries WHERE id = ?',
      [entryId]
    );

    const entry = newEntry[0];
    entry.images = entry.images ? JSON.parse(entry.images) : [];

    res.status(201).json(entry);

  } catch (error) {
    console.error('Error creating survey entry:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Update a survey entry
router.put('/:id', [
  body('uid').notEmpty().withMessage('UID is required'),
  body('areaCode').notEmpty().withMessage('Area code is required'),
  body('qrPlateHouseNumber').notEmpty().withMessage('QR plate house number is required'),
  body('ownerNameHindi').notEmpty().withMessage('Owner name (Hindi) is required'),
  body('ownerNameEnglish').notEmpty().withMessage('Owner name (English) is required'),
  body('mobileNumber').isMobilePhone().withMessage('Valid mobile number is required'),
  body('whatsappNumber').isMobilePhone().withMessage('Valid WhatsApp number is required'),
  body('latitude').isFloat({ min: -90, max: 90 }).withMessage('Valid latitude is required'),
  body('longitude').isFloat({ min: -180, max: 180 }).withMessage('Valid longitude is required'),
], async (req, res) => {
  try {
    // Check validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { id } = req.params;
    const {
      uid,
      areaCode,
      qrPlateHouseNumber,
      ownerNameHindi,
      ownerNameEnglish,
      mobileNumber,
      whatsappNumber,
      latitude,
      longitude,
      notes,
      propertyStatus,
      images = []
    } = req.body;

    // Check if entry exists and user has permission
    const [existingEntries] = await pool.execute(
      'SELECT user_id FROM survey_entries WHERE id = ?',
      [id]
    );

    if (existingEntries.length === 0) {
      return res.status(404).json({ error: 'Survey entry not found' });
    }

    const entry = existingEntries[0];
    if (req.user.role !== 'admin' && req.user.userId !== entry.user_id) {
      return res.status(403).json({ error: 'Access denied' });
    }

    await pool.execute(`
      UPDATE survey_entries SET
        uid = ?, area_code = ?, qr_plate_house_number = ?, owner_name_hindi = ?,
        owner_name_english = ?, mobile_number = ?, whatsapp_number = ?, latitude = ?, longitude = ?,
        notes = ?, property_status = ?, images = ?, updated_at = CURRENT_TIMESTAMP
      WHERE id = ?
    `, [
      uid, areaCode, qrPlateHouseNumber, ownerNameHindi,
      ownerNameEnglish, mobileNumber, whatsappNumber, latitude, longitude,
      notes, propertyStatus, JSON.stringify(images), id
    ]);

    // Fetch the updated entry
    const [updatedEntry] = await pool.execute(
      'SELECT * FROM survey_entries WHERE id = ?',
      [id]
    );

    const updatedEntryData = updatedEntry[0];
    updatedEntryData.images = updatedEntryData.images ? JSON.parse(updatedEntryData.images) : [];

    res.json(updatedEntryData);

  } catch (error) {
    console.error('Error updating survey entry:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Delete a survey entry
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    // Check if entry exists and user has permission
    const [existingEntries] = await pool.execute(
      'SELECT user_id FROM survey_entries WHERE id = ?',
      [id]
    );

    if (existingEntries.length === 0) {
      return res.status(404).json({ error: 'Survey entry not found' });
    }

    const entry = existingEntries[0];
    if (req.user.role !== 'admin' && req.user.userId !== entry.user_id) {
      return res.status(403).json({ error: 'Access denied' });
    }

    await pool.execute('DELETE FROM survey_entries WHERE id = ?', [id]);

    res.json({ message: 'Survey entry deleted successfully' });

  } catch (error) {
    console.error('Error deleting survey entry:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;