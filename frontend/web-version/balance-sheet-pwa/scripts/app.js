// JavaScript code for the Balance Sheet PWA
document.addEventListener('DOMContentLoaded', () => {
    const form = document.getElementById('entry-form');
    const entryList = document.getElementById('entry-list');
    const totalDisplay = document.getElementById('total-display');

    // Load entries from local storage
    function loadEntries() {
        const entries = JSON.parse(localStorage.getItem('entries')) || [];
        entryList.innerHTML = '';
        let total = 0;

        entries.forEach(entry => {
            const li = document.createElement('li');
            li.textContent = `${entry.description}: $${entry.amount}`;
            entryList.appendChild(li);
            total += parseFloat(entry.amount);
        });

        totalDisplay.textContent = `Total: $${total.toFixed(2)}`;
    }

    // Add entry to local storage
    form.addEventListener('submit', (event) => {
        event.preventDefault();
        const description = document.getElementById('description').value;
        const amount = document.getElementById('amount').value;

        if (description && amount) {
            const entries = JSON.parse(localStorage.getItem('entries')) || [];
            entries.push({ description, amount });
            localStorage.setItem('entries', JSON.stringify(entries));
            loadEntries();
            form.reset();
        }
    });

    loadEntries();
});