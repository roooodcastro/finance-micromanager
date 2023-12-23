import _ from 'lodash';

/*
 * Converts a string that is in camelCase to dash-case.
 */
export function dasherize(camelCaseString) {
  return camelCaseString.replace(/([a-z\d])([A-Z])/g, '$1-$2').toLowerCase()
}

/*
 * Fixes Object keys returned by the JSFromRoutes library. The library converts all keys to camelCase, thus ruining all
 * UUID used as keys. This function is essentially a case converter to dash-case, returning the UUIDs to the correct
 * format.
 */
export function fixUuidObjectKeys(object) {
  return _.mapKeys(object, (_value, key) => dasherize(key));
}
