const express = require('express');
const router = express.Router();
const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');

// 데이터베이스 연결 설정
const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || 'mysql123',
  database: process.env.DB_NAME || 'scrs',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// 사용자 정보 조회
router.get('/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const connection = await pool.getConnection();

    try {
      const [users] = await connection.query(
        `SELECT user_id, user_name, user_email, user_phone, user_status, 
         user_created_at, user_profile_image, user_preferred_store_id
         FROM user WHERE user_id = ?`,
        [userId]
      );

      if (users.length === 0) {
        return res.status(404).json({
          success: false,
          message: '사용자를 찾을 수 없습니다.'
        });
      }

      res.json({
        success: true,
        user: users[0]
      });

    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('사용자 조회 오류:', error);
    res.status(500).json({
      success: false,
      message: '서버 오류가 발생했습니다.'
    });
  }
});

// 사용자 정보 수정
router.put('/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const { user_name, user_email, user_phone, user_password, user_preferred_store_id } = req.body;
    const connection = await pool.getConnection();

    try {
      let updateFields = [];
      let updateValues = [];

      if (user_name) {
        updateFields.push('user_name = ?');
        updateValues.push(user_name);
      }

      if (user_email) {
        updateFields.push('user_email = ?');
        updateValues.push(user_email);
      }

      if (user_phone) {
        updateFields.push('user_phone = ?');
        updateValues.push(user_phone);
      }

      if (user_password) {
        const hashedPassword = await bcrypt.hash(user_password, 10);
        updateFields.push('user_password = ?');
        updateValues.push(hashedPassword);
      }

      if (user_preferred_store_id) {
        updateFields.push('user_preferred_store_id = ?');
        updateValues.push(user_preferred_store_id);
      }

      if (updateFields.length === 0) {
        return res.status(400).json({
          success: false,
          message: '수정할 정보를 입력해주세요.'
        });
      }

      updateFields.push('user_updated_at = NOW()');
      const query = `UPDATE user SET ${updateFields.join(', ')} WHERE user_id = ?`;
      updateValues.push(userId);

      const [result] = await connection.query(query, updateValues);

      if (result.affectedRows === 0) {
        return res.status(404).json({
          success: false,
          message: '사용자를 찾을 수 없습니다.'
        });
      }

      res.json({
        success: true,
        message: '사용자 정보가 수정되었습니다.'
      });

    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('사용자 정보 수정 오류:', error);
    res.status(500).json({
      success: false,
      message: '서버 오류가 발생했습니다.'
    });
  }
});

// 사용자 삭제 (비활성화)
router.delete('/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const connection = await pool.getConnection();

    try {
      const [result] = await connection.query(
        'UPDATE user SET user_status = "INACTIVE", user_updated_at = NOW() WHERE user_id = ?',
        [userId]
      );

      if (result.affectedRows === 0) {
        return res.status(404).json({
          success: false,
          message: '사용자를 찾을 수 없습니다.'
        });
      }

      res.json({
        success: true,
        message: '사용자 계정이 비활성화되었습니다.'
      });

    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('사용자 삭제 오류:', error);
    res.status(500).json({
      success: false,
      message: '서버 오류가 발생했습니다.'
    });
  }
});

module.exports = router; 