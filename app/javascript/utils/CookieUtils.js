import Cookies from 'js-cookie';

export const getValueFromJsonCookie = (cookieName, key) => JSON.parse(Cookies.get(cookieName) ?? '{}')[key];

export const setValueToJsonCookie = (cookieName, key, value) => {
  const cookieValue = JSON.parse(Cookies.get(cookieName) ?? '{}');
  cookieValue[key] = value;
  Cookies.set(cookieName, JSON.stringify(cookieValue));
};
