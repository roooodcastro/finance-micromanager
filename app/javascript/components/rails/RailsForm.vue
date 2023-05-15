<template>
  <form
    v-bind="$props"
    :method="method"
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
    inline: {
      type: Boolean,
      default: false,
    },
    novalidate: {
      type: Boolean,
      default: false,
    },
    validated: {
      type: Boolean,
      default: false,
    },
    method: {
      type: String,
      default: 'post',
    },
    resource: {
      type: String,
      default: null,
    },
  },
  data() {
    return {
      submitting: false,
    };
  },
  setup(props) {
    const csrfToken = Csrf.getToken();
    const isGetRequest = props.method.toLowerCase() === 'get';

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
    }

    return {
      csrfToken,
      formHelper,
      isGetRequest,
    };
  },
};
</script>
