import dayjs from 'dayjs';

import { BROWSER_CACHE_NAME, CACHED_TIMESTAMP_HEADER_NAME } from '~/utils/Constants.js';

export const fetchFromCache = (path, latestUpdatedAt) => {
  let responseResolve;
  let responseReject;
  const returnPromise = new Promise((resolve, reject) => {
    responseResolve = resolve;
    responseReject = reject;
  });

  caches.open(BROWSER_CACHE_NAME).then((cache) => {
    return cache.match(path).then((response) => {
      if (response) {
        const cachedAt = dayjs.unix(response.headers.get(CACHED_TIMESTAMP_HEADER_NAME));

        if (cachedAt >= latestUpdatedAt) {
          // console.log(`cache HIT for ${path}`);
          response.json().then(jsonResponse => responseResolve(jsonResponse));
        } else {
          cache.delete(path);
          // console.log(`cache STALE (cachedAt: ${cachedAt}, updatedAt: ${latestUpdatedAt}) for ${path}`);
          responseReject('stale');
        }
      } else {
        // console.log(`cache MISS for ${path}`);
        responseReject('miss');
      }
    });
  });

  return returnPromise;
};
