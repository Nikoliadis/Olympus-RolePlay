const overlay = document.getElementById('overlay');
const form = document.getElementById('creation-form');
const firstnameInput = document.getElementById('firstname');
const lastnameInput = document.getElementById('lastname');
const birthdateInput = document.getElementById('birthdate');
const errorBox = document.getElementById('error');
const cancelBtn = document.getElementById('cancel-btn');
const genderButtons = document.querySelectorAll('.gender-btn');

let selectedGender = 'male';

function resourceName() {
    return window.location.hostname || 'olympus_spawn';
}

function post(endpoint, data) {
    return fetch(`https://${resourceName()}/${endpoint}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify(data || {})
    });
}

function showError(message) {
    errorBox.textContent = message;
    errorBox.classList.remove('hidden');
}

function clearError() {
    errorBox.classList.add('hidden');
}

genderButtons.forEach((btn) => {
    btn.addEventListener('click', () => {
        genderButtons.forEach((b) => b.classList.remove('active'));
        btn.classList.add('active');
        selectedGender = btn.dataset.gender;
    });
});

form.addEventListener('submit', (e) => {
    e.preventDefault();
    clearError();

    const firstname = firstnameInput.value.trim();
    const lastname = lastnameInput.value.trim();
    const birthdate = birthdateInput.value;

    if (!firstname || !lastname) {
        showError('Συμπλήρωσε όνομα και επώνυμο.');
        return;
    }

    if (/\s/.test(firstname) || /\s/.test(lastname)) {
        showError('Το όνομα και το επώνυμο πρέπει να είναι μία λέξη.');
        return;
    }

    if (!birthdate) {
        showError('Επίλεξε ημερομηνία γέννησης.');
        return;
    }

    post('olympus_spawn:submitCreation', {
        firstname,
        lastname,
        gender: selectedGender,
        birthdate
    });
});

cancelBtn.addEventListener('click', () => {
    post('olympus_spawn:cancelCreation', {});
});

window.addEventListener('message', (event) => {
    const data = event.data;

    if (data.action === 'openCreation') {
        form.reset();
        clearError();
        selectedGender = 'male';
        genderButtons.forEach((b) => b.classList.toggle('active', b.dataset.gender === 'male'));

        if (data.dateMin) birthdateInput.min = data.dateMin;
        if (data.dateMax) birthdateInput.max = data.dateMax;

        overlay.classList.remove('hidden');
        firstnameInput.focus();
    } else if (data.action === 'closeCreation') {
        overlay.classList.add('hidden');
    }
});

// Esc για ακύρωση
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && !overlay.classList.contains('hidden')) {
        post('olympus_spawn:cancelCreation', {});
    }
});
