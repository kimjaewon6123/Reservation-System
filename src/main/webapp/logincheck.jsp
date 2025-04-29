<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="util.DBConnection" %>
<%@ page import="org.json.simple.*" %>

<%
    request.setCharacterEncoding("UTF-8");
    String userId = request.getParameter("user_id");
    String userPw = request.getParameter("user_password");

    if (userId == null || userPw == null || userId.trim().isEmpty() || userPw.trim().isEmpty()) {
        response.sendError(400, "아이디와 비밀번호를 입력해주세요.");
        return;
    }

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    JSONObject result = new JSONObject();

    try {
        conn = DBConnection.getConnection();
        String sql = "SELECT user_id, user_name, user_status FROM user WHERE user_id = ? AND user_password = ? AND user_status = 'ACTIVE'";
        ps = conn.prepareStatement(sql);
        ps.setString(1, userId);
        ps.setString(2, userPw);
        rs = ps.executeQuery();

        if (rs.next()) {
            session.setAttribute("user_id", rs.getString("user_id"));
            session.setAttribute("user_name", rs.getString("user_name"));
            
            result.put("success", true);
            result.put("user_id", rs.getString("user_id"));
            result.put("user_name", rs.getString("user_name"));
        } else {
            result.put("success", false);
            result.put("message", "아이디 또는 비밀번호가 일치하지 않습니다.");
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
