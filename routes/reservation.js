const express = require('express');
const router = express.Router();

module.exports = (pool) => {
  // 예약 생성
  router.post('/', async (req, res) => {
    try {
      if (!req.session.user) {
        return res.status(401).json({ success: false, message: '로그인이 필요합니다.' });
      }

      const { store_id, reservation_datetime, people_count, request } = req.body;
      
      const [result] = await pool.execute(
        'INSERT INTO reservation (reservation_user_id, reservation_store_id, reservation_datetime, reservation_people_count, reservation_request) VALUES (?, ?, ?, ?, ?)',
        [req.session.user.user_id, store_id, reservation_datetime, people_count, request]
      );

      // 알림 생성
      await pool.execute(
        'INSERT INTO notification (notification_type, notification_content, notification_recipient, notification_reservation_id) VALUES (?, ?, ?, ?)',
        ['RESERVATION', '새로운 예약이 생성되었습니다.', req.session.user.user_id, result.insertId]
      );

      res.json({ success: true, reservation_id: result.insertId });
    } catch (error) {
      console.error('예약 생성 에러:', error);
      res.status(500).json({ success: false, message: '서버 오류가 발생했습니다.' });
    }
  });

  // 예약 조회
  router.get('/my', async (req, res) => {
    try {
      if (!req.session.user) {
        return res.status(401).json({ success: false, message: '로그인이 필요합니다.' });
      }

      const [rows] = await pool.execute(
        `SELECT r.*, s.store_name 
         FROM reservation r 
         JOIN store s ON r.reservation_store_id = s.store_id 
         WHERE r.reservation_user_id = ? 
         ORDER BY r.reservation_datetime DESC`,
        [req.session.user.user_id]
      );

      res.json({ success: true, reservations: rows });
    } catch (error) {
      console.error('예약 조회 에러:', error);
      res.status(500).json({ success: false, message: '서버 오류가 발생했습니다.' });
    }
  });

  // 예약 취소
  router.post('/:id/cancel', async (req, res) => {
    try {
      if (!req.session.user) {
        return res.status(401).json({ success: false, message: '로그인이 필요합니다.' });
      }

      const [result] = await pool.execute(
        'UPDATE reservation SET reservation_status = ? WHERE reservation_id = ? AND reservation_user_id = ?',
        ['CANCELLED', req.params.id, req.session.user.user_id]
      );

      if (result.affectedRows > 0) {
        // 알림 생성
        await pool.execute(
          'INSERT INTO notification (notification_type, notification_content, notification_recipient, notification_reservation_id) VALUES (?, ?, ?, ?)',
          ['CANCELLATION', '예약이 취소되었습니다.', req.session.user.user_id, req.params.id]
        );

        res.json({ success: true });
      } else {
        res.status(404).json({ success: false, message: '예약을 찾을 수 없습니다.' });
      }
    } catch (error) {
      console.error('예약 취소 에러:', error);
      res.status(500).json({ success: false, message: '서버 오류가 발생했습니다.' });
    }
  });

  return router;
}; 