const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');

module.exports = (pool) => {
  // 로그인
  router.post('/login', async (req, res) => {
    try {
      const { user_email, user_password } = req.body;
      const [rows] = await pool.execute(
        'SELECT * FROM user WHERE user_email = ?',
        [user_email]
      );

      if (rows.length > 0) {
        const user = rows[0];
        const isValid = await bcrypt.compare(user_password, user.user_password);
        
        if (isValid) {
          req.session.user = {
            user_id: user.user_id,
            user_name: user.user_name,
            user_email: user.user_email
          };
          res.json({ success: true });
        } else {
          res.status(401).json({ success: false, message: '비밀번호가 일치하지 않습니다.' });
        }
      } else {
        res.status(404).json({ success: false, message: '사용자를 찾을 수 없습니다.' });
      }
    } catch (error) {
      console.error('로그인 에러:', error);
      res.status(500).json({ success: false, message: '서버 오류가 발생했습니다.' });
    }
  });

  // 회원가입
  router.post('/join', async (req, res) => {
    try {
      const { user_id, user_name, user_email, user_phone, user_password } = req.body;
      const hashedPassword = await bcrypt.hash(user_password, 10);
      
      await pool.execute(
        'INSERT INTO user (user_id, user_name, user_email, user_phone, user_password) VALUES (?, ?, ?, ?, ?)',
        [user_id, user_name, user_email, user_phone, hashedPassword]
      );
      
      res.json({ success: true });
    } catch (error) {
      console.error('회원가입 에러:', error);
      res.status(500).json({ success: false, message: '서버 오류가 발생했습니다.' });
    }
  });

  // 로그아웃
  router.get('/logout', (req, res) => {
    req.session.destroy((err) => {
      if (err) {
        console.error('로그아웃 에러:', err);
        res.status(500).json({ success: false, message: '서버 오류가 발생했습니다.' });
      } else {
        res.json({ success: true });
      }
    });
  });

  // 마이페이지 정보 조회
  router.get('/mypage', async (req, res) => {
    try {
      if (!req.session.user) {
        return res.status(401).json({ success: false, message: '로그인이 필요합니다.' });
      }

      const [rows] = await pool.execute(
        'SELECT user_id, user_name, user_email, user_phone, user_profile_image FROM user WHERE user_id = ?',
        [req.session.user.user_id]
      );

      if (rows.length > 0) {
        res.json({ success: true, user: rows[0] });
      } else {
        res.status(404).json({ success: false, message: '사용자 정보를 찾을 수 없습니다.' });
      }
    } catch (error) {
      console.error('마이페이지 조회 에러:', error);
      res.status(500).json({ success: false, message: '서버 오류가 발생했습니다.' });
    }
  });

  return router;
}; 