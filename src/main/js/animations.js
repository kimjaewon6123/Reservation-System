// 로딩 애니메이션 관리
const loadingManager = {
  show: function() {
    const overlay = document.querySelector('.loading-overlay');
    if (overlay) {
      overlay.classList.add('active');
    }
  },
  hide: function() {
    const overlay = document.querySelector('.loading-overlay');
    if (overlay) {
      overlay.classList.remove('active');
    }
  }
};

// 스크롤 애니메이션 관리
const scrollManager = {
  init: function() {
    this.animateElements = document.querySelectorAll('.fade-in, .slide-in-left, .slide-in-right');
    this.checkVisibility();
    window.addEventListener('scroll', this.checkVisibility.bind(this));
    window.addEventListener('resize', this.checkVisibility.bind(this));
  },
  checkVisibility: function() {
    this.animateElements.forEach(element => {
      const elementTop = element.getBoundingClientRect().top;
      const elementBottom = element.getBoundingClientRect().bottom;
      const windowHeight = window.innerHeight;
      
      if (elementTop < windowHeight * 0.8 && elementBottom > 0) {
        element.classList.add('visible');
      }
    });
  }
};

// 페이지 전환 효과 관리
const pageTransitionManager = {
  init: function() {
    this.transitionElement = document.querySelector('.page-transition');
    this.setupPageTransitions();
  },
  setupPageTransitions: function() {
    document.querySelectorAll('a[href], button[onclick*="location.href"]').forEach(element => {
      element.addEventListener('click', (e) => {
        if (element.hasAttribute('onclick')) {
          const match = element.getAttribute('onclick').match(/location\.href=\'([^\']+)\'/);
          if (match) {
            e.preventDefault();
            this.transitionToPage(match[1]);
          }
        } else if (element.hasAttribute('href')) {
          e.preventDefault();
          this.transitionToPage(element.getAttribute('href'));
        }
      });
    });
  },
  transitionToPage: function(url) {
    if (this.transitionElement) {
      this.transitionElement.classList.add('active');
      setTimeout(() => {
        window.location.href = url;
      }, 800);
    } else {
      window.location.href = url;
    }
  }
};

// 반응형 디자인 관리
const responsiveManager = {
  init: function() {
    this.setupResponsiveElements();
    window.addEventListener('resize', this.setupResponsiveElements.bind(this));
  },
  setupResponsiveElements: function() {
    const width = window.innerWidth;
    
    // 카테고리 버튼 그룹 반응형 처리
    const categoryGroup = document.querySelector('.category-group');
    if (categoryGroup) {
      if (width <= 768) {
        categoryGroup.style.flexWrap = 'wrap';
        categoryGroup.style.justifyContent = 'center';
      } else {
        categoryGroup.style.flexWrap = 'nowrap';
        categoryGroup.style.justifyContent = 'flex-start';
      }
    }
    
    // 매장 카드 반응형 처리
    const shopCards = document.querySelectorAll('.shop-card');
    shopCards.forEach(card => {
      if (width <= 768) {
        card.style.width = '100%';
        card.style.margin = '10px 0';
      } else {
        card.style.width = '';
        card.style.margin = '';
      }
    });
    
    // 하단 네비게이션 반응형 처리
    const bottomNav = document.querySelector('.bottom-nav');
    if (bottomNav) {
      if (width <= 768) {
        bottomNav.style.padding = '10px';
        const navItems = bottomNav.querySelectorAll('.nav-item');
        navItems.forEach(item => {
          item.style.fontSize = '12px';
        });
      } else {
        bottomNav.style.padding = '';
        const navItems = bottomNav.querySelectorAll('.nav-item');
        navItems.forEach(item => {
          item.style.fontSize = '';
        });
      }
    }
  }
};

// 애니메이션 요소 초기화
function initializeAnimations() {
  // fade-in 클래스를 가진 요소들에 대해 순차적으로 애니메이션 적용
  const fadeElements = document.querySelectorAll('.fade-in');
  fadeElements.forEach((element, index) => {
    element.style.animationDelay = `${index * 0.2}s`;
  });

  // slide-in-left 클래스를 가진 요소들에 대해 순차적으로 애니메이션 적용
  const slideLeftElements = document.querySelectorAll('.slide-in-left');
  slideLeftElements.forEach((element, index) => {
    element.style.animationDelay = `${index * 0.1}s`;
  });

  // slide-in-right 클래스를 가진 요소들에 대해 순차적으로 애니메이션 적용
  const slideRightElements = document.querySelectorAll('.slide-in-right');
  slideRightElements.forEach((element, index) => {
    element.style.animationDelay = `${index * 0.1}s`;
  });
}

// 페이지 로드 시 모든 매니저 초기화
document.addEventListener('DOMContentLoaded', function() {
  // 로딩 애니메이션 표시
  loadingManager.show();
  
  // 의도적으로 로딩 시간 추가 (개발 환경에서 효과를 확실히 보기 위함)
  setTimeout(() => {
    // 페이지 로드 완료 후 로딩 애니메이션 숨김
    loadingManager.hide();
    // 로딩 완료 후 애니메이션 초기화
    initializeAnimations();
  }, 1500); // 1.5초 후에 로딩 화면 제거
  
  // 스크롤 애니메이션 초기화
  scrollManager.init();
  
  // 페이지 전환 효과 초기화
  pageTransitionManager.init();
  
  // 반응형 디자인 초기화
  responsiveManager.init();
}); 