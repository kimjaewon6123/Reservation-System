<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%
  // (0) 로그인 체크
  String userId = (String) session.getAttribute("user_id");
  if (userId == null || userId.trim().isEmpty()) {
    response.sendRedirect("login.html");
    return;
  }

  // DB 접속 정보
  String dbURL  = "jdbc:mysql://localhost:3306/scrs";
  String dbUser = "root", dbPass = "mysql123";

  // (1) 알림 + 매장·예약정보 조회
  List<Map<String,Object>> notifies = new ArrayList<>();
  try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    try (
      Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPass);
      PreparedStatement ps = conn.prepareStatement(
        "SELECT n.notification_id, n.notification_type, n.notification_sent_at,  " +
        "       r.reservation_datetime, s.store_name, r.reservation_status       " +
        "  FROM notification AS n                                          " +
        "  LEFT JOIN reservation AS r                                      " +
        "    ON n.notification_reservation_id = r.reservation_id           " +
        "  LEFT JOIN store AS s                                            " +
        "    ON r.reservation_store_id = s.store_id                        " +
        " WHERE n.notification_recipient = ?                              " +
        " ORDER BY n.notification_sent_at DESC"
      )
    ) {
      ps.setString(1, userId);
      try (ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
          Map<String,Object> m = new HashMap<>();
          m.put("nid",   rs.getInt      ("notification_id"));
          m.put("typ",   rs.getString   ("notification_type"));
          m.put("ts",    rs.getTimestamp("notification_sent_at"));
          m.put("dt",    rs.getTimestamp("reservation_datetime"));
          m.put("store", rs.getString   ("store_name"));
          m.put("status", rs.getString  ("reservation_status"));
          notifies.add(m);
        }
      }
    }
  } catch(Exception e) {
    e.printStackTrace();
  }

  // (2) 삭제 요청 처리
  String del = request.getParameter("delN");
  if (del != null && !del.isEmpty()) {
    try (
      Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPass);
      PreparedStatement dps = conn.prepareStatement(
        "DELETE FROM notification WHERE notification_id = ?"
      )
    ) {
      dps.setInt(1, Integer.parseInt(del));
      dps.executeUpdate();
      response.sendRedirect("notify.jsp");
      return;
    } catch(Exception e) {
      e.printStackTrace();
    }
  }
%>
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8" />
    <title>내 알림</title>
    <link rel="stylesheet" href="css/global.css" />
    <link rel="stylesheet" href="css/styleguide.css" />
    <link rel="stylesheet" href="css/mapstyle.css" />
    <style>
      .notify-container {
        position: absolute; top: 70px; left: 0; width: 100%;
        padding: 8px 12px; background: #fafafa;
        max-height: 200px; overflow-y: auto; box-sizing: border-box;
      }
      .notify-item {
        margin-bottom: 6px; padding: 6px 8px;
        border: 1px solid #ddd; border-radius: 4px;
        background: #fff;
      }
      .notify-item:last-child { margin-bottom: 0; }
      .notify-msg { font-size: 13px; margin-bottom: 4px; }
      .notify-time { font-size: 11px; color: #999; }
      .notify-delete-btn {
        font-size: 11px; padding: 2px 4px;
        background: transparent; border: none;
        color: #999; cursor: pointer;
      }
      .notify-delete-btn:hover { color: #e74c3c; }
    </style>
  </head>
  <body>
    <div class="screen">
      <div class="div">

        <!-- (1) 상단 상태바 -->
        <div class="overlap">
          <div class="status-bars">
            <div class="statusbar-ios">
              <div class="left-side">
                <div class="statusbars-time"><div class="time">9:41</div></div>
              </div>
              <div class="right-side">
                <img class="icon-mobile-signal" src="img/ㅊㅊㅊㅍㅍ.png" alt="신호" />
                <img class="wifi"               src="img/ㅊㅊㅊㅊ.png" alt="와이파이" />
                <div class="statusbar-battery">
                  <div class="overlap-group-2">
                    <img class="outline" src="img/ㅊㅌ.png" alt="배터리 외곽" />
                    <div class="percentage"></div>
                  </div>
                  <img class="battery-end" src="img/battery-end.svg" alt="배터리 끝" />
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- (2) 알림 리스트 영역 -->
        <div class="notify-container">
          <h3 style="margin:0 0 6px;font-size:14px;">📢 내 알림</h3>
          <%
            if (notifies.isEmpty()) {
          %>
            <p style="margin:0;color:#666;font-size:12px;">새 알림이 없습니다.</p>
          <%
            } else {
              for (Map<String,Object> n : notifies) {
                int       nid   = (int)       n.get("nid");
                String    typ   = (String)    n.get("typ");
                Timestamp ts    = (Timestamp) n.get("ts");
                Timestamp dt    = (Timestamp) n.get("dt");
                String    store = (String)    n.get("store");
                String    msg;
                
                if ("OPEN".equals(typ)) {
                  msg = String.format(
                    "🔔 %s 매장의 %2$tY년 %2$tm월 %2$td일 %2$tH시 %2$tM분 예약이 가능해졌습니다!",
                    store, dt
                  );
                } else if ("CANCEL".equals(typ)) {
                  msg = String.format(
                    "❌ %s 매장의 %2$tY년 %2$tm월 %2$td일 %2$tH시 %2$tM분 예약이 취소되었습니다.",
                    store, dt
                  );
                } else if ("WAITING".equals(typ)) {
                  msg = String.format(
                    "⏳ %s 매장의 %2$tY년 %2$tm월 %2$td일 %2$tH시 %2$tM분 예약 대기가 등록되었습니다.",
                    store, dt
                  );
                } else if ("CONFIRMED".equals(typ)) {
                  msg = String.format(
                    "✅ %s 매장의 %2$tY년 %2$tm월 %2$td일 %2$tH시 %2$tM분 예약이 확정되었습니다.",
                    store, dt
                  );
                } else {
                  msg = "알림(" + typ + ")";
                }
          %>
            <div class="notify-item">
              <div class="notify-msg"><%= msg %></div>
              <div class="notify-time"><%= ts %></div>
              <form method="post" action="notify.jsp" style="text-align:right;margin:0;">
                <input type="hidden" name="delN" value="<%= nid %>"/>
                <button type="submit" class="notify-delete-btn">삭제</button>
              </form>
            </div>
          <%
              }
            }
          %>
        </div>

        <!-- (3) 하단 네비게이션 -->
        <div class="group">
          <div class="overlap-2">
            <div class="group-wrapper">
              <div class="group-2">
                <img class="vector"   onclick="location.href='index.jsp'"  src="img/home.png"  alt="홈"/>
                <img class="img"      onclick="location.href='myrev.jsp'" src="img/rev.png"   alt="피드"/>
                <img class="vector-2" onclick="location.href='mypage.jsp'" src="img/my.png"    alt="마이"/>
                <img class="vector-3" onclick="location.href='map.jsp'"    src="img/mmap.png"  alt="지도"/>
                <div class="text-wrapper">홈</div>
                <div class="text-wrapper-2">피드</div>
                <div class="text-wrapper-3">내주변</div>
                <div class="text-wrapper-4">예약</div>
                <div class="text-wrapper-5">마이</div>
              </div>
            </div>
            <div class="solar-feed-bold">
              <img class="vector-4" src="img/cxxc.png" alt="기타"/>
            </div>
          </div>
        </div>

      </div>
    </div>
  </body>
</html>
