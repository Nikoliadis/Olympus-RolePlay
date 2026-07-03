const hud = document.getElementById('hud');

const bars = {
    health: document.querySelector('.fill-health'),
    armor: document.querySelector('.fill-armor'),
    stamina: document.querySelector('.fill-stamina'),
    hunger: document.querySelector('.fill-hunger'),
    thirst: document.querySelector('.fill-thirst'),
};

const cashValue = document.getElementById('cash-value');
const ammoPanel = document.getElementById('ammo-panel');
const ammoValue = document.getElementById('ammo-value');
const jobLabel = document.getElementById('job-label');
const jobGrade = document.getElementById('job-grade');
const clock = document.getElementById('clock');

function formatCash(amount) {
    return '€' + Math.max(0, Math.floor(amount)).toLocaleString('en-US');
}

function pulseRow(bar) {
    const el = bars[bar];
    if (!el) return;
    const row = el.closest('.bar-row');
    row.classList.remove('pulse');
    // force reflow so the animation can retrigger
    void row.offsetWidth;
    row.classList.add('pulse');
}

function popValue(el) {
    el.classList.remove('value-pop');
    void el.offsetWidth;
    el.classList.add('value-pop');
}

window.addEventListener('message', (event) => {
    const data = event.data;

    switch (data.action) {
        case 'show':
            hud.classList.remove('hidden');
            break;

        case 'hide':
            hud.classList.add('hidden');
            break;

        case 'updateBar': {
            const el = bars[data.bar];
            if (!el) break;
            el.style.width = Math.max(0, Math.min(100, data.value)) + '%';
            pulseRow(data.bar);
            break;
        }

        case 'updateCash':
            cashValue.textContent = formatCash(data.value);
            popValue(cashValue);
            break;

        case 'updateAmmo':
            if (data.visible) {
                ammoPanel.classList.remove('hidden');
                ammoValue.textContent = data.value;
            } else {
                ammoPanel.classList.add('hidden');
            }
            break;

        case 'updateJob':
            jobLabel.textContent = data.label;
            jobGrade.textContent = data.grade || '';
            break;

        case 'updateClock':
            clock.textContent = data.value;
            break;

        case 'fullSync':
            cashValue.textContent = formatCash(data.cash);
            if (data.job) {
                jobLabel.textContent = data.job.label;
                jobGrade.textContent = data.job.grade || '';
            }
            break;
    }
});
