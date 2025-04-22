<%@ page contentType="application/json; charset=UTF-8"
         pageEncoding="UTF-8"
         buffer="8kb"
         trimDirectiveWhitespaces="true" %>
<%@ page import="java.sql.*, java.time.*, java.time.format.*, java.util.*, com.google.gson.Gson" %>
<%
    // 1) 파라미터 받아오기 (널·빈 검사 포함)
    String timeSlotParam = Optional.ofNullable(request.getParameter("timeSlot")).orElse("");
    String dateParam     = Optional.ofNullable(request.getParameter("date"))
                                    .filter(s -> !s.trim().isEmpty())
                                    .orElse(LocalDate.now().toString());

    // 2) 날짜/시간 파싱
    LocalDate   date = LocalDate.parse(dateParam);  // "yyyy-MM-dd" 포맷 가정
    DateTimeFormatter slotFmt = DateTimeFormatter.ofPattern("a h:mm", Locale.KOREAN);
    LocalTime   time;
    try {
        time = LocalTime.parse(timeSlotParam, slotFmt);
    } catch (Exception e) {
        // 파싱 실패 시 자정으로 처리
        time = LocalTime.MIDNIGHT;
    }
    LocalDateTime startDt = LocalDateTime.of(date, time);
    Timestamp       tsStart = Timestamp.valueOf(startDt);
    Timestamp       tsEnd   = Timestamp.valueOf(startDt.plusMinutes(1));

    // 3) DB에서 COUNT 조회
    int currentCount = 0;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection conn = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/scrs", "root", "mysql123");
             PreparedStatement ps = conn.prepareStatement(
                "SELECT COUNT(*) AS cnt "
              + "  FROM reservation "
              + " WHERE reservation_datetime >= ? "
              + "   AND reservation_datetime <  ? "
              + "   AND reservation_status = 'CONFIRMED'"
             )) {
            ps.setTimestamp(1, tsStart);
            ps.setTimestamp(2, tsEnd);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    currentCount = rs.getInt("cnt");
                }
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
        // JSON으로 에러 응답
        Map<String,Object> err = new HashMap<>();
        err.put("error", "쿼리 실행 실패");
        out.print(new Gson().toJson(err));
        return;
    }

    // 4) JSON 응답 출력
    Map<String,Object> result = new HashMap<>();
    result.put("currentCount", currentCount);
    out.print(new Gson().toJson(result));
%>
