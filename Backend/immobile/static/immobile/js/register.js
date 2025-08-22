document.addEventListener('DOMContentLoaded', function() {
  const carousel = document.querySelector('.immobile-carousel');
  const slide = carousel.querySelector('.carousel-slide');
  const images = slide.querySelectorAll('img');
  const prevButton = carousel.querySelector('.prev');
  const nextButton = carousel.querySelector('.next');

  let counter = 0;
  const slideWidth = carousel.offsetWidth; // Largura de uma imagem

  
  slide.style.transform = `translateX(0px)`;

  if (prevButton && nextButton) {
      nextButton.addEventListener('click', () => {
          if (counter < images.length - 1) {
              counter++;
              slide.style.transform = `translateX(-${slideWidth * counter}px)`;
          }
      });

      prevButton.addEventListener('click', () => {
          if (counter > 0) {
              counter--;
              slide.style.transform = `translateX(-${slideWidth * counter}px)`;
          }
      });
  }
});