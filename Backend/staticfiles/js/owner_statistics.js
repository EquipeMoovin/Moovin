document.addEventListener('DOMContentLoaded', function() {
    // Toggle register payment form
    const toggleFormBtn = document.getElementById('toggleRegisterForm');
    const registerForm = document.getElementById('registerPaymentForm');
    const cancelBtn = document.getElementById('cancelRegister');
    
    if (toggleFormBtn && registerForm) {
        toggleFormBtn.addEventListener('click', function() {
            registerForm.style.display = 'block';
            toggleFormBtn.style.display = 'none';
        });
    }
    
    if (cancelBtn && registerForm && toggleFormBtn) {
        cancelBtn.addEventListener('click', function() {
            registerForm.style.display = 'none';
            toggleFormBtn.style.display = 'inline-block';
        });
    }
    
    const dateField = document.getElementById('date_received');
    if (dateField) {
        const today = new Date();
        const formattedDate = today.toISOString().substr(0, 10);
        dateField.value = formattedDate;
    }
});