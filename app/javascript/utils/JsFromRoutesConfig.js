import { Config } from '@js-from-routes/client';

import useBrowserCacheStore from '~/stores/BrowserCacheStore.js';

const withResponse = (response) => {
  const browserCacheStore = useBrowserCacheStore();
  const headers = response.headers || {};
  const updatedToken = headers.get('x-csrf-token');

  browserCacheStore.loadFromResponse(response);

  if (updatedToken) {
    Config.csrfToken = updatedToken;
  }
};

Config.withResponse = withResponse;
