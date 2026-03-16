const BASE_URL = "http://localhost:8080/kxreport/"

function openWin() {
    return window.open("", "_blank")
}

function getFormDataAsJson() {
    const form = document.getElementById("form")
    const formData = new FormData(form)
    const data = {}
    for (let [key, value] of formData.entries()) {
        if (data[key] !== undefined) {
            if (!Array.isArray(data[key])) {
                data[key] = [data[key]]
            }
            data[key].push(value)
        } else {
            data[key] = value
        }
    }
    return data
}

function getPDF() {
    const data = getFormDataAsJson()
    const reports = Array.isArray(data.report) ? data.report : [data.report]
    const comCodes = Array.isArray(data.comCode) ? data.comCode : [data.comCode]
    
    // Filter out undefined in case nothing is selected
    const validReports = reports.filter(r => r)
    const validComCodes = comCodes.filter(c => c)
    
    if (validReports.length === 0 || validComCodes.length === 0) {
        alert("กรุณาเลือก Report Name และ Company Name อย่างน้อย 1 รายการ")
        return
    }

    for (const report of validReports) {
        for (const comCode of validComCodes) {
            // Clone the original data and override report/comCode for this specific tab
            const payload = { ...data, report, comCode }
            const params = new URLSearchParams(payload)
            const url = BASE_URL + "getPDF?" + params.toString()
            window.open(url, "_blank")
        }
    }
}

async function openPDF() {
    const data = getFormDataAsJson()
    const reports = Array.isArray(data.report) ? data.report : [data.report]
    const comCodes = Array.isArray(data.comCode) ? data.comCode : [data.comCode]
    
    const validReports = reports.filter(r => r)
    const validComCodes = comCodes.filter(c => c)
    
    if (validReports.length === 0 || validComCodes.length === 0) {
        alert("กรุณาเลือก Report Name และ Company Name อย่างน้อย 1 รายการ")
        return
    }

    // Process each combination sequentially to handle pop-up blockers potentially
    for (const report of validReports) {
        for (const comCode of validComCodes) {
            const payload = { ...data, report, comCode }
            
            // Open window before fetch to avoid popup blocker
            const reportWindow = openWin()
            if (!reportWindow) {
                alert("Please allow pop-ups for this site to open multiple reports.");
                return; // Stop processing if popup blocker is active
            }
            
            try {
                const response = await fetch(BASE_URL + "openPDF", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json",
                    },
                    body: JSON.stringify(payload),
                })
        
                if (!response.ok) {
                    throw new Error(`Service call failed with status: ${response.status}`)
                }
                const blob = await response.blob();
                const blobUrl = URL.createObjectURL(blob);
                reportWindow.location.href = blobUrl;
            } catch (error) {
                console.error("Error calling openPDF:", error)
                alert(`KX Report Error (${report} - ${comCode}): ${error.message}`)
        
                if (reportWindow) {
                    reportWindow.close()
                }
            }
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
    btn.tabIndex = 0; // Make focusable

    btn.addEventListener("mouseenter", () => {
      if (startDate && !endDate) {
        hoverDate = date;
        paintDayStates();
      }
    });

    btn.addEventListener("click", () => {
      selectDay(date);
    });

    // Keyboard navigation
    btn.addEventListener("keydown", (e) => {
      const allDays = Array.from(daysContainer.querySelectorAll(".day:not(.empty)"));
      const currentIndex = allDays.indexOf(btn);
      
      // Determine what day of the week this button represents (0=Sun, 6=Sat)
      const dayOfWeek = date.getDay();

      let targetIndex = null;
      if (e.key === "ArrowRight") {
        e.preventDefault();
        if (dayOfWeek === 6 || currentIndex === allDays.length - 1) { // Saturday or last day
          shiftViewMonth(1);
          setTimeout(() => {
            const freshDays = Array.from(daysContainer.querySelectorAll(".day:not(.empty)"));
            if (freshDays.length > 0) {
              // Try to stay on the same row roughly, or just first day of next week
              freshDays[0].focus();
            }
          }, 10);
          return;
        }
        targetIndex = currentIndex + 1;
      } else if (e.key === "ArrowLeft") {
        e.preventDefault();
        if (dayOfWeek === 0 || currentIndex === 0) { // Sunday or first day
          shiftViewMonth(-1);
          setTimeout(() => {
            const freshDays = Array.from(daysContainer.querySelectorAll(".day:not(.empty)"));
            if (freshDays.length > 0) freshDays[freshDays.length - 1].focus();
          }, 10);
          return;
        }
        targetIndex = currentIndex - 1;
      } else if (e.key === "ArrowDown") {
        e.preventDefault();
        if (currentIndex + 7 >= allDays.length) {
          // Bottom row -> clearBtn
          const clearBtn = document.getElementById("clearBtn");
          if (clearBtn) clearBtn.focus();
          return;
        }
        targetIndex = currentIndex + 7;
      } else if (e.key === "ArrowUp") {
        e.preventDefault();
        if (currentIndex - 7 < 0) {
          // Top row -> goes back to year Select
          const ySel = document.getElementById("yearSelect");
          if (ySel) ySel.focus();
          return;
        }
        targetIndex = currentIndex - 7;
      } else if (e.key === "Enter" || e.key === " ") {
        e.preventDefault();
        // Fire click event to leverage existing selectDay logic seamlessly
        btn.click(); 

        // Important: After a click redraws the calendar, we need to restore focus!
        setTimeout(() => {
          const freshDays = Array.from(daysContainer.querySelectorAll(".day:not(.empty)"));
          // Re-find the button for this exact date
          const dateStr = btn.dataset.date;
          const newBtn = freshDays.find(b => b.dataset.date === dateStr);
          if (newBtn) {
              newBtn.focus();
              // Prevent default click-induced mouseenter bugs
              if (!endDate) {
                 hoverDate = parseISODate(dateStr);
                 paintDayStates();
              }
          }
        }, 10);
        return;
      }

      if (targetIndex !== null && targetIndex >= 0 && targetIndex < allDays.length) {
        // Must use setTimeout to allow DOM to catch breath before focus, especially if shifted month
        setTimeout(() => {
          const freshDays = Array.from(daysContainer.querySelectorAll(".day:not(.empty)"));
          if(freshDays[targetIndex]) freshDays[targetIndex].focus();
        }, 10);
        
        // Update hoverDate for preview functionality if a start date is already selected
        if (startDate && !endDate) {
          hoverDate = parseISODate(allDays[targetIndex].dataset.date);
          paintDayStates();
        }
      }
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

  // clear btn keyboard nav
  clearBtn.addEventListener("keydown", (e) => {
    if (e.key === "ArrowDown") {
      e.preventDefault();
      const cGroup = document.getElementById('comCode');
      const cCheckboxes = cGroup ? Array.from(cGroup.querySelectorAll('input[type="checkbox"]')) : [];
      if (cCheckboxes.length > 0) cCheckboxes[0].focus();
    } else if (e.key === "ArrowUp") {
      e.preventDefault();
      const daysContainer = document.getElementById("days");
      const allDays = Array.from(daysContainer.querySelectorAll(".day:not(.empty)"));
      if (allDays.length > 0) allDays[allDays.length - 1].focus(); // Focus last day
    } else if (e.key === "Enter" || e.key === " ") {
      // Allow default button click handling
      setTimeout(() => {
        const cGroup = document.getElementById('comCode');
        const cCheckboxes = cGroup ? Array.from(cGroup.querySelectorAll('input[type="checkbox"]')) : [];
        if (cCheckboxes.length > 0) cCheckboxes[0].focus();
      }, 50);
    }
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

  initAdvancedKeyboardNav();
}

function initAdvancedKeyboardNav() {
  const rGroup = document.getElementById('report');
  const cGroup = document.getElementById('comCode');
  const rCheckboxes = rGroup ? Array.from(rGroup.querySelectorAll('input[type="checkbox"]')) : [];
  const cCheckboxes = cGroup ? Array.from(cGroup.querySelectorAll('input[type="checkbox"]')) : [];

  const sDate = document.getElementById("startDateInput");
  const eDate = document.getElementById("endDateInput");
  const ySel = document.getElementById("yearSelect");
  const mSel = document.getElementById("monthSelect");
  const qSel = document.getElementById("quarterSelect");

  // Helper to focus safely
  const focusEl = (el) => el && el.focus();

  // Report Nav
  rCheckboxes.forEach((cb, i) => {
    cb.addEventListener('keydown', (e) => {
      if (e.key === 'ArrowDown') {
        e.preventDefault();
        if (i === rCheckboxes.length - 1) focusEl(sDate);
        else focusEl(rCheckboxes[i + 1]);
      } else if (e.key === 'ArrowUp') {
        if (i > 0) {
          e.preventDefault();
          focusEl(rCheckboxes[i - 1]);
        }
      } else if (e.key === 'Enter') {
        e.preventDefault();
        cb.click();
      }
    });
  });

  // Dates Nav
  if (sDate) {
    sDate.addEventListener("keydown", (e) => {
      if (e.key === "ArrowRight" && sDate.selectionStart === sDate.value.length) {
        e.preventDefault();
        focusEl(eDate);
      } else if (e.key === "ArrowDown") {
        e.preventDefault();
        focusEl(ySel);
      } else if (e.key === "ArrowUp") {
        e.preventDefault();
        focusEl(rCheckboxes[rCheckboxes.length - 1]);
      }
    });
  }

  if (eDate) {
    eDate.addEventListener("keydown", (e) => {
      if (e.key === "ArrowLeft" && eDate.selectionStart === 0) {
        e.preventDefault();
        focusEl(sDate);
      } else if (e.key === "ArrowDown") {
        e.preventDefault();
        focusEl(mSel);
      } else if (e.key === "ArrowUp") {
        e.preventDefault();
        focusEl(rCheckboxes[rCheckboxes.length - 1]);
      }
    });
  }

  // Selects Nav (Year/Month/Quarter)
  const focusFirstDay = () => {
    // Timeout needed in case UI was just updated
    setTimeout(() => {
      const daysContainer = document.getElementById("days");
      if (!daysContainer) return;
      const firstDay = daysContainer.querySelector(".day:not(.empty)");
      if (firstDay) firstDay.focus();
    }, 10);
  };

  const handleSelectNav = (sel, e) => {
    // If alt is pressed, let native browser dropdown work
    if (e.altKey) return;
    
    if (e.key === "ArrowRight") {
      if (sel === ySel) { e.preventDefault(); focusEl(mSel); }
      else if (sel === mSel) { e.preventDefault(); focusEl(qSel); }
      else if (sel === qSel) { e.preventDefault(); focusFirstDay(); }
    } else if (e.key === "ArrowLeft") {
      if (sel === qSel) { e.preventDefault(); focusEl(mSel); }
      else if (sel === mSel) { e.preventDefault(); focusEl(ySel); }
      else if (sel === ySel) { e.preventDefault(); focusEl(eDate); }
    } else if (e.key === "ArrowDown") {
      e.preventDefault();
      focusFirstDay();
    } else if (e.key === "ArrowUp") {
      e.preventDefault();
      if (sel === ySel) focusEl(sDate);
      else if (sel === mSel || sel === qSel) focusEl(eDate);
    }
  };

  [ySel, mSel, qSel].forEach(sel => {
    if (sel) sel.addEventListener('keydown', (e) => handleSelectNav(sel, e));
  });

  // Company Nav
  cCheckboxes.forEach((cb, i) => {
    cb.addEventListener('keydown', (e) => {
      if (e.key === 'ArrowDown') {
        if (i < cCheckboxes.length - 1) {
          e.preventDefault();
          focusEl(cCheckboxes[i + 1]);
        }
      } else if (e.key === 'ArrowUp') {
        e.preventDefault();
        if (i === 0) {
          const clearBtn = document.getElementById("clearBtn");
          if (clearBtn) focusEl(clearBtn);
        }
        else focusEl(cCheckboxes[i - 1]);
      } else if (e.key === 'Enter') {
        e.preventDefault();
        cb.click();
      }
    });
  });
}

// Initialize when DOM is loaded
document.addEventListener("DOMContentLoaded", () => {
    const form = document.getElementById("form");
    if (form) form.addEventListener("submit", (e) => e.preventDefault());
    initCalendar();
});
