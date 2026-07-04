// Olympus RolePlay — HUD renderer (circular gauges + money + mic)

const hud = document.getElementById('hud');

const RING_CIRCUMFERENCE = 100.53; // 2π·16

// bar-name -> gauge element id
const GAUGE_IDS = {
    health: 'g-health',
    armor: 'g-armor',
    hunger: 'g-hunger',
    thirst: 'g-thirst',
    stamina: 'g-stamina',
    voice: 'g-voice',
};

const moneyCash = document.getElementById('money-cash');
const moneyBank = document.getElementById('money-bank');
const moneyBlack = document.getElementById('money-black');
const ammo = document.getElementById('ammo');
const ammoValue = document.getElementById('ammo-value');
const voiceLabel = document.getElementById('voice-label');

// Voice mode -> ποσοστό γεμίσματος του mic ring (εμβέλεια φωνής)
const VOICE_RANGE_PCT = { Whisper: 33, Normal: 66, Shouting: 100 };

function setRing(barName, value) {
    const gauge = document.getElementById(GAUGE_IDS[barName]);
    if (!gauge) return;
    const fg = gauge.querySelector('.ring-fg');
    if (!fg) return;
    const pct = Math.max(0, Math.min(100, value));
    fg.style.strokeDashoffset = (RING_CIRCUMFERENCE * (1 - pct / 100)).toFixed(2);
}

function formatMoney(amount) {
    const n = Math.max(0, Math.floor(amount || 0));
    // thousands separator με '.' (π.χ. 25000 -> $25.000)
    return '$' + n.toString().replace(/\B(?=(\d{3})+(?!\d))/g, '.');
}

window.addEventListener('message', (event) => {
    const data = event.data || {};

    switch (data.action) {
        case 'show':
            hud.classList.remove('hidden');
            break;

        case 'hide':
            hud.classList.add('hidden');
            break;

        case 'updateBar':
            setRing(data.bar, data.value);
            break;

        case 'updateMoney':
            if (moneyCash)  moneyCash.textContent  = formatMoney(data.cash);
            if (moneyBank)  moneyBank.textContent  = formatMoney(data.bank);
            if (moneyBlack) moneyBlack.textContent = formatMoney(data.black);
            break;

        case 'updateAmmo':
            if (!ammo) break;
            if (data.visible) {
                ammo.classList.remove('hidden');
                if (ammoValue) ammoValue.textContent = data.value;
            } else {
                ammo.classList.add('hidden');
            }
            break;

        case 'updateVoice': {
            const gauge = document.getElementById('g-voice');
            setRing('voice', VOICE_RANGE_PCT[data.mode] || 66);
            if (gauge) gauge.classList.toggle('talking', !!data.talking);
            if (voiceLabel) {
                voiceLabel.textContent = data.mode || 'Normal';
                voiceLabel.classList.toggle('hidden', !data.talking);
            }
            break;
        }

        // updateJob / updateClock / fullSync: δεν υπάρχουν στοιχεία σε αυτό το layout — αγνοούνται.
        default:
            break;
    }
});
