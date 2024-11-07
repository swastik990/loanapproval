// Function to increment numbers smoothly
function animateValue(id, start, end, duration) {
  const obj = document.getElementById(id);
  let startTimestamp = null;
  
  const step = (timestamp) => {
    if (!startTimestamp) startTimestamp = timestamp;
    const progress = Math.min((timestamp - startTimestamp) / duration, 1);
    obj.innerText = Math.floor(progress * (end - start) + start);
    
    if (progress < 1) {
      window.requestAnimationFrame(step);
    }
  };

  window.requestAnimationFrame(step);
}

// Scroll Observer to trigger the number animation
document.addEventListener("DOMContentLoaded", function() {
  const registeredUsers = document.getElementById('registeredUsers');
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        registeredUsers.classList.add('show');
        animateValue('registeredUsers', 0, 150, 2000); // Example: animate from 0 to 1500 in 2 seconds
        observer.unobserve(registeredUsers); 
      }
    });
  });

  observer.observe(registeredUsers);
});

/* Questions toogle*/ 
document.addEventListener("DOMContentLoaded", function() {
  const faqItems = document.querySelectorAll('.faq-item h3');
  if (faqItems.length === 0) {
    console.warn("No FAQ items found! Ensure HTML structure is correct.");
    return;
  }
  
  faqItems.forEach(item => {
    item.addEventListener('click', () => {
      const faqItem = item.parentElement;
      faqItem.classList.toggle('open');
      console.log("Toggled FAQ item:", faqItem); // Debugging
    });
  });
});

/*For navbar*/

const togglerButton = document.getElementById('toggler-button');
const navbarMenu = document.getElementById('navbar1');

// Add a click event to toggle the menu
togglerButton.addEventListener('click', function() {
  navbarMenu.classList.toggle('active');
});




