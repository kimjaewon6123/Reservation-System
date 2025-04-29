const express = require('express');
const router = express.Router();

module.exports = (pool) => {
  // 매장 목록 조회
  router.get('/', async (req, res) => {
    try {
      const { category, search } = req.query;
      let query = 'SELECT * FROM store WHERE store_is_active = TRUE';
      const params = [];

      if (category) {
        query += ' AND store_category = ?';
        params.push(category);
      }

      if (search) {
        query += ' AND (store_name LIKE ? OR store_address LIKE ?)';
        params.push(`%${search}%`, `%${search}%`);
      }

      const [rows] = await pool.execute(query, params);
      res.json({ success: true, stores: rows });
    } catch (error) {
      console.error('매장 목록 조회 에러:', error);
      res.status(500).json({ success: false, message: '서버 오류가 발생했습니다.' });
    }
  });

  // 매장 상세 정보 조회
  router.get('/:id', async (req, res) => {
    try {
      const [rows] = await pool.execute(
        'SELECT * FROM store WHERE store_id = ? AND store_is_active = TRUE',
        [req.params.id]
      );

      if (rows.length > 0) {
        res.json({ success: true, store: rows[0] });
      } else {
        res.status(404).json({ success: false, message: '매장을 찾을 수 없습니다.' });
      }
    } catch (error) {
      console.error('매장 상세 정보 조회 에러:', error);
      res.status(500).json({ success: false, message: '서버 오류가 발생했습니다.' });
    }
  });

  // 매장 대기 목록 조회
  router.get('/:id/waiting', async (req, res) => {
    try {
      const [rows] = await pool.execute(
        `SELECT w.*, u.user_name 
         FROM waiting_list w 
         JOIN user u ON w.user_id = u.user_id 
         WHERE w.store_id = ? AND w.status = 'WAITING' 
         ORDER BY w.created_at`,
        [req.params.id]
      );

      res.json({ success: true, waitingList: rows });
    } catch (error) {
      console.error('대기 목록 조회 에러:', error);
      res.status(500).json({ success: false, message: '서버 오류가 발생했습니다.' });
    }
  });

  // 대기 등록
  router.post('/:id/waiting', async (req, res) => {
    try {
      if (!req.session.user) {
        return res.status(401).json({ success: false, message: '로그인이 필요합니다.' });
      }

      const [result] = await pool.execute(
        'INSERT INTO waiting_list (store_id, user_id, waiting_datetime) VALUES (?, ?, NOW())',
        [req.params.id, req.session.user.user_id]
      );

      res.json({ success: true, waiting_id: result.insertId });
    } catch (error) {
      console.error('대기 등록 에러:', error);
      res.status(500).json({ success: false, message: '서버 오류가 발생했습니다.' });
    }
  });

  return router;
}; 