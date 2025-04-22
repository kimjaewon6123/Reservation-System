<%@ page contentType="application/json; charset=UTF-8" %>
<%@ page import="org.json.JSONObject" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    JSONObject json = new JSONObject();
    String userId = (String) session.getAttribute("user_id");
    
    json.put("loggedIn", userId != null && !userId.trim().isEmpty());
    if (userId != null && !userId.trim().isEmpty()) {
        json.put("userId", userId);
    }
    
    out.print(json.toString());
%> 