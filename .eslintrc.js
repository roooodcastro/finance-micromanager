module.exports = {
  parserOptions: {
    parser: '@babel/eslint-parser',
    ecmaVersion: 2017,
    ecmaFeatures: {
      jsx: false,
      spread: true,
    },
  },
  extends: [
    'eslint:recommended',
    'plugin:vue/vue3-essential',
    'plugin:vue/vue3-strongly-recommended',
    'plugin:vue/vue3-recommended',
    'plugin:vue-scoped-css/vue3-recommended',
  ],
  globals: {
    App: true,
    SIR: true,
    $t: true,
    zE: true,
    $: true,
    document: true,
    window: true,
  },
  rules: {
    'vue/singleline-html-element-content-newline': 'off',
    'vue/html-indent': 'off',
    'vue/max-attributes-per-line': 'off',
    'vue/multi-word-component-names': 'off',
    'no-var': 'error',
    'no-plusplus': 'error',
    'eol-last': 'error',
    'no-undefined': 'error',
    'no-useless-return': 'error',
    'no-eq-null': 'error',
    'eqeqeq': 'error',
    'complexity': 'error',
    'no-useless-concat': 'error',
    'no-console': 'error',
    'block-scoped-var': 'error',
    'no-lonely-if': 'error',
    'object-shorthand': ['error', 'properties'],
    'vue/html-closing-bracket-newline': 'error',
    'vue/no-deprecated-slot-attribute': 'error',
    'spaced-comment': [
      'error',
      'always',
      {
        exceptions: ['-', '+'],
      },
    ],
    'vue/require-explicit-emits': 'error',
    'vue/no-deprecated-filter': 'error',
    'vue/custom-event-name-casing': [
      'error',
      'kebab-case',
      {
        'ignores': ['/^ajax:/', '/^update:/'],
      },
    ],
    'vue/v-slot-style': [
      'error',
      {
        'atComponent': 'v-slot',
        'default': 'longform',
        'named': 'longform',
      },
    ],
    'vue/no-unused-properties': [
      'error',
      {
        'groups': ['props', 'data', 'computed', 'methods'],
        'deepData': false,
      },
    ],
    'vue-scoped-css/require-v-deep-argument': 'error',
    'vue-scoped-css/no-deprecated-deep-combinator': 'error',
    'vue-scoped-css/no-unused-selector': 'off',
  },
  env: {
    browser: true,
    node: true,
    jquery: true,
    es6: true,
  },
  overrides: [
    {
      files: [
        'app/javascript/**/*.js',
        'app/javascript/**/*.vue',
      ],
      env: {
        browser: true,
        node: true,
        jquery: true,
        es6: true,
      },
      rules: {
        'vue/no-v-html': 0,
        'vue/html-self-closing': 0,
        'class-methods-use-this': 0,
        'linebreak-style': 0,
        'import/no-unresolved': 0,
        'vue/no-parsing-error': [
          2,
          {
            'x-invalid-end-tag': false,
          },
        ],
        'no-underscore-dangle': 0,
        'consistent-return': [
          'error',
          {
            'treatUndefinedAsUnspecified': true,
          },
        ],
        'no-unused-vars': [
          'error',
          {
            'varsIgnorePattern': '^_',
          },
        ],
      },
    },
    {
      files: ['**/*.vue'],
      rules: {
        'eol-last': 0,
      },
    },
  ],
};
