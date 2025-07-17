/**
 * Transforms a UTC timestamp to London timezone and returns formatted time and date
 * @param {string} utcTimestamp - ISO timestamp string (e.g., "2025-07-19T18:00:16.349Z")
 * @returns {{time: string, date: string}} Object with formatted time and date
 * @example
 * const result = formatLondonDateTime('2025-07-19T18:00:16.349Z');
 * // Returns: { startTime: '19:00', startDate: '19 Jul 25' }
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

    return {
      time: londonTime,
      date: londonDate
    };
  }