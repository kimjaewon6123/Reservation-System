<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%
request.setCharacterEncoding("UTF-8");

String userId = request.getParameter("userId");
String userPw = request.getParameter("userPw");

String dbURL = "jdbc:mysql://localhost:3306/scrs";
String dbUser = "root";
String dbPass = "mysql123";

Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection(dbURL, dbUser, dbPass);
    String sql = "SELECT user_name FROM user WHERE user_id = ? AND user_password = ?";
    pstmt = conn.prepareStatement(sql);
    pstmt.setString(1, userId);
    pstmt.setString(2, userPw);
    rs = pstmt.executeQuery();

    if (rs.next()) {
        String userName = rs.getString("user_name");

        // 세션 저장: 다른 페이지와 일치하도록 "user_id" 키 사용
        session.setAttribute("user_id", userId);
        session.setAttribute("userName", userName);
%>
        <script>
          // localStorage에도 필요한 정보를 저장 (키 이름도 일관되게)
          localStorage.setItem("isLoggedIn", "true");
          localStorage.setItem("userName", "<%= userName %>");
          localStorage.setItem("userId", "<%= userId %>");
          window.location.href = "index.jsp";
        </script>
<%
    } else {
%>
        <script>
          alert("로그인 실패: 아이디 또는 비밀번호가 틀렸습니다.");
          window.location.href = "login.html";
        </script>
<%
    }
} catch (Exception e) {
    out.println("오류 발생: " + e.getMessage());
    e.printStackTrace();
} finally {
    if (rs != null) rs.close();
    if (pstmt != null) pstmt.close();
    if (conn != null) conn.close();
}
%>
