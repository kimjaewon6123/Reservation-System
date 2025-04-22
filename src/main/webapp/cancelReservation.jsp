<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
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

  // ★ 디버그 출력: 파라미터와 세션 유저 확인
  out.println("<p>🚀 deleteReservationId=" + deleteResId
            + ", deleteWaitId=" + deleteWaitId
            + ", session.userId='" + userId + "'</p>");

  // 파라미터가 둘 다 없으면 → myrev.jsp 로 바로 복귀
  if ((deleteResId == null || deleteResId.isEmpty()) &&
      (deleteWaitId == null || deleteWaitId.isEmpty())) {
    out.println("<p>ℹ️ 파라미터 없음 → myrev.jsp로 리다이렉트</p>");
    response.setHeader("Refresh", "1; URL=myrev.jsp");
    return;
  }

  // (2) “나의 예약” 취소 처리 & 알림 발송
  if (deleteResId != null && !deleteResId.isEmpty()) {
    int rid = Integer.parseInt(deleteResId);
    try (Connection conn = DriverManager.getConnection(url, usr, pwd)) {
      conn.setAutoCommit(false);

      // 2‑a) 슬롯 정보 조회
      int storeId = 0;
      Timestamp resDt = null;
      try (PreparedStatement ps = conn.prepareStatement(
             "SELECT reservation_store_id, reservation_datetime "
           + "  FROM reservation "
           + " WHERE reservation_id = ? AND reservation_user_id = ?"
         )) {
        ps.setInt(1, rid);
        ps.setString(2, userId);
        try (ResultSet rs = ps.executeQuery()) {
          if (rs.next()) {
            storeId = rs.getInt("reservation_store_id");
            resDt   = rs.getTimestamp("reservation_datetime");
          }
        }
      }
      out.println("<p>🔍 slotInfo → storeId=" + storeId + ", resDt=" + resDt + "</p>");

      // 2‑b) 상태만 CANCELLED 로 업데이트
      int updated = 0;
      try (PreparedStatement ps = conn.prepareStatement(
             "UPDATE reservation "
           + "   SET reservation_status='CANCELLED', "
           + "       reservation_cancel_reason='사용자 취소', "
           + "       reservation_updated_at=NOW() "
           + " WHERE reservation_id = ? AND reservation_user_id = ?"
         )) {
        ps.setInt(1, rid);
        ps.setString(2, userId);
        updated = ps.executeUpdate();
      }
      out.println("<p>✅ reservation UPDATE affected rows = " + updated + "</p>");
      if (updated == 0) {
        out.println("<p style='color:red;'>✋ UPDATE가 0건 입니다. reservation_id/user_id 확인 요망</p>");
      }

      // 2‑c) 본인에게 RESERVATION_CANCELLED 알림
      if (updated > 0) {
        try (PreparedStatement ps = conn.prepareStatement(
               "INSERT INTO notification "
             + "(notification_reservation_id, notification_type, notification_sent_at, notification_recipient) "
             + "VALUES (?, 'RESERVATION_CANCELLED', NOW(), ?)"
           )) {
          ps.setInt(1, rid);
          ps.setString(2, userId);
          ps.executeUpdate();
        }
        out.println("<p>✅ 알림 INSERT 완료(RESERVATION_CANCELLED)</p>");
      }

      // 2‑d) 대기 리스트 전체에게 SLOT_OPENED 알림
      if (updated > 0) {
        try (PreparedStatement ps = conn.prepareStatement(
               "SELECT user_id "
             + "  FROM waiting_list "
             + " WHERE store_id = ? AND waiting_datetime = ? AND status = 'WAITING'"
           )) {
          ps.setInt(1, storeId);
          ps.setTimestamp(2, resDt);
          try (ResultSet rs = ps.executeQuery()) {
            boolean any = false;
            while (rs.next()) {
              any = true;
              String waitUser = rs.getString(1);
              out.println("<p>⏱ waiting-user=" + waitUser + "</p>");

              // – 대기리스트 상태 업데이트
              try (PreparedStatement p2 = conn.prepareStatement(
                     "UPDATE waiting_list "
                   + "   SET status='OPENED', updated_at=NOW() "
                   + " WHERE store_id = ? AND waiting_datetime = ? AND user_id = ?"
                 )) {
                p2.setInt(1, storeId);
                p2.setTimestamp(2, resDt);
                p2.setString(3, waitUser);
                int w = p2.executeUpdate();
                out.println("<p>✅ waiting_list UPDATE rows=" + w + "</p>");
              }

              // – SLOT_OPENED 알림 생성
              try (PreparedStatement p3 = conn.prepareStatement(
                     "INSERT INTO notification "
                   + "(notification_reservation_id, notification_type, notification_sent_at, notification_recipient) "
                   + "VALUES (?, 'SLOT_OPENED', NOW(), ?)"
                 )) {
                p3.setInt(1, rid);
                p3.setString(2, waitUser);
                int s = p3.executeUpdate();
                out.println("<p>✅ SLOT_OPENED notify rows=" + s + "</p>");
              }
            }
            if (!any) {
              out.println("<p>ℹ️ waiting_list: 대기자가 없습니다.</p>");
            }
          }
        }
      }

      conn.commit();
      out.println("<p>🎉 트랜잭션 COMMIT 완료</p>");
    } catch (Exception e) {
      out.println("<pre style='color:red;'>");
      e.printStackTrace(new java.io.PrintWriter(out));
      out.println("</pre>");
      // 예외 시 커밋되지 않으므로 롤백된 상태입니다.
    }
    // PRG: 처리 후 myrev.jsp 로 리다이렉트
    out.println("<p>🔄 2초 후 myrev.jsp 로 돌아갑니다...</p>");
    response.setHeader("Refresh", "2; URL=myrev.jsp");
    return;
  }

  // (3) “대기 예약” 취소 처리
  if (deleteWaitId != null && !deleteWaitId.isEmpty()) {
    out.println("<p>🚀 deleteWaitId=" + deleteWaitId + "</p>");
    try (Connection conn = DriverManager.getConnection(url, usr, pwd);
         PreparedStatement ps = conn.prepareStatement(
           "DELETE FROM waiting_list WHERE wait_id = ? AND user_id = ?"
         )) {
      ps.setInt(1, Integer.parseInt(deleteWaitId));
      ps.setString(2, userId);
      int wdel = ps.executeUpdate();
      out.println("<p>✅ waiting_list DELETE rows = " + wdel + "</p>");
    } catch (Exception e) {
      out.println("<pre style='color:red;'>");
      e.printStackTrace(new java.io.PrintWriter(out));
      out.println("</pre>");
    }
    out.println("<p>🔄 2초 후 myrev.jsp 로 돌아갑니다...</p>");
    response.setHeader("Refresh", "2; URL=myrev.jsp");
    return;
  }
%>
