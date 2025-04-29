const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const mysql = require('mysql2/promise');

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

// 회원가입
router.post('/register', async (req, res) => {
  try {
    const { user_id, user_name, user_email, user_phone, user_password } = req.body;

    // 필수 필드 검증
    if (!user_id || !user_name || !user_email || !user_phone || !user_password) {
      return res.status(400).json({
        success: false,
        message: '모든 필드를 입력해주세요.'
      });
    }

    const connection = await pool.getConnection();

    try {
      // 아이디 중복 체크
      const [existingUsers] = await connection.query(
        'SELECT user_id FROM user WHERE user_id = ?',
        [user_id]
      );

      if (existingUsers.length > 0) {
        return res.status(400).json({
          success: false,
          error: 'duplicate_id',
          message: '이미 사용 중인 아이디입니다.'
        });
      }

      // 이메일 중복 체크
      const [existingEmails] = await connection.query(
        'SELECT user_email FROM user WHERE user_email = ?',
        [user_email]
      );

      if (existingEmails.length > 0) {
        return res.status(400).json({
          success: false,
          error: 'duplicate_email',
          message: '이미 사용 중인 이메일입니다.'
        });
      }

      // 비밀번호 해시화
      const hashedPassword = await bcrypt.hash(user_password, 10);

      // 사용자 등록
      const [result] = await connection.query(
        `INSERT INTO user (user_id, user_name, user_email, user_phone, user_password, 
          user_status, user_created_at, user_updated_at)
         VALUES (?, ?, ?, ?, ?, 'ACTIVE', NOW(), NOW())`,
        [user_id, user_name, user_email, user_phone, hashedPassword]
      );

      res.status(201).json({
        success: true,
        message: '회원가입이 완료되었습니다.'
      });

    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('회원가입 오류:', error);
    res.status(500).json({
      success: false,
      message: '서버 오류가 발생했습니다.'
    });
  }
});

// 로그인
router.post('/login', async (req, res) => {
  try {
    const { user_id, user_password } = req.body;

    if (!user_id || !user_password) {
      return res.status(400).json({
        success: false,
        message: '아이디와 비밀번호를 입력해주세요.'
      });
    }

    const connection = await pool.getConnection();

    try {
      const [users] = await connection.query(
        'SELECT * FROM user WHERE user_id = ? AND user_status = "ACTIVE"',
        [user_id]
      );

      if (users.length === 0) {
        return res.status(401).json({
          success: false,
          message: '아이디 또는 비밀번호가 일치하지 않습니다.'
        });
      }

      const user = users[0];
      const isValidPassword = await bcrypt.compare(user_password, user.user_password);

      if (!isValidPassword) {
        return res.status(401).json({
          success: false,
          message: '아이디 또는 비밀번호가 일치하지 않습니다.'
        });
      }

      // JWT 토큰 생성
      const token = jwt.sign(
        { userId: user.user_id },
        process.env.JWT_SECRET || 'your-secret-key',
        { expiresIn: '24h' }
      );

      res.json({
        success: true,
        token,
        user: {
          id: user.user_id,
          name: user.user_name,
          email: user.user_email
        }
      });

    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('로그인 오류:', error);
    res.status(500).json({
      success: false,
      message: '서버 오류가 발생했습니다.'
    });
  }
});

module.exports = router; 