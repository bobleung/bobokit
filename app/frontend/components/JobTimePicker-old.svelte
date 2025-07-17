<script>
    import { DateTime } from 'luxon';
    
    // Props
    let { 
      start = $bindable(),
      end = $bindable(),
      break_minutes = $bindable(0),
      timezone = 'Europe/London',
      showDuration = false,
      showClock = true,
      debounceDelay = 500,
      onChange = () => {}
    } = $props();
    
    // Local state
    let startDate = $state('');
    let startTime = $state('');
    let endTime = $state('');
    let localBreakMinutes = $state(0);
    let isInitialized = $state(false);
    
    // Debounce timer
    let debounceTimer = null;
    
    // Track if we're in the middle of updating to prevent loops
    let isUpdating = false;
    
    // Validation functions
    function isValidDateString(dateStr) {
      if (!dateStr || !/^\d{4}-\d{2}-\d{2}$/.test(dateStr)) return false;
      const dt = DateTime.fromISO(dateStr);
      return dt.isValid;
    }
    
    function isValidTimeString(timeStr) {
      if (!timeStr || !/^\d{2}:\d{2}$/.test(timeStr)) return false;
      const [hours, minutes] = timeStr.split(':').map(Number);
      return hours >= 0 && hours <= 23 && minutes >= 0 && minutes <= 59;
    }
    
    // Derived validation states
    let isStartDateValid = $derived(isValidDateString(startDate));
    let isStartTimeValid = $derived(isValidTimeString(startTime));
    let isEndTimeValid = $derived(isValidTimeString(endTime));
    let areAllInputsValid = $derived(isStartDateValid && isStartTimeValid && isEndTimeValid);
    
    // Utility functions
    function createTimestamp(dateStr, timeStr) {
      if (!isValidDateString(dateStr) || !isValidTimeString(timeStr)) return null;
      try {
        const [hour, minute] = timeStr.split(':').map(Number);
        const [year, month, day] = dateStr.split('-').map(Number);
        const dt = DateTime.fromObject(
          { year, month, day, hour, minute }, 
          { zone: timezone }
        );
        return dt.isValid ? dt.toISO() : null;
      } catch (error) {
        console.error("Error in createTimestamp:", error);
        return null;
      }
    }
    
    function parseTimestamp(isoString) {
      if (!isoString) return { date: '', time: '' };
      try {
        const dt = DateTime.fromISO(isoString, { zone: timezone });
        if (!dt.isValid) return { date: '', time: '' };
        return {
          date: dt.toFormat("yyyy-MM-dd"),
          time: dt.toFormat("HH:mm")
        };
      } catch (error) {
        console.error("Error parsing timestamp:", error);
        return { date: '', time: '' };
      }
    }
    
    function addMinutesToTimestamp(isoString, minutes) {
      if (!isoString) return null;
      try {
        const dt = DateTime.fromISO(isoString, { zone: timezone });
        const newDt = dt.plus({ minutes });
        return newDt.isValid ? newDt.toISO() : null;
      } catch (error) {
        console.error("Error adding minutes:", error);
        return null;
      }
    }
    
    function calculateDateOffset(startTimeStr, endTimeStr, dateStr) {
      if (!isValidTimeString(startTimeStr) || !isValidTimeString(endTimeStr) || !isValidDateString(dateStr)) {
        return 0;
      }
      try {
        const [startHour, startMinute] = startTimeStr.split(':').map(Number);
        const [endHour, endMinute] = endTimeStr.split(':').map(Number);
        const [year, month, day] = dateStr.split('-').map(Number);
        
        const startDt = DateTime.fromObject({ year, month, day, hour: startHour, minute: startMinute }, { zone: timezone });
        const endDt = DateTime.fromObject({ year, month, day, hour: endHour, minute: endMinute }, { zone: timezone });
        
        // If end is before or equal to start, assume next day
        if (endDt <= startDt) return 1;
        return 0;
      } catch (error) {
        console.error("Error in calculateDateOffset:", error);
        return 0;
      }
    }
    
    function calculateTotalDurationFromTimestamps(startIso, endIso) {
      if (!startIso || !endIso) return 0;
      try {
        const startDt = DateTime.fromISO(startIso, { zone: timezone });
        const endDt = DateTime.fromISO(endIso, { zone: timezone });
        if (!startDt.isValid || !endDt.isValid || endDt < startDt) return 0;
        
        const diff = endDt.diff(startDt, 'minutes');
        return Math.floor(diff.minutes);
      } catch (error) {
        console.error("Error calculating duration:", error);
        return 0;
      }
    }
    
    // Calculate current timestamps
    function getCurrentStartTimestamp() {
      return areAllInputsValid ? createTimestamp(startDate, startTime) : null;
    }
    
    function getCurrentEndTimestamp() {
      if (!areAllInputsValid) return null;
      
      const dateOffset = calculateDateOffset(startTime, endTime, startDate);
      if (dateOffset === 0) {
        return createTimestamp(startDate, endTime);
      } else {
        // Next day
        const baseEnd = createTimestamp(startDate, endTime);
        return baseEnd ? addMinutesToTimestamp(baseEnd, 24 * 60) : null;
      }
    }
    
    function getCurrentWorkDuration() {
      const startTs = getCurrentStartTimestamp();
      const endTs = getCurrentEndTimestamp();
      return startTs && endTs 
        ? Math.max(0, calculateTotalDurationFromTimestamps(startTs, endTs) - localBreakMinutes)
        : 0;
    }
    
    // Debounce helper
    function debounce(callback, delay) {
      if (debounceTimer) clearTimeout(debounceTimer);
      debounceTimer = setTimeout(() => {
        callback();
        debounceTimer = null;
      }, delay);
    }
    
    // Initialize from props
    function initializeFromProps() {
      isUpdating = true;
      
      if (start) {
        const parsed = parseTimestamp(start);
        startDate = parsed.date;
        startTime = parsed.time;
      } else {
        // Default to current date/time
        const now = DateTime.now().setZone(timezone);
        startDate = now.toFormat("yyyy-MM-dd");
        startTime = "09:00";
      }
      
      if (end) {
        const parsed = parseTimestamp(end);
        endTime = parsed.time;
      } else {
        endTime = "17:00";
      }
      
      localBreakMinutes = break_minutes || 0;
      isInitialized = true;
      
      setTimeout(() => {
        isUpdating = false;
      }, 0);
    }
    
    // Store the work duration before changes
    let previousWorkDuration = 0;
    
    // Handle start date/time changes
    function handleStartChange() {
      if (!isInitialized || isUpdating) return;
      
      if (!isStartDateValid || !isStartTimeValid) return;
      
      isUpdating = true;
      
      // Use the previous work duration to maintain shift length
      const totalShiftMinutes = previousWorkDuration + localBreakMinutes;
      
      const startTs = getCurrentStartTimestamp();
      if (totalShiftMinutes > 0 && startTs) {
        // Update end timestamp to maintain duration
        const newEndTimestamp = addMinutesToTimestamp(startTs, totalShiftMinutes);
        if (newEndTimestamp) {
          const parsed = parseTimestamp(newEndTimestamp);
          endTime = parsed.time;
        }
      }
      
      updateProps();
      
      setTimeout(() => {
        isUpdating = false;
      }, 0);
    }
    
    // Handle end time changes
    function handleEndChange() {
      if (!isInitialized || isUpdating) return;
      updateProps();
    }
    
    // Handle break changes
    function handleBreakChange() {
      if (!isInitialized || isUpdating) return;
      updateProps();
    }
    
    // Update props based on current state
    function updateProps() {
      const startTs = getCurrentStartTimestamp();
      const endTs = getCurrentEndTimestamp();
      const duration = getCurrentWorkDuration();
      
      if (startTs) start = startTs;
      if (endTs) end = endTs;
      break_minutes = localBreakMinutes;
      
      debounce(() => {
        onChange({
          start: startTs,
          end: endTs,
          break_minutes: localBreakMinutes,
          durationMinutes: duration
        });
      }, debounceDelay);
    }
    
    // Store work duration before any changes
    $effect(() => {
      if (areAllInputsValid && !isUpdating) {
        previousWorkDuration = getCurrentWorkDuration();
      }
    });
    
    // Initialize on mount
    $effect(() => {
      if (!isInitialized) {
        initializeFromProps();
      }
    });
    
    // Watch for external prop changes - React to all prop changes
    $effect(() => {
      // Skip during initialization
      if (!isInitialized) return;
      
      // Check if any prop has changed by comparing parsed values
      let propsChanged = false;
      
      if (start) {
        const parsed = parseTimestamp(start);
        if (parsed.date !== startDate || parsed.time !== startTime) {
          propsChanged = true;
        }
      }
      
      if (end) {
        const parsed = parseTimestamp(end);
        // Need to check if the actual end timestamp differs
        const currentEndTs = getCurrentEndTimestamp();
        if (end !== currentEndTs) {
          propsChanged = true;
        }
      }
      
      if (break_minutes !== localBreakMinutes) {
        propsChanged = true;
      }
      
      if (propsChanged) {
        initializeFromProps();
      }
    });
    
    // Cleanup
    $effect(() => {
      return () => {
        if (debounceTimer) clearTimeout(debounceTimer);
      };
    });
    
    // Exported functions
    export function reset() {
      const now = DateTime.now().setZone(timezone);
      startDate = now.toFormat("yyyy-MM-dd");
      startTime = "09:00";
      endTime = "17:00";
      localBreakMinutes = 0;
      updateProps();
    }
    
    export function getSchedule() {
      return {
        startDate,
        startTime,
        endTime,
        breakMinutes: localBreakMinutes,
        start: getCurrentStartTimestamp(),
        end: getCurrentEndTimestamp(),
        durationMinutes: getCurrentWorkDuration()
      };
    }
  </script>
  
  <div class="grid grid-cols-1 sm:grid-cols-4 gap-4">
    <!-- Date Input -->
    <label class="floating-label input validator w-full">
      <span>Date</span>
      <input 
        type="date" 
        bind:value={startDate}
        oninput={handleStartChange}
        placeholder="Date"
        class:input-error={!isStartDateValid && startDate}
      />
    </label>
    
    <!-- Start Time Input -->
    <label class="floating-label input validator w-full">
      <span>Start Time</span>
      <input 
        type="time" 
        bind:value={startTime}
        oninput={handleStartChange}
        placeholder="Start Time"
        disabled={!isStartDateValid}
        class:input-error={!isStartTimeValid && startTime && isStartDateValid}
        class:hide-clock-icon={!showClock}
      />
    </label>
    
    <!-- End Time Input -->
    <label class="floating-label input validator w-full">
      <span>End Time</span>
      <input 
        type="time" 
        bind:value={endTime}
        oninput={handleEndChange}
        placeholder="End Time"
        disabled={!isStartDateValid || !isStartTimeValid}
        class:input-error={!isEndTimeValid && endTime && isStartDateValid && isStartTimeValid}
        class:hide-clock-icon={!showClock}
      />
    </label>
    
    <!-- Break Minutes Input -->
    <label class="floating-label input validator w-full">
      <span>Break (min)</span>
      <input 
        type="number" 
        min="0"
        bind:value={localBreakMinutes}
        oninput={handleBreakChange}
        placeholder="0"
        disabled={!areAllInputsValid}
        class:input-disabled={!areAllInputsValid}
      />
    </label>
  </div>
  
  {#if showDuration}
    <div class="mt-4 text-sm">
      <span class="font-medium">Duration:</span> 
      <span class="tabular-nums">
        {areAllInputsValid ? getCurrentWorkDuration() : 'N/A'} minutes
      </span>
    </div>
  {/if}
  
  <style>
    /* Hide clock icon on time inputs if needed */
    input[type="time"].hide-clock-icon::-webkit-calendar-picker-indicator {
      display: none;
    }
    
    /* Disabled input styling to match DaisyUI */
    input.input-disabled {
      opacity: 0.5;
      cursor: not-allowed;
    }
    
    /* Ensure consistent spacing in number displays */
    .tabular-nums {
      font-variant-numeric: tabular-nums;
    }
  </style>