<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.io.*, java.net.*, org.json.JSONObject, org.json.JSONArray" %>
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8" />
    <title>매장 상세 페이지</title>
    <link rel="stylesheet" href="css/global.css" />
    <link rel="stylesheet" href="css/styleguide.css" />
    <link rel="stylesheet" href="css/servicestyle.css" />
    <style>
      .image {
        width: 100%;
        height: 200px; /* 이미지 높이를 200px로 수정 */
        object-fit: cover;
        margin-top: 44px;
        border-radius: 8px;
        margin-left: 10px;
        margin-right: 10px;
        width: calc(100% - 20px);
      }
    </style>
  </head>
  <body>
    <%
      // 1. URL 파라미터로 전달된 storeName 받기
      String storeName = request.getParameter("storeName");
      if (storeName == null || storeName.trim().isEmpty()) {
          storeName = "이철헤어커커 교대점";
      }

      // 2. Google Custom Search API를 사용하여 이미지 검색
      String apiKey = "AIzaSyBlInxraJHh5rRss5uteBdJdvhTqKBMxok";
      String cx = "40d9e6b3267344a07";

      String imageUrl = "img/44.png"; // 기본 이미지
      boolean useDefaultImage = true;
      
      try {
          String keyword = storeName;  // 키워드 단순화
          String query = URLEncoder.encode(keyword, "UTF-8");

          String googleApiUrl = "https://www.googleapis.com/customsearch/v1?"
                               + "key=" + apiKey
                               + "&cx=" + cx
                               + "&q=" + query
                               + "&searchType=image"
                               + "&num=1"  // 하나의 결과만 요청
                               + "&imgType=photo"
                               + "&safe=active";

          URI uri = URI.create(googleApiUrl);
          HttpURLConnection conn = (HttpURLConnection) uri.toURL().openConnection();
          conn.setRequestMethod("GET");
          conn.setRequestProperty("Accept", "application/json");
          conn.connect();

          int responseCode = conn.getResponseCode();
          
          if (responseCode == 200) {
              BufferedReader reader = new BufferedReader(
                  new InputStreamReader(conn.getInputStream(), "UTF-8")
              );
              StringBuilder jsonSb = new StringBuilder();
              String line;
              while ((line = reader.readLine()) != null) {
                  jsonSb.append(line);
              }
              reader.close();

              String jsonStr = jsonSb.toString();
              JSONObject json = new JSONObject(jsonStr);
              
              if (json.has("items")) {
                  JSONArray items = json.getJSONArray("items");
                  if (items.length() > 0) {
                      // 첫 번째 이미지 URL을 바로 사용
                      JSONObject item = items.getJSONObject(0);
                      imageUrl = item.getString("link");
                      useDefaultImage = false;
                  }
              }
          }
      } catch (Exception e) {
          e.printStackTrace(new PrintWriter(out));
      }
      
      if (useDefaultImage) {
          imageUrl = "img/44.png";
      }
    %>

    <div class="screen">
      <div class="overlap-wrapper">
        <div class="overlap">
          <div class="status-bars">
            <div class="statusbar-ios">
              <div class="left-side">
                <div class="statusbars-time">
                  <div class="time">9:41</div>
                </div>
              </div>
              <div class="right-side">
                <img class="icon-mobile-signal" src="img/ㅊㅊㅊㅍㅍ.png" alt="모바일 신호">
                <img class="wifi" src="img/ㅊㅊㅊㅊ.png" alt="와이파이 신호">
                <div class="statusbar-battery">
                  <div class="overlap-group">
                    <img class="outline" src="img/ㅊㅌ.png" alt="배터리 외곽">
                    <div class="percentage"></div>
                  </div>
                  <img class="battery-end" src="img/battery-end.svg" alt="배터리 끝">
                </div>
              </div>
            </div>
          </div>
          <!-- 검색된 이미지로 교체 -->
          <img class="image" src="<%= imageUrl %>" alt="매장 이미지" onerror="this.src='img/44.png';" />
          <div class="rectangle"></div>
          <div class="div"></div>
          <div class="status-bars">
            <div class="statusbar-ios">
              <div class="left-side">
                <div class="statusbars-time">
                  <div class="time">9:41</div>
                </div>
              </div>
              <div class="right-side">
                <img class="icon-mobile-signal" src="img/ㅊㅊㅊㅍㅍ.png" alt="모바일 신호" />
                <img class="wifi" src="img/ㅊㅊㅊㅊ.png" alt="와이파이 신호" />
                <div class="statusbar-battery">
                  <div class="overlap-group">
                    <img class="outline" src="img/ㅊㅌ.png" alt="배터리 외곽" />
                    <div class="percentage"></div>
                  </div>
                  <img class="battery-end" src="img/battery-end.svg" alt="배터리 끝" />
                </div>
              </div>
            </div>
          </div>
          <div class="rectangle-2"></div>
          <p class="element">
            <span class="text-wrapper">영업중</span>
            <span class="span">&nbsp;&nbsp;10:00 ~ 20:00</span>
          </p>
          <div class="text-wrapper-2">매장정보</div>
          <p class="element-OPEN">
            안녕하십니까 고객의 소리에 귀 기울이고 항상 밝은 미소를<br />
            선사하며 최선을 다하는 <%= storeName %> 입니다.<br />
            2020년 OPEN하여 늘 고객의 곁에 자리하고 있습니다.<br />
            언제나 아름다운 꽃을 피우는 태양이 되겠습니다.
          </p>
          <div class="text-wrapper-3">남성 커트<br />디자인펌<br />헤드 스파</div>
          <p class="p">
            기본 커트 서비스<br />디지털 펌 시술<br />두피 클렌징+마사지
          </p>
          <div class="element-2">
            20,000원 ~<br />80,000원 ~<br />50,000원 ~
          </div>
          <div class="text-wrapper-4">더보기</div>
          <p class="element-3">
            <span class="text-wrapper">홈</span>
            <span class="text-wrapper-5"
              >&nbsp;&nbsp;&nbsp;&nbsp;메뉴&nbsp;&nbsp;&nbsp;&nbsp;디자이너&nbsp;&nbsp;&nbsp;&nbsp;스타일&nbsp;&nbsp;&nbsp;&nbsp;리뷰 3</span>
          </p>
          <div class="text-wrapper-6"><%= storeName %></div>
          <p class="element-4">
            <span class="text-wrapper-7">3.7 </span>
            <span class="text-wrapper-8">/ 5</span>
          </p>
          <img class="material-symbols" src="img/ㅅㅅㅅㅅ.png" alt="별" />
          <img class="uil-calender" src="img/cc.png" alt="캘린더" />
          <img class="bx-store-alt" src="img/ㅂㅂ.png" alt="매장 아이콘" />
          <img class="img" src="img/ㅡ.png" alt="구분선" />
          <!-- rectangle-3 안에 rectangle-4와 text-wrapper-9를 넣습니다 -->
          <div class="rectangle-3">
            <div class="rectangle-4">
              <div class="text-wrapper-9">예약하기</div>
            </div>
          </div>
          <img class="vector" src="img/home.png" alt="벡터 이미지" onclick="window.location.href='index.jsp';" style="cursor: pointer;">
          <img class="uiw-right-2" id="goToHairshop" src="img/yy.png" alt="헤어샵 이동">
          <script>
            window.onload = function () {
              const goToHairshop = document.getElementById('goToHairshop');
              if (goToHairshop) {
                goToHairshop.addEventListener('click', function (e) {
                  e.preventDefault();
                  e.stopPropagation();
                  window.history.back();
                });
              }
              // rectangle-4 클릭 시 storeName과 함께 rev.html로 이동
              const rectangle4 = document.querySelector('.rectangle-4');
              if (rectangle4) {
                rectangle4.addEventListener('click', function () {
                  const storeName = '<%= storeName %>'; // JSP에서 storeName 가져오기
                  window.location.href = 'rev.html?storeName=' + encodeURIComponent(storeName);
                });
              }
            };
          </script>
        </div>
      </div>
    </div>
  </body>
</html>

