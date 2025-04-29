const express = require('express');
const router = express.Router();
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

// 예약 목록 조회
router.get('/user/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const connection = await pool.getConnection();

    try {
      const [reservations] = await connection.query(
        `SELECT r.*, s.store_name 
         FROM reservation r 
         JOIN store s ON r.reservation_store_id = s.store_id 
         WHERE r.reservation_user_id = ? 
         ORDER BY r.reservation_datetime DESC`,
        [userId]
      );

      res.json({
        success: true,
        reservations: reservations.map(reservation => ({
          id: reservation.reservation_id,
          store_id: reservation.reservation_store_id,
          store_name: reservation.store_name,
          datetime: reservation.reservation_datetime,
          status: reservation.reservation_status,
          people_count: reservation.reservation_people_count,
          request: reservation.reservation_request,
          created_at: reservation.reservation_created_at
        }))
      });

    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('예약 목록 조회 오류:', error);
    res.status(500).json({
      success: false,
      message: '서버 오류가 발생했습니다.'
    });
  }
});

// 예약 상세 정보 조회
router.get('/:reservationId', async (req, res) => {
  try {
    const { reservationId } = req.params;
    const connection = await pool.getConnection();

    try {
      const [reservations] = await connection.query(
        `SELECT r.*, s.store_name, u.user_name, u.user_phone 
         FROM reservation r 
         JOIN store s ON r.reservation_store_id = s.store_id 
         JOIN user u ON r.reservation_user_id = u.user_id 
         WHERE r.reservation_id = ?`,
        [reservationId]
      );

      if (reservations.length === 0) {
        return res.status(404).json({
          success: false,
          message: '예약을 찾을 수 없습니다.'
        });
      }

      const reservation = reservations[0];
      res.json({
        success: true,
        reservation: {
          id: reservation.reservation_id,
          store_id: reservation.reservation_store_id,
          store_name: reservation.store_name,
          user_id: reservation.reservation_user_id,
          user_name: reservation.user_name,
          user_phone: reservation.user_phone,
          datetime: reservation.reservation_datetime,
          status: reservation.reservation_status,
          people_count: reservation.reservation_people_count,
          request: reservation.reservation_request,
          created_at: reservation.reservation_created_at
        }
      });

    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('예약 상세 정보 조회 오류:', error);
    res.status(500).json({
      success: false,
      message: '서버 오류가 발생했습니다.'
    });
  }
});

// 예약 생성
router.post('/', async (req, res) => {
  try {
    const {
      user_id,
      store_id,
      datetime,
      people_count,
      request
    } = req.body;

    // 필수 필드 검증
    if (!user_id || !store_id || !datetime || !people_count) {
      return res.status(400).json({
        success: false,
        message: '필수 정보가 누락되었습니다.'
      });
    }

    const connection = await pool.getConnection();

    try {
      const [result] = await connection.query(
        `INSERT INTO reservation (
          reservation_user_id,
          reservation_store_id,
          reservation_datetime,
          reservation_people_count,
          reservation_request,
          reservation_status,
          reservation_created_at
        ) VALUES (?, ?, ?, ?, ?, 'PENDING', NOW())`,
        [user_id, store_id, datetime, people_count, request]
      );

      res.status(201).json({
        success: true,
        message: '예약이 생성되었습니다.',
        reservation_id: result.insertId
      });

    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('예약 생성 오류:', error);
    res.status(500).json({
      success: false,
      message: '서버 오류가 발생했습니다.'
    });
  }
});

// 예약 상태 변경
router.put('/:reservationId/status', async (req, res) => {
  try {
    const { reservationId } = req.params;
    const { status } = req.body;

    if (!['PENDING', 'CONFIRMED', 'CANCELLED', 'COMPLETED'].includes(status)) {
      return res.status(400).json({
        success: false,
        message: '잘못된 예약 상태입니다.'
      });
    }

    const connection = await pool.getConnection();

    try {
      const [result] = await connection.query(
        'UPDATE reservation SET reservation_status = ? WHERE reservation_id = ?',
        [status, reservationId]
      );

      if (result.affectedRows === 0) {
        return res.status(404).json({
          success: false,
          message: '예약을 찾을 수 없습니다.'
        });
      }

      res.json({
        success: true,
        message: '예약 상태가 변경되었습니다.'
      });

    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('예약 상태 변경 오류:', error);
    res.status(500).json({
      success: false,
      message: '서버 오류가 발생했습니다.'
    });
  }
});

// 예약 취소
router.delete('/:reservationId', async (req, res) => {
  try {
    const { reservationId } = req.params;
    const { user_id } = req.body; // 보안을 위해 사용자 ID 확인

    const connection = await pool.getConnection();

    try {
      const [result] = await connection.query(
        'UPDATE reservation SET reservation_status = "CANCELLED" WHERE reservation_id = ? AND reservation_user_id = ?',
        [reservationId, user_id]
      );

      if (result.affectedRows === 0) {
        return res.status(404).json({
          success: false,
          message: '예약을 찾을 수 없거나 취소 권한이 없습니다.'
        });
      }

      res.json({
        success: true,
        message: '예약이 취소되었습니다.'
      });

    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('예약 취소 오류:', error);
    res.status(500).json({
      success: false,
      message: '서버 오류가 발생했습니다.'
    });
  }
});

module.exports = router; 