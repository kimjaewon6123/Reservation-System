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

// 매장 목록 조회
router.get('/', async (req, res) => {
  try {
    const connection = await pool.getConnection();

    try {
      const [stores] = await connection.query(
        'SELECT * FROM store WHERE store_status = "ACTIVE" ORDER BY store_name'
      );

      res.json({
        success: true,
        stores: stores.map(store => ({
          id: store.store_id,
          name: store.store_name,
          address: store.store_address,
          phone: store.store_phone,
          description: store.store_description,
          status: store.store_status
        }))
      });

    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('매장 목록 조회 오류:', error);
    res.status(500).json({
      success: false,
      message: '서버 오류가 발생했습니다.'
    });
  }
});

// 매장 상세 정보 조회
router.get('/:storeId', async (req, res) => {
  try {
    const { storeId } = req.params;
    const connection = await pool.getConnection();

    try {
      const [stores] = await connection.query(
        'SELECT * FROM store WHERE store_id = ? AND store_status = "ACTIVE"',
        [storeId]
      );

      if (stores.length === 0) {
        return res.status(404).json({
          success: false,
          message: '매장을 찾을 수 없습니다.'
        });
      }

      const store = stores[0];
      res.json({
        success: true,
        store: {
          id: store.store_id,
          name: store.store_name,
          address: store.store_address,
          phone: store.store_phone,
          description: store.store_description,
          status: store.store_status
        }
      });

    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('매장 상세 정보 조회 오류:', error);
    res.status(500).json({
      success: false,
      message: '서버 오류가 발생했습니다.'
    });
  }
});

// 매장 검색
router.get('/search/:keyword', async (req, res) => {
  try {
    const { keyword } = req.params;
    const connection = await pool.getConnection();

    try {
      const [stores] = await connection.query(
        'SELECT * FROM store WHERE store_status = "ACTIVE" AND (store_name LIKE ? OR store_address LIKE ?)',
        [`%${keyword}%`, `%${keyword}%`]
      );

      res.json({
        success: true,
        stores: stores.map(store => ({
          id: store.store_id,
          name: store.store_name,
          address: store.store_address,
          phone: store.store_phone,
          description: store.store_description,
          status: store.store_status
        }))
      });

    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('매장 검색 오류:', error);
    res.status(500).json({
      success: false,
      message: '서버 오류가 발생했습니다.'
    });
  }
});

module.exports = router; 