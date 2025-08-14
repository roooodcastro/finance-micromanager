/*
 * Modal IDsCaching
 */
export const CONFIRMATION_MODAL_ID = 'confirmationModal';
export const PASSWORD_CHANGE_MODAL_ID = 'passwordChangeModal';
export const TRANSACTION_PREDICTION_CONDITION_MODAL_ID = 'transactionPredictionConditionModal';
export const TRANSACTION_PREDICTION_ACTION_MODAL_ID = 'transactionPredictionActionModal';
export const DAILY_TOTALS_CHART_MODE_MODAL_ID = 'dailyTotalsChartModeModal';
export const SHORTCUTS_HELP_MODAL_ID = 'shortcutsHelpModal';
export const PROFILE_SHARE_INVITE_MODAL_ID = 'profileShareInviteModal';
export const MATCH_TRANSACTION_SELECTOR_MODAL_ID = 'matchTransactionSelectorModal';

/*
 * Form IDs
 */
export const BUDGET_FORM_ID = 'budgetForm';
export const CATEGORY_FORM_ID = 'categoryForm';
export const IMPORT_FORM_ID = 'importForm';
export const IMPORT_NAME_FORM_ID = 'importNameForm';
export const PROFILE_FORM_ID = 'profileForm';
export const RECONCILIATION_FORM_ID = 'reconciliationForm';
export const SUBCATEGORY_FORM_ID = 'subcategoryForm';
export const TRANSACTION_FORM_ID = 'transactionForm';
export const TRANSACTION_AUTOMATION_FORM_ID = 'transactionAutomationForm';
export const TRANSACTION_PREDICTION_FORM_ID = 'transactionPredictionForm';
export const MASS_EDIT_TRANSACTION_FORM_ID = 'massEditTransactionForm';
export const WALLET_FORM_ID = 'walletForm';
export const PASSWORD_CHANGE_FORM_ID = 'passwordChangeForm';

/*
 * Bootstrap variants and colors
 */
export const VARIANTS_FOR_RECONCILIATION_STATUSES = {
  in_progress: 'secondary',
  finished: 'success',
  cancelled: 'danger',
};

export const COLORS_FOR_RECONCILIATION_STATUSES = {
  in_progress: 'var(--bs-secondary)',
  finished: 'var(--bs-success)',
  cancelled: 'var(--bs-danger)',
};

export const COLORS_FOR_IMPORT_STATUSES = {
  in_progress: 'var(--bs-secondary)',
  finished: 'var(--bs-success)',
  cancelled: 'var(--bs-danger)',
};

export const VARIANTS_FOR_IMPORT_ACTIONS = {
  import: 'primary',
  skip: 'light',
  block: 'danger',
  match: 'secondary',
}

/*
 * Cookies
 */
export const CATEGORY_OPTIONS_COOKIE_NAME = 'category-options';
export const PROFILE_OPTIONS_COOKIE_NAME = 'profile-options';
export const DISPLAY_OPTIONS_COOKIE_NAME = 'display-options';
export const DATE_RANGE_COOKIE_NAME = 'date-range-options';

/*
 * Caching
 */
export const BROWSER_CACHE_NAME = 'finance_micromanager_cache';
export const LATEST_UPDATED_AT_VALUES_HEADER_NAME = 'Browser-Cache-Updated-At-Values';
export const CACHED_TIMESTAMP_HEADER_NAME = 'Browser-Cache-Timestamp';
export const CURRENT_PROFILE_ID_HEADER_NAME = 'Current-Profile-Id';

/*
 * Icons
 */
export const ICON_BUDGETS = 'piggy-bank';
export const ICON_DASHBOARD = 'home';
export const ICON_TRANSACTION_AUTOMATIONS = 'robot';
export const ICON_TRANSACTION_LIST = 'list';
export const ICON_TRANSACTION_PREDICTIONS = 'wand-magic-sparkles';
export const ICON_TRANSACTIONS = 'money-bill-transfer';
export const ICON_RECONCILIATIONS = 'scale-balanced';
export const ICON_CATEGORIES = 'shapes';
export const ICON_IMPORTS = 'file-import';
export const ICON_IMPORT_LIST = 'list';
export const ICON_IMPORT_SETTINGS = 'gear';
export const ICON_WALLETS = ['far', 'credit-card'];
export const ICON_PROFILES = 'wallet';
export const ICON_SETTINGS = 'sliders';
export const ICON_SIGN_IN = 'right-to-bracket';
export const ICON_SIGN_UP = 'user-plus';
export const ICON_SIGN_OUT = 'right-from-bracket';

/*
 * Other
 */
export const DEBIT_TRANSACTION = 'debit';
export const CREDIT_TRANSACTION = 'credit';
export const ALL_TRANSACTIONS = 'all';
export const PAGINATION_PER_PAGE_OPTIONS = [10, 25, 50, 100];
export const GITHUB_REPO_URL = 'https://github.com/roooodcastro/finance-micromanager';

/*
 * Budgets
 */

export const BUDGET_OWNER_TYPE_CATEGORY = 'Category';
export const BUDGET_OWNER_TYPE_PROFILE = 'Profile';

export const BUDGET_LIMIT_TYPE_ABSOLUTE ='absolute';
export const BUDGET_LIMIT_TYPE_PERCENTAGE ='percentage';
export const BUDGET_LIMIT_TYPE_REMAINDER ='remainder';

export const BUDGET_VALID_LIMIT_TYPES_FOR_PROFILE = [BUDGET_LIMIT_TYPE_ABSOLUTE, BUDGET_LIMIT_TYPE_PERCENTAGE];
export const BUDGET_VALID_LIMIT_TYPES_FOR_CATEGORY = [
  BUDGET_LIMIT_TYPE_ABSOLUTE,
  BUDGET_LIMIT_TYPE_PERCENTAGE,
  BUDGET_LIMIT_TYPE_REMAINDER,
];

export const BUDGET_VALID_LIMIT_TYPES = {
  [BUDGET_OWNER_TYPE_PROFILE]: BUDGET_VALID_LIMIT_TYPES_FOR_PROFILE,
  [BUDGET_OWNER_TYPE_CATEGORY]: BUDGET_VALID_LIMIT_TYPES_FOR_CATEGORY,
}

/*
 * Imports
 */
export const IMPORT_ACTION_IMPORT = 'import';
export const IMPORT_ACTION_SKIP = 'skip';
export const IMPORT_ACTION_MATCH = 'match';
export const IMPORT_ACTION_BLOCK = 'block';
export const IMPORT_ACTIONS = [
  { id: IMPORT_ACTION_IMPORT, labelI18nKey: 'views.imports.action_labels.import', icon: 'plus' },
  { id: IMPORT_ACTION_MATCH, labelI18nKey: 'views.imports.action_labels.match', icon: 'link' },
  { id: IMPORT_ACTION_SKIP, labelI18nKey: 'views.imports.action_labels.skip', icon: 'scissors' },
  { id: IMPORT_ACTION_BLOCK, labelI18nKey: 'views.imports.action_labels.block', icon: 'ban' },
];
export const IMPORT_PREVIEW_SAVE_STATES = {
  saved: 'saved',
  saving: 'saving',
  error: 'error',
};
