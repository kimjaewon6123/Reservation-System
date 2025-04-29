<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="util.DBConnection" %>
<%@ page import="org.json.simple.*" %>

<%
    // 세션 체크
    String userId = (String) session.getAttribute("user_id");
    if (userId == null || userId.trim().isEmpty()) {
        response.sendError(401, "로그인이 필요합니다.");
        return;
    }

    String action = request.getParameter("action");
    String notificationId = request.getParameter("notification_id");

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    JSONObject result = new JSONObject();

    try {
        conn = DBConnection.getConnection();

        if ("list".equals(action)) {
            // 알림 목록 조회
            String sql = "SELECT n.*, r.reservation_datetime, s.store_name " +
                        "FROM notification n " +
                        "LEFT JOIN reservation r ON n.notification_reservation_id = r.reservation_id " +
                        "LEFT JOIN store s ON r.reservation_store_id = s.store_id " +
                        "WHERE n.notification_recipient = ? " +
                        "ORDER BY n.notification_sent_at DESC";
            
            ps = conn.prepareStatement(sql);
            ps.setString(1, userId);
            rs = ps.executeQuery();

            JSONArray notifications = new JSONArray();
            while (rs.next()) {
                JSONObject notification = new JSONObject();
                notification.put("id", rs.getInt("notification_id"));
                notification.put("type", rs.getString("notification_type"));
                notification.put("content", rs.getString("notification_content"));
                notification.put("sent_at", rs.getTimestamp("notification_sent_at").toString());
                notification.put("status", rs.getString("notification_status"));
                notification.put("store_name", rs.getString("store_name"));
                if (rs.getTimestamp("reservation_datetime") != null) {
                    notification.put("reservation_datetime", rs.getTimestamp("reservation_datetime").toString());
                }
                notifications.add(notification);
            }
            result.put("notifications", notifications);

        } else if ("delete".equals(action) && notificationId != null) {
            // 알림 삭제
            String sql = "DELETE FROM notification WHERE notification_id = ? AND notification_recipient = ?";
            ps = conn.prepareStatement(sql);
            ps.setString(1, notificationId);
            ps.setString(2, userId);
            int deleted = ps.executeUpdate();
            
            result.put("success", deleted > 0);
            result.put("message", deleted > 0 ? "알림이 삭제되었습니다." : "알림 삭제에 실패했습니다.");

        } else if ("read".equals(action) && notificationId != null) {
            // 알림 읽음 처리
            String sql = "UPDATE notification SET notification_status = 'READ' WHERE notification_id = ? AND notification_recipient = ?";
            ps = conn.prepareStatement(sql);
            ps.setString(1, notificationId);
            ps.setString(2, userId);
            int updated = ps.executeUpdate();
            
            result.put("success", updated > 0);
            result.put("message", updated > 0 ? "알림이 읽음 처리되었습니다." : "알림 상태 변경에 실패했습니다.");

        } else {
            response.sendError(400, "잘못된 요청입니다.");
            return;
        }

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        out.print(result.toJSONString());

    } catch (Exception e) {
        response.sendError(500, "서버 오류가 발생했습니다: " + e.getMessage());
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) { }
        if (ps != null) try { ps.close(); } catch (SQLException e) { }
        if (conn != null) try { conn.close(); } catch (SQLException e) { }
    }
%>
