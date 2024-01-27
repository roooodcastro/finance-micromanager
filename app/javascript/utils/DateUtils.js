import dayjs from 'dayjs';

export function formatDate(date) {
  return dayjs.tz(date, 'utc').format('L');
}

export function formatDateTime(date) {
  return dayjs(date).format('L LTS');
}
