<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%
  // (0) 로그인 체크
  String userId = (String) session.getAttribute("user_id");
  if (userId == null || userId.trim().isEmpty()) {
    response.sendRedirect("login.html");
    return;
  }

  Class.forName("com.mysql.cj.jdbc.Driver");
  String url = "jdbc:mysql://localhost:3306/scrs";
  String usr = "root", pwd = "mysql123";

  // (1) 파라미터 읽기
  String deleteResId  = request.getParameter("deleteReservationId");
  String deleteWaitId = request.getParameter("deleteWaitId");
  boolean isAjaxRequest = "XMLHttpRequest".equals(request.getHeader("X-Requested-With"));

  // (2) "나의 예약" 취소 처리 & 대기자 알림
  if (deleteResId != null && !deleteResId.isEmpty()) {
    response.setContentType("application/json;charset=UTF-8");
    Connection conn = null;
    try {
      conn = DriverManager.getConnection(url, usr, pwd);
      conn.setAutoCommit(false);

      // 2‑a) 슬롯 정보 조회
      int storeId = 0;
      Timestamp resDt = null;
      try (PreparedStatement ps = conn.prepareStatement(
             "SELECT reservation_store_id, reservation_datetime "
           + "  FROM reservation "
           + " WHERE reservation_id = ? AND reservation_user_id = ?"
         )) {
        ps.setInt(1, Integer.parseInt(deleteResId));
        ps.setString(2, userId);
        try (ResultSet rs = ps.executeQuery()) {
          if (rs.next()) {
            storeId = rs.getInt("reservation_store_id");
            resDt   = rs.getTimestamp("reservation_datetime");
          }
        }
      }

      // 2‑b) 예약 상태만 CANCELLED 로 업데이트
      int updateResult = 0;
      try (PreparedStatement ps = conn.prepareStatement(
             "UPDATE reservation "
           + "   SET reservation_status='CANCELLED', "
           + "       reservation_cancel_reason='사용자 취소', "
           + "       reservation_updated_at=NOW() "
           + " WHERE reservation_id = ? AND reservation_user_id = ?"
         )) {
        ps.setInt(1, Integer.parseInt(deleteResId));
        ps.setString(2, userId);
        updateResult = ps.executeUpdate();
      }

      if (updateResult > 0) {
        // 2‑c) 본인에게 RESERVATION_CANCELLED 알림
        try (PreparedStatement ps = conn.prepareStatement(
               "INSERT INTO notification "
             + "(notification_reservation_id, notification_type, notification_sent_at, notification_recipient) "
             + "VALUES (?, 'CANCEL', NOW(), ?)"
           )) {
          ps.setInt(1, Integer.parseInt(deleteResId));
          ps.setString(2, userId);
          ps.executeUpdate();
        }

        // 2‑d) 같은 슬롯에 대기 중인 유저들에게 SLOT_OPENED 알림
        try (PreparedStatement ps = conn.prepareStatement(
               "SELECT user_id "
             + "  FROM waiting_list "
             + " WHERE store_id = ? AND waiting_datetime = ? AND status = 'WAITING'"
           )) {
          ps.setInt(1, storeId);
          ps.setTimestamp(2, resDt);
          try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
              String waitUser = rs.getString(1);
              // – 대기리스트 상태 업데이트
              try (PreparedStatement p2 = conn.prepareStatement(
                     "UPDATE waiting_list "
                   + "   SET status='OPENED', updated_at=NOW() "
                   + " WHERE store_id = ? AND waiting_datetime = ? AND user_id = ?"
                 )) {
                p2.setInt(1, storeId);
                p2.setTimestamp(2, resDt);
                p2.setString(3, waitUser);
                p2.executeUpdate();
              }
              // – SLOT_OPENED 알림 생성
              try (PreparedStatement p3 = conn.prepareStatement(
                     "INSERT INTO notification "
                   + "(notification_reservation_id, notification_type, notification_sent_at, notification_recipient) "
                   + "VALUES (?, 'OPEN', NOW(), ?)"
                 )) {
                p3.setInt(1, Integer.parseInt(deleteResId));
                p3.setString(2, waitUser);
                p3.executeUpdate();
              }
            }
          }
        }
        conn.commit();
        out.print("{\"success\":true,\"message\":\"예약이 취소되었습니다.\"}");
      } else {
        conn.rollback();
        out.print("{\"success\":false,\"message\":\"예약을 찾을 수 없습니다.\"}");
      }
    } catch (Exception e) {
      if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
      out.print("{\"success\":false,\"message\":\"" + e.getMessage() + "\"}");
    } finally {
      if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
    return;
  }

  // (3) "대기 예약" 취소 처리
  if (deleteWaitId != null && !deleteWaitId.isEmpty()) {
    try (Connection conn = DriverManager.getConnection(url, usr, pwd);
         PreparedStatement ps = conn.prepareStatement(
           "DELETE FROM waiting_list WHERE wait_id = ? AND user_id = ?"
         )) {
      ps.setInt(1, Integer.parseInt(deleteWaitId));
      ps.setString(2, userId);
      ps.executeUpdate();
    } catch (Exception e) {
      e.printStackTrace();
    }
    response.sendRedirect("myrev.jsp");
    return;
  }

  // (4) 화면 렌더링용 "나의 예약" 조회 (CANCELLED 제외)
  List<Map<String,Object>> myReservations = new ArrayList<>();
  try (Connection conn = DriverManager.getConnection(url, usr, pwd);
       PreparedStatement ps = conn.prepareStatement(
         "SELECT reservation_id, reservation_datetime, reservation_status "
       + "  FROM reservation "
       + " WHERE reservation_user_id = ? "
       + "   AND reservation_status <> 'CANCELLED' "
       + " ORDER BY reservation_datetime DESC"
       )) {
    ps.setString(1, userId);
    try (ResultSet rs = ps.executeQuery()) {
      while (rs.next()) {
        Map<String,Object> m = new HashMap<>();
        m.put("id", rs.getInt("reservation_id"));
        m.put("dt", rs.getTimestamp("reservation_datetime"));
        m.put("st", rs.getString("reservation_status"));
        myReservations.add(m);
      }
    }
  }

  // (5) 화면 렌더링용 "대기 예약" 조회
  List<Map<String,Object>> myWaitings = new ArrayList<>();
  try (Connection conn = DriverManager.getConnection(url, usr, pwd);
       PreparedStatement ps = conn.prepareStatement(
         "SELECT wait_id, waiting_datetime, status "
       + "  FROM waiting_list "
       + " WHERE user_id = ? "
       + " ORDER BY waiting_datetime DESC"
       )) {
    ps.setString(1, userId);
    try (ResultSet rs = ps.executeQuery()) {
      while (rs.next()) {
        Map<String,Object> m = new HashMap<>();
        m.put("id", rs.getInt("wait_id"));
        m.put("dt", rs.getTimestamp("waiting_datetime"));
        m.put("st", rs.getString("status"));
        myWaitings.add(m);
      }
    }
  }
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8" />
  <title>예약 현황</title>
  <link rel="stylesheet" href="css/global.css" />
  <link rel="stylesheet" href="css/styleguide.css" />
  <link rel="stylesheet" href="css/myrevstyle.css" />
  <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
  <style>
    .reservation-section { position:absolute; top:160px; left:26px; width:320px; }
    .waiting-section   { position:absolute; top:460px; left:26px; width:320px; }
    table { 
      width: 100%; 
      border-collapse: separate; 
      border-spacing: 0;
      font-size: 13px;
      border-radius: 12px;
      overflow: hidden;
      box-shadow: 0 4px 16px rgba(138, 43, 226, 0.08);
      background: linear-gradient(145deg, #ffffff, #fcfaff);
    }
    th, td {
      border: none;
      padding: 12px 8px;
      text-align: center;
      font-family: "Pretendard-Regular", Helvetica;
      line-height: 1.4;
    }
    th { 
      background: linear-gradient(to right, #f3f0ff, #f8f0ff);
      color: #495057;
      font-weight: 500;
      border-bottom: 1px solid #e9ecef;
    }
    tr:nth-child(even) {
      background: linear-gradient(to right, #fcfaff, #ffffff);
    }
    tr:hover {
      background: linear-gradient(to right, #f3f0ff, #f8f0ff);
      transition: all 0.3s ease;
    }
    .no-data { 
      text-align: center; 
      padding: 16px; 
      color: #868e96;
      background: linear-gradient(to right, #fcfaff, #ffffff);
      font-size: 13px;
    }
    .cancel-button {
      background: linear-gradient(145deg, #9775fa, #845ef7);
      color: white;
      border: none;
      padding: 6px 12px;
      font-size: 12px;
      border-radius: 6px;
      cursor: pointer;
      transition: all 0.3s ease;
      box-shadow: 0 2px 8px rgba(138, 43, 226, 0.15);
    }
    .cancel-button:hover { 
      background: linear-gradient(145deg, #845ef7, #7950f2);
      transform: translateY(-1px);
      box-shadow: 0 4px 12px rgba(138, 43, 226, 0.2);
    }
    .cancel-form { display:inline; margin:0; padding:0; }

    /* 하단 네비게이션 스타일 */
    .nav-container {
      position: absolute;
      bottom: 0;
      left: 0;
      width: 100%;
      background: #ffffff;
      border-radius: 0 0 30px 30px;
      border-top: 1px solid #f0f0f0;
      z-index: 1000;
    }
    .nav-wrapper {
      display: flex;
      justify-content: space-around;
      align-items: center;
      height: 80px;
      padding: 0 20px;
    }
    .nav-item {
      display: flex;
      flex-direction: column;
      align-items: center;
      cursor: pointer;
    }
    .nav-item img {
      width: 24px;
      height: 24px;
      opacity: 0.5;
      transition: opacity 0.2s;
    }
    .nav-item img.active,
    .nav-item:hover img {
      opacity: 1;
    }
    .nav-label {
      margin-top: 4px;
      font-size: 10px;
      color: #666;
      text-align: center;
    }
    .nav-item:hover .nav-label {
      color: #000;
    }
  </style>
  <script>
    function cancelReservation(reservationId) {
      if (!confirm('정말 예약을 취소하시겠습니까?')) return false;
      $.ajax({
        url: 'myrev.jsp',
        type: 'POST',
        data: { 'deleteReservationId': reservationId },
        headers: { 'X-Requested-With': 'XMLHttpRequest' },
        dataType: 'json',
        success: function(response) {
          alert(response.message || '예약이 취소되었습니다.');
          if (response.success) {
            window.location.reload();
          }
        },
        error: function(xhr, status, error) {
          console.error('Error:', error);
          alert('서버 통신 중 오류가 발생했습니다.');
        }
      });
      return false;
    }
  </script>
</head>
<body>
  <div class="screen">
    <div class="div">

      <!-- (1) 상단 상태바 -->
      <div class="status-bars">
        <div class="statusbar-ios">
          <div class="left-side">
            <div class="statusbars-time"><div class="time">9:41</div></div>
          </div>
          <div class="right-side">
            <img class="icon-mobile-signal" src="img/ㅊㅊㅊㅍㅍ.png" alt="신호" />
            <img class="wifi"               src="img/ㅊㅊㅊㅊ.png" alt="와이파이" />
            <div class="statusbar-battery">
              <div class="overlap-group">
                <img class="outline" src="img/ㅊㅌ.png" alt="배터리 외곽" />
                <div class="percentage"></div>
              </div>
              <img class="battery-end" src="img/battery-end.svg" alt="배터리 끝" />
            </div>
          </div>
        </div>
      </div>

      <!-- (2) 제목 영역 -->
      <div class="text-wrapper">예약 현황</div>
      <img class="vector" src="img/ㅍ.png" alt="아이콘" />
      <div class="text-wrapper-2">나의 예약</div>
      <div class="text-wrapper-3">대기 예약</div>

      <!-- (3) 나의 예약 테이블 -->
      <div class="reservation-section">
        <table>
          <tr><th>예약 번호</th><th>예약 일시</th><th>예약 상태</th><th>취소</th></tr>
          <%
            if (myReservations.isEmpty()) {
          %>
            <tr><td colspan="4" class="no-data">예약 내역이 없습니다.</td></tr>
          <%
            } else {
              for (Map<String,Object> r : myReservations) {
          %>
            <tr>
              <td><%= r.get("id") %></td>
              <td><%= r.get("dt") %></td>
              <td><%= r.get("st") %></td>
              <td>
                <button type="button" class="cancel-button" 
                        onclick="cancelReservation('<%= r.get("id") %>')">
                  취소
                </button>
              </td>
            </tr>
          <%
              }
            }
          %>
        </table>
      </div>

      <!-- (4) 대기 예약 테이블 -->
      <div class="waiting-section">
        <table>
          <tr><th>대기 번호</th><th>대기 일시</th><th>상태</th><th>취소</th></tr>
          <%
            if (myWaitings.isEmpty()) {
          %>
            <tr><td colspan="4" class="no-data">대기 예약 내역이 없습니다.</td></tr>
          <%
            } else {
              for (Map<String,Object> w : myWaitings) {
          %>
            <tr>
              <td><%= w.get("id") %></td>
              <td><%= w.get("dt") %></td>
              <td><%= w.get("st") %></td>
              <td>
                <form class="cancel-form" method="post" action="myrev.jsp">
                  <input type="hidden" name="deleteWaitId" value="<%= w.get("id") %>" />
                  <button type="submit" class="cancel-button"
                          onclick="return confirm('정말 대기 예약을 취소하시겠습니까?');">
                    취소
                  </button>
                </form>
              </td>
            </tr>
          <%
              }
            }
          %>
        </table>
      </div>

      <!-- (5) 하단 네비게이션 -->
      <div class="nav-container">
        <div class="nav-wrapper">
          <div class="nav-item" onclick="location.href='index.jsp'">
            <img src="img/home.png" alt="홈" />
            <div class="nav-label">홈</div>
          </div>
          <div class="nav-item" onclick="location.href='feed.jsp'">
            <img src="img/cxxc.png" alt="피드" />
            <div class="nav-label">피드</div>
          </div>
          <div class="nav-item" onclick="location.href='map.html'">
            <img src="img/map.png" alt="내주변" />
            <div class="nav-label">내주변</div>
          </div>
          <div class="nav-item" onclick="location.href='myrev.jsp'">
            <img src="img/rev.png" alt="예약" class="active" />
            <div class="nav-label">예약</div>
          </div>
          <div class="nav-item" onclick="location.href='mypage.jsp'">
            <img src="img/my.png" alt="마이" />
            <div class="nav-label">마이</div>
          </div>
        </div>
      </div>

    </div>
  </div>
</body>
</html>
