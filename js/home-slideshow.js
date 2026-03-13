(function () {
  'use strict';

  function getSlideNumber(path) {
    var fileName = (path.split('/').pop() || '').replace(/\.[^.]+$/, '');
    var match = fileName.match(/^(\d+)/);
    return match ? Number(match[1]) : Number.MAX_SAFE_INTEGER;
  }

  function getReadableAlt(path) {
    var fileStem = (path.split('/').pop() || 'Lab highlight').replace(/\.[^.]+$/, '');
    fileStem = fileStem.replace(/^\d+[-_]?/, '');
    return fileStem.replace(/[-_]+/g, ' ');
  }

  function getOrderedImages(imagePaths) {
    return imagePaths.slice().sort(function (a, b) {
      return getSlideNumber(a) - getSlideNumber(b);
    });
  }

  function init(options) {
    var settings = options || {};
    var images = getOrderedImages(Array.isArray(settings.images) ? settings.images.filter(Boolean) : []);
    var container = document.getElementById(settings.containerId);
    var viewport = document.getElementById(settings.viewportId);
    var imageNode = document.getElementById(settings.imageId);
    var dotsContainer = document.getElementById(settings.dotsContainerId);
    var previousButton = document.getElementById(settings.previousButtonId);
    var nextButton = document.getElementById(settings.nextButtonId);

    if (!container || !viewport || !imageNode || images.length === 0) {
      if (container) {
        container.style.display = 'none';
      }
      return;
    }

    var intervalMs = Number(settings.intervalMs) || 3000;
    var currentIndex = 0;
    var timerId = null;
    var touchStartX = null;
    var touchStartY = null;
    var dots = [];

    function setActiveDot() {
      if (!dots.length) {
        return;
      }

      dots.forEach(function (dot, index) {
        var isActive = index === currentIndex;
        dot.classList.toggle('is-active', isActive);
        dot.setAttribute('aria-current', isActive ? 'true' : 'false');
      });
    }

    function transitionToIndex(index) {
      currentIndex = (index + images.length) % images.length;
      var path = images[currentIndex];

      imageNode.classList.add('is-transitioning');
      window.setTimeout(function () {
        imageNode.src = path;
        imageNode.alt = getReadableAlt(path);
        imageNode.classList.remove('is-transitioning');
        setActiveDot();
      }, 120);
    }

    function renderDots() {
      if (!dotsContainer) {
        return;
      }

      dotsContainer.innerHTML = '';
      dots = images.map(function (_, index) {
        var dot = document.createElement('button');
        dot.type = 'button';
        dot.className = 'hero-slideshow__dot';
        dot.setAttribute('aria-label', 'Go to slide ' + (index + 1));
        dot.addEventListener('click', function () {
          transitionToIndex(index);
          restartTimer();
        });
        dotsContainer.appendChild(dot);
        return dot;
      });
    }

    function goToNext() {
      transitionToIndex(currentIndex + 1);
    }

    function goToPrevious() {
      transitionToIndex(currentIndex - 1);
    }

    function restartTimer() {
      if (timerId) {
        window.clearInterval(timerId);
      }

      timerId = window.setInterval(function () {
        goToNext();
      }, intervalMs);
    }

    previousButton.addEventListener('click', function () {
      goToPrevious();
      restartTimer();
    });

    nextButton.addEventListener('click', function () {
      goToNext();
      restartTimer();
    });

    viewport.addEventListener('touchstart', function (event) {
      if (!event.changedTouches || event.changedTouches.length === 0) {
        return;
      }

      touchStartX = event.changedTouches[0].clientX;
      touchStartY = event.changedTouches[0].clientY;
    }, { passive: true });

    viewport.addEventListener('touchend', function (event) {
      if (
        touchStartX === null ||
        touchStartY === null ||
        !event.changedTouches ||
        event.changedTouches.length === 0
      ) {
        return;
      }

      var touchEndX = event.changedTouches[0].clientX;
      var touchEndY = event.changedTouches[0].clientY;
      var deltaX = touchEndX - touchStartX;
      var deltaY = touchEndY - touchStartY;

      touchStartX = null;
      touchStartY = null;

      if (Math.abs(deltaX) < 40 || Math.abs(deltaX) < Math.abs(deltaY)) {
        return;
      }

      if (deltaX > 0) {
        goToPrevious();
      } else {
        goToNext();
      }

      restartTimer();
    }, { passive: true });

    renderDots();
    transitionToIndex(0);
    restartTimer();
  }

  window.PEISlideshow = {
    init: init
  };
}());
