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

// 알림 목록 조회
router.get('/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const connection = await pool.getConnection();

    try {
      const [notifications] = await connection.query(
        `SELECT n.*, r.reservation_datetime, s.store_name 
         FROM notification n 
         LEFT JOIN reservation r ON n.notification_reservation_id = r.reservation_id 
         LEFT JOIN store s ON r.reservation_store_id = s.store_id 
         WHERE n.notification_recipient = ? 
         ORDER BY n.notification_sent_at DESC`,
        [userId]
      );

      res.json({
        success: true,
        notifications: notifications.map(notification => ({
          id: notification.notification_id,
          type: notification.notification_type,
          content: notification.notification_content,
          sent_at: notification.notification_sent_at,
          status: notification.notification_status,
          store_name: notification.store_name,
          reservation_datetime: notification.reservation_datetime
        }))
      });

    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('알림 목록 조회 오류:', error);
    res.status(500).json({
      success: false,
      message: '서버 오류가 발생했습니다.'
    });
  }
});

// 알림 삭제
router.delete('/:notificationId', async (req, res) => {
  try {
    const { notificationId } = req.params;
    const { userId } = req.body; // 보안을 위해 사용자 ID도 확인

    const connection = await pool.getConnection();

    try {
      const [result] = await connection.query(
        'DELETE FROM notification WHERE notification_id = ? AND notification_recipient = ?',
        [notificationId, userId]
      );

      if (result.affectedRows === 0) {
        return res.status(404).json({
          success: false,
          message: '알림을 찾을 수 없습니다.'
        });
      }

      res.json({
        success: true,
        message: '알림이 삭제되었습니다.'
      });

    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('알림 삭제 오류:', error);
    res.status(500).json({
      success: false,
      message: '서버 오류가 발생했습니다.'
    });
  }
});

// 알림 읽음 처리
router.put('/:notificationId/read', async (req, res) => {
  try {
    const { notificationId } = req.params;
    const { userId } = req.body; // 보안을 위해 사용자 ID도 확인

    const connection = await pool.getConnection();

    try {
      const [result] = await connection.query(
        'UPDATE notification SET notification_status = "READ" WHERE notification_id = ? AND notification_recipient = ?',
        [notificationId, userId]
      );

      if (result.affectedRows === 0) {
        return res.status(404).json({
          success: false,
          message: '알림을 찾을 수 없습니다.'
        });
      }

      res.json({
        success: true,
        message: '알림이 읽음 처리되었습니다.'
      });

    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('알림 상태 변경 오류:', error);
    res.status(500).json({
      success: false,
      message: '서버 오류가 발생했습니다.'
    });
  }
});

module.exports = router; 