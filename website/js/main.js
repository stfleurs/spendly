document.addEventListener('DOMContentLoaded', () => {
  const form = document.getElementById('waitlistForm');
  const successMessage = document.getElementById('successMessage');
  const submitBtn = document.getElementById('submitBtn');

  if (form) {
    form.addEventListener('submit', (e) => {
      e.preventDefault();
      
      const emailInput = document.getElementById('emailInput');
      const email = emailInput.value;

      if (email) {
        // Simulate API call
        submitBtn.textContent = 'Joining...';
        submitBtn.disabled = true;

        setTimeout(() => {
          form.classList.add('hidden');
          successMessage.style.display = 'block';
        }, 800);
      }
    });
  }
});
