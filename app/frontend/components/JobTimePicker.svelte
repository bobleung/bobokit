<script>
    import { formatLondonDateTime } from "@utils"
    import { DateTime } from "luxon";

    // Props
    let { 
    start = $bindable(),
    end = $bindable(),
    break_minutes = $bindable(0)
    } = $props();

    // Local UI State
    let isInitialised = false;
    let startDate = $state(formatLondonDateTime(start).isoDate)
    let startTime = $state(formatLondonDateTime(start).time)
    let endTime = $state(formatLondonDateTime(end).time)
    let breakMinutes = $state(break_minutes)
    let duration = $derived(DateTime.fromISO(end).diff(DateTime.fromISO(start), 'minutes').minutes - breakMinutes);

    // When startDate is changed by user
    function handleStartDateChange(){
        console.log("handleStartDateChange Triggered : " + startDate)
        const newStart = DateTime.fromISO(`${startDate}T${startTime}`, { zone: 'Europe/London' });
        const newEnd = newStart.plus({ minutes: duration + breakMinutes });

        // Update the parent props with the ISO string
        start = newStart.toISO();
        end = newEnd.toISO();

        // Update local state 
        startTime = formatLondonDateTime(start).time
        endTime = formatLondonDateTime(end).time

    }

    // When startTime is changed by user
    function handleStartTimeChange(){
        console.log("handleStartTimeChange Triggered : " + startTime)
        const newStart = DateTime.fromISO(`${startDate}T${startTime}`, { zone: 'Europe/London' });
        const newEnd = newStart.plus({ minutes: duration + breakMinutes });

        // Update the start prop with the ISO string
        start = newStart.toISO();
        end = newEnd.toISO();

        // Update local state
        endTime = formatLondonDateTime(end).time
    }

    // When endTime is changed by user
    function handleEndTimeChange() {
        console.log("handleBreakMinuteChange Triggered: " + breakMinutes);
        const startDt = DateTime.fromISO(start, { zone: 'Europe/London' });
        let newEnd = DateTime.fromISO(`${startDate}T${endTime}`, { zone: 'Europe/London' });

        // If new end time is before or equal to start time, add one day to end time
        if (newEnd <= startDt) {
            newEnd = newEnd.plus({ days: 1 });
        }

        // Update parent prop
        end = newEnd.toISO();
    }

    // When breakMinutes is changed by user
    function handleBreakMinutesChange() {
        console.log("handleEndTimeChange Triggered: " + endTime);

        // Update parent prop
        break_minutes = breakMinutes
    }

    // Logging
    $inspect("Start Date Changed:" + startDate)
    $inspect("Start Time Changed:" + startTime)
    $inspect("End Time Changed:" + endTime)
    $inspect("Breaks Changed:" + breakMinutes)
    $inspect("Duration:" + duration)
    $inspect("Initialised State:" + isInitialised)
    $inspect("Start Changed:" + start)

</script>

<div class="grid grid-cols-2 lg:grid-cols-4 gap-6">
    <label class="floating-label input validator w-full"><span>Date</span>
        <input type="date" bind:value={startDate} onchange={handleStartDateChange}/>
    </label>
    <label class="floating-label input validator w-full"><span>Start</span>
        <input type="time" bind:value={startTime} onchange={handleStartTimeChange}/>
    </label>
    <label class="floating-label input validator w-full"><span>End</span>
        <input type="time" bind:value={endTime} onchange={handleEndTimeChange}/>
    </label>
    <label class="floating-label input validator w-full"><span>Break (mins)</span>
        <input type="number" bind:value={breakMinutes} onchange={handleBreakMinutesChange}/>
    </label>
</div>