document.addEventListener("DOMContentLoaded", function() {
    const forms = document.querySelectorAll("form"); // Select all forms
  
    forms.forEach(form => {
      const submitButton = form.querySelector("#submit-button");
      
      if (submitButton) {
        form.addEventListener("submit", function() {
          // Disable the button
          submitButton.disabled = true;
          submitButton.innerText = submitButton.dataset.disable_with; // Change button text
        });
      }
    });
  });
  