<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String userName = (String) session.getAttribute("userName");
    if (userName == null) {
        response.sendRedirect("login.html");
        return;
    }
%>
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8" />
    <link rel="stylesheet" href="css/global.css" />
    <link rel="stylesheet" href="css/styleguide.css" />
    <link rel="stylesheet" href="css/mypagestyle.css" />
    <style>
      html, body {
        height: 100%;
        margin: 0;
        padding: 0;
        font-family: 'Pretendard', sans-serif;
      }

      .screen {
        height: 100%;
        position: relative;
      }

      .div {
        position: relative;
        width: 100%;
        max-width: 375px;
        height: 812px;
        margin: 0 auto;
        background-color: #ffffff;
        border-radius: 30px;
        overflow: hidden;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
      }

      /* 상단 상태바 */
      .status-bars {
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        z-index: 1000;
        background: #ffffff;
        border-radius: 30px 30px 0 0;
      }

      .statusbar-ios {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 14px 24px 12px;
        background: #ffffff;
      }

      /* 프로필 섹션 */
      .profile-section {
        position: absolute;
        top: 48px;
        left: 0;
        right: 0;
        padding: 24px;
        background: linear-gradient(135deg, #8d4bf6 0%, #6a2db8 100%);
        color: white;
        z-index: 100;
      }

      .profile-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 20px;
      }

      .profile-title {
        font-size: 24px;
        font-weight: 600;
      }

      .profile-edit {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 14px;
        opacity: 0.9;
        cursor: pointer;
      }

      .profile-info {
        display: flex;
        align-items: center;
        gap: 16px;
      }

      .profile-image {
        width: 64px;
        height: 64px;
        border-radius: 50%;
        background: #ffffff;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 24px;
        color: #8d4bf6;
      }

      .profile-details {
        flex: 1;
      }

      .profile-name {
        font-size: 20px;
        font-weight: 600;
        margin-bottom: 4px;
      }

      .profile-email {
        font-size: 14px;
        opacity: 0.8;
      }

      /* 메인 컨텐츠 */
      .main-content {
        position: absolute;
        top: 200px;
        left: 0;
        right: 0;
        bottom: 80px;
        overflow-y: auto;
        padding: 24px;
        background: #ffffff;
      }

      /* 쿠폰/이벤트 섹션 */
      .benefits-section {
        display: flex;
        gap: 12px;
        margin-top: 20px;
        margin-bottom: 24px;
      }

      .benefit-card {
        flex: 1;
        background: white;
        border-radius: 16px;
        padding: 16px;
        text-align: center;
        box-shadow: 0 2px 8px rgba(0,0,0,0.05);
      }

      .benefit-count {
        font-size: 24px;
        font-weight: 600;
        color: #8d4bf6;
        margin-bottom: 4px;
      }

      .benefit-label {
        font-size: 14px;
        color: #666;
      }

      /* 메뉴 섹션 */
      .menu-section {
        background: white;
        border-radius: 16px;
        padding: 20px;
        margin-bottom: 24px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.05);
      }

      .menu-title {
        font-size: 18px;
        font-weight: 600;
        margin-bottom: 16px;
        color: #333;
      }

      .menu-list {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        gap: 16px;
      }

      .menu-item {
        display: flex;
        align-items: center;
        gap: 12px;
        padding: 12px;
        border-radius: 12px;
        background: #f8f8f8;
        cursor: pointer;
        transition: all 0.2s ease;
      }

      .menu-item:hover {
        background: #f0f0f0;
        transform: translateY(-2px);
      }

      .menu-item img {
        width: 24px;
        height: 24px;
        opacity: 0.7;
      }

      .menu-item span {
        font-size: 14px;
        color: #333;
      }

      /* 하단 네비게이션 */
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
        transition: transform 0.2s ease;
      }

      .nav-item:hover {
        transform: translateY(-3px);
      }

      .nav-item img {
        width: 24px;
        height: 24px;
        opacity: 0.5;
        transition: all 0.2s ease;
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
        transition: color 0.2s ease;
      }

      .nav-item:hover .nav-label {
        color: #8d4bf6;
      }
    </style>
  </head>
  <body>
    <div class="screen">
      <div class="div">
        <!-- 상단 상태바 -->
        <div class="status-bars">
          <div class="statusbar-ios">
            <div class="left-side">
              <div class="time">9:41</div>
            </div>
            <div class="right-side">
              <img src="img/ㅊㅊㅊㅍㅍ.png" alt="신호" />
              <img src="img/ㅊㅊㅊㅊ.png" alt="와이파이" />
              <div class="statusbar-battery">
                <div class="overlap-group">
                  <img class="outline" src="img/ㅊㅌ.png" alt="배터리" />
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 프로필 섹션 -->
        <div class="profile-section">
          <div class="profile-header">
            <div class="profile-title">마이페이지</div>
            <div class="profile-edit">
              <span>프로필 수정</span>
              <img src="img/ㅍ.png" alt="편집" style="width: 16px; height: 16px;" />
            </div>
          </div>
          <div class="profile-info">
            <div class="profile-image">
              <%= (userName != null && userName.length() > 0) ? userName.substring(0,1) : "U" %>
            </div>
            <div class="profile-details">
              <div class="profile-name"><%= userName %></div>
              <div class="profile-email">user@example.com</div>
            </div>
          </div>
        </div>

        <!-- 메인 컨텐츠 -->
        <div class="main-content">
          <!-- 쿠폰/이벤트 섹션 -->
          <div class="benefits-section">
            <div class="benefit-card">
              <div class="benefit-count">2</div>
              <div class="benefit-label">나의 리뷰</div>
            </div>
            <div class="benefit-card">
              <div class="benefit-count">5000</div>
              <div class="benefit-label">포인트</div>
            </div>
          </div>

          <!-- 나의 메뉴 -->
          <div class="menu-section">
            <div class="menu-title">나의 메뉴</div>
            <div class="menu-list">
              <a href="myrev.jsp" class="menu-item" style="text-decoration: none;">
                <img src="img/666.png" alt="예약" />
                <span>예약 현황</span>
              </a>
              <div class="menu-item">
                <img src="img/333.png" alt="관심" />
                <span>관심 매장</span>
              </div>
              <div class="menu-item">
                <img src="img/66.png" alt="알림" />
                <span>알림 설정</span>
              </div>
              <div class="menu-item">
                <img src="img/33333.png" alt="쿠폰" />
                <span>쿠폰함</span>
              </div>
            </div>
          </div>

          <!-- 고객센터 -->
          <div class="menu-section">
            <div class="menu-title">고객센터</div>
            <div class="menu-list">
              <div class="menu-item">
                <img src="img/3333.png" alt="공지" />
                <span>공지사항</span>
              </div>
              <div class="menu-item">
                <img src="img/33.png" alt="문의" />
                <span>문의하기</span>
              </div>
              <div class="menu-item">
                <img src="img/333.png" alt="입점" />
                <span>입점문의</span>
              </div>
              <a href="logout.jsp" class="menu-item" style="text-decoration: none;">
                <img src="img/ss.png" alt="로그아웃" />
                <span>로그아웃</span>
              </a>
            </div>
          </div>
        </div>

        <!-- 하단 네비게이션 -->
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
              <img src="img/rev.png" alt="예약" />
              <div class="nav-label">예약</div>
            </div>
            <div class="nav-item" onclick="location.href='mypage.jsp'">
              <img src="img/my.png" alt="마이" class="active" />
              <div class="nav-label">마이</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </body>
</html>
