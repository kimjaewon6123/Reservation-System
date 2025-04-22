<%@ page contentType="application/json; charset=UTF-8" %>
<%@ page import="java.sql.*, org.json.JSONObject" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Calendar" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    // 로그인 체크
    String userIdSession = (String) session.getAttribute("user_id");
    JSONObject json = new JSONObject();
    
    if (userIdSession == null || userIdSession.trim().isEmpty()) {
        json.put("error", "login_required");
        json.put("message", "로그인이 필요합니다.");
        out.print(json.toString());
        return;
    }

    String dateParam = request.getParameter("date");
    String storeIdParam = request.getParameter("store_id");
    
    // 디버깅을 위한 로그
    System.out.println("User ID: " + userIdSession);
    System.out.println("Received date: " + dateParam);
    System.out.println("Received store_id: " + storeIdParam);
    
    if (dateParam == null || dateParam.trim().isEmpty()) {
        json.put("error", "invalid_date");
        json.put("message", "날짜가 선택되지 않았습니다.");
        out.print(json.toString());
        return;
    }
    
    int storeId = 1;
    if (storeIdParam != null && !storeIdParam.trim().isEmpty()) {
        try {
            storeId = Integer.parseInt(storeIdParam);
        } catch (Exception e) {
            System.out.println("Invalid store_id: " + storeIdParam);
        }
    }
    
    // 시간대 배열
    String[] times = {
        "오전 9:00", "오전 9:30", "오전 10:00", "오전 10:30", 
        "오전 11:00", "오전 11:30", "오후 12:00", "오후 12:30",
        "오후 1:00", "오후 1:30", "오후 2:00", "오후 2:30",
        "오후 3:00", "오후 3:30", "오후 4:00", "오후 4:30",
        "오후 5:00", "오후 5:30", "오후 6:00", "오후 6:30",
        "오후 7:00", "오후 7:30", "오후 8:00", "오후 8:30"
    };
    
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/scrs?useUnicode=true&characterEncoding=UTF-8&serverTimezone=Asia/Seoul",
            "root", "mysql123"
        );
        
        // 매장의 최대 예약 수 확인
        ps = conn.prepareStatement("SELECT capacity FROM store WHERE store_id = ?");
        ps.setInt(1, storeId);
        rs = ps.executeQuery();
        int maxReservations = 2;  // 기본값
        if (rs.next()) {
            maxReservations = rs.getInt("capacity");
            System.out.println("Store " + storeId + " capacity: " + maxReservations);
        }
        rs.close();
        ps.close();
        
        // 각 시간대별 예약 현황 확인
        for (String t : times) {
            String dbTime = convertTimeToDBFormat(t);
            System.out.println("Checking time: " + t + " (DB format: " + dbTime + ")");
            
            // 해당 날짜와 시간에 대한 모든 예약 확인
            String sql = "SELECT COUNT(*) AS cnt FROM reservation " +
                        "WHERE reservation_store_id = ? " +
                        "AND DATE(reservation_datetime) = ? " +
                        "AND TIME(reservation_datetime) = ? " +
                        "AND reservation_status = 'CONFIRMED'";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, storeId);
            ps.setString(2, dateParam);
            ps.setString(3, dbTime);
            rs = ps.executeQuery();
            int count = 0;
            if (rs.next()) {
                count = rs.getInt("cnt");
            }
            System.out.println("Time: " + t + ", Reservations: " + count);
            rs.close();
            ps.close();
            
            // 대기 수 확인
            sql = "SELECT COUNT(*) AS cnt FROM waiting_list " +
                  "WHERE store_id = ? " +
                  "AND DATE(waiting_datetime) = ? " +
                  "AND TIME(waiting_datetime) = ? " +
                  "AND status = 'WAITING'";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, storeId);
            ps.setString(2, dateParam);
            ps.setString(3, dbTime);
            rs = ps.executeQuery();
            int waitingCount = 0;
            if (rs.next()) {
                waitingCount = rs.getInt("cnt");
            }
            System.out.println("Time: " + t + ", Waiting: " + waitingCount);
            rs.close();
            ps.close();
            
            // 상태 결정
            String status;
            System.out.println("Determining status for time " + t);
            System.out.println("Current reservations: " + count);
            System.out.println("Max reservations: " + maxReservations);
            System.out.println("Waiting count: " + waitingCount);

            if (count >= maxReservations) {
                status = "FULL";
            } else if (count > 0) {
                status = "WAITING";
            } else {
                status = "AVAILABLE";
            }
            
            // JSON에 상태 추가
            try {
                json.put(t, status);
                System.out.println("Added to JSON - Time: " + t + ", Status: " + status);
            } catch (Exception e) {
                System.out.println("Error adding to JSON: " + e.getMessage());
            }
        }
        
        // 전체 JSON 출력 전 로깅
        System.out.println("Final JSON response: " + json.toString());
        
        // JSON 응답 헤더 설정
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        // JSON 출력
        out.print(json.toString());
        
    } catch (Exception e) {
        System.out.println("Error occurred: " + e.getMessage());
        e.printStackTrace();
        json = new JSONObject();
        json.put("error", e.getMessage());
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception ex) {}
        if (ps != null) try { ps.close(); } catch (Exception ex) {}
        if (conn != null) try { conn.close(); } catch (Exception ex) {}
    }
%>

<%!
    // 시간 문자열을 DB 시간 형식으로 변환
    private String convertTimeToDBFormat(String timeStr) {
        if (timeStr == null) return "00:00:00";
        
        // 오전/오후 처리
        boolean pm = timeStr.contains("오후");
        boolean am = timeStr.contains("오전");
        
        // 시간과 분 추출
        java.util.regex.Pattern p = java.util.regex.Pattern.compile("(\\d{1,2}):(\\d{2})");
        java.util.regex.Matcher m = p.matcher(timeStr);
        if (!m.find()) {
            return "00:00:00";
        }
        
        String[] parts = m.group(0).split(":");
        int hour = 0, min = 0;
        try {
            hour = Integer.parseInt(parts[0]);
            min = Integer.parseInt(parts[1]);
        } catch (Exception e) {
            return "00:00:00";
        }
        
        if (pm && hour < 12) {
            hour += 12;
        } else if (am && hour == 12) {
            hour = 0;
        }
        
        return String.format("%02d:%02d:00", hour, min);
    }
%>
