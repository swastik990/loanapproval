function showSuccessMessage() {
    alert("Your changes have been successfully saved");
}

function showSuccessMessage() {
    // Get the values of the input fields
    const firstName = document.getElementById('firstname').value.trim();
    const lastName = document.getElementById('lastname').value.trim();
    const email = document.getElementById('mailinput').value.trim();
    const employmentStatus = document.getElementById('employment-status').value.trim();

    // Check if any field is empty
    if (!firstName || !lastName || !email || !employmentStatus) {
        alert("Please fill out all the fields before updating.");
        return;
    }

    // If all fields are filled, show the success message
    alert("Your changes have been successfully saved");
}