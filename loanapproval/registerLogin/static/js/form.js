

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


function nextPrev(n) {
    const steps = document.querySelectorAll('.step-content');
    
    if (n === 1 && !validateForm()) return false;

    currentStep += n;

    if (currentStep > steps.length) {
        // Submit the form
        document.getElementById("stepperForm").submit();
        return false; // Prevent default button behavior
    }

    showStep(currentStep);
}



