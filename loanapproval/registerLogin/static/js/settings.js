

function showSection(sectionId) {
    // Hide all sections
    document.querySelectorAll('.section-content').forEach(section => {
      section.style.display = 'none';
    });
    // Show the selected section
    document.getElementById(sectionId).style.display = 'block';

    // Set the active menu item
    document.querySelectorAll('.menu-item').forEach(menu => {
      menu.classList.remove('active');
    });
    document.getElementById('menu-' + sectionId.split('-')[0]).classList.add('active');
  }

  function loadFile(event) {
    const image = document.getElementById('profileImage');
    image.src = URL.createObjectURL(event.target.files[0]);
  }

  function resetForm(formId) {
    document.getElementById(formId).reset();
  }



 // Toggle show/hide password for current password
 const toggleCurrentPassword = document.getElementById('toggleCurrentPassword');
 const currentPassword = document.getElementById('currentPassword');
 
 toggleCurrentPassword.addEventListener('click', function() {
   const type = currentPassword.getAttribute('type') === 'password' ? 'text' : 'password';
   currentPassword.setAttribute('type', type);
   this.classList.toggle('fa-eye-slash');
   this.classList.toggle('fa-eye');
 });

 // Toggle show/hide password for new password
 const toggleNewPassword = document.getElementById('toggleNewPassword');
 const newPassword = document.getElementById('newPassword');
 
 toggleNewPassword.addEventListener('click', function() {
   const type = newPassword.getAttribute('type') === 'password' ? 'text' : 'password';
   newPassword.setAttribute('type', type);
   this.classList.toggle('fa-eye-slash');
   this.classList.toggle('fa-eye');
 });

 // Toggle show/hide password for confirm password
 const toggleConfirmPassword = document.getElementById('toggleConfirmPassword');
 const confirmPassword = document.getElementById('confirmPassword');
 
 toggleConfirmPassword.addEventListener('click', function() {
   const type = confirmPassword.getAttribute('type') === 'password' ? 'text' : 'password';
   confirmPassword.setAttribute('type', type);
   this.classList.toggle('fa-eye-slash');
   this.classList.toggle('fa-eye');
 });


/*for navbar*/
 const togglerButton = document.getElementById('toggler-button');
 const navbarMenu = document.getElementById('navbarNav');
 
 // Add a click event to toggle the menu
 togglerButton.addEventListener('click', function() {
   navbarMenu.classList.toggle('active');
 });

 /*for update button*/


  function updateForm(formId) {
    const form = document.getElementById(formId);
    
    // Perform validation checks or additional processing if needed here.
    // For now, we will simply alert that the form was updated.

    if (formId === 'accountForm') {
      alert('Account settings updated successfully!');
    } else if (formId === 'securityForm') {
      alert('Security settings updated successfully!');
    } else if (formId === 'notificationsForm') {
      alert('Notification settings updated successfully!');
    }
    
    // Reset the form
    form.reset();
    
  }

  function updateForm(formId) {
    const form = document.getElementById(formId);
    // Check form validity
    if (form.checkValidity()) {
      alert('Form submitted successfully!');
      form.reset(); 

    } else {
      
      form.reportValidity();
    }
  }
  




  