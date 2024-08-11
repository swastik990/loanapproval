/*let txt = document.getElementById("head")
console.dir(txt);

let head = document.getElementById("head1");
console.dir(head.innerText);

head.innerText = head.innerText + "From patan";


let unique = document.getElementsByClassName("practice");

unique[0].innerText = "hello this is bullshit";
unique[1].innerText = "hello this is aayush here"; 

let buttn = document.createElement("button");
buttn.innerText = "clickme";
buttn.style.colour = "white";
buttn.style.backgroundcolour = "red";

document.querySelector("body").prepend(buttn);


document.addEventListener("DOMContentLoaded", function() {
    var emailIcon = document.getElementById("emailIcon");
    emailIcon.innerHTML = '<i class="fa-solid fa-envelope"></i>';
});

document.addEventListener(
    "DOMContentLoaded", function() {
        var phoneIcon = document.getElementById("phoneIcon");
        phoneIcon.innerHTML = '<i class="fa-solid fa-phone"></i>';
    }
)

document.addEventListener(
    "DOMContentLoaded", function() {
        var addressIcon = document.getElementById("addressIcon");
        addressIcon.innerHTML = '<i class="fa-solid fa-location-dot"></i>';
    }
)*/


let currentStep = 1;
    showStep(currentStep);

function showStep(step) {
    const steps = document.querySelectorAll('.step-content');
    const navLinks = document.querySelectorAll('.stepper-header .nav-link');
    
    steps.forEach((stepElement, index) => {
        stepElement.classList.add('d-none');
        navLinks[index].classList.remove('active');
    });

    steps[step - 1].classList.remove('d-none');
    navLinks[step - 1].classList.add('active');

    document.getElementById("prevBtn").disabled = step === 1;
    document.getElementById("nextBtn").innerHTML = step === steps.length ? "Submit" : "Next";
}

function nextPrev(n) {
    const steps = document.querySelectorAll('.step-content');
    
    if (n === 1 && !validateForm()) return false;

    currentStep += n;

    if (currentStep > steps.length) {
        document.getElementById("stepperForm").submit(); // Submitting the form
        return false;
    }

    showStep(currentStep);
}

function validateForm() {
    const currentInputs = document.querySelectorAll('.step-content:not(.d-none) input, .step-content:not(.d-none) select');
    let valid = true;

    currentInputs.forEach(input => {
        if (input.tagName === 'SELECT') {
            if (input.value === "") {
                input.classList.add("is-invalid");
                valid = false;
            } else {
                input.classList.remove("is-invalid");
            }
        } else {
            if (input.value === "") {
                input.classList.add("is-invalid");
                valid = false;
            } else {
                input.classList.remove("is-invalid");
            }
        }
    });

    return valid;
}

  // Function to change the input type from number to text to remove spinners
  function removeNumberInputSpinner(input) {
    input.setAttribute('type', 'text');
    input.addEventListener('input', function() {
        // Allow only numbers and handle other invalid inputs
        this.value = this.value.replace(/[^0-9.]/g, '');
    });
}

// Apply the function to all number inputs
document.querySelectorAll('input[type=number]').forEach(removeNumberInputSpinner);




