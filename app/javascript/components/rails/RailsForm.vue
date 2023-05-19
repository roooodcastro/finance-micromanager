<template>
  <form
    v-bind="$props"
    :method="formMethod"
    v-on="listeners"
  >
    <input
      v-if="!isGetRequest"
      type="hidden"
      name="authenticity_token"
      :value="csrfToken"
    />

    <input
      v-if="!isSafeMethod"
      :value="method"
      name="_method"
      type="hidden"
    />

    <slot
      :form-helper="formHelper"
    />
  </form>
</template>

<script>
import { isEmpty } from 'lodash';

import Csrf from '~/utils/Csrf.js';

export default {
  props: {
    method: {
      type: String,
      default: 'post',
    },
    resource: {
      type: String,
      default: null,
    },
    errors: {
      type: Object,
      default: () => {},
    },
  },
  setup(props) {
    const csrfToken = Csrf.getToken();
    const isGetRequest = props.method.toLowerCase() === 'get';
    const formMethod = isGetRequest ? 'GET' : 'POST';

    const formHelper = {
      resource: props.resource,
      fieldId: ((column) => {
        return isEmpty(props.resource) ? column : `${props.resource}_${column}`;
      }),
      fieldName: ((column, isArray = false) => {
        const arraySuffix = isArray ? '[]' : '';
        const columnWithArray = `${column}${arraySuffix}`;
        return isEmpty(props.resource)
          ? columnWithArray
          : `${props.resource}[${columnWithArray}]`;
      }),
      hasError: ((column) => !!props.errors?.[column]),
      errorFor: ((column) => props.errors?.[column]),
    }

    return {
      csrfToken,
      formHelper,
      formMethod,
      isGetRequest,
    };
  },
  data() {
    return {
    };
  },
};
</script>
