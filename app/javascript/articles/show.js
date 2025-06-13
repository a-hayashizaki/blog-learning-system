document.addEventListener('DOMContentLoaded', function() {
  const stars = document.querySelectorAll('.rating-star');
  const ratingInputs = document.querySelectorAll('input[name="feedback[rating]"]');
  
  stars.forEach((star, index) => {
    star.addEventListener('click', function() {
      const rating = parseInt(this.dataset.rating);
      
      // Update radio button
      ratingInputs[index].checked = true;
      
      // Update star display
      stars.forEach((s, i) => {
        if (i < rating) {
          s.style.color = '#fbbf24';
        } else {
          s.style.color = '#d1d5db';
        }
      });
    });
    
    star.addEventListener('mouseover', function() {
      const rating = parseInt(this.dataset.rating);
      stars.forEach((s, i) => {
        if (i < rating) {
          s.style.color = '#fbbf24';
        } else {
          s.style.color = '#d1d5db';
        }
      });
    });
  });
});