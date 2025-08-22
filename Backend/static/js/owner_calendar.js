document.addEventListener('DOMContentLoaded', function() {
    const unpaidDays = document.querySelectorAll('.calendar-day.unpaid');
    unpaidDays.forEach(day => {
        day.addEventListener('mouseenter', function() {
            const dayInfo = this.querySelector('.day-info');
            if (dayInfo) {
                dayInfo.classList.add('show');
            }
        });
        
        day.addEventListener('mouseleave', function() {
            const dayInfo = this.querySelector('.day-info');
            if (dayInfo) {
                dayInfo.classList.remove('show');
            }
        });
    });

    window.navigateToMonth = function() {
        const month = document.getElementById('month-select').value;
        const year = document.getElementById('year-select').value;
        window.location.href = `?month=${year}-${month.padStart(2, '0')}`;
    };
});