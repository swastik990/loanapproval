// Select container and buttons
const container = document.getElementById('container');
const registerBtn = document.getElementById('register');
const loginBtn = document.getElementById('login');

// Track the currently active form
let activeForm = 'SignIn';  // Default form is SignIn

// Function to toggle to the SignUp form
registerBtn.addEventListener('click', () => {
    container.classList.add("active");
    activeForm = 'SignUp';  // Update active form to SignUp
});

// Function to toggle to the SignIn form
loginBtn.addEventListener('click', () => {
    container.classList.remove("active");
    activeForm = 'SignIn';  // Update active form to SignIn
});

// Prevent the slide on error if user is already in the wrong form
function handleError(formType) {
    console.log("active",activeForm)
    if (formType === 'SignUp' && activeForm !== 'SignUp') {
        container.classList.add("active");
        activeForm = 'SignUp';
    } else if (formType === 'SignIn' && activeForm !== 'SignIn') {
        container.classList.remove("active");
        activeForm = 'SignIn';
    }
}

// Check if there are errors on SignUp or SignIn form and toggle form accordingly
// Check if there are errors on SignUp or SignIn form and toggle form accordingly
window.onload = function () {
    // Get the message lengths from the body tag's data attributes
    const signupMessagesLength = parseInt(document.body.getAttribute('data-signup-messages')) || 0;
    const signinMessagesLength = parseInt(document.body.getAttribute('data-signin-messages')) || 0;

    // Handle SignUp form errors
    if (signupMessagesLength > 0) {
        // Only toggle to SignUp if it's not already active
        if (!container.classList.contains("active")) {
            container.classList.add("active");
            activeForm = 'SignUp'; // Update active form to SignUp
        }
    }

    // Handle SignIn form errors
    if (signinMessagesLength > 0) {
        // Only toggle to SignIn if it's not already active
        if (container.classList.contains("active")) {
            container.classList.remove("active");
            activeForm = 'SignIn'; // Update active form to SignIn
        }
    }
};


// to get cookies and manage CSRF
function getCookie(name) {
    let cookieValue = null;
    if (document.cookie && document.cookie !== '') {
        const cookies = document.cookie.split(';');
        for (let i = 0; i < cookies.length; i++) {
            const cookie = cookies[i].trim();
            if (cookie.substring(0, name.length + 1) === (name + '=')) {
                cookieValue = decodeURIComponent(cookie.substring(name.length + 1));
                break;
            }
        }
    }
    return cookieValue;
}

const csrftoken = getCookie('csrftoken');

function csrfSafeMethod(method) {
    // These HTTP methods do not require CSRF protection
    return (/^(GET|HEAD|OPTIONS|TRACE)$/.test(method));
}

$.ajaxSetup({
    beforeSend: function(xhr, settings) {
        if (!csrfSafeMethod(settings.type) && !this.crossDomain) {
            xhr.setRequestHeader("X-CSRFToken", csrftoken);
        }
    }
});
