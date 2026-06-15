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

const $ = id => document.getElementById(id);
const val = id => parseFloat($(id).value) || 0;
const fmtDec = n => '$' + n.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const pct = n => n.toFixed(1) + '%';

const ctxText = text => `<div class="info-note" style="margin-top:16px;font-size:0.85rem"><strong style="color:var(--text)">How Receet Pro helps:</strong> ${text}</div>`;
const cmpText = `<div class="info-note" style="margin-top:12px;font-size:0.85rem"><strong style="color:var(--text)">Without Receet Pro:</strong> Recalculate manually. Spreadsheets. Stress.<br><br><strong style="color:var(--text)">With Receet Pro:</strong> Updates automatically from your transactions. Envelope balances refresh instantly. No math required.</div>`;

const CHART_COLORS = ['#0d9488','#3b82f6','#f59e0b','#ef4444','#8b5cf6','#ec4899','#14b8a6','#f97316','#6366f1','#84cc16'];

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
  const cx = s / 2, cy = s / 2, r = s * 0.4, ir = s * 0.22;
  const total = slices.reduce((sum, sl) => sum + sl.value, 0);
  if (total === 0) { ctx.font = `${s*0.07}px Inter, sans-serif`; ctx.textAlign = 'center'; ctx.fillStyle = '#a8a29e'; ctx.fillText('No data', cx, cy + 4); return; }
  let start = -Math.PI / 2;
  const gap = 0.015;
  slices.forEach((slice, i) => {
    const rawAngle = (slice.value / total) * Math.PI * 2;
    const angle = Math.max(rawAngle - gap, 0);
    ctx.beginPath();
    ctx.arc(cx, cy, r, start + gap/2, start + gap/2 + angle);
    ctx.arc(cx, cy, ir, start + gap/2 + angle, start + gap/2, true);
    ctx.closePath();
    ctx.fillStyle = CHART_COLORS[i % CHART_COLORS.length];
    ctx.fill();
    start += rawAngle;
  });
  ctx.beginPath();
  ctx.arc(cx, cy, ir, 0, Math.PI * 2);
  ctx.fillStyle = '#0b0f19';
  ctx.fill();
  ctx.fillStyle = '#cbd5e1';
  ctx.font = `bold ${s*0.1}px Inter, sans-serif`;
  ctx.textAlign = 'center';
  ctx.textBaseline = 'middle';
  ctx.fillText(fmtDec(total), cx, cy - 2);
  ctx.fillStyle = '#64748b';
  ctx.font = `${s*0.055}px Inter, sans-serif`;
  ctx.fillText('Total', cx, cy + s*0.07);
}

function drawBars(canvas, bars, width, height) {
  if (!canvas) return;
  const dpr = window.devicePixelRatio || 1;
  const w = width || 320, h = height || 220;
  canvas.width = w * dpr;
  canvas.height = h * dpr;
  canvas.style.width = w + 'px';
  canvas.style.height = h + 'px';
  const ctx = canvas.getContext('2d');
  ctx.scale(dpr, dpr);
  ctx.clearRect(0, 0, w, h);
  if (!bars.length) return;
  const max = Math.max(...bars.map(b => b.value), 1);
  const pad = { t: 22, r: 16, b: 42, l: 12 };
  const cw = w - pad.l - pad.r;
  const ch = h - pad.t - pad.b;
  const gap = cw / bars.length;
  const bw = Math.min(gap * 0.6, 42);
  const colors = CHART_COLORS;
  bars.forEach((bar, i) => {
    const bh = Math.max((bar.value / max) * ch, 2);
    const x = pad.l + gap * i + (gap - bw) / 2;
    const y = pad.t + ch - bh;
    const grad = ctx.createLinearGradient(x, y, x, pad.t + ch);
    const c = colors[i % colors.length];
    grad.addColorStop(0, c);
    grad.addColorStop(1, c + '99');
    ctx.fillStyle = grad;
    ctx.beginPath();
    ctx.roundRect(x, y, bw, bh, [4, 4, 0, 0]);
    ctx.fill();
    ctx.fillStyle = '#64748b';
    ctx.font = '10px Inter, sans-serif';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'top';
    ctx.fillText(bar.label, x + bw / 2, h - pad.b + 8);
    ctx.fillStyle = '#cbd5e1';
    ctx.font = 'bold 11px Inter, sans-serif';
    ctx.textBaseline = 'bottom';
    ctx.fillText(fmtDec(bar.value), x + bw / 2, y - 3);
  });
}

function calcSpendingCapacity() {
  const income = val('sc-income');
  const bills = val('sc-bills');
  const savings = val('sc-savings');
  const capacity = income - bills - savings;
  const result = $('sc-result');
  const breakdown = $('sc-breakdown');
  if (!income) { result.innerHTML = '<p style="color:var(--text-muted);font-size:0.9rem">Enter your income above</p>'; breakdown.innerHTML = ''; return; }
  result.innerHTML = `
    <div class="result-number large">${fmtDec(Math.max(0, capacity))}</div>
    <div class="result-label">Your safe spending amount this month</div>
  `;
  breakdown.innerHTML = `
    <div class="result-row"><span class="label">Monthly Income</span><span class="value">${fmtDec(income)}</span></div>
    <div class="result-row"><span class="label">Fixed Bills</span><span class="value negative">-${fmtDec(bills)}</span></div>
    <div class="result-row"><span class="label">Savings Goal</span><span class="value negative">-${fmtDec(savings)}</span></div>
    <div class="result-row" style="border-top:2px solid var(--border-light);margin-top:4px;padding-top:14px">
      <span class="label" style="font-weight:600">Remaining for Spending</span>
      <span class="value positive" style="font-weight:700">${fmtDec(Math.max(0, capacity))}</span>
    </div>
  `;
  drawDonut($('sc-chart'), [
    { value: Math.max(0, bills) }, { value: Math.max(0, savings) }, { value: Math.max(0, capacity) }
  ], 220);
  const scCtx = $('sc-ctx');
  if (scCtx) scCtx.innerHTML = ctxText('Receet Pro automatically tracks your income, bills, and savings goals — so you always know your safe spending amount in one tap. No manual calculations needed.') + cmpText;
}

function calcBudget() {
  const income = val('bp-income');
  const housing = val('bp-housing'), utilities = val('bp-utilities');
  const food = val('bp-food'), transport = val('bp-transport');
  const insurance = val('bp-insurance'), debt = val('bp-debt');
  const savings = val('bp-savings-goal'), entertainment = val('bp-entertainment'), other = val('bp-other');
  const totalExpenses = housing + utilities + food + transport + insurance + debt + entertainment + other;
  const remaining = income - totalExpenses - savings;
  const results = $('bp-content');
  if (!results) return;
  if (!income) { results.innerHTML = '<p style="color:var(--text-muted);font-size:0.9rem">Enter your income to see your budget</p>'; return; }
  const categories = [
    { label: 'Housing', value: housing }, { label: 'Utilities', value: utilities },
    { label: 'Food & Groceries', value: food }, { label: 'Transportation', value: transport },
    { label: 'Insurance', value: insurance }, { label: 'Debt Payments', value: debt },
    { label: 'Entertainment', value: entertainment }, { label: 'Other', value: other },
  ];
  const nonZero = categories.filter(c => c.value > 0);
  drawDonut($('bp-donut'), nonZero.map(c => ({ value: c.value })), 200);
  drawBars($('bp-chart'), nonZero.map(c => ({ label: c.label.split(' ')[0], value: Math.round(c.value) })), 320, 200);
  const statusColor = remaining >= 0 ? 'var(--success)' : 'var(--danger)';
  results.innerHTML = `
    <div class="results-grid">
      <div class="result-stat"><div class="value">${fmtDec(income)}</div><div class="label">Monthly Income</div></div>
      <div class="result-stat"><div class="value">${fmtDec(totalExpenses)}</div><div class="label">Total Expenses</div></div>
      <div class="result-stat"><div class="value" style="color:${statusColor}">${fmtDec(Math.abs(remaining))}</div><div class="label">${remaining >= 0 ? 'Remaining' : 'Overspent'}</div></div>
      <div class="result-stat"><div class="value">${fmtDec(savings)}</div><div class="label">Savings Goal</div></div>
    </div>
    ${categories.map(c => `
      <div class="result-row"><span class="label">${c.label}</span><span class="value">${fmtDec(c.value)}</span></div>
    `).join('')}
    <div class="result-row" style="border-top:2px solid var(--border-light);margin-top:4px;padding-top:14px">
      <span class="label" style="font-weight:600">${remaining >= 0 ? 'After Savings' : 'Adjustment Needed'}</span>
      <span class="value ${remaining >= 0 ? 'positive' : 'negative'}" style="font-weight:700">${remaining >= 0 ? fmtDec(remaining) : '- ' + fmtDec(Math.abs(remaining))}</span>
    </div>
  `;
  results.innerHTML += ctxText('Receet Pro automatically sorts every transaction into categories and shows your real-time budget breakdown. No manual data entry or spreadsheets.') + cmpText;
  const cta = $('bp-cta');
  if (cta) cta.classList.remove('hidden');
}

function calcPaycheck() {
  const freq = $('pc-frequency').value;
  const perPaycheck = val('pc-income');
  const monthlyBills = val('pc-bills');
  const ppm = { weekly: 4.33, biweekly: 2.17, 'semi-monthly': 2, monthly: 1 }[freq] || 4.33;
  const monthlyIncome = perPaycheck * ppm;
  const afterBills = monthlyIncome - monthlyBills;
  const perPeriod = afterBills / ppm;
  const results = $('pc-content');
  if (!results) return;
  if (!perPaycheck) { results.innerHTML = '<p style="color:var(--text-muted);font-size:0.9rem">Enter your paycheck amount</p>'; return; }
  const envelopes = [
    { label: 'Groceries', pct: 0.25 }, { label: 'Dining Out', pct: 0.10 },
    { label: 'Gas & Transport', pct: 0.15 }, { label: 'Shopping', pct: 0.10 },
    { label: 'Entertainment', pct: 0.10 }, { label: 'Savings', pct: 0.20 },
    { label: 'Miscellaneous', pct: 0.10 },
  ];
  const freqLabel = { weekly: 'Week', biweekly: '2 Weeks', 'semi-monthly': 'Half-Month', monthly: 'Month' };
  drawBars($('pc-chart'), envelopes.map(e => ({ label: e.label.split(' ')[0], value: Math.round(perPeriod * e.pct) })), 320, 200);
  results.innerHTML = `
    <div class="results-grid">
      <div class="result-stat"><div class="value">${fmtDec(perPaycheck)}</div><div class="label">Per ${freqLabel[freq]}</div></div>
      <div class="result-stat"><div class="value">${fmtDec(monthlyIncome)}</div><div class="label">Monthly Income</div></div>
      <div class="result-stat"><div class="value">${fmtDec(monthlyBills)}</div><div class="label">Monthly Bills</div></div>
      <div class="result-stat"><div class="value" style="color:var(--success)">${fmtDec(Math.max(0, perPeriod))}</div><div class="label">Per ${freqLabel[freq]} to Spend</div></div>
    </div>
    <div style="margin-top:20px">
      <h3 style="font-size:0.875rem;font-weight:600;margin-bottom:12px;color:var(--text-secondary);text-transform:uppercase;letter-spacing:0.04em">Suggested Envelopes (per ${freqLabel[freq].toLowerCase()})</h3>
      ${envelopes.map(e => `
        <div class="result-row"><span class="label">${e.label}</span><span class="value positive">${fmtDec(perPeriod * e.pct)}</span></div>
      `).join('')}
    </div>
  `;
  results.innerHTML += ctxText('Receet Pro creates envelopes for each spending category and automatically distributes your paycheck. No manual splitting or spreadsheets.') + cmpText;
  const cta = $('pc-cta');
  if (cta) cta.classList.remove('hidden');
}

function calcEmergency() {
  const monthly = val('ef-monthly'), months = val('ef-months');
  const current = val('ef-current'), monthlySave = val('ef-save');
  const target = monthly * months;
  const needed = Math.max(0, target - current);
  const timeMonths = monthlySave > 0 ? needed / monthlySave : 0;
  const progress = target > 0 ? Math.min(100, (current / target) * 100) : 0;
  const results = $('ef-results');
  if (!monthly) { results.innerHTML = '<p style="color:var(--text-muted);font-size:0.9rem">Enter your monthly expenses</p>'; return; }
  const isComplete = needed <= 0;
  results.innerHTML = `
    <h2>Your Emergency Fund Plan</h2>
    <div class="results-grid">
      <div class="result-stat"><div class="value">${fmtDec(target)}</div><div class="label">Target Emergency Fund</div></div>
      <div class="result-stat"><div class="value" style="color:var(--text)">${fmtDec(current)}</div><div class="label">Current Savings</div></div>
      <div class="result-stat"><div class="value" style="color:${isComplete ? 'var(--success)' : 'var(--danger)'}">${fmtDec(needed)}</div><div class="label">${isComplete ? 'Fully Funded ✓' : 'Still Needed'}</div></div>
      <div class="result-stat"><div class="value">${timeMonths > 0 ? Math.ceil(timeMonths) + ' mo' : isComplete ? '—' : '—'}</div><div class="label">${monthlySave > 0 ? 'Time to Goal' : 'Set savings rate'}</div></div>
    </div>
    <div style="margin-top:24px">
      <div style="display:flex;justify-content:space-between;font-size:0.8125rem;color:var(--text-secondary);margin-bottom:8px">
        <span>Progress</span><span style="font-weight:600">${pct(progress)}</span>
      </div>
      <div style="height:10px;background:var(--bg-alt);border-radius:99px;overflow:hidden">
        <div style="height:100%;width:${progress}%;background:linear-gradient(90deg,var(--primary),var(--success));border-radius:99px;transition:width 0.5s ease"></div>
      </div>
    </div>
    <div class="info-note">
      ${isComplete ? '✅ You\'ve fully funded your emergency fund!' : monthlySave > 0 ? `At <strong>${fmtDec(monthlySave)}/month</strong>, you'll reach your <strong>${months}-month</strong> emergency fund in <strong>${Math.ceil(timeMonths)} months</strong>.` : 'Set a monthly savings amount above to see how long it will take.'}
    </div>
  `;
  results.innerHTML += ctxText('Receet Pro creates a dedicated Emergency Fund envelope and automatically tracks every contribution toward your goal. Progress updates in real time.') + cmpText;
  const cta = $('ef-cta');
  if (cta) cta.classList.remove('hidden');
}

let debtCount = 0;
function addDebt() {
  debtCount++;
  const container = $('debt-entries');
  if (!container) return;
  const div = document.createElement('div');
  div.className = 'debt-entry';
  div.id = 'debt-' + debtCount;
  div.style.cssText = 'display:grid;grid-template-columns:1fr 1fr 1fr 40px;gap:10px;margin-bottom:10px;align-items:end';
  div.innerHTML = `
    <div class="form-group" style="margin-bottom:0">
      <label style="font-size:0.75rem;letter-spacing:0.04em">Name</label>
      <input type="text" id="debt-name-${debtCount}" value="Debt ${debtCount}" style="padding:9px 12px;font-size:0.85rem">
    </div>
    <div class="form-group" style="margin-bottom:0">
      <label style="font-size:0.75rem;letter-spacing:0.04em">Balance</label>
      <input type="number" id="debt-bal-${debtCount}" min="0" step="100" value="${5000 + (debtCount-1) * 2000}" style="padding:9px 12px;font-size:0.85rem">
    </div>
    <div class="form-group" style="margin-bottom:0">
      <label style="font-size:0.75rem;letter-spacing:0.04em">APR %</label>
      <input type="number" id="debt-apr-${debtCount}" min="0" step="0.1" value="${[22.9, 18.5, 15.0][(debtCount-1) % 3] || 20}" style="padding:9px 12px;font-size:0.85rem">
    </div>
    <button class="btn-remove" onclick="removeDebt('debt-${debtCount}')" style="margin-bottom:2px">✕</button>
  `;
  container.appendChild(div);
}
function removeDebt(id) { const el = $(id); if (el) el.remove(); }

function calcDebt() {
  const monthlyPayment = val('debt-payment');
  const entries = document.querySelectorAll('.debt-entry');
  const debts = [];
  entries.forEach(e => {
    const id = e.id.replace('debt-', '');
    const bal = val('debt-bal-' + id), apr = val('debt-apr-' + id);
    const name = document.getElementById('debt-name-' + id)?.value || 'Debt';
    if (bal > 0) debts.push({ name, balance: bal, apr, monthlyRate: apr / 100 / 12 });
  });
  const results = $('debt-results');
  if (!debts.length || !monthlyPayment) { results.innerHTML = '<p style="color:var(--text-muted);font-size:0.9rem">Add at least one debt and a monthly payment</p>'; return; }
  function simulate(list) {
    let avail = monthlyPayment, totalMonths = 0, totalInterest = 0;
    const lines = [];
    list.forEach(d => {
      let bal = d.balance, intTotal = 0, m = 0, pay = avail;
      while (bal > 0.01 && m < 600) {
        const i = bal * d.monthlyRate;
        intTotal += i; bal += i;
        const p = Math.min(pay, bal);
        bal -= p; m++; totalMonths++;
      }
      totalInterest += intTotal;
      lines.push({ name: d.name, months: m, interest: intTotal, payment: avail });
      avail += pay;
    });
    return { totalMonths, totalInterest, results: lines };
  }
  const sb = simulate([...debts].sort((a, b) => a.balance - b.balance));
  const av = simulate([...debts].sort((a, b) => b.apr - a.apr));
  const dfDate = new Date();
  dfDate.setMonth(dfDate.getMonth() + sb.totalMonths);
  const dfString = dfDate.toLocaleDateString('en-US', { month: 'long', year: 'numeric' });
  const methodSavings = Math.round(Math.abs(sb.totalInterest - av.totalInterest));
  const fasterLabel = sb.totalMonths < av.totalMonths ? 'Snowball' : 'Avalanche';
  const diffMonths = Math.abs(sb.totalMonths - av.totalMonths);
  const renderTable = (data, label) => `
    <div style="margin-top:20px">
      <h3 style="font-size:0.9375rem;font-weight:600;margin-bottom:10px;display:flex;align-items:center;gap:8px">
        <span style="display:inline-flex;align-items:center;justify-content:center;width:24px;height:24px;border-radius:50%;background:var(--primary-bg);font-size:0.75rem">${label === 'Snowball' ? '📦' : '⚡'}</span>
        ${label} Method
      </h3>
      <div style="display:flex;gap:20px;margin-bottom:12px;font-size:0.875rem">
        <span>Paid off in <strong>${data.totalMonths} months</strong></span>
        <span>Total interest: <strong style="color:var(--danger)">${fmtDec(Math.round(data.totalInterest))}</strong></span>
      </div>
      <table class="comparison-table">
        <thead><tr><th>Debt</th><th>Time</th><th>Interest Paid</th></tr></thead>
        <tbody>${data.results.map(r => `<tr><td>${r.name}</td><td>${r.months} mo</td><td>${fmtDec(Math.round(r.interest))}</td></tr>`).join('')}</tbody>
      </table>
    </div>
  `;
  const bestLabel = sb.totalInterest <= av.totalInterest ? 'Snowball' : 'Avalanche';
  results.innerHTML = `
    <h2>Your Debt Payoff Plan</h2>
    <div class="results-grid">
      <div class="result-stat"><div class="value">${debts.length}</div><div class="label">Debts</div></div>
      <div class="result-stat"><div class="value">${fmtDec(debts.reduce((s,d) => s+d.balance, 0))}</div><div class="label">Total Debt</div></div>
      <div class="result-stat"><div class="value">${fmtDec(monthlyPayment)}</div><div class="label">Monthly Payment</div></div>
      <div class="result-stat"><div class="value" style="font-size:1rem;color:var(--success)">${dfString}</div><div class="label">Debt Free By (Snowball)</div></div>
    </div>
    ${methodSavings > 0 ? `<div class="info-note" style="text-align:center;font-size:0.9rem">⚡ The <strong>${bestLabel}</strong> method saves you <strong>${fmtDec(methodSavings)}</strong> in interest${diffMonths > 0 ? ` and gets you debt free ${diffMonths} months sooner` : ''}.</div>` : ''}
    ${renderTable(sb, 'Snowball')}
    ${renderTable(av, 'Avalanche')}
  `;
  results.innerHTML += ctxText('Receet Pro tracks every debt payment in real time and shows your progress toward being debt free. No spreadsheets required.') + cmpText;
  const cta = $('debt-cta');
  if (cta) cta.classList.remove('hidden');
}

let subCount = 0;
function addSub() {
  subCount++;
  const container = $('sub-entries');
  if (!container) return;
  const div = document.createElement('div');
  div.className = 'sub-entry';
  div.id = 'sub-' + subCount;
  div.style.cssText = 'display:grid;grid-template-columns:1fr 100px 100px 40px;gap:10px;margin-bottom:10px;align-items:end';
  const defaults = [
    { name: 'Netflix', cost: 15.49 }, { name: 'Spotify', cost: 10.99 },
    { name: 'HBO Max', cost: 15.99 }, { name: 'iCloud', cost: 2.99 },
  ];
  const d = defaults[(subCount - 1) % defaults.length];
  div.innerHTML = `
    <div class="form-group" style="margin-bottom:0">
      <label style="font-size:0.75rem;letter-spacing:0.04em">Name</label>
      <input type="text" id="sub-name-${subCount}" value="${d.name}" style="padding:9px 12px;font-size:0.85rem">
    </div>
    <div class="form-group" style="margin-bottom:0">
      <label style="font-size:0.75rem;letter-spacing:0.04em">Cost</label>
      <input type="number" id="sub-cost-${subCount}" min="0" step="0.01" value="${d.cost}" style="padding:9px 12px;font-size:0.85rem">
    </div>
    <div class="form-group" style="margin-bottom:0">
      <label style="font-size:0.75rem;letter-spacing:0.04em">/mo or /yr</label>
      <select id="sub-freq-${subCount}" style="padding:9px 12px;font-size:0.85rem">
        <option value="monthly">Monthly</option>
        <option value="yearly">Yearly</option>
      </select>
    </div>
    <button class="btn-remove" onclick="removeSub('sub-${subCount}')" style="margin-bottom:2px">✕</button>
  `;
  container.appendChild(div);
}
function removeSub(id) { const el = $(id); if (el) el.remove(); }

function calcSubs() {
  const entries = document.querySelectorAll('.sub-entry');
  const income = val('sub-income');
  let monthlyTotal = 0;
  const subs = [];
  entries.forEach(e => {
    const id = e.id.replace('sub-', '');
    const cost = val('sub-cost-' + id);
    const freq = document.getElementById('sub-freq-' + id)?.value || 'monthly';
    if (cost > 0) {
      const m = freq === 'yearly' ? cost / 12 : cost;
      monthlyTotal += m;
      subs.push({ name: document.getElementById('sub-name-' + id)?.value || 'Sub', monthly: m, freq });
    }
  });
  const results = $('sub-content');
  if (!results) return;
  if (!subs.length) { results.innerHTML = '<p style="color:var(--text-muted);font-size:0.9rem">Add subscriptions above</p>'; return; }
  const yearlyTotal = monthlyTotal * 12;
  const incomePct = income > 0 ? (monthlyTotal / income) * 100 : 0;
  const biggest = subs.reduce((max, s) => s.monthly > max.monthly ? s : max, subs[0]);
  const fiveYearSave = Math.round(biggest.monthly * 12 * 5);
  drawBars($('sub-chart'), subs.map(s => ({ label: s.name.length > 8 ? s.name.slice(0,7)+'…' : s.name, value: Math.round(s.monthly) })), 320, 200);
  results.innerHTML = `
    <div class="results-grid">
      <div class="result-stat"><div class="value">${fmtDec(Math.round(monthlyTotal))}</div><div class="label">Per Month</div></div>
      <div class="result-stat"><div class="value">${fmtDec(Math.round(yearlyTotal))}</div><div class="label">Per Year</div></div>
      <div class="result-stat"><div class="value">${subs.length}</div><div class="label">Subscriptions</div></div>
      <div class="result-stat"><div class="value" style="color:var(--danger)">${fmtDec(Math.round(yearlyTotal * 5))}</div><div class="label">5-Year Cost</div></div>
    </div>
    ${incomePct > 0 ? `<div class="info-note" style="text-align:center;font-size:0.9rem;margin-bottom:16px">Your subscriptions consume <strong>${pct(incomePct)}</strong> of your monthly income.</div>` : ''}
    ${subs.map(s => `
      <div class="result-row"><span class="label">${s.name}</span><span class="value">${fmtDec(s.monthly)}/mo${s.freq === 'yearly' ? ' (billed annually)' : ''}</span></div>
    `).join('')}
    <div class="info-note" style="margin-top:16px;font-size:0.85rem">
      💡 Cancel <strong>${biggest.name}</strong> and you'd save <strong>${fmtDec(fiveYearSave)}</strong> over 5 years.
    </div>
  `;
  results.innerHTML += ctxText('Receet Pro automatically detects recurring charges and tracks every subscription in one place. Know exactly what you\'re spending — and cancel what you don\'t need.') + cmpText;
  const cta = $('sub-cta');
  if (cta) cta.classList.remove('hidden');
}

function calc503020() {
  const income = val('fr-income'), needs = val('fr-needs'), wants = val('fr-wants'), savings = val('fr-savings');
  const results = $('fr-content');
  if (!results) return;
  if (!income) { results.innerHTML = '<p style="color:var(--text-muted);font-size:0.9rem">Enter your after-tax income</p>'; return; }
  const tNeeds = income * 0.50, tWants = income * 0.30, tSavings = income * 0.20;
  drawDonut($('fr-chart'), [{ value: tNeeds }, { value: tWants }, { value: tSavings }], 200);
  const hasActuals = needs > 0 || wants > 0 || savings > 0;
  results.innerHTML = `
    <div class="results-grid">
      <div class="result-stat"><div class="value">${fmtDec(income)}</div><div class="label">After-Tax Income</div></div>
      <div class="result-stat"><div class="value" style="color:var(--success)">${fmtDec(tSavings)}</div><div class="label">Target: 20% Savings</div></div>
    </div>
    <div style="margin-top:16px">
      <div class="result-row"><span class="label"><span style="display:inline-block;width:10px;height:10px;border-radius:50%;background:${CHART_COLORS[0]};margin-right:8px"></span>Needs (50%)</span><span class="value">${fmtDec(tNeeds)}${hasActuals ? `<span style="color:var(--text-muted);font-weight:400;font-size:0.85rem"> &middot; Yours: ${fmtDec(needs)}</span>` : ''}</span></div>
      <div class="result-row"><span class="label"><span style="display:inline-block;width:10px;height:10px;border-radius:50%;background:${CHART_COLORS[1]};margin-right:8px"></span>Wants (30%)</span><span class="value">${fmtDec(tWants)}${hasActuals ? `<span style="color:var(--text-muted);font-weight:400;font-size:0.85rem"> &middot; Yours: ${fmtDec(wants)}</span>` : ''}</span></div>
      <div class="result-row"><span class="label"><span style="display:inline-block;width:10px;height:10px;border-radius:50%;background:${CHART_COLORS[2]};margin-right:8px"></span>Savings (20%)</span><span class="value">${fmtDec(tSavings)}${hasActuals ? `<span style="color:var(--text-muted);font-weight:400;font-size:0.85rem"> &middot; Yours: ${fmtDec(savings)}</span>` : ''}</span></div>
    </div>
    ${hasActuals ? `
    <div class="info-note" style="margin-top:16px">
      ${savings >= tSavings ? '✅ Great job — you\'re saving enough!' : savings > 0 ? `⚠️ You're saving <strong>${fmtDec(savings)}</strong> of your <strong>${fmtDec(tSavings)}</strong> target.` : ''}
      ${needs + wants + savings > income ? '<br>⚠️ Your total spending exceeds your income.' : ''}
    </div>` : ''}
  `;
  results.innerHTML += ctxText('Receet Pro automatically categorizes every transaction so you can see your exact needs/wants/savings split — without manual work or spreadsheets.') + cmpText;
  const cta = $('fr-cta');
  if (cta) cta.classList.remove('hidden');
}

document.addEventListener('DOMContentLoaded', () => {
  if ($('debt-entries')) addDebt();
  if ($('sub-entries')) { addSub(); addSub(); addSub(); }
  ['sc-income','sc-bills','sc-savings'].forEach(id => {
    const el = $(id);
    if (el) el.addEventListener('input', calcSpendingCapacity);
  });
  calcSpendingCapacity();

  ['bp-income','bp-housing','bp-utilities','bp-food','bp-transport','bp-insurance','bp-debt','bp-savings-goal','bp-entertainment','bp-other'].forEach(id => {
    const el = $(id);
    if (el) el.addEventListener('input', calcBudget);
  });
  ['pc-frequency','pc-income','pc-bills'].forEach(id => {
    const el = $(id);
    if (el) el.addEventListener('input', calcPaycheck);
  });
  ['ef-monthly','ef-months','ef-current','ef-save'].forEach(id => {
    const el = $(id);
    if (el) el.addEventListener('input', calcEmergency);
  });
  ['debt-payment'].forEach(id => {
    const el = $(id);
    if (el) el.addEventListener('input', calcDebt);
  });
  ['sub-income'].forEach(id => {
    const el = $(id);
    if (el) el.addEventListener('input', calcSubs);
  });
  ['fr-income','fr-needs','fr-wants','fr-savings'].forEach(id => {
    const el = $(id);
    if (el) el.addEventListener('input', calc503020);
  });
  const debtEntries = $('debt-entries');
  if (debtEntries) {
    debtEntries.addEventListener('input', calcDebt);
    const dp = $('debt-payment');
    if (dp) dp.addEventListener('input', calcDebt);
  }
  const subEntries = $('sub-entries');
  if (subEntries) {
    subEntries.addEventListener('input', calcSubs);
  }
  if ($('bp-income')) calcBudget();
  if ($('pc-income')) calcPaycheck();
  if ($('ef-monthly')) calcEmergency();
  if ($('debt-payment')) calcDebt();
  if ($('sub-entries')) calcSubs();
  if ($('fr-income')) calc503020();
});
