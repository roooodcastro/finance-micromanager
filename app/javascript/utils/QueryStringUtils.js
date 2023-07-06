import _ from 'lodash';

export function getQueryParams() {
  if (!_.isString(window.location.search)) return {};

  const params = new URLSearchParams(window.location.search);
  return Object.fromEntries(params.entries());
}

export function toQueryString(queryParams) {
  return new URLSearchParams(queryParams).toString();
}

export function setQueryParam(name, value) {
  const queryParams = getQueryParams();

  /* eslint-disable-next-line no-undefined */
  if (value === null || value === undefined) {
    delete queryParams[name];
  } else {
    queryParams[name] = value;
  }

  if (history.pushState) {
    let url = window.location.origin + window.location.pathname;
    if (!_.isEmpty(queryParams)) {
      url = url + `?${toQueryString(queryParams)}`
    }
    window.history.pushState({ path: url}, '', url);
  }
}
