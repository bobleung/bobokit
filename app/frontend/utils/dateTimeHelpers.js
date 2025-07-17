/**
 * Transforms a UTC timestamp to London timezone and returns formatted time and date
 * @param {string} utcTimestamp - ISO timestamp string (e.g., "2025-07-19T18:00:16.349Z")
 * @returns {{time: string, date: string, isoDate: string}} Object with formatted time and date
 * @example
 * const result = formatLondonDateTime('2025-07-19T18:00:16.349Z');
 * // Returns: { time: '19:00', date: '19 Jul 25', isoDate: '2025-07-19' }
 */
export function formatLondonDateTime(utcTimestamp) {
    const date = new Date(utcTimestamp);

    // Convert to London timezone
    const londonTime = new Intl.DateTimeFormat('en-GB', {
      timeZone: 'Europe/London',
      hour: '2-digit',
      minute: '2-digit',
      hour12: false
    }).format(date);

    const londonDate = new Intl.DateTimeFormat('en-GB', {
      timeZone: 'Europe/London',
      day: '2-digit',
      month: 'short',
      year: '2-digit'
    }).format(date);

    // Get ISO date in YYYY-MM-DD format
    const isoDate = new Intl.DateTimeFormat('en-CA', {
      timeZone: 'Europe/London',
      year: 'numeric',
      month: '2-digit',
      day: '2-digit'
    }).format(date);

    return {
      time: londonTime,
      date: londonDate,
      isoDate
    };
  }

/**
 * Calculates the duration between two timestamps, accounting for break time
 * @param {string} start - ISO timestamp string (e.g., "2025-07-28T08:00:00.000+01:00")
 * @param {string} end - ISO timestamp string (e.g., "2025-07-28T17:00:00.000+01:00")
 * @param {number} [breakMinutes=0] - Optional break time in minutes (defaults to 0)
 * @returns {DurationResult} Object with duration in different formats
 * @example
 * const duration = getJobDuration('2025-07-28T08:00:00.000+01:00', '2025-07-28T17:00:00.000+01:00', 60);
 * // Returns: { minutes: 480, hours: 8, hoursAndMinutes: '8h 0m' }
 */
/**
 * @typedef {Object} DurationResult
 * @property {number} minutes - Total duration in minutes
 * @property {number} hours - Total duration in hours (including fractions)
 * @property {string} hoursAndMinutes - Formatted string (e.g., "8h 30m")
 */

/**
 * Calculates the duration of a job between two timestamps, accounting for break time
 * @param {string} start - ISO timestamp string (e.g., "2025-07-28T08:00:00.000+01:00")
 * @param {string} end - ISO timestamp string (e.g., "2025-07-28T17:00:00.000+01:00")
 * @param {number} [breakMinutes=0] - Optional break time in minutes (defaults to 0)
 * @returns {DurationResult} Object with duration in different formats
 * @example
 * const duration = getJobDuration('2025-07-28T08:00:00.000+01:00', '2025-07-28T17:00:00.000+01:00', 60);
 * // Returns: { minutes: 480, hours: 8, hoursAndMinutes: '8h 00m' }
 */
export function getJobDuration(start, end, breakMinutes = 0) {
    // Convert to timestamps (milliseconds since epoch)
    const startMs = new Date(start).getTime();
    const endMs = new Date(end).getTime();
    
    // Calculate total minutes between start and end
    const totalMinutes = Math.round((endMs - startMs) / (1000 * 60));
    
    // Ensure breakMinutes is a number and not negative
    const breakMins = typeof breakMinutes === 'number' ? breakMinutes : parseInt(breakMinutes, 10) || 0;
    const workingMinutes = Math.max(0, totalMinutes - breakMins);
    
    // Calculate hours and remaining minutes
    const hours = Math.floor(workingMinutes / 60);
    const remainingMinutes = workingMinutes % 60;
    
    // Format hours and minutes as string (e.g., "8h 30m")
    const hoursAndMinutes = `${hours}h ${remainingMinutes.toString().padStart(2, '0')}m`;
    
    return {
        minutes: workingMinutes,
        hours: hours + (remainingMinutes / 60),
        hoursAndMinutes
    };
}