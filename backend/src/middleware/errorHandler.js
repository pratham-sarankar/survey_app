function errorHandler(error, req, res, next) {
  console.error('Error:', error);

  // Database errors
  if (error.code === 'ER_DUP_ENTRY') {
    return res.status(400).json({ 
      error: 'Duplicate entry',
      message: 'A record with this data already exists'
    });
  }

  if (error.code === 'ER_NO_REFERENCED_ROW_2') {
    return res.status(400).json({ 
      error: 'Invalid reference',
      message: 'Referenced record does not exist'
    });
  }

  // JWT errors
  if (error.name === 'JsonWebTokenError') {
    return res.status(401).json({ 
      error: 'Invalid token',
      message: 'The provided token is invalid'
    });
  }

  if (error.name === 'TokenExpiredError') {
    return res.status(401).json({ 
      error: 'Token expired',
      message: 'The provided token has expired'
    });
  }

  // Validation errors
  if (error.name === 'ValidationError') {
    return res.status(400).json({ 
      error: 'Validation error',
      message: error.message
    });
  }

  // File upload errors
  if (error.code === 'LIMIT_FILE_SIZE') {
    return res.status(400).json({ 
      error: 'File too large',
      message: 'The uploaded file exceeds the size limit'
    });
  }

  // Default error
  res.status(500).json({ 
    error: 'Internal server error',
    message: process.env.NODE_ENV === 'development' ? error.message : 'Something went wrong'
  });
}

module.exports = {
  errorHandler
};