-- 데이터베이스 생성
CREATE DATABASE IF NOT EXISTS scrs
  CHARACTER SET = 'utf8mb4'
  COLLATE = 'utf8mb4_unicode_ci';

USE scrs;

-- 사용자 테이블
CREATE TABLE IF NOT EXISTS user (
  user_id VARCHAR(50) PRIMARY KEY,
  user_name VARCHAR(100) NOT NULL,
  user_email VARCHAR(100) NOT NULL UNIQUE,
  user_phone VARCHAR(20) NOT NULL,
  user_password VARCHAR(255) NOT NULL,
  user_status ENUM('ACTIVE', 'INACTIVE', 'SUSPENDED') NOT NULL DEFAULT 'ACTIVE',
  user_created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  user_updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  user_profile_image VARCHAR(255),
  user_preferred_store_id INT,
  INDEX idx_user_email (user_email),
  INDEX idx_user_status (user_status)
);

-- 매장 테이블
CREATE TABLE IF NOT EXISTS store (
  store_id INT AUTO_INCREMENT PRIMARY KEY,
  store_name VARCHAR(100) NOT NULL,
  store_address VARCHAR(255) NOT NULL,
  store_phone VARCHAR(20) NOT NULL,
  store_description TEXT,
  store_status ENUM('ACTIVE', 'INACTIVE', 'CLOSED') NOT NULL DEFAULT 'ACTIVE',
  store_category VARCHAR(50),
  store_hours VARCHAR(255),
  store_rating DECIMAL(3,2) DEFAULT 0.00,
  store_image_url VARCHAR(255),
  store_is_active BOOLEAN NOT NULL DEFAULT TRUE,
  store_created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  store_updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_store_status (store_status),
  INDEX idx_store_category (store_category)
);

-- 예약 테이블
CREATE TABLE IF NOT EXISTS reservation (
  reservation_id INT AUTO_INCREMENT PRIMARY KEY,
  reservation_user_id VARCHAR(50) NOT NULL,
  reservation_store_id INT NOT NULL,
  reservation_datetime DATETIME NOT NULL,
  reservation_status ENUM('PENDING', 'CONFIRMED', 'CANCELLED', 'COMPLETED') NOT NULL DEFAULT 'PENDING',
  reservation_people_count INT NOT NULL,
  reservation_request TEXT,
  reservation_created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  reservation_updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (reservation_user_id) REFERENCES user(user_id) ON DELETE CASCADE,
  FOREIGN KEY (reservation_store_id) REFERENCES store(store_id) ON DELETE CASCADE,
  INDEX idx_reservation_datetime (reservation_datetime),
  INDEX idx_reservation_status (reservation_status)
);

-- 알림 테이블
CREATE TABLE IF NOT EXISTS notification (
  notification_id INT AUTO_INCREMENT PRIMARY KEY,
  notification_type ENUM('RESERVATION', 'CANCELLATION', 'REMINDER', 'SYSTEM') NOT NULL,
  notification_content TEXT NOT NULL,
  notification_recipient VARCHAR(50) NOT NULL,
  notification_sent_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  notification_status ENUM('UNREAD', 'READ') NOT NULL DEFAULT 'UNREAD',
  notification_reservation_id INT,
  FOREIGN KEY (notification_recipient) REFERENCES user(user_id) ON DELETE CASCADE,
  FOREIGN KEY (notification_reservation_id) REFERENCES reservation(reservation_id) ON DELETE SET NULL,
  INDEX idx_notification_recipient (notification_recipient),
  INDEX idx_notification_status (notification_status)
);

-- 대기 목록 테이블
CREATE TABLE IF NOT EXISTS waiting_list (
  waiting_id INT AUTO_INCREMENT PRIMARY KEY,
  store_id INT NOT NULL,
  user_id VARCHAR(50) NOT NULL,
  waiting_datetime DATETIME NOT NULL,
  status ENUM('WAITING', 'CALLED', 'CANCELLED', 'EXPIRED') NOT NULL DEFAULT 'WAITING',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (store_id) REFERENCES store(store_id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE,
  INDEX idx_waiting_status (status),
  INDEX idx_waiting_datetime (waiting_datetime)
);

-- 외래 키 제약 조건 추가
ALTER TABLE user
ADD CONSTRAINT fk_user_preferred_store
FOREIGN KEY (user_preferred_store_id) REFERENCES store(store_id)
ON DELETE SET NULL; 