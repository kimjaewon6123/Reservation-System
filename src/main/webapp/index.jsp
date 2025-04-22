<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*" %>
<%
  // (0) 세션에서 user_id 가져오기
  String userId = (String) session.getAttribute("user_id");
  boolean logged = (userId != null && !userId.trim().isEmpty());

  // (1) 알림 개수 조회
  String notifyCount = "0";
  if (logged) {
    Class.forName("com.mysql.cj.jdbc.Driver");
    try ( Connection conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/scrs", "root", "mysql123");
          PreparedStatement ps = conn.prepareStatement(
            "SELECT COUNT(*) FROM notification WHERE notification_recipient = ?") ) {
      ps.setString(1, userId);
      try ( ResultSet rs = ps.executeQuery() ) {
        if (rs.next()) notifyCount = rs.getString(1);
      }
    }
  }
%>
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no" />
    <title>Index Page with Overlaid Search</title>
    <link rel="stylesheet" href="css/global.css" />
    <link rel="stylesheet" href="css/styleguide.css" />
    <link rel="stylesheet" href="css/style.css" />
    <link rel="stylesheet" href="css/animations.css" />
    <style>
      /* ============== 뱃지 스타일만 추가 ============== */
      .notify-badge {
        position: absolute;
        top: -4px;
        right: -4px;
        background: #e74c3c;
        color: #fff;
        border-radius: 50%;
        padding: 2px 5px;
        font-size: 10px;
        line-height: 1;
        font-family: Helvetica, sans-serif;
      }

      /* 하단 네비게이션 스타일 */
      .nav-container {
        position: absolute;
        bottom: 0;
        left: 0;
        width: 100%;
        max-width: 375px;
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

      .div-wrapper {
        padding: 20px;
        width: 100%;
        display: flex;
        justify-content: center;
        min-height: 100vh;
        background-color: #ffffff;
      }

      .div-wrapper .div {
        background-color: #ffffff;
        overflow-y: auto;
        width: 100%;
        max-width: 375px;
        height: 812px;
        position: relative;
        border-radius: 30px;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
        margin-top: 0;
      }

      .div, .overlap-wrapper {
        background-color: #ffffff;
        width: 100%;
        max-width: 375px;
        height: 812px;
        position: relative;
        border-radius: 30px;
        overflow-y: auto;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
      }

      /* 스크롤바 스타일 */
      .div-wrapper .div::-webkit-scrollbar,
      .div::-webkit-scrollbar,
      .overlap-wrapper::-webkit-scrollbar {
        width: 6px;
      }

      .div-wrapper .div::-webkit-scrollbar-track,
      .div::-webkit-scrollbar-track,
      .overlap-wrapper::-webkit-scrollbar-track {
        background: transparent;
      }

      .div-wrapper .div::-webkit-scrollbar-thumb,
      .div::-webkit-scrollbar-thumb,
      .overlap-wrapper::-webkit-scrollbar-thumb {
        background: rgba(0, 0, 0, 0.1);
        border-radius: 3px;
      }

      .div-wrapper .div::-webkit-scrollbar-thumb:hover,
      .div::-webkit-scrollbar-thumb:hover,
      .overlap-wrapper::-webkit-scrollbar-thumb:hover {
        background: rgba(0, 0, 0, 0.2);
      }

      .group {
        position: absolute;
        bottom: 0;
        left: 0;
        right: 0;
        background: #ffffff;
        border-top: 1px solid #f0f0f0;
        border-radius: 0 0 30px 30px;
        z-index: 1000;
      }

      .group-2 {
        display: flex;
        justify-content: space-around;
        align-items: center;
        height: 80px;
      }

      .group-2 img {
        width: 24px;
        height: 24px;
        opacity: 0.5;
        cursor: pointer;
      }

      .group-2 img.active,
      .group-2 img:hover {
        opacity: 1;
      }

      .text-label {
        font-size: 10px;
        color: #666;
        text-align: center;
        margin-top: 4px;
      }

      .screen {
        background-color: #ffffff;
        display: flex;
        flex-direction: row;
        justify-content: center;
        width: 100%;
      }

      .screen .div {
        background-color: #ffffff;
        width: 375px;
        height: 812px;
        position: relative;
        overflow: hidden;
        border-radius: 30px;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
      }

      html, body {
        height: 100%;
        margin: 0;
        padding: 0;
        background-color: #ffffff;
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

      .left-side {
        display: flex;
        align-items: center;
      }

      .right-side {
        display: flex;
        align-items: center;
        gap: 5px;
      }

      .right-side img {
        height: 11px;
        width: auto;
      }

      .time {
        font-family: 'SF Pro Text', sans-serif;
        font-size: 15px;
        font-weight: 600;
        color: #000000;
      }

      /* 하단 네비게이션 */
      .group {
        position: absolute;
        bottom: 0;
        left: 0;
        right: 0;
        background: #ffffff;
        border-top: 1px solid #f0f0f0;
        border-radius: 0 0 30px 30px;
        z-index: 1000;
      }

      .group-2 {
        display: flex;
        justify-content: space-around;
        align-items: center;
        height: 80px;
      }

      .group-2 img {
        width: 24px;
        height: 24px;
        opacity: 0.5;
        cursor: pointer;
      }

      .group-2 img.active,
      .group-2 img:hover {
        opacity: 1;
      }

      .text-label {
        font-size: 10px;
        color: #666;
        text-align: center;
        margin-top: 4px;
      }

      /* 배너 컨테이너 수정 */
      .banner-section {
        position: relative;
        width: 100%;
        padding: 0 10px;
        margin-top: 140px;
      }

      .banner-container {
        position: relative;
        width: 100%;
        height: 180px;
        border-radius: 15px;
        overflow: hidden;
        background-color: #f5f5f5;
        max-width: 100%;
      }

      .banner-item {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        opacity: 0;
        transition: opacity 0.5s ease;
        pointer-events: none;
      }

      .banner-item.active {
        opacity: 1;
        pointer-events: auto;
      }

      .banner-item img {
        width: 100%;
        height: 100%;
        object-fit: cover;
        border-radius: 15px;
      }

      .banner-dots {
        display: flex;
        justify-content: center;
        gap: 8px;
        margin-top: 16px;
      }

      .banner-dot {
        width: 6px;
        height: 6px;
        background-color: rgba(141, 75, 246, 0.3);
        border-radius: 50%;
        cursor: pointer;
        transition: all 0.3s ease;
      }

      .banner-dot.active {
        width: 18px;
        border-radius: 3px;
        background-color: #8d4bf6;
      }

      /* 전국 텍스트 관련 스타일 */
      .text-wrapper-21 {
        margin-bottom: 5px;
      }

      .group-3 {
        position: relative;
        padding-left: 20px;
        margin-top: 0;
      }

      /* 스크롤 가능한 콘텐츠 영역 */
      .content-area {
        position: absolute;
        top: 0; /* 상단에 붙임 */
        left: 0;
        right: 0;
        bottom: 80px; /* 하단 네비게이션 바 높이 */
        overflow-y: auto;
        padding: 20px;
        background-color: #ffffff; /* 배경색을 흰색으로 변경 */
        -webkit-overflow-scrolling: touch; /* iOS에서 부드러운 스크롤을 위한 설정 */
        scroll-behavior: smooth; /* 부드러운 스크롤 효과 */
        z-index: 1; /* 상태바 아래에 위치하도록 z-index 설정 */
      }

      /* 로딩 인디케이터 */
      .loading-indicator {
        text-align: center;
        padding: 20px 0;
        display: none;
        background-color: rgba(255, 255, 255, 0.9);
        border-radius: 12px;
        margin: 10px 0;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
      }
      
      .loading-spinner {
        display: inline-block;
        width: 30px;
        height: 30px;
        border: 4px solid rgba(141, 75, 246, 0.2);
        border-radius: 50%;
        border-top-color: #8d4bf6;
        animation: spin 1s ease-in-out infinite;
      }
      
      .loading-text {
        display: block;
        margin-top: 10px;
        color: #8d4bf6;
        font-size: 14px;
        font-weight: 500;
      }
      
      @keyframes spin {
        to { transform: rotate(360deg); }
      }
    </style>
  </head>
  <body>
    <!-- 로딩 애니메이션 -->
    <div class="loading-overlay">
      <div class="loading-spinner"></div>
    </div>
    
    <!-- 페이지 전환 효과 -->
    <div class="page-transition"></div>
    
    <div class="div-wrapper">
      <div class="div">
        <!-- (3) 상단 상태바 -->
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

        <!-- 스크롤 가능한 콘텐츠 영역 -->
        <div class="content-area" id="content-container">
          <!-- (1) 사이드 보라색 배경바, 예비 페이지 버튼 -->
          <button onclick="location.href='hairshop.html'" style="all:unset; cursor:pointer;">
            <div class="overlap">
              <img class="image" src="img/Group 568.png" alt="헤어샵 이동" />
            </div>
          </button>
          <button onclick="location.href='prepare.html'" style="all:unset; cursor:pointer;">
            <div class="overlap-group">
              <img class="img" src="img/Frame 144.png" alt="예비 페이지 이동" />
            </div>
          </button>

          <!-- (2) 상단 알림(RR.png) + 북마크 -->
          <a href="<%= logged ? "notify.jsp" : "login.html" %>"
            style="
              position:absolute;
              top:109px;
              left:320px;
              width:16px;
              height:17px;
              cursor:pointer;
              display:block;
            "
          >
            <img src="img/RR.png" alt="알림" style="width:100%; height:100%;" />
            <% if (!"0".equals(notifyCount)) { %>
              <span class="notify-badge"><%= notifyCount %></span>
            <% } %>
          </a>

          <button onclick="location.href='prepare.html'" style="all:unset; cursor:pointer;">
            <div class="img-wrapper">
              <img class="image-3" src="img/Frame 142.png" alt="북마크" />
            </div>
          </button>
          <button onclick="location.href='prepare.html'" style="all:unset; cursor:pointer;">
          <div class="image-wrapper">
            <img class="image-2" src="img/Frame 143.png" alt="알림">
          </div>
			</button>
          <!-- (4) 전국 텍스트 -->
          <div class="group-3">
            <div class="text-wrapper-21">전국</div>
            <img class="vector-8" src="img/ㅇ.png" alt="벡터 아이콘">
          </div>

          <!-- (5) 메인 배너 캐러셀 -->
          <div class="banner-section">
            <div class="banner-container">
              <div class="banner-item active">
                <img src="img/qqq.png" alt="메인 배너1">
              </div>
              <div class="banner-item">
                <img src="img/qq.png" alt="메인 배너2">
              </div>
              <div class="banner-item">
                <img src="img/ㅂ.png" alt="메인 배너3">
              </div>
            </div>
            <div class="banner-dots">
              <div class="banner-dot active"></div>
              <div class="banner-dot"></div>
              <div class="banner-dot"></div>
            </div>
          </div>

          <!-- (6) 검색 바 (디자인용) -->
          <img class="frame" src="img/EE.png" alt="검색 바" />

          <!-- (7) 검색 폼 -->
          <form class="search-form" action="search.jsp" method="get">
            <input type="text" name="query" placeholder="매장 검색..." />
          </form>

          <!-- (8) 나머지 원본 레이아웃은 한 글자도 건들지 않았습니다 -->
         
          <div class="text-wrapper-3">눈썹&amp;속눈썹</div>
          <div class="text-wrapper-4">타임세일</div>
          <div class="text-wrapper-5">쿠폰/ 혜택</div>
          <div class="text-wrapper-6">바버샵</div>
          <div class="text-wrapper-7">이달의 트렌드</div>
          <div class="text-wrapper-8">에스테틱</div>

          <!-- 메인 홈 콘텐츠 -->
          <div class="main-content" style="position: absolute; top: 620px; left: 0; width: 100%; padding: 20px; background-color: #ffffff;">
            <!-- 시술별 인기 매장 -->
            <div class="popular-shops" style="margin-bottom: 30px;">
              <div class="shop-cards" style="display: flex; overflow-x: auto; gap: 15px; padding-bottom: 10px; scrollbar-width: none;">
                <div class="shop-card" style="min-width: 200px; border-radius: 12px; overflow: hidden; box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);">
                  <img src="img/55.jpg" alt="매장1" style="width: 100%; height: 120px; object-fit: cover;">
                  <div style="padding: 12px;">
                    <div style="font-family: 'Pretendard-SemiBold', Helvetica; font-weight: 600; font-size: 14px; margin-bottom: 4px;">준오헤어 강남점</div>
                    <div style="font-family: 'Pretendard', Helvetica; font-size: 12px; color: #888;">커트 15,000원 ~</div>
                    <div style="display: flex; align-items: center; gap: 4px; margin-top: 8px;">
                      <span style="color: #8d4bf6;">⭐ 4.8</span>
                      <span style="font-family: 'Pretendard', Helvetica; font-size: 12px; color: #888;">(128)</span>
                    </div>
                  </div>
                </div>
                <div class="shop-card" style="min-width: 200px; border-radius: 12px; overflow: hidden; box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);">
                  <img src="img/555.jpg" alt="매장2" style="width: 100%; height: 120px; object-fit: cover;">
                  <div style="padding: 12px;">
                    <div style="font-family: 'Pretendard-SemiBold', Helvetica; font-weight: 600; font-size: 14px; margin-bottom: 4px;">미소헤어샵</div>
                    <div style="font-family: 'Pretendard', Helvetica; font-size: 12px; color: #888;">펌 50,000원 ~</div>
                    <div style="display: flex; align-items: center; gap: 4px; margin-top: 8px;">
                      <span style="color: #8d4bf6;">⭐ 4.7</span>
                      <span style="font-family: 'Pretendard', Helvetica; font-size: 12px; color: #888;">(96)</span>
                    </div>
                  </div>
                </div>
                <div class="shop-card" style="min-width: 200px; border-radius: 12px; overflow: hidden; box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);">
                  <img src="img/55.jpg" alt="매장3" style="width: 100%; height: 120px; object-fit: cover;">
                  <div style="padding: 12px;">
                    <div style="font-family: 'Pretendard-SemiBold', Helvetica; font-weight: 600; font-size: 14px; margin-bottom: 4px;">청담동헤어</div>
                    <div style="font-family: 'Pretendard', Helvetica; font-size: 12px; color: #888;">염색 80,000원 ~</div>
                    <div style="display: flex; align-items: center; gap: 4px; margin-top: 8px;">
                      <span style="color: #8d4bf6;">⭐ 4.9</span>
                      <span style="font-family: 'Pretendard', Helvetica; font-size: 12px; color: #888;">(156)</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- 오늘의 특가 시술 -->
            <div class="special-offers" style="margin-bottom: 30px;">
              <h2 style="font-family: 'Pretendard-SemiBold', Helvetica; font-weight: 600; color: #000000; font-size: 15px; line-height: normal; white-space: nowrap; letter-spacing: 0; margin-bottom: 15px;">오늘의 특가 시술</h2>
              <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 15px;">
                <div style="position: relative; border-radius: 12px; overflow: hidden; background: #f8f8f8; padding: 15px;">
                  <div style="position: absolute; top: 10px; right: 10px; background: #8d4bf6; color: white; padding: 4px 8px; border-radius: 12px; font-family: 'Pretendard-SemiBold', Helvetica; font-size: 12px;">30% 할인</div>
                  <div style="font-family: 'Pretendard-SemiBold', Helvetica; font-weight: 600; font-size: 14px; margin-bottom: 8px;">볼륨펌</div>
                  <div style="display: flex; align-items: baseline; gap: 4px;">
                    <div style="font-family: 'Pretendard-SemiBold', Helvetica; font-weight: 600; font-size: 16px; color: #8d4bf6;">35,000원</div>
                    <div style="font-family: 'Pretendard', Helvetica; font-size: 12px; color: #888; text-decoration: line-through;">50,000원</div>
                  </div>
                  <div style="font-family: 'Pretendard', Helvetica; font-size: 12px; color: #666; margin-top: 8px;">오늘 마감</div>
                </div>
                <div style="position: relative; border-radius: 12px; overflow: hidden; background: #f8f8f8; padding: 15px;">
                  <div style="position: absolute; top: 10px; right: 10px; background: #8d4bf6; color: white; padding: 4px 8px; border-radius: 12px; font-family: 'Pretendard-SemiBold', Helvetica; font-size: 12px;">20% 할인</div>
                  <div style="font-family: 'Pretendard-SemiBold', Helvetica; font-weight: 600; font-size: 14px; margin-bottom: 8px;">염색</div>
                  <div style="display: flex; align-items: baseline; gap: 4px;">
                    <div style="font-family: 'Pretendard-SemiBold', Helvetica; font-weight: 600; font-size: 16px; color: #8d4bf6;">64,000원</div>
                    <div style="font-family: 'Pretendard', Helvetica; font-size: 12px; color: #888; text-decoration: line-through;">80,000원</div>
                  </div>
                  <div style="font-family: 'Pretendard', Helvetica; font-size: 12px; color: #666; margin-top: 8px;">오늘 마감</div>
                </div>
              </div>
            </div>

            <!-- 스타일 트렌드 -->
            <div class="style-trends" style="margin-bottom: 30px;">
              <h2 style="font-family: 'Pretendard-SemiBold', Helvetica; font-weight: 600; color: #000000; font-size: 15px; line-height: normal; white-space: nowrap; letter-spacing: 0; margin-bottom: 15px;">스타일 트렌드</h2>
              <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 15px;">
                <div style="text-align: center;">
                  <div style="width: 100px; height: 100px; border-radius: 50%; background: #f0f0f0; margin: 0 auto 12px; overflow: hidden;">
                    <img src="img/222.jpg" alt="트렌드1" style="width: 100%; height: 100%; object-fit: cover;">
                  </div>
                  <div style="font-family: 'Pretendard-SemiBold', Helvetica; font-size: 14px;">레이어드 컷</div>
                </div>
                <div style="text-align: center;">
                  <div style="width: 100px; height: 100px; border-radius: 50%; background: #f0f0f0; margin: 0 auto 12px; overflow: hidden;">
                    <img src="img/2222.jpg" alt="트렌드2" style="width: 100%; height: 100%; object-fit: cover;">
                  </div>
                  <div style="font-family: 'Pretendard-SemiBold', Helvetica; font-size: 14px;">볼륨 펌</div>
                </div>
                <div style="text-align: center;">
                  <div style="width: 100px; height: 100px; border-radius: 50%; background: #f0f0f0; margin: 0 auto 12px; overflow: hidden;">
                    <img src="img/7777.jpg" alt="트렌드3" style="width: 100%; height: 100%; object-fit: cover;">
                  </div>
                  <div style="font-family: 'Pretendard-SemiBold', Helvetica; font-size: 14px;">스트레이트</div>
                </div>
              </div>
            </div>

            <!-- 시술 가이드 -->
            <div class="service-guide" style="margin-bottom: 30px;">
              <h2 style="font-family: 'Pretendard-SemiBold', Helvetica; font-weight: 600; color: #000000; font-size: 15px; line-height: normal; white-space: nowrap; letter-spacing: 0; margin-bottom: 15px;">시술 가이드</h2>
              <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 15px;">
                <div style="position: relative; border-radius: 12px; overflow: hidden; background: linear-gradient(45deg, #8d4bf6, #b388ff); padding: 20px; color: white;">
                  <div style="font-family: 'Pretendard-SemiBold', Helvetica; font-size: 16px; margin-bottom: 8px;">커트 가이드</div>
                  <div style="font-family: 'Pretendard', Helvetica; font-size: 13px; opacity: 0.9;">얼굴형별 맞춤 커트 추천</div>
                  <div style="position: absolute; right: 15px; bottom: 15px; font-family: 'Pretendard-SemiBold', Helvetica; font-size: 12px;">자세히 보기 →</div>
                </div>
                <div style="position: relative; border-radius: 12px; overflow: hidden; background: linear-gradient(45deg, #ff6b6b, #ffa07a); padding: 20px; color: white;">
                  <div style="font-family: 'Pretendard-SemiBold', Helvetica; font-size: 16px; margin-bottom: 8px;">펌 가이드</div>
                  <div style="font-family: 'Pretendard', Helvetica; font-size: 12px; opacity: 0.9;">헤어 타입별 펌 추천</div>
                  <div style="position: absolute; right: 15px; bottom: 15px; font-family: 'Pretendard-SemiBold', Helvetica; font-size: 12px;">자세히 보기 →</div>
                </div>
              </div>
            </div>
          </div>

          <!-- 왁싱 아이콘 -->
          <button onclick="location.href='prepare.html'" style="all:unset; cursor:pointer;">
          <div class="group-4" style="top: 385px; left: 166px;">
            <img class="image-7" src="img/Frame 138.png" alt="왁싱">
          </div>
          </button>
          <div class="text-wrapper-16">왁싱</div>

          <!-- (10) 이하 생략 없이 원본 그대로 -->
          <div class="text-wrapper-14">헤어샵</div>
          <div class="text-wrapper-15">네일샵</div>
          <div class="text-wrapper-17">당일 예약</div>
          <button onclick="location.href='prepare.html'" style="all:unset; cursor:pointer;">
            <div class="group-2">
              <img class="image-6" src="img/Frame 138.png" alt="위치 핀" />
            </div>
          </button>
        
          <button onclick="location.href='prepare.html'" style="all:unset; cursor:pointer;">
            <div class="group-4"><img class="image-7" src="img/Frame 139.png" alt="아이콘1"/></div>
          </button>
          <button onclick="location.href='prepare.html'" style="all:unset; cursor:pointer;">
            <div class="overlap-9"><img class="image-8" src="img/Frame 140.png" alt="아이콘2"/></div>
          </button>
          <button onclick="location.href='prepare.html'" style="all:unset; cursor:pointer;">
            <div class="group-5">
              <img class="image-9" src="img/image-47.png" alt="왁싱">
            </div>
          </button>
          <button onclick="location.href='prepare.html'" style="all:unset; cursor:pointer;">
            <div class="group-6"><img class="image-8" src="img/Frame 134.png" alt="아이콘4"/></div>
          </button>
          <button onclick="location.href='prepare.html'" style="all:unset; cursor:pointer;">
            <div class="overlap-10"><img class="image-10" src="img/Frame 141.png" alt="아이콘5"/></div>
          </button>
          <div class="group-7">
            <div class="text-wrapper-22">헤어샵</div>
            <div class="text-wrapper-23">음식점</div>
          </div>
          <div class="text-wrapper-18">시술별 재예약 많은 샵</div>
          <div class="overlap-5"><div class="rectangle-4"></div><div class="text-wrapper-19">커트</div></div>
          <div class="overlap-6"><div class="rectangle-4"></div><div class="text-wrapper-20">펌</div></div>
          <div class="overlap-7"><div class="rectangle-4"></div><div class="text-wrapper-19">염색</div></div>
          <div class="overlap-8"><div class="rectangle-4"></div><div class="text-wrapper-19">네일</div></div>
          
          <!-- 로딩 인디케이터 -->
          <div class="loading-indicator" id="loading-indicator">
            <div class="loading-spinner"></div>
            <div class="loading-text">새 콘텐츠를 불러오는 중...</div>
          </div>
        </div>

        <!-- (9) 하단 네비게이션 -->
        <div class="nav-container">
          <div class="nav-wrapper">
            <div class="nav-item" onclick="location.href='index.jsp'">
              <img src="img/home.png" alt="홈" class="active">
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
    
    <!-- 애니메이션 스크립트 -->
    <script src="js/animations.js"></script>
    
    <!-- 배너 슬라이더 스크립트 -->
    <script>
      document.addEventListener('DOMContentLoaded', function() {
        // 배너 요소 선택
        const bannerItems = document.querySelectorAll('.banner-item');
        const bannerDots = document.querySelectorAll('.banner-dot');
        let currentIndex = 0;
        let interval;

        // 배너 전환 함수
        function showBanner(index) {
          // 모든 배너 숨기기
          bannerItems.forEach(item => {
            item.classList.remove('active');
          });
          
          // 모든 도트 비활성화
          bannerDots.forEach(dot => {
            dot.classList.remove('active');
          });
          
          // 선택된 배너와 도트 활성화
          bannerItems[index].classList.add('active');
          bannerDots[index].classList.add('active');
          
          // 현재 인덱스 업데이트
          currentIndex = index;
        }

        // 다음 배너로 전환
        function nextBanner() {
          const nextIndex = (currentIndex + 1) % bannerItems.length;
          showBanner(nextIndex);
        }

        // 자동 전환 시작
        function startAutoSlide() {
          if (interval) {
            clearInterval(interval);
          }
          interval = setInterval(nextBanner, 3000);
        }

        // 도트 클릭 이벤트
        bannerDots.forEach((dot, index) => {
          dot.addEventListener('click', () => {
            showBanner(index);
            startAutoSlide();
          });
        });

        // 초기 설정
        showBanner(0);
        startAutoSlide();
        
        // 스크롤 동작 개선
        const contentContainer = document.getElementById('content-container');
        if (contentContainer) {
          // 스크롤 이벤트 리스너 추가
          contentContainer.addEventListener('scroll', function() {
            // 스크롤 위치에 따라 네비게이션 바 스타일 조정
            const navContainer = document.querySelector('.nav-container');
            if (navContainer) {
              if (contentContainer.scrollTop > 50) {
                navContainer.style.boxShadow = '0 -2px 10px rgba(0, 0, 0, 0.1)';
              } else {
                navContainer.style.boxShadow = 'none';
              }
            }
          });
        }
      });
    </script>

    <script>
      document.addEventListener('DOMContentLoaded', function() {
        const rectangle4 = document.querySelector('.rectangle-4');
        const shopCards = document.querySelector('.shop-cards');

        rectangle4.addEventListener('click', function() {
          // 새로운 매장 데이터
          const newShops = [
            {
              name: '새로운 매장 1',
              price: '커트 20,000원 ~',
              rating: '4.9',
              reviews: '200',
              image: 'img/555.jpg'
            },
            {
              name: '새로운 매장 2',
              price: '펌 60,000원 ~',
              rating: '4.8',
              reviews: '150',
              image: 'img/55.jpg'
            },
            {
              name: '새로운 매장 3',
              price: '염색 90,000원 ~',
              rating: '4.7',
              reviews: '180',
              image: 'img/555.jpg'
            }
          ];

          // 기존 매장 카드 제거
          shopCards.innerHTML = '';

          // 새로운 매장 카드 추가
          newShops.forEach(shop => {
            const shopCard = document.createElement('div');
            shopCard.className = 'shop-card';
            shopCard.style = 'min-width: 200px; border-radius: 12px; overflow: hidden; box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);';
            shopCard.innerHTML = `
              <img src="${shop.image}" alt="${shop.name}" style="width: 100%; height: 120px; object-fit: cover;">
              <div style="padding: 12px;">
                <div style="font-family: 'Pretendard-SemiBold', Helvetica; font-weight: 600; font-size: 14px; margin-bottom: 4px;">${shop.name}</div>
                <div style="font-family: 'Pretendard', Helvetica; font-size: 12px; color: #888;">${shop.price}</div>
                <div style="display: flex; align-items: center; gap: 4px; margin-top: 8px;">
                  <span style="color: #8d4bf6;">⭐ ${shop.rating}</span>
                  <span style="font-family: 'Pretendard', Helvetica; font-size: 12px; color: #888;">(${shop.reviews})</span>
                </div>
              </div>
            `;
            shopCards.appendChild(shopCard);
          });
        });
      });
    </script>
  </body>
</html>