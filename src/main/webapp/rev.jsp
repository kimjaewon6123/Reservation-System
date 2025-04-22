<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.io.StringWriter, java.io.PrintWriter, java.text.Normalizer" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.Calendar" %>
<%@ page import="java.util.TimeZone" %>
<%!
    // 오전/오후 또는 24시간 표기를 "HH:mm:ss"로 변환 (유니코드 정규화 적용 + 정규식)
    public String parseTimeStr(String timeStr) {
        if(timeStr == null) return "00:00:00";
        timeStr = timeStr.trim();
        if(timeStr.isEmpty()) return "00:00:00";
        
        // 유니코드 정규화
        String normalized = Normalizer.normalize(timeStr, Normalizer.Form.NFC).trim();
        
        // 1) "HH:mm" 형식
        if(normalized.matches("\\d{1,2}:\\d{2}")) {
            try {
                String[] parts = normalized.split(":");
                int hr = Integer.parseInt(parts[0]);
                int mn = Integer.parseInt(parts[1]);
                return String.format("%02d:%02d:00", hr, mn);
            } catch(Exception e) {
                return "00:00:00";
            }
        }
        // 2) 오전/오후 처리
        boolean pm = normalized.contains("오후");
        boolean am = normalized.contains("오전");
        java.util.regex.Pattern p = java.util.regex.Pattern.compile("(\\d{1,2}):(\\d{2})");
        java.util.regex.Matcher m = p.matcher(normalized);
        if(!m.find()) {
            return "00:00:00";
        }
        String hhmm = m.group(0);
        String[] parts = hhmm.split(":");
        int hour=0, min=0;
        try {
            hour = Integer.parseInt(parts[0]);
            min  = Integer.parseInt(parts[1]);
        } catch(Exception e) {
            return "00:00:00";
        }
        if(pm) {
            if(hour < 12) { hour += 12; }
        } else if(am) {
            if(hour == 12) { hour = 0; }
        }
        return String.format("%02d:%02d:00", hour, min);
    }
%>
<html>
<head>
    <meta charset="UTF-8">
    <title>예약 처리</title>
    <style>
        body { font-family: Arial, sans-serif; background: #f2f2f2; margin: 0; padding: 0; }
        .container {
            width: 70%; margin: 40px auto; background: #fff; border-radius: 6px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1); padding: 20px 30px;
        }
        .success { background: #e3f2fd; border-left: 4px solid #2196f3; padding: 10px 15px;
                   margin: 15px 0; color: #333; font-size: 15px; }
        .error { background: #ffe4e4; border-left: 4px solid #f44336; padding: 10px 15px;
                 margin: 15px 0; color: #333; font-size: 15px; }
    </style>
</head>
<body>
<div class="container">
<%
    // DB 연결 정보
    String dbURL = "jdbc:mysql://localhost:3306/scrs?useUnicode=true&characterEncoding=UTF-8&serverTimezone=Asia/Seoul";
    String dbUser = "root";
    String dbPass = "mysql123";

    // 세션에서 사용자 ID 가져오기
    String userIdSession = (String) session.getAttribute("user_id");
    if (userIdSession == null || userIdSession.trim().isEmpty()) {
        response.sendRedirect("login.html");
        return;
    }

    // 파라미터 받기
    String storeIdParam = request.getParameter("store_id");
    String selectedDate = request.getParameter("selectedDate");
    String selectedTime = request.getParameter("selectedTime");
    String waitingFlag = request.getParameter("waitingFlag");
    String serviceIdParam = request.getParameter("service_id");
    
    // 디버깅을 위한 로그
    System.out.println("User ID: " + userIdSession);
    System.out.println("Store ID: " + storeIdParam);
    System.out.println("Selected Date: " + selectedDate);
    System.out.println("Selected Time: " + selectedTime);
    System.out.println("Waiting Flag: " + waitingFlag);
    System.out.println("Service ID: " + serviceIdParam);
    
    // 필수 파라미터 검증
    if (storeIdParam == null || selectedDate == null || selectedTime == null) {
        out.println("<div class='error'>필수 정보가 누락되었습니다.</div>");
        return;
    }

    int storeId = 1, serviceId = 1;
    try {
        storeId = Integer.parseInt(storeIdParam);
        if (serviceIdParam != null && !serviceIdParam.trim().isEmpty()) {
            serviceId = Integer.parseInt(serviceIdParam);
        }
    } catch (Exception e) {
        out.println("<div class='error'>잘못된 매장 또는 서비스 ID입니다.</div>");
        return;
    }

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbURL, dbUser, dbPass);
        conn.setAutoCommit(false);  // 트랜잭션 시작

        // 날짜/시간 파싱
        String hhmmss = parseTimeStr(selectedTime);
        String dateTimeStr = selectedDate.trim() + " " + hhmmss;
        java.sql.Timestamp reservationDateTime = null;
        try {
            reservationDateTime = java.sql.Timestamp.valueOf(dateTimeStr);
        } catch (Exception e) {
            throw new Exception("예약 일시 형식이 올바르지 않습니다: " + dateTimeStr);
        }

        // 동일 사용자의 같은 시간대 예약 확인
        ps = conn.prepareStatement(
            "SELECT COUNT(*) FROM reservation " +
            "WHERE reservation_user_id = ? " +
            "AND DATE(reservation_datetime) = ? " +
            "AND TIME(reservation_datetime) = ? " +
            "AND reservation_status = 'CONFIRMED'"
        );
        ps.setString(1, userIdSession);
        ps.setString(2, selectedDate);
        ps.setString(3, hhmmss);
        rs = ps.executeQuery();
        if (rs.next() && rs.getInt(1) > 0) {
            throw new Exception("이미 같은 시간대에 예약하셨습니다.");
        }
        rs.close();
        ps.close();

        // 예약 가능 여부 확인
        ps = conn.prepareStatement(
            "SELECT COUNT(*) AS cnt FROM reservation " +
            "WHERE reservation_store_id = ? " +
            "AND DATE(reservation_datetime) = ? " +
            "AND TIME(reservation_datetime) = ? " +
            "AND reservation_status = 'CONFIRMED'"
        );
        ps.setInt(1, storeId);
        ps.setString(2, selectedDate);
        ps.setString(3, hhmmss);
        rs = ps.executeQuery();
        int currentReserve = 0;
        if (rs.next()) {
            currentReserve = rs.getInt("cnt");
        }
        rs.close();
        ps.close();

        // 매장의 최대 예약 수 확인
        ps = conn.prepareStatement("SELECT capacity FROM store WHERE store_id = ?");
        ps.setInt(1, storeId);
        rs = ps.executeQuery();
        int maxReservations = 2;  // 기본값
        if (rs.next()) {
            maxReservations = rs.getInt("capacity");
        }
        rs.close();
        ps.close();

        boolean isFull = (currentReserve >= maxReservations);
        boolean isWaiting = "true".equalsIgnoreCase(waitingFlag);

        if (isFull && !isWaiting) {
            throw new Exception("해당 시간은 예약이 마감되었습니다.");
        }

        // 예약 또는 대기 등록
        if (isWaiting) {
            System.out.println("대기 등록 처리 시작");
            System.out.println("사용자 ID: " + userIdSession);
            System.out.println("매장 ID: " + storeId);
            System.out.println("예약 일시: " + reservationDateTime);
            
            // 대기 목록에 추가
            ps = conn.prepareStatement(
                "INSERT INTO waiting_list (user_id, store_id, service_id, waiting_datetime, status, created_at, updated_at) " +
                "VALUES (?, ?, ?, ?, 'WAITING', NOW(), NOW())",
                Statement.RETURN_GENERATED_KEYS
            );
            ps.setString(1, userIdSession);
            ps.setInt(2, storeId);
            ps.setInt(3, serviceId);
            ps.setTimestamp(4, reservationDateTime);
            
            int waitingResult = ps.executeUpdate();
            System.out.println("대기 등록 결과: " + waitingResult);
            
            if (waitingResult == 0) {
                throw new Exception("대기 등록에 실패했습니다.");
            }
            
            rs = ps.getGeneratedKeys();
            int waitId = 0;
            if (rs.next()) {
                waitId = rs.getInt(1);
                System.out.println("생성된 대기 ID: " + waitId);
                out.println("<div class='success'>대기 등록이 완료되었습니다. (대기번호: " + waitId + ")</div>");
            } else {
                throw new Exception("대기 ID를 가져오는데 실패했습니다.");
            }
            rs.close();
            ps.close();
        } else {
            // 일반 예약 처리
            ps = conn.prepareStatement(
                "INSERT INTO reservation (reservation_user_id, reservation_store_id, reservation_service_id, " +
                "reservation_datetime, reservation_status, reservation_created_at, reservation_updated_at) " +
                "VALUES (?, ?, ?, ?, 'CONFIRMED', NOW(), NOW())",
                Statement.RETURN_GENERATED_KEYS
            );
            ps.setString(1, userIdSession);
            ps.setInt(2, storeId);
            ps.setInt(3, serviceId);
            ps.setTimestamp(4, reservationDateTime);
            
            if (ps.executeUpdate() == 0) {
                throw new Exception("예약 등록에 실패했습니다.");
            }
            
            rs = ps.getGeneratedKeys();
            if (rs.next()) {
                int reservationId = rs.getInt(1);
                out.println("<div class='success'>예약이 완료되었습니다. (예약번호: " + reservationId + ")</div>");
            }
        }

        conn.commit();  // 트랜잭션 커밋
        System.out.println("트랜잭션 커밋 완료");
    } catch (Exception e) {
        if (conn != null) {
            try { conn.rollback(); } catch (SQLException ex) {}
        }
        out.println("<div class='error'>" + e.getMessage() + "</div>");
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception ex) {}
        if (ps != null) try { ps.close(); } catch (Exception ex) {}
        if (conn != null) try { conn.close(); } catch (Exception ex) {}
    }
%>
<script>
    setTimeout(function() {
        window.location.href = 'myrev.jsp';
    }, 2000);
</script>
</div>
</body>
</html>
