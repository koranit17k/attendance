const BASE_URL = "http://192.168.30.162:8080/kxreport/"

function openWin() {
    return window.open("", "_blank")
}

function getFormDataAsJson() {
    const form = document.getElementById("form")
    const data = Object.fromEntries(new FormData(form).entries())
    return data
}

function getPDF() {
    const data = getFormDataAsJson()
    const params = new URLSearchParams(data)
    const url = BASE_URL + "getPDF?" + params.toString()
    window.open(url, "_blank")
}

async function openPDF() {
    const reportWindow = openWin()
    try {
        const data = getFormDataAsJson()

        const response = await fetch(BASE_URL + "openPDF", {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
            },
            body: JSON.stringify(data),
        })

        if (!response.ok) {
            throw new Error(`Service call failed with status: ${response.status}`)
        }
        const blob = await response.blob();
        const blobUrl = URL.createObjectURL(blob);
        reportWindow.location.href = blobUrl;
    } catch (error) {
        console.error("Error calling FilePDF:", error)
        alert(`KX Report Error: ${error.message}`)

        if (reportWindow) {
            reportWindow.close()
        }
    }
}

// Calendar Logic
const monthNames = [
  "มกราคม", "กุมภาพันธ์", "มีนาคม", "เมษายน", "พฤษภาคม", "มิถุนายน",
  "กรกฎาคม", "สิงหาคม", "กันยายน", "ตุลาคม", "พฤศจิกายน", "ธันวาคม"
];

const quarterNames = ["ไตรมาส 1", "ไตรมาส 2", "ไตรมาส 3", "ไตรมาส 4"];
const weekdays = ["อา", "จ", "อ", "พ", "พฤ", "ศ", "ส"];

let startDate = null;
let endDate = null;
let hoverDate = null;
let activePreset = "year";

const today = new Date(2025, 11, 1);
today.setHours(0, 0, 0, 0);

let viewMonth = 11; // December
let viewYear = 2025;

function normalizeDate(date) {
  const d = new Date(date);
  d.setHours(0, 0, 0, 0);
  return d;
}

function formatISODate(date) {
  if (!date) return "";
  const y = date.getFullYear();
  const m = String(date.getMonth() + 1).padStart(2, "0");
  const d = String(date.getDate()).padStart(2, "0");
  return `${y}-${m}-${d}`;
}

function parseISODate(iso) {
  if (!iso) return null;
  const [y, m, d] = iso.split("-").map(Number);
  const date = new Date(y, m - 1, d);
  date.setHours(0, 0, 0, 0);
  return date;
}

function parseUserDate(value) {
  const text = value.trim();
  if (!text) return null;

  const match = text.match(/^(\d{4})-(\d{2})-(\d{2})$/);
  if (!match) return null;

  const year = Number(match[1]);
  const month = Number(match[2]);
  const day = Number(match[3]);

  const date = new Date(year, month - 1, day);
  date.setHours(0, 0, 0, 0);

  const isValid =
    date.getFullYear() === year &&
    date.getMonth() === month - 1 &&
    date.getDate() === day;

  return isValid ? date : null;
}

function sameDate(a, b) {
  return !!(a && b && a.getTime() === b.getTime());
}

function normalizeRange(a, b) {
  if (!a || !b) return null;
  return a.getTime() <= b.getTime()
    ? { start: a, end: b }
    : { start: b, end: a };
}

function isBetweenInclusive(date, start, end) {
  return !!(
    start &&
    end &&
    date.getTime() >= start.getTime() &&
    date.getTime() <= end.getTime()
  );
}

function getPreviewRange() {
  if (!startDate || endDate || !hoverDate) return null;
  return normalizeRange(startDate, hoverDate);
}

function getLastDayOfMonth(year, month) {
  return new Date(year, month + 1, 0).getDate();
}

function setInputsFromState() {
  const startDateInput = document.getElementById("startDateInput");
  const endDateInput = document.getElementById("endDateInput");
  // Also update the hidden main form inputs if they exist
  const mainStartDate = document.getElementById("startDate");
  const mainEndDate = document.getElementById("endDate");

  if (startDateInput) startDateInput.value = startDate ? formatISODate(startDate) : "";
  if (endDateInput) endDateInput.value = endDate ? formatISODate(endDate) : "";
  
  if (mainStartDate) mainStartDate.value = startDate ? formatISODate(startDate) : "";
  if (mainEndDate) mainEndDate.value = endDate ? formatISODate(endDate) : "";

  if (startDateInput) startDateInput.classList.remove("invalid");
  if (endDateInput) endDateInput.classList.remove("invalid");
}

function renderWeekdays() {
  const weekdaysContainer = document.getElementById("weekdays");
  if (!weekdaysContainer) return;
  weekdaysContainer.innerHTML = "";
  weekdays.forEach((day) => {
    const el = document.createElement("div");
    el.className = "weekday";
    el.textContent = day;
    weekdaysContainer.appendChild(el);
  });
}

function renderYearOptions() {
  const yearSelect = document.getElementById("yearSelect");
  if (!yearSelect) return;
  yearSelect.innerHTML = "";
  const startYear = today.getFullYear() - 10;
  const endYear = today.getFullYear() + 10;

  for (let year = startYear; year <= endYear; year++) {
    const option = document.createElement("option");
    option.value = year;
    option.textContent = year;
    yearSelect.appendChild(option);
  }
}

function renderMonthOptions() {
  const monthSelect = document.getElementById("monthSelect");
  if (!monthSelect) return;
  monthSelect.innerHTML = "";

  const allOption = document.createElement("option");
  allOption.value = "";
  allOption.textContent = "เดือน";
  monthSelect.appendChild(allOption);

  monthNames.forEach((name, index) => {
    const option = document.createElement("option");
    option.value = index;
    option.textContent = name;
    monthSelect.appendChild(option);
  });
}

function renderQuarterOptions() {
  const quarterSelect = document.getElementById("quarterSelect");
  if (!quarterSelect) return;
  quarterSelect.innerHTML = "";

  const emptyOption = document.createElement("option");
  emptyOption.value = "";
  emptyOption.textContent = "ไตรมาส";
  quarterSelect.appendChild(emptyOption);

  quarterNames.forEach((name, index) => {
    const option = document.createElement("option");
    option.value = index;
    option.textContent = name;
    quarterSelect.appendChild(option);
  });
}

function updateCalendarTitle() {
  const calendarTitle = document.getElementById("calendarTitle");
  if (calendarTitle) calendarTitle.textContent = `${monthNames[viewMonth]} ${viewYear}`;
}

function renderMonthGrid() {
  const daysContainer = document.getElementById("days");
  if (!daysContainer) return;
  daysContainer.innerHTML = "";

  const firstDay = new Date(viewYear, viewMonth, 1).getDay();
  const lastDate = new Date(viewYear, viewMonth + 1, 0).getDate();

  for (let i = 0; i < firstDay; i++) {
    const empty = document.createElement("button");
    empty.type = "button";
    empty.className = "day empty";
    daysContainer.appendChild(empty);
  }

  for (let d = 1; d <= lastDate; d++) {
    const date = new Date(viewYear, viewMonth, d);
    date.setHours(0, 0, 0, 0);

    const btn = document.createElement("button");
    btn.type = "button";
    btn.className = "day";
    btn.textContent = d;
    btn.dataset.date = formatISODate(date);

    btn.addEventListener("mouseenter", () => {
      if (startDate && !endDate) {
        hoverDate = date;
        paintDayStates();
      }
    });

    btn.addEventListener("click", () => {
      selectDay(date);
    });

    daysContainer.appendChild(btn);
  }
}

function paintDayStates() {
  const previewRange = getPreviewRange();
  const allDays = document.querySelectorAll(".day[data-date]");

  allDays.forEach((btn) => {
    btn.classList.remove(
      "start",
      "end",
      "in-range",
      "preview-range",
      "preview-end"
    );

    const date = parseISODate(btn.dataset.date);

    if (sameDate(date, startDate)) btn.classList.add("start");
    if (sameDate(date, endDate)) btn.classList.add("end");

    if (startDate && endDate) {
      if (isBetweenInclusive(date, startDate, endDate)) {
        btn.classList.add("in-range");
      }
    } else if (previewRange) {
      if (isBetweenInclusive(date, previewRange.start, previewRange.end)) {
        btn.classList.add("preview-range");
      }
      if (hoverDate && sameDate(date, hoverDate) && !sameDate(date, startDate)) {
        btn.classList.add("preview-end");
      }
    }
  });
}

function renderCalendar() {
  updateCalendarTitle();
  renderMonthGrid();
  paintDayStates();
}

function applyYearRange(year) {
  activePreset = "year";
  const periodTypeInput = document.getElementById("periodTypeInput");
  if (periodTypeInput) periodTypeInput.value = "year";

  startDate = new Date(year, 0, 1);
  endDate = new Date(year, 11, 31);
  startDate.setHours(0, 0, 0, 0);
  endDate.setHours(0, 0, 0, 0);

  viewYear = year;
  viewMonth = 0;
  hoverDate = null;

  setInputsFromState();
  renderCalendar();
}

function applyMonthRange(year, month) {
  activePreset = "month";
  const periodTypeInput = document.getElementById("periodTypeInput");
  if (periodTypeInput) periodTypeInput.value = "month";

  startDate = new Date(year, month, 1);
  endDate = new Date(year, month, getLastDayOfMonth(year, month));
  startDate.setHours(0, 0, 0, 0);
  endDate.setHours(0, 0, 0, 0);

  viewYear = year;
  viewMonth = month;
  hoverDate = null;

  setInputsFromState();
  renderCalendar();
}

function applyQuarterRange(year, quarterIndex) {
  activePreset = "quarter";
  const periodTypeInput = document.getElementById("periodTypeInput");
  if (periodTypeInput) periodTypeInput.value = "quarter";

  const startMonth = quarterIndex * 3;
  const endMonth = startMonth + 2;

  startDate = new Date(year, startMonth, 1);
  endDate = new Date(year, endMonth, getLastDayOfMonth(year, endMonth));
  startDate.setHours(0, 0, 0, 0);
  endDate.setHours(0, 0, 0, 0);

  viewYear = year;
  viewMonth = startMonth;
  hoverDate = null;

  setInputsFromState();
  renderCalendar();
}

function applyPresetFromSelectors(source = "") {
  const yearSelect = document.getElementById("yearSelect");
  const monthSelect = document.getElementById("monthSelect");
  const quarterSelect = document.getElementById("quarterSelect");
  if (!yearSelect) return;

  const year = Number(yearSelect.value);

  if (source === "month" && monthSelect && monthSelect.value !== "") {
    if (quarterSelect) quarterSelect.value = "";
  }

  if (source === "quarter" && quarterSelect && quarterSelect.value !== "") {
    if (monthSelect) monthSelect.value = "";
  }

  if (monthSelect && monthSelect.value !== "") {
    applyMonthRange(year, Number(monthSelect.value));
    return;
  }

  if (quarterSelect && quarterSelect.value !== "") {
    applyQuarterRange(year, Number(quarterSelect.value));
    return;
  }

  applyYearRange(year);
}

function shiftViewMonth(step) {
  const next = new Date(viewYear, viewMonth + step, 1);
  viewYear = next.getFullYear();
  viewMonth = next.getMonth();
  renderCalendar();
}

function selectDay(date) {
  activePreset = "custom";
  const periodTypeInput = document.getElementById("periodTypeInput");
  if (periodTypeInput) periodTypeInput.value = "custom";

  date = normalizeDate(date);

  if (!startDate || endDate) {
    startDate = date;
    endDate = null;
    hoverDate = null;
  } else {
    const range = normalizeRange(startDate, date);
    startDate = range.start;
    endDate = range.end;
    hoverDate = null;
  }

  viewYear = date.getFullYear();
  viewMonth = date.getMonth();

  setInputsFromState();
  renderCalendar();
}

function applyTypedDates() {
  const startDateInput = document.getElementById("startDateInput");
  const endDateInput = document.getElementById("endDateInput");
  if (!startDateInput || !endDateInput) return;

  const startRaw = startDateInput.value.trim();
  const endRaw = endDateInput.value.trim();

  const startParsed = parseUserDate(startRaw);
  const endParsed = parseUserDate(endRaw);

  const isStartValid = startRaw === "" || !!startParsed;
  const isEndValid = endRaw === "" || !!endParsed;

  startDateInput.classList.toggle("invalid", !isStartValid);
  endDateInput.classList.toggle("invalid", !isEndValid);

  if (!isStartValid || !isEndValid) return;

  if (!startRaw && !endRaw) {
    const monthSelect = document.getElementById("monthSelect");
    const quarterSelect = document.getElementById("quarterSelect");
    const yearSelect = document.getElementById("yearSelect");
    const periodTypeInput = document.getElementById("periodTypeInput");
    
    if (monthSelect) monthSelect.value = "";
    if (quarterSelect) quarterSelect.value = "";
    if (yearSelect) yearSelect.value = String(today.getFullYear());
    if (periodTypeInput) periodTypeInput.value = "year";
    applyYearRange(Number(yearSelect ? yearSelect.value : today.getFullYear()));
    return;
  }

  activePreset = "custom";
  const periodTypeInput = document.getElementById("periodTypeInput");
  if (periodTypeInput) periodTypeInput.value = "custom";
  hoverDate = null;

  if (startParsed && endParsed) {
    const range = normalizeRange(startParsed, endParsed);
    startDate = range.start;
    endDate = range.end;
    viewYear = startDate.getFullYear();
    viewMonth = startDate.getMonth();
  } else if (startParsed && !endParsed) {
    startDate = startParsed;
    endDate = null;
    viewYear = startDate.getFullYear();
    viewMonth = startDate.getMonth();
  } else if (!startParsed && endParsed) {
    startDate = null;
    endDate = endParsed;
    viewYear = endDate.getFullYear();
    viewMonth = endDate.getMonth();
  }

  setInputsFromState();
  renderCalendar();
}

function maybeApplyTypedDates() {
  const startDateInput = document.getElementById("startDateInput");
  const endDateInput = document.getElementById("endDateInput");
  if (!startDateInput || !endDateInput) return;

  const startRaw = startDateInput.value.trim();
  const endRaw = endDateInput.value.trim();

  const ready =
    (startRaw === "" || startRaw.length === 10) &&
    (endRaw === "" || endRaw.length === 10);

  if (ready) {
    applyTypedDates();
  }
}

function bindInputEvents(input) {
  if (!input) return;
  input.addEventListener("input", () => {
    input.classList.remove("invalid");
    maybeApplyTypedDates();
  });

  input.addEventListener("keydown", (e) => {
    if (e.key === "Enter") {
      e.preventDefault();
      applyTypedDates();
    }
  });

  input.addEventListener("blur", applyTypedDates);
  input.addEventListener("change", applyTypedDates);
}

function initCalendar() {
  const prevBtn = document.getElementById("prevBtn");
  const nextBtn = document.getElementById("nextBtn");
  const yearSelect = document.getElementById("yearSelect");
  const monthSelect = document.getElementById("monthSelect");
  const quarterSelect = document.getElementById("quarterSelect");
  const clearBtn = document.getElementById("clearBtn");
  const daysContainer = document.getElementById("days");
  const startDateInput = document.getElementById("startDateInput");
  const endDateInput = document.getElementById("endDateInput");

  if (!prevBtn) return; // Exit if calendar elements are not found

  prevBtn.addEventListener("click", () => {
    shiftViewMonth(-1);
  });

  nextBtn.addEventListener("click", () => {
    shiftViewMonth(1);
  });

  yearSelect.addEventListener("change", () => {
    applyPresetFromSelectors("year");
  });

  monthSelect.addEventListener("change", () => {
    applyPresetFromSelectors("month");
  });

  quarterSelect.addEventListener("change", () => {
    applyPresetFromSelectors("quarter");
  });

  daysContainer.addEventListener("mouseleave", () => {
    if (startDate && !endDate) {
      hoverDate = null;
      paintDayStates();
    }
  });

  clearBtn.addEventListener("click", () => {
    startDate = null;
    endDate = null;
    hoverDate = null;
    activePreset = "year";
    const periodTypeInput = document.getElementById("periodTypeInput");
    if (periodTypeInput) periodTypeInput.value = "year";
    yearSelect.value = String(today.getFullYear());
    monthSelect.value = "";
    quarterSelect.value = "";
    applyYearRange(Number(yearSelect.value));
  });

  bindInputEvents(startDateInput);
  bindInputEvents(endDateInput);

  renderYearOptions();
  renderMonthOptions();
  renderQuarterOptions();
  renderWeekdays();

  yearSelect.value = "2025";
  monthSelect.value = "11";
  quarterSelect.value = "";

  applyMonthRange(2025, 11);
}

// Initialize when DOM is loaded
document.addEventListener("DOMContentLoaded", initCalendar);
