<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.net.URLEncoder" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
  <title>검색 결과</title>
  <link rel="stylesheet" href="css/global.css" />
  <link rel="stylesheet" href="css/styleguide.css" />
  <style>
    .screen {
      background-color: #ffffff;
      display: flex;
      flex-direction: row;
      justify-content: center;
      width: 100%;
    }

    .screen .div {
      background-color: #ffffff;
      overflow: hidden;
      width: 375px;
      height: 812px;
      position: relative;
      border-radius: 30px;
      box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
    }

    .screen .overlap {
      position: absolute;
      width: 375px;
      height: 812px;
      top: 0;
      left: 0;
    }

    .screen .status-bars {
      display: inline-flex;
      flex-direction: column;
      align-items: flex-start;
      gap: 10px;
      padding: 3px 0px 0px;
      position: absolute;
      top: 0;
      left: 0;
    }

    .screen .statusbar-ios {
      position: relative;
      width: 390px;
      height: 47px;
    }

    .screen .left-side {
      position: absolute;
      width: 54px;
      height: 21px;
      top: 14px;
      left: 27px;
    }

    .screen .statusbars-time {
      position: relative;
      height: 21px;
      border-radius: 24px;
    }

    .screen .time {
      position: absolute;
      width: 54px;
      top: 1px;
      left: 0;
      font-family: var(--body-bold-font-family);
      font-weight: var(--body-bold-font-weight);
      color: var(--label-colorlightprimary);
      font-size: var(--body-bold-font-size);
      text-align: center;
      letter-spacing: var(--body-bold-letter-spacing);
      line-height: var(--body-bold-line-height);
      white-space: nowrap;
      font-style: var(--body-bold-font-style);
    }

    .screen .right-side {
      position: absolute;
      width: 78px;
      height: 13px;
      top: 19px;
      left: 286px;
    }

    .screen .icon-mobile-signal {
      position: absolute;
      width: 18px;
      height: 12px;
      top: 0;
      left: 0;
    }

    .screen .wifi {
      position: absolute;
      width: 17px;
      height: 12px;
      top: 0;
      left: 26px;
    }

    .screen .statusbar-battery {
      position: absolute;
      width: 27px;
      height: 13px;
      top: 0;
      left: 51px;
    }

    .content-area {
      position: absolute;
      top: 47px;
      height: calc(100% - 127px); /* 전체 높이에서 상단(47px)과 네비게이션 바(80px) 높이를 뺌 */
      left: 0;
      right: 0;
      padding: 20px 16px;
      overflow-y: auto;
      -webkit-overflow-scrolling: touch;
      background-color: #ffffff;
    }

    h1 {
      font-size: 20px;
      font-weight: 800;
      color: #8d4bf6;
      margin: 0 0 20px;
      font-family: "Pretendard-ExtraBold";
    }

    .store-result {
      background: linear-gradient(145deg, #ffffff, #fcfaff);
      border-radius: 16px;
      margin: 16px 0;
      padding: 20px;
      box-shadow: 0 4px 16px rgba(138, 43, 226, 0.08);
      transition: all 0.3s ease;
      border: 1px solid rgba(138, 43, 226, 0.05);
    }

    .store-result:hover {
      transform: translateY(-2px);
      box-shadow: 0 6px 20px rgba(138, 43, 226, 0.12);
      background: linear-gradient(145deg, #fcfaff, #f3f0ff);
    }

    .store-result h2 {
      font-size: 16px;
      font-weight: 600;
      color: #495057;
      margin: 0 0 12px;
      transition: color 0.3s ease;
    }

    .store-result:hover h2 {
      color: #8a2be2;
    }

    .store-result p {
      font-size: 13px;
      color: #868e96;
      margin: 8px 0;
      line-height: 1.5;
      display: flex;
      align-items: center;
    }

    .store-result p::before {
      content: "•";
      color: #9775fa;
      margin-right: 8px;
      font-size: 16px;
    }

    .store-link {
      text-decoration: none;
      color: inherit;
      display: block;
    }

    .no-results {
      text-align: center;
      padding: 40px 20px;
      color: #868e96;
    }

    .no-results img {
      width: 120px;
      height: 120px;
      margin-bottom: 16px;
      opacity: 0.7;
    }

    .no-results p {
      font-size: 14px;
      line-height: 1.6;
      color: #868e96;
    }

    .group {
      display: none;
    }

    .content-area::-webkit-scrollbar {
      display: none;
    }

    /* 하단 네비게이션 스타일 수정 */
    .nav-wrapper {
      position: absolute;
      bottom: 0;
      left: 50%;
      transform: translateX(-50%);
      width: 375px;
      height: 80px;
      display: flex;
      justify-content: space-around;
      align-items: center;
      padding: 0 8px;
      background: #ffffff;
      border-top: 1px solid #f0f0f0;
      z-index: 1000;
      border-radius: 0 0 30px 30px;
    }

    .nav-item {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 6px;
      cursor: pointer;
      transition: all 0.3s ease;
      padding: 8px;
    }

    .nav-item img {
      width: 24px;
      height: 24px;
      opacity: 0.5;
      transition: all 0.3s ease;
    }

    .nav-item:hover img {
      opacity: 1;
    }

    .nav-label {
      font-size: 10px;
      color: #666;
      text-align: center;
    }
  </style>
</head>
<body>
  <div class="screen">
    <div class="div">
      <div class="overlap">
        <!-- 상태바 -->
        <div class="status-bars">
          <div class="statusbar-ios">
            <div class="left-side">
              <div class="statusbars-time">
                <div class="time">9:41</div>
              </div>
            </div>
            <div class="right-side">
              <img class="icon-mobile-signal" src="img/ㅊㅊㅊㅍㅍ.png" alt="신호" />
              <img class="wifi" src="img/ㅊㅊㅊㅊ.png" alt="와이파이" />
              <div class="statusbar-battery">
                <div class="overlap-group">
                  <img class="outline" src="img/ㅊㅌ.png" alt="배터리" />
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 검색 결과 영역 -->
        <div class="content-area">
          <h1>검색 결과</h1>
          <%
            String query = request.getParameter("query");
            if(query == null || query.trim().isEmpty()){
          %>
              <div class="no-results">
                <img src="images/search-empty.svg" alt="검색어 없음" />
                <p>검색어를 입력해주세요</p>
              </div>
          <%
            } else {
              Connection conn = null;
              PreparedStatement pstmt = null;
              ResultSet rs = null;
              try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/scrs", "root", "mysql123");
                String sql = "SELECT store_name, store_category, store_address, store_phone, store_hours FROM store WHERE store_name LIKE ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, "%" + query + "%");
                rs = pstmt.executeQuery();
                boolean found = false;
                while(rs.next()){
                  found = true;
                  String name = rs.getString("store_name");
                  String category = rs.getString("store_category");
                  String address = rs.getString("store_address");
                  String phone = rs.getString("store_phone");
                  String hours = rs.getString("store_hours");
                  String encoded = URLEncoder.encode(name, "UTF-8");
          %>
                  <a href="service.jsp?storeName=<%= encoded %>" class="store-link">
                    <div class="store-result">
                      <h2><%= name %></h2>
                      <p>카테고리: <%= category %></p>
                      <p>주소: <%= address %></p>
                      <p>전화번호: <%= phone %></p>
                      <p>영업시간: <%= hours %></p>
                    </div>
                  </a>
          <%
                }
                if(!found){
          %>
                  <div class="no-results">
                    <img src="images/no-results.svg" alt="검색 결과 없음" />
                    <p>'<%= query %>'에 대한<br>검색 결과가 없습니다</p>
                  </div>
          <%
                }
              } catch(Exception e) {
          %>
                <div class="no-results">
                  <img src="images/error.svg" alt="오류 발생" />
                  <p>오류가 발생했습니다<br><%= e.getMessage() %></p>
                </div>
          <%
              } finally {
                if(rs != null) rs.close();
                if(pstmt != null) pstmt.close();
                if(conn != null) conn.close();
              }
            }
          %>
        </div>

        <!-- 하단 네비게이션 -->
        <div class="nav-wrapper">
          <div class="nav-item" onclick="location.href='index.jsp'">
            <img src="img/home.png" alt="홈">
            <div class="nav-label">홈</div>
          </div>
          <div class="nav-item" onclick="location.href='feed.jsp'">
            <img src="img/cxxc.png" alt="피드">
            <div class="nav-label">피드</div>
          </div>
          <div class="nav-item" onclick="location.href='map.html'">
            <img src="img/map.png" alt="내주변">
            <div class="nav-label">내주변</div>
          </div>
          <div class="nav-item" onclick="location.href='myrev.jsp'">
            <img src="img/rev.png" alt="예약">
            <div class="nav-label">예약</div>
          </div>
          <div class="nav-item" onclick="location.href='mypage.jsp'">
            <img src="img/my.png" alt="마이">
            <div class="nav-label">마이</div>
          </div>
        </div>
      </div>
    </div>
  </div>
</body>
</html>
