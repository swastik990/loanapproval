// Get the toggler button and menu
const togglerButton = document.getElementById('toggler-button');
const navbarMenu = document.getElementById('navbar1');

// Add a click event to toggle the menu
togglerButton.addEventListener('click', function() {
  navbarMenu.classList.toggle('active');
});

  