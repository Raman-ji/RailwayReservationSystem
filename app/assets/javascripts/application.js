document.addEventListener("turbo:submit-start", function(event) {
    const submitButton = document.getElementById("confirm-button");
    if (submitButton) {
      submitButton.disabled = true;
      submitButton.value = "Submitting...";
    }
  });
  