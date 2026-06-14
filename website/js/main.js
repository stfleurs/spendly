// ===== POLYFILL =====
if (!CanvasRenderingContext2D.prototype.roundRect) {
  CanvasRenderingContext2D.prototype.roundRect = function(x, y, w, h, radii) {
    const r = Array.isArray(radii) ? radii : [radii || 0];
    const tl = r[0] || 0, tr = r[1] || tl, br = r[2] || tr, bl = r[3] || br;
    this.moveTo(x + tl, y);
    this.lineTo(x + w - tr, y);
    this.quadraticCurveTo(x + w, y, x + w, y + tr);
    this.lineTo(x + w, y + h - br);
    this.quadraticCurveTo(x + w, y + h, x + w - br, y + h);
    this.lineTo(x + bl, y + h);
    this.quadraticCurveTo(x, y + h, x, y + h - bl);
    this.lineTo(x, y + tl);
    this.quadraticCurveTo(x, y, x + tl, y);
    this.closePath();
    return this;
  };
}

// ===== UTILITY =====
const $ = id => document.getElementById(id);
const val = id => parseFloat($(id).value) || 0;
const fmtDec = n => '$' + n.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const pct = n => n.toFixed(1) + '%';

// Simple donut chart on canvas
function drawDonut(canvas, slices, size) {
  if (!canvas) return;
  const dpr = window.devicePixelRatio || 1;
  const s = size || 200;
  canvas.width = s * dpr;
  canvas.height = s * dpr;
  canvas.style.width = s + 'px';
  canvas.style.height = s + 'px';
  const ctx = canvas.getContext('2d');
  ctx.scale(dpr, dpr);
  const cx = s / 2, cy = s / 2, r = s * 0.38, ir = s * 0.2;
  const total = slices.reduce((sum, s) => sum + s.value, 0);
  if (total === 0) return;
  let start = -Math.PI / 2;
  const colors = ['#10b981','#3b82f6','#f59e0b','#ef4444','#8b5cf6','#ec4899','#14b8a6','#f97316'];
  slices.forEach((slice, i) => {
    const angle = (slice.value / total) * Math.PI * 2;
    ctx.beginPath();
    ctx.arc(cx, cy, r, start, start + angle);
    ctx.arc(cx, cy, ir, start + angle, start, true);
    ctx.closePath();
    ctx.fillStyle = colors[i % colors.length];
    ctx.fill();
    start += angle;
  });
}

// Simple bar chart on canvas
function drawBars(canvas, bars, width, height) {
  if (!canvas) return;
  const dpr = window.devicePixelRatio || 1;
  const w = width || 300, h = height || 200;
  canvas.width = w * dpr;
  canvas.height = h * dpr;
  canvas.style.width = w + 'px';
  canvas.style.height = h + 'px';
  const ctx = canvas.getContext('2d');
  ctx.scale(dpr, dpr);
  ctx.clearRect(0, 0, w, h);
  if (!bars.length) return;
  const max = Math.max(...bars.map(b => b.value), 1);
  const pad = { t: 20, r: 20, b: 40, l: 50 };
  const cw = w - pad.l - pad.r;
  const ch = h - pad.t - pad.b;
  const bw = Math.min(cw / bars.length * 0.65, 40);
  const gap = cw / bars.length;
  const colors = ['#10b981','#3b82f6','#f59e0b','#ef4444','#8b5cf6','#ec4899','#14b8a6','#f97316','#6366f1','#84cc16'];
  bars.forEach((bar, i) => {
    const bh = (bar.value / max) * ch;
    const x = pad.l + gap * i + (gap - bw) / 2;
    const y = pad.t + ch - bh;
    ctx.fillStyle = colors[i % colors.length];
    ctx.beginPath();
    ctx.roundRect(x, y, bw, bh, [4,4,0,0]);
    ctx.fill();
    ctx.fillStyle = '#6b7280';
    ctx.font = '10px Inter, sans-serif';
    ctx.textAlign = 'center';
    ctx.fillText(bar.label, x + bw / 2, h - pad.b + 16);
    ctx.fillStyle = '#374151';
    ctx.font = 'bold 11px Inter, sans-serif';
    ctx.fillText(fmtDec(bar.value), x + bw / 2, y - 4);
  });
}

// ===== SPENDING CAPACITY CALCULATOR (homepage) =====
function calcSpendingCapacity() {
  const income = val('sc-income');
  const bills = val('sc-bills');
  const savings = val('sc-savings');
  const capacity = income - bills - savings;
  const result = $('sc-result');
  const breakdown = $('sc-breakdown');
  if (!income) { result.innerHTML = '<p class="result-label" style="color:var(--gray-400)">Enter your income above</p>'; breakdown.innerHTML = ''; return; }
  const pBills = income > 0 ? (bills / income) * 100 : 0;
  const pSavings = income > 0 ? (savings / income) * 100 : 0;
  const pCapacity = income > 0 ? (capacity / income) * 100 : 0;
  result.innerHTML = `
    <div class="result-number large">${fmtDec(Math.max(0, capacity))}</div>
    <div class="result-label">Your safe spending amount this month</div>
  `;
  breakdown.innerHTML = `
    <div class="result-row"><span class="label">Income</span><span class="value">${fmtDec(income)}</span></div>
    <div class="result-row"><span class="label">Fixed Bills (${pct(pBills)})</span><span class="value negative">-${fmtDec(bills)}</span></div>
    <div class="result-row"><span class="label">Savings Goal (${pct(pSavings)})</span><span class="value negative">-${fmtDec(savings)}</span></div>
    <div class="result-row"><span class="label" style="font-weight:600">Remaining for Spending</span><span class="value positive" style="font-weight:700">${fmtDec(Math.max(0, capacity))}</span></div>
  `;
  const canvas = $('sc-chart');
  drawDonut(canvas, [
    { value: Math.max(0, bills) }, { value: Math.max(0, savings) }, { value: Math.max(0, capacity) }
  ], 220);
}

// ===== BUDGET PLANNER =====
function calcBudget() {
  const income = val('bp-income');
  const housing = val('bp-housing');
  const utilities = val('bp-utilities');
  const food = val('bp-food');
  const transport = val('bp-transport');
  const insurance = val('bp-insurance');
  const debt = val('bp-debt');
  const savings = val('bp-savings-goal');
  const entertainment = val('bp-entertainment');
  const other = val('bp-other');
  const totalExpenses = housing + utilities + food + transport + insurance + debt + entertainment + other;
  const remaining = income - totalExpenses - savings;
  const results = $('bp-results');
  if (!income) { results.innerHTML = '<p class="result-label" style="color:var(--gray-400)">Enter your income to see your budget</p>'; return; }
  const categories = [
    { label: 'Housing', value: housing, pct: income > 0 ? (housing/income)*100 : 0 },
    { label: 'Utilities', value: utilities, pct: income > 0 ? (utilities/income)*100 : 0 },
    { label: 'Food & Groceries', value: food, pct: income > 0 ? (food/income)*100 : 0 },
    { label: 'Transportation', value: transport, pct: income > 0 ? (transport/income)*100 : 0 },
    { label: 'Insurance', value: insurance, pct: income > 0 ? (insurance/income)*100 : 0 },
    { label: 'Debt Payments', value: debt, pct: income > 0 ? (debt/income)*100 : 0 },
    { label: 'Entertainment', value: entertainment, pct: income > 0 ? (entertainment/income)*100 : 0 },
    { label: 'Other', value: other, pct: income > 0 ? (other/income)*100 : 0 },
  ];
  const nonZero = categories.filter(c => c.value > 0);
  const bars = nonZero.map(c => ({ label: c.label.split(' ')[0], value: Math.round(c.value) }));
  drawBars($('bp-chart'), bars, 320, 200);
  drawDonut($('bp-donut'), nonZero.map(c => ({ value: c.value })), 200);
  let rows = categories.map(c => `
    <div class="result-row">
      <span class="label">${c.label}</span>
      <span class="value">${fmtDec(c.value)} (${pct(c.pct)})</span>
    </div>
  `).join('');
  results.innerHTML = `
    <div class="results-grid">
      <div class="result-stat"><div class="value">${fmtDec(income)}</div><div class="label">Monthly Income</div></div>
      <div class="result-stat"><div class="value">${fmtDec(totalExpenses)}</div><div class="label">Total Expenses</div></div>
      <div class="result-stat"><div class="value" style="color:${remaining >= 0 ? 'var(--green-700)' : 'var(--red-500)'}">${fmtDec(Math.abs(remaining))}</div><div class="label">${remaining >= 0 ? 'Remaining' : 'Overspent'}</div></div>
      <div class="result-stat"><div class="value">${fmtDec(savings)}</div><div class="label">Savings Goal</div></div>
    </div>
    ${rows}
    <div class="result-row" style="border-top:2px solid var(--gray-200);margin-top:8px;padding-top:12px">
      <span class="label" style="font-weight:600">${remaining >= 0 ? 'After Savings' : 'Adjustment Needed'}</span>
      <span class="value ${remaining >= 0 ? 'positive' : 'negative'}" style="font-weight:700">${remaining >= 0 ? fmtDec(remaining) : '- ' + fmtDec(Math.abs(remaining))}</span>
    </div>
  `;
  const cta = $('bp-cta');
  if (cta) cta.classList.remove('hidden');
}

// ===== PAYCHECK BUDGET CALCULATOR =====
function calcPaycheck() {
  const freq = $('pc-frequency').value;
  const perPaycheck = val('pc-income');
  const monthlyBills = val('pc-bills');
  const periodsPerMonth = { weekly: 4.33, biweekly: 2.17, 'semi-monthly': 2, monthly: 1 };
  const ppm = periodsPerMonth[freq] || 4.33;
  const monthlyIncome = perPaycheck * ppm;
  const afterBills = monthlyIncome - monthlyBills;
  const perPeriod = afterBills / ppm;
  const results = $('pc-results');
  if (!perPaycheck) { results.innerHTML = '<p class="result-label" style="color:var(--gray-400)">Enter your paycheck amount</p>'; return; }
  const envelopes = [
    { label: 'Groceries', pct: 0.25 },
    { label: 'Dining Out', pct: 0.10 },
    { label: 'Gas & Transport', pct: 0.15 },
    { label: 'Shopping', pct: 0.10 },
    { label: 'Entertainment', pct: 0.10 },
    { label: 'Savings', pct: 0.20 },
    { label: 'Miscellaneous', pct: 0.10 },
  ];
  const freqLabel = { weekly: 'Week', biweekly: '2 Weeks', 'semi-monthly': 'Half-Month', monthly: 'Month' };
  let envRows = envelopes.map(e => `
    <div class="result-row">
      <span class="label">${e.label}</span>
      <span class="value positive">${fmtDec(perPeriod * e.pct)}</span>
    </div>
  `).join('');
  results.innerHTML = `
    <div class="results-grid">
      <div class="result-stat"><div class="value">${fmtDec(perPaycheck)}</div><div class="label">Per ${freqLabel[freq]}</div></div>
      <div class="result-stat"><div class="value">${fmtDec(monthlyIncome)}</div><div class="label">Monthly Income</div></div>
      <div class="result-stat"><div class="value">${fmtDec(monthlyBills)}</div><div class="label">Monthly Bills</div></div>
      <div class="result-stat"><div class="value" style="color:var(--green-700)">${fmtDec(Math.max(0, perPeriod))}</div><div class="label">Per ${freqLabel[freq]} to Spend</div></div>
    </div>
    <div style="margin-top:16px">
      <h3 style="font-size:0.95rem;font-weight:600;margin-bottom:8px;color:var(--gray-700)">Suggested Envelope Budget (per ${freqLabel[freq].toLowerCase()})</h3>
      ${envRows}
    </div>
  `;
  const envelopeBars = envelopes.map(e => ({ label: e.label.split(' ')[0], value: Math.round(perPeriod * e.pct) }));
  drawBars($('pc-chart'), envelopeBars, 320, 200);
  const cta = $('pc-cta');
  if (cta) cta.classList.remove('hidden');
}

// ===== EMERGENCY FUND CALCULATOR =====
function calcEmergency() {
  const monthly = val('ef-monthly');
  const months = val('ef-months');
  const current = val('ef-current');
  const monthlySave = val('ef-save');
  const target = monthly * months;
  const needed = Math.max(0, target - current);
  const timeMonths = monthlySave > 0 ? needed / monthlySave : 0;
  const progress = target > 0 ? Math.min(100, (current / target) * 100) : 0;
  const results = $('ef-results');
  if (!monthly) { results.innerHTML = '<p class="result-label" style="color:var(--gray-400)">Enter your monthly expenses</p>'; return; }
  results.innerHTML = `
    <div class="results-grid">
      <div class="result-stat"><div class="value">${fmtDec(target)}</div><div class="label">Recommended Emergency Fund</div></div>
      <div class="result-stat"><div class="value" style="color:var(--blue-500)">${fmtDec(current)}</div><div class="label">Current Savings</div></div>
      <div class="result-stat"><div class="value" style="color:${needed > 0 ? 'var(--red-500)' : 'var(--green-700)'}">${fmtDec(needed)}</div><div class="label">Still Needed</div></div>
      <div class="result-stat"><div class="value">${timeMonths > 0 ? Math.ceil(timeMonths) + ' mo' : '0'}</div><div class="label">Time to Goal${monthlySave > 0 ? '' : ' (set savings)'}</div></div>
    </div>
    <div style="margin-top:20px">
      <div style="display:flex;justify-content:space-between;font-size:0.85rem;color:var(--gray-500);margin-bottom:6px">
        <span>Progress</span><span>${pct(progress)}</span>
      </div>
      <div style="height:12px;background:var(--gray-100);border-radius:99px;overflow:hidden">
        <div style="height:100%;width:${progress}%;background:linear-gradient(90deg,var(--green-500),var(--green-400));border-radius:99px;transition:width 0.4s"></div>
      </div>
    </div>
    <div style="margin-top:16px;padding:16px;background:var(--gray-50);border-radius:var(--radius-sm)">
      <p style="font-size:0.85rem;color:var(--gray-600)">
        ${months}-month emergency fund: <strong>${fmtDec(target)}</strong>.<br>
        ${needed <= 0 ? 'You\'ve reached your goal!' : monthlySave > 0 ? `At $${monthlySave}/month, you'll reach it in <strong>${Math.ceil(timeMonths)} months</strong>.` : 'Set a monthly savings amount above to see how long it will take.'}
      </p>
    </div>
  `;
  const cta = $('ef-cta');
  if (cta) cta.classList.remove('hidden');
}

// ===== DEBT PAYOFF CALCULATOR =====
let debtCount = 0;
function addDebt() {
  debtCount++;
  const container = $('debt-entries');
  const div = document.createElement('div');
  div.className = 'debt-entry';
  div.id = 'debt-' + debtCount;
  div.style.cssText = 'display:grid;grid-template-columns:1fr 1fr 1fr 40px;gap:8px;margin-bottom:8px;align-items:end';
  div.innerHTML = `
    <div class="form-group" style="margin-bottom:0">
      <label style="font-size:0.75rem">Debt Name</label>
      <input type="text" id="debt-name-${debtCount}" value="Debt ${debtCount}" style="padding:8px 10px;font-size:0.85rem">
    </div>
    <div class="form-group" style="margin-bottom:0">
      <label style="font-size:0.75rem">Balance</label>
      <input type="number" id="debt-bal-${debtCount}" min="0" step="100" value="5000" style="padding:8px 10px;font-size:0.85rem">
    </div>
    <div class="form-group" style="margin-bottom:0">
      <label style="font-size:0.75rem">APR %</label>
      <input type="number" id="debt-apr-${debtCount}" min="0" step="0.1" value="22.9" style="padding:8px 10px;font-size:0.85rem">
    </div>
    <button class="btn-remove" onclick="removeDebt('debt-${debtCount}')" style="margin-bottom:1px">✕</button>
  `;
  container.appendChild(div);
}
function removeDebt(id) {
  const el = $(id);
  if (el) el.remove();
}
function calcDebt() {
  const monthlyPayment = val('debt-payment');
  const entries = document.querySelectorAll('.debt-entry');
  const debts = [];
  entries.forEach(e => {
    const id = e.id.replace('debt-', '');
    const bal = val('debt-bal-' + id);
    const apr = val('debt-apr-' + id);
    const name = document.getElementById('debt-name-' + id)?.value || 'Debt';
    if (bal > 0) debts.push({ name, balance: bal, apr: apr, monthlyRate: apr / 100 / 12 });
  });
  const results = $('debt-results');
  if (!debts.length || !monthlyPayment) { results.innerHTML = '<p class="result-label" style="color:var(--gray-400)">Add at least one debt and a monthly payment</p>'; return; }
  // Snowball: sort by balance
  const snowball = [...debts].sort((a, b) => a.balance - b.balance);
  // Avalanche: sort by APR
  const avalanche = [...debts].sort((a, b) => b.apr - a.apr);
  function simulate(order, extraLabel) {
    let remaining = monthlyPayment;
    let totalMonths = 0;
    let totalInterest = 0;
    const results = [];
    order.forEach(d => {
      let bal = d.balance;
      let months = 0;
      let interest = 0;
      let payment = remaining;
      while (bal > 0.01 && months < 600) {
        const intPart = bal * d.monthlyRate;
        interest += intPart;
        bal += intPart;
        const pay = Math.min(payment, bal);
        bal -= pay;
        months++;
        totalMonths++;
      }
      totalInterest += interest;
      results.push({ name: d.name, months, interest, payment: remaining });
      remaining += payment;
    });
    return { totalMonths, totalInterest, results };
  }
  const sb = simulate(snowball, 'Snowball');
  const av = simulate(avalanche, 'Avalanche');
  function table(data, label, totalMonths, totalInterest) {
    let rows = data.results.map(r => `
      <tr>
        <td>${r.name}</td>
        <td>${r.months} mo</td>
        <td>${fmtDec(Math.round(r.interest))}</td>
      </tr>
    `).join('');
    return `
      <h3>${label} Method</h3>
      <div style="display:flex;gap:16px;margin:8px 0">
        <span style="font-size:0.9rem;font-weight:600;">Paid off in <strong style="color:var(--green-700)">${totalMonths} months</strong></span>
        <span style="font-size:0.9rem;font-weight:600;">Total interest: <strong style="color:var(--red-500)">${fmtDec(Math.round(totalInterest))}</strong></span>
      </div>
      <table class="comparison-table">
        <thead><tr><th>Debt</th><th>Time</th><th>Interest Paid</th></tr></thead>
        <tbody>${rows}</tbody>
      </table>
    `;
  }
  results.innerHTML = `
    <div class="results-grid">
      <div class="result-stat"><div class="value">${debts.length}</div><div class="label">Debts</div></div>
      <div class="result-stat"><div class="value">${fmtDec(debts.reduce((s,d) => s+d.balance, 0))}</div><div class="label">Total Debt</div></div>
      <div class="result-stat"><div class="value">${fmtDec(monthlyPayment)}</div><div class="label">Monthly Payment</div></div>
      <div class="result-stat"><div class="value" style="font-size:1.1rem">${sb.totalMonths} / ${av.totalMonths} mo</div><div class="label">Snowball vs Avalanche</div></div>
    </div>
    <div class="comparison">${table(sb, 'Snowball', sb.totalMonths, sb.totalInterest)}</div>
    <div class="comparison">${table(av, 'Avalanche', av.totalMonths, av.totalInterest)}</div>
  `;
  const cta = $('debt-cta');
  if (cta) cta.classList.remove('hidden');
}

// ===== SUBSCRIPTION COST CALCULATOR =====
let subCount = 0;
function addSub() {
  subCount++;
  const container = $('sub-entries');
  const div = document.createElement('div');
  div.className = 'sub-entry';
  div.id = 'sub-' + subCount;
  div.style.cssText = 'display:grid;grid-template-columns:1fr 100px 100px 40px;gap:8px;margin-bottom:8px;align-items:end';
  const defaults = [
    { name: 'Netflix', cost: 15.49 }, { name: 'Spotify', cost: 10.99 },
    { name: 'HBO Max', cost: 15.99 }, { name: 'iCloud', cost: 2.99 },
  ];
  const d = defaults[(subCount - 1) % defaults.length];
  div.innerHTML = `
    <div class="form-group" style="margin-bottom:0">
      <label style="font-size:0.75rem">Name</label>
      <input type="text" id="sub-name-${subCount}" value="${d.name} ${subCount > 4 ? '' : ''}" style="padding:8px 10px;font-size:0.85rem">
    </div>
    <div class="form-group" style="margin-bottom:0">
      <label style="font-size:0.75rem">Cost</label>
      <input type="number" id="sub-cost-${subCount}" min="0" step="0.01" value="${d.cost}" style="padding:8px 10px;font-size:0.85rem">
    </div>
    <div class="form-group" style="margin-bottom:0">
      <label style="font-size:0.75rem">/mo or /yr</label>
      <select id="sub-freq-${subCount}" style="padding:8px 10px;font-size:0.85rem">
        <option value="monthly">Monthly</option>
        <option value="yearly">Yearly</option>
      </select>
    </div>
    <button class="btn-remove" onclick="removeSub('sub-${subCount}')" style="margin-bottom:1px">✕</button>
  `;
  container.appendChild(div);
}
function removeSub(id) {
  const el = $(id);
  if (el) el.remove();
}
function calcSubs() {
  const entries = document.querySelectorAll('.sub-entry');
  let monthlyTotal = 0;
  const subs = [];
  entries.forEach(e => {
    const id = e.id.replace('sub-', '');
    const cost = val('sub-cost-' + id);
    const freq = document.getElementById('sub-freq-' + id)?.value || 'monthly';
    if (cost > 0) {
      const monthly = freq === 'yearly' ? cost / 12 : cost;
      monthlyTotal += monthly;
      const name = document.getElementById('sub-name-' + id)?.value || 'Sub';
      subs.push({ name, cost, freq, monthly });
    }
  });
  const results = $('sub-results');
  if (!subs.length) { results.innerHTML = '<p class="result-label" style="color:var(--gray-400)">Add subscriptions above</p>'; return; }
  const yearlyTotal = monthlyTotal * 12;
  const bars = subs.map(s => ({ label: s.name.length > 8 ? s.name.slice(0,7)+'…' : s.name, value: Math.round(s.monthly) }));
  drawBars($('sub-chart'), bars, 320, 200);
  let rows = subs.map(s => `
    <div class="result-row">
      <span class="label">${s.name}</span>
      <span class="value">${fmtDec(s.monthly)}/mo${s.freq === 'yearly' ? ' (billed yearly)' : ''}</span>
    </div>
  `).join('');
  results.innerHTML = `
    <div class="results-grid">
      <div class="result-stat"><div class="value">${fmtDec(Math.round(monthlyTotal))}</div><div class="label">Per Month</div></div>
      <div class="result-stat"><div class="value">${fmtDec(Math.round(yearlyTotal))}</div><div class="label">Per Year</div></div>
      <div class="result-stat"><div class="value">${subs.length}</div><div class="label">Subscriptions</div></div>
      <div class="result-stat"><div class="value" style="color:var(--red-500)">${fmtDec(Math.round(yearlyTotal * 5))}</div><div class="label">5-Year Cost</div></div>
    </div>
    ${rows}
  `;
  const cta = $('sub-cta');
  if (cta) cta.classList.remove('hidden');
}

// ===== 50/30/20 CALCULATOR =====
function calc503020() {
  const income = val('fr-income');
  const needs = val('fr-needs');
  const wants = val('fr-wants');
  const savings = val('fr-savings');
  const results = $('fr-results');
  if (!income) { results.innerHTML = '<p class="result-label" style="color:var(--gray-400)">Enter your after-tax income</p>'; return; }
  const targetNeeds = income * 0.50;
  const targetWants = income * 0.30;
  const targetSavings = income * 0.20;
  const actualTotal = needs + wants + savings;
  results.innerHTML = `
    <div class="results-grid">
      <div class="result-stat"><div class="value">${fmtDec(income)}</div><div class="label">After-Tax Income</div></div>
      <div class="result-stat"><div class="value" style="color:var(--green-700)">${fmtDec(targetSavings)}</div><div class="label">Goal: 20% Savings</div></div>
    </div>
    <div style="margin-top:16px">
      <div class="result-row">
        <span class="label">Needs (50%)</span>
        <span class="value">Target: ${fmtDec(targetNeeds)} ${needs > 0 ? '| Yours: ' + fmtDec(needs) : ''}</span>
      </div>
      <div class="result-row">
        <span class="label">Wants (30%)</span>
        <span class="value">Target: ${fmtDec(targetWants)} ${wants > 0 ? '| Yours: ' + fmtDec(wants) : ''}</span>
      </div>
      <div class="result-row">
        <span class="label">Savings (20%)</span>
        <span class="value">Target: ${fmtDec(targetSavings)} ${savings > 0 ? '| Yours: ' + fmtDec(savings) : ''}</span>
      </div>
    </div>
    <div style="margin-top:16px" class="${needs > 0 || wants > 0 || savings > 0 ? '' : 'hidden'}">
      <hr style="border:none;border-top:1px solid var(--gray-200);margin-bottom:16px">
      <p style="font-size:0.9rem;color:var(--gray-600)">
        ${savings >= targetSavings ? '✅ You\'re saving enough! Great job.' : savings > 0 ? '⚠️ You\'re saving ' + fmtDec(savings) + ' of ' + fmtDec(targetSavings) + ' target.' : ''}
        ${actualTotal > income ? '<br>⚠️ Your spending exceeds your income.' : ''}
      </p>
    </div>
  `;
  const canvas = $('fr-chart');
  drawDonut(canvas, [
    { value: Math.max(0, income > 0 ? targetNeeds : 0) },
    { value: Math.max(0, income > 0 ? targetWants : 0) },
    { value: Math.max(0, income > 0 ? targetSavings : 0) },
  ], 200);
  const cta = $('fr-cta');
  if (cta) cta.classList.remove('hidden');
}

// ===== INITIALIZE =====
document.addEventListener('DOMContentLoaded', () => {
  // Initialize with one debt entry
  addDebt();
  // Initialize with subscription entries
  addSub(); addSub(); addSub();
  // Auto-calculate on homepage if fields exist
  ['sc-income','sc-bills','sc-savings'].forEach(id => {
    const el = $(id);
    if (el) el.addEventListener('input', calcSpendingCapacity);
  });
  calcSpendingCapacity();
});
