<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.text.SimpleDateFormat, java.util.Date" %>
<%@ page import="java.time.*" %>
<%@ page import="java.time.format.*" %>
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8" />
    <title>예약 확정</title>
    <style>
      body { 
        font-family: 'Pretendard-Medium', Arial, sans-serif; 
        background-color: #f8f9fa; 
        margin: 0; 
        padding: 0; 
        color: #495057;
      }
      .container { 
        width: 80%; 
        margin: 50px auto; 
        padding: 30px; 
        background-color: #ffffff; 
        border: 1px solid #e9ecef; 
        border-radius: 12px;
        box-shadow: 0 2px 12px rgba(0,0,0,0.05); 
      }
      .success { 
        color: #2b7a39; 
        font-size: 16px;
        background-color: #e8f5e9;
        padding: 15px 20px;
        border-radius: 8px;
        border-left: 4px solid #43a047;
      }
      .error { 
        color: #c62828; 
        font-size: 16px;
        background-color: #fef2f2;
        padding: 15px 20px;
        border-radius: 8px;
        border-left: 4px solid #ef5350;
      }
    </style>
  </head>
  <body>
    <div class="container">
<%
    // 파라미터 받기
    String selectedDate = request.getParameter("selectedDate");
    String selectedTime = request.getParameter("selectedTime");
    String waitingFlag = request.getParameter("waitingFlag");
    
    // 날짜 형식 검증
    if (selectedDate == null || selectedTime == null) {
        response.sendRedirect("rev.html?error=invalid_params");
        return;
    }
    
    try {
        // 현재 연도와 월 가져오기
        LocalDate now = LocalDate.now();
        int year = now.getYear();
        int month = now.getMonthValue();
        
        // 날짜 문자열 생성 (예: 2024-03-15)
        String dateStr = String.format("%d-%02d-%02d", year, month, selectedDate);
        
        // 날짜와 시간 결합
        String reservationDatetime = dateStr + " " + selectedTime + ":00";
        
        // 날짜 형식 유효성 검사
        LocalDateTime.parse(reservationDatetime, DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
        
        // 데이터베이스 연결 및 예약 처리
        Class.forName("com.mysql.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/yourdb", "username", "password");
        
        // 예약 가능 여부 확인
        String checkQuery = "SELECT COUNT(*) FROM reservations WHERE reservation_datetime = ?";
        PreparedStatement checkStmt = conn.prepareStatement(checkQuery);
        checkStmt.setString(1, reservationDatetime);
        ResultSet rs = checkStmt.executeQuery();
        rs.next();
        int currentCount = rs.getInt(1);
        
        if (currentCount == 0 || "true".equals(waitingFlag)) {
            // 예약 추가
            String insertQuery = "INSERT INTO reservations (reservation_datetime, waiting_flag) VALUES (?, ?)";
            PreparedStatement insertStmt = conn.prepareStatement(insertQuery);
            insertStmt.setString(1, reservationDatetime);
            insertStmt.setBoolean(2, "true".equals(waitingFlag));
            insertStmt.executeUpdate();
            
            response.sendRedirect("rev.html?success=true");
        } else {
            response.sendRedirect("rev.html?error=full");
        }
        
        conn.close();
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("rev.html?error=" + e.getMessage());
    }
%>
    </div>
  </body>
</html>
