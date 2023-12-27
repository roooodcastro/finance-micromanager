import dayjs from 'dayjs';

export function formatDate(date) {
  return dayjs(date).format('L');
}

export function formatDateTime(date) {
  return dayjs(date).format('L LTS');
}
