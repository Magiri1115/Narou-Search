// ============================================
// Door Animation Component
// ============================================
class DoorAnimation {
    constructor() {
        this.doorLeft = document.getElementById('doorLeft');
        this.doorRight = document.getElementById('doorRight');
    }

    open() {
        setTimeout(() => {
            this.doorLeft?.classList.add('open-left');
            this.doorRight?.classList.add('open-right');
        }, 300);
    }
}

// ============================================
// Uptime Counter Component
// ============================================
class UptimeCounter {
    constructor(elementId) {
        this.element = document.getElementById(elementId);
        this.startTime = Date.now();
        this.intervalId = null;
    }

    start() {
        this.update();
        this.intervalId = setInterval(() => this.update(), 1000);
    }

    update() {
        if (!this.element) return;

        const elapsed = Math.floor((Date.now() - this.startTime) / 1000);
        const hours = String(Math.floor(elapsed / 3600)).padStart(2, '0');
        const minutes = String(Math.floor((elapsed % 3600) / 60)).padStart(2, '0');
        const seconds = String(elapsed % 60).padStart(2, '0');

        this.element.textContent = hours + ':' + minutes + ':' + seconds;
    }

    stop() {
        if (this.intervalId) {
            clearInterval(this.intervalId);
        }
    }
}

// ============================================
// Console Logger Component
// ============================================
class ConsoleLogger {
    constructor(elementId) {
        this.console = document.getElementById(elementId);
        this.logs = [
            { delay: 10, type: 'info', msg: '→ API health check completed' },
            { delay: 15, type: 'success', msg: '✓ Database connection healthy' },
            { delay: 20, type: 'info', msg: '→ Request received from client' },
            { delay: 25, type: 'success', msg: '✓ Response sent: 200 OK' },
            { delay: 30, type: 'info', msg: '→ Monitoring system performance...' },
            { delay: 35, type: 'success', msg: '✓ All systems operational' }
        ];
        this.currentIndex = 0;
    }

    start() {
        this.scheduleNext();
    }

    scheduleNext() {
        if (this.currentIndex >= this.logs.length) return;

        const log = this.logs[this.currentIndex];
        setTimeout(() => {
            this.addLog(log.type, log.msg);
            this.currentIndex++;
            this.scheduleNext();
        }, log.delay * 1000);
    }

    addLog(type, message) {
        if (!this.console) return;

        const now = new Date();
        const timeStr = [now.getHours(), now.getMinutes(), now.getSeconds()]
            .map(n => String(n).padStart(2, '0'))
            .join(':');

        const logLine = document.createElement('div');
        logLine.className = 'log-line log-' + type;
        logLine.innerHTML = '<span class="log-time">[' + timeStr + ']</span> ' + message;

        this.console.appendChild(logLine);
        this.console.scrollTop = this.console.scrollHeight;
    }
}

// ============================================
// API Tester Component
// ============================================
async function testAPI(endpoint) {
    const modal = document.getElementById('apiModal');
    const statusEl = document.getElementById('responseStatus');
    const timeEl = document.getElementById('responseTime');
    const bodyEl = document.getElementById('responseBody');

    // Show modal with loading state
    modal.classList.add('show');
    statusEl.textContent = 'Loading...';
    timeEl.textContent = '';
    bodyEl.textContent = 'Fetching data...';

    const startTime = performance.now();

    try {
        const response = await fetch(endpoint);
        const endTime = performance.now();
        const responseTime = Math.round(endTime - startTime);

        const data = await response.json();

        // Update modal with response
        statusEl.textContent = 'Status: ' + response.status + ' ' + response.statusText;
        timeEl.textContent = 'Time: ' + responseTime + 'ms';
        bodyEl.textContent = JSON.stringify(data, null, 2);

    } catch (error) {
        statusEl.textContent = 'Error';
        timeEl.textContent = '';
        bodyEl.textContent = 'Failed to fetch: ' + error.message;
    }
}

function closeModal() {
    const modal = document.getElementById('apiModal');
    modal.classList.remove('show');
}

// Close modal on outside click
window.onclick = function(event) {
    const modal = document.getElementById('apiModal');
    if (event.target === modal) {
        closeModal();
    }
};

// ============================================
// Application Initialization
// ============================================
window.addEventListener('load', () => {
    // Initialize door animation
    const door = new DoorAnimation();
    door.open();

    // Initialize uptime counter
    const uptime = new UptimeCounter('uptime');
    uptime.start();

    // Initialize console logger
    const logger = new ConsoleLogger('console');
    logger.start();
});
