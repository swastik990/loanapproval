
//for password view and unview

document.querySelectorAll('.togglePassword').forEach(item => {
    item.addEventListener('click', function () {
        // Get the input element associated with the clicked toggle
        const input = this.previousElementSibling;

        // Toggle the type attribute between 'password' and 'text'
        if (input.type === 'password') {
            input.type = 'text';
            this.querySelector('i').classList.remove('fa-eye');
            this.querySelector('i').classList.add('fa-eye-slash');
        } else {
            input.type = 'password';
            this.querySelector('i').classList.remove('fa-eye-slash');
            this.querySelector('i').classList.add('fa-eye');
        }
    });
});



//for password greater than 8 numbers 
document.getElementById('button').addEventListener('click', function (event) {
    event.preventDefault(); // Prevent form submission for validation

    const currentPassword = document.getElementById('passwordInput').value.trim();
    const newPassword = document.getElementById('newpass').value.trim();
    const confirmPassword = document.getElementById('confpass').value.trim();

    let valid = true;

    // Clear previous error messages
    document.getElementById('passwordInputError').textContent = '';
    document.getElementById('newpassError').textContent = '';
    document.getElementById('confpassError').textContent = '';

    // Password validation function
    const validatePassword = (password) => {
        const minLength = /.{8,}/;
        const hasUpperCase = /[A-Z]/;
        const hasLowerCase = /[a-z]/;
        const hasNumber = /\d/;
        const hasSpecialChar = /[!@#$%^&*(),.?":{}|<>]/;

        return minLength.test(password) &&
               hasUpperCase.test(password) &&
               hasLowerCase.test(password) &&
               hasNumber.test(password) &&
               hasSpecialChar.test(password);
    };

    // Validate current password
    if (currentPassword.length < 8) {
        document.getElementById('passwordInputError').textContent = 'Current password must be at least 8 characters long.';
        valid = false;
    }

    // Validate new password
    if (!validatePassword(newPassword)) {
        document.getElementById('newpassError').textContent = 'New password must be at least 8 characters long, include uppercase, lowercase, a number, and a special character.';
        valid = false;
    }

    // Validate confirm password
    if (newPassword !== confirmPassword) {
        document.getElementById('confpassError').textContent = 'Passwords do not match.';
        valid = false;
    }
});


//alert messages
document.getElementById('button').addEventListener('click', function() {
    // Get the values of the input fields
    const currentPassword = document.getElementById('passwordInput').value.trim();
    const newPassword = document.getElementById('newpass').value.trim();
    const confirmPassword = document.getElementById('confpass').value.trim();

    // Check if any field is empty
    if (!currentPassword || !newPassword || !confirmPassword) {
        alert("Please fill out all the fields before updating.");
        return;
    }

    // Basic validation checks
    if (newPassword !== confirmPassword) {
        alert("New Password and Confirm Password do not match.");
        return;
    }

    // If all fields are filled and validation passes, show the success message
    alert("Your changes have been successfully saved");
});


//refresh the page
document.getElementById('button').addEventListener('click', function() {
    // Get the values of the input fields
    const currentPassword = document.getElementById('passwordInput').value.trim();
    const newPassword = document.getElementById('newpass').value.trim();
    const confirmPassword = document.getElementById('confpass').value.trim();

    // Check if any field is empty
    if (!currentPassword || !newPassword || !confirmPassword) {
        return;
    }

    // Basic validation checks
    if (newPassword !== confirmPassword) {
        return;
    }

    // If all fields are filled and validation passes, refresh the page
    location.reload();
});