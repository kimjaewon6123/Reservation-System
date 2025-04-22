<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>피드</title>
  <link rel="stylesheet" href="css/global.css" />
  <link rel="stylesheet" href="css/styleguide.css" />
  <link rel="stylesheet" href="css/style.css" />
  <style>
    html, body {
      height: 100%;
      margin: 0;
      padding: 0;
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

    /* 피드 영역 */
    .content-area {
      position: absolute;
      top: 48px;
      left: 0;
      right: 0;
      bottom: 80px;
      overflow-y: auto;
      padding: 20px;
      background-color: #f8f8f8;
    }

    .feed-item {
      background: white;
      border-radius: 12px;
      padding: 16px;
      margin-bottom: 16px;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }

    .feed-header {
      display: flex;
      align-items: center;
      margin-bottom: 12px;
    }

    .feed-profile-img {
      width: 40px;
      height: 40px;
      border-radius: 50%;
      margin-right: 12px;
      object-fit: cover;
    }

    .feed-user-info {
      flex: 1;
    }

    .feed-username {
      font-weight: 600;
      font-size: 14px;
      margin-bottom: 2px;
    }

    .feed-time {
      font-size: 12px;
      color: #666;
    }

    .feed-content {
      margin-bottom: 12px;
      font-size: 14px;
      line-height: 1.4;
    }

    .feed-image {
      width: 100%;
      border-radius: 8px;
      margin-bottom: 12px;
      cursor: pointer;
      transition: transform 0.3s ease;
    }

    .feed-image:hover {
      transform: scale(1.02);
    }

    .feed-actions {
      display: flex;
      gap: 16px;
      color: #666;
      font-size: 12px;
    }

    .feed-action {
      display: flex;
      align-items: center;
      gap: 4px;
      cursor: pointer;
    }

    .feed-action img {
      width: 16px;
      height: 16px;
      opacity: 0.6;
    }

    .feed-action:hover img {
      opacity: 1;
    }

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

    /* 이미지 모달 */
    .image-modal {
      display: none;
      position: fixed;
      top: 48px;
      left: 0;
      right: 0;
      bottom: 80px;
      background: rgba(0, 0, 0, 0.9);
      z-index: 2000;
      align-items: center;
      justify-content: center;
      overflow: hidden;
    }

    .modal-content {
      max-width: calc(100% - 40px);
      max-height: calc(100% - 40px);
      border-radius: 12px;
      box-shadow: 0 5px 15px rgba(0, 0, 0, 0.3);
      object-fit: contain;
    }

    .close-modal {
      position: absolute;
      top: 20px;
      right: 20px;
      color: white;
      font-size: 30px;
      cursor: pointer;
      z-index: 2001;
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

      <!-- 피드 내용 -->
      <div class="content-area" id="feed-container">
        <!-- 첫 번째 피드 -->
        <div class="feed-item">
          <div class="feed-header">
            <img src="img/1.jpg" alt="프로필" class="feed-profile-img">
            <div class="feed-user-info">
              <div class="feed-username">준오헤어 강남점</div>
              <div class="feed-time">2시간 전</div>
            </div>
          </div>
          <div class="feed-content">
            오늘의 스타일링 완성작입니다 ✨<br>
            #헤어스타일 #미용실 #염색
          </div>
          <img src="img/4.jpg" alt="피드 이미지" class="feed-image">
          <div class="feed-actions">
            <div class="feed-action"><img src="img/3.png" alt="좋아요"><span>123</span></div>
            <div class="feed-action"><img src="img/2.png" alt="댓글"><span>12</span></div>
            <div class="feed-action"><img src="img/4.png" alt="공유"><span>공유</span></div>
          </div>
        </div>

        <!-- 두 번째 피드 -->
        <div class="feed-item">
          <div class="feed-header">
            <img src="img/1.jpg" alt="프로필" class="feed-profile-img">
            <div class="feed-user-info">
              <div class="feed-username">준오헤어 강남점</div>
              <div class="feed-time">2시간 전</div>
            </div>
          </div>
          <div class="feed-content">
            오늘의 스타일링 완성작입니다 ✨<br>
            #헤어스타일 #미용실 #염색
          </div>
          <img src="img/7.jpg" alt="피드 이미지" class="feed-image">
          <div class="feed-actions">
            <div class="feed-action"><img src="img/3.png" alt="좋아요"><span>321</span></div>
            <div class="feed-action"><img src="img/2.png" alt="댓글"><span>21</span></div>
            <div class="feed-action"><img src="img/4.png" alt="공유"><span>공유</span></div>
          </div>
        </div>

        <!-- 세 번째 피드 -->
        <div class="feed-item">
          <div class="feed-header">
            <img src="img/1.jpg" alt="프로필" class="feed-profile-img">
            <div class="feed-user-info">
              <div class="feed-username">준오헤어 강남점</div>
              <div class="feed-time">2시간 전</div>
            </div>
          </div>
          <div class="feed-content">
            오늘의 스타일링 완성작입니다 ✨<br>
            #헤어스타일 #미용실 #염색
          </div>
          <img src="img/8.jpg" alt="피드 이미지" class="feed-image">
          <div class="feed-actions">
            <div class="feed-action"><img src="img/3.png" alt="좋아요"><span>123</span></div>
            <div class="feed-action"><img src="img/2.png" alt="댓글"><span>12</span></div>
            <div class="feed-action"><img src="img/4.png" alt="공유"><span>공유</span></div>
          </div>
        </div>
        
        <!-- 로딩 인디케이터 -->
        <div class="loading-indicator" id="loading-indicator">
          <div class="loading-spinner"></div>
          <div class="loading-text">새 피드를 불러오는 중...</div>
        </div>

        <!-- 이미지 모달 -->
        <div class="image-modal" id="image-modal">
          <span class="close-modal">&times;</span>
          <img class="modal-content" id="modal-image">
        </div>
      </div>

      <!-- 하단 네비게이션 -->
      <div class="nav-container">
        <div class="nav-wrapper">
          <div class="nav-item" onclick="location.href='index.jsp'">
            <img src="img/home.png" alt="홈">
            <div class="nav-label">홈</div>
          </div>
          <div class="nav-item" onclick="location.href='feed.jsp'">
            <img src="img/cxxc.png" alt="피드" class="active">
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
  
  <!-- 무한 스크롤 및 이미지 모달 스크립트 -->
  <script>
    document.addEventListener('DOMContentLoaded', function() {
      const feedContainer = document.getElementById('feed-container');
      const loadingIndicator = document.getElementById('loading-indicator');
      const imageModal = document.getElementById('image-modal');
      const modalImage = document.getElementById('modal-image');
      const closeModal = document.querySelector('.close-modal');
      let isLoading = false;
      let page = 1;
      
      // 기존 피드 아이템들을 가져옵니다
      const originalFeedItems = document.querySelectorAll('.feed-item');
      const feedItems = Array.from(originalFeedItems);
      
      // 스크롤 이벤트 리스너
      feedContainer.addEventListener('scroll', function() {
        // 스크롤이 하단에 가까워지면 새 피드 로드
        if (feedContainer.scrollHeight - feedContainer.scrollTop <= feedContainer.clientHeight + 100) {
          if (!isLoading) {
            loadMoreFeeds();
          }
        }
      });
      
      // 새 피드 로드 함수
      function loadMoreFeeds() {
        isLoading = true;
        loadingIndicator.style.display = 'block';
        
        // 실제 서버 요청을 시뮬레이션하기 위한 지연
        setTimeout(function() {
          // 기존 피드 아이템들을 복제하여 추가
          feedItems.forEach(item => {
            const clonedItem = item.cloneNode(true);
            feedContainer.insertBefore(clonedItem, loadingIndicator);
          });
          
          page++;
          
          // 로딩 인디케이터를 잠시 더 표시
          setTimeout(function() {
            isLoading = false;
            loadingIndicator.style.display = 'none';
            console.log(`페이지 ${page} 로드 완료`);
          }, 500); // 0.5초 더 표시
        }, 1500); // 1.5초 지연
      }

      // 이미지 클릭 시 모달 표시
      document.querySelectorAll('.feed-image').forEach(img => {
        img.addEventListener('click', function() {
          imageModal.style.display = 'flex';
          modalImage.src = this.src;
        });
      });

      // 모달 닫기
      closeModal.addEventListener('click', function() {
        imageModal.style.display = 'none';
      });

      // 모달 외부 클릭 시 닫기
      imageModal.addEventListener('click', function(e) {
        if (e.target === imageModal) {
          imageModal.style.display = 'none';
        }
      });
    });
  </script>
</body>
</html>
