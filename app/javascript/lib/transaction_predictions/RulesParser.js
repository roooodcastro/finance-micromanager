import useCategoryStore from '~/stores/CategoryStore.js';
import useWalletStore from '~/stores/WalletStore.js';
import I18n from '~/utils/I18n.js';

export const CONTAINS_OPERATOR = 'contains';
export const EQUALS_OPERATOR = 'equals';

export class RulesParser {
  constructor(rulesJson) {
    this.rules = JSON.parse(rulesJson ?? '{}');

    if (!this.rules.conditions) {
      this.rules.conditions = [];
    }
    if (!this.rules.actions) {
      this.rules.actions = [];
    }
  }

  get conditions() {
    return this.rules.conditions;
  }

  get conditionsDescription() {
    const t = I18n.scopedTranslator('views.transaction_predictions.form');

    return this.rules.conditions.map((condition) => {
      const column = condition.column ? t(`${condition.column}_label`) : '?';
      const operator = condition.operator ? t(`${condition.operator}_operator_label`) : '?';
      const displayValue = this.formattedValueFor(condition);
      const value = displayValue ? `"${displayValue}"` : '?';

      return `${column} ${operator} ${value}`;
    }).join(`, ${t('label_or')} `);
  }

  get actionsDescription() {
    const t = I18n.scopedTranslator('views.transaction_predictions.form');

    return this.rules.actions.map((action) => {
      const column = action.column ? t(`${action.column}_label`) : '?';
      const displayValue = this.formattedValueFor(action);
      const value = displayValue ? `"${displayValue}"` : '?';

      return `${column} ${t('label_with')} ${value}`;
    }).join(`, ${t('label_and')} `);
  }

  get actions() {
    return this.rules.actions;
  }

  set conditions(conditions) {
    this.rules.conditions = conditions;
  }

  set actions(actions) {
    this.rules.actions = actions;
  }

  toJson() {
    return JSON.stringify(this.rules);
  }

  getConditionAt(index) {
    return this.rules.conditions[index] ?? {};
  }

  setConditionAt(index, condition) {
    this.rules.conditions[index] = condition;
  }

  deleteConditionAt(index) {
    this.rules.conditions.splice(index, 1);
  }

  deleteActionAt(index) {
    this.rules.actions.splice(index, 1);
  }

  getActionAt(index) {
    return this.rules.actions[index] ?? {};
  }

  setActionAt(index, action) {
    this.rules.actions[index] = action;
  }

  hasConditionsMatch(transaction) {
    return this.conditions.reduce((result, condition) => {
      return result && this.#hasConditionMatch(transaction, condition);
    }, true);
  }

  formattedValueFor(conditionOrAction) {
    if (conditionOrAction.column === 'category_id') {
      const categoryStore = useCategoryStore();
      return categoryStore.categoryNameFor(conditionOrAction.value);
    } else if (conditionOrAction.column === 'wallet_id') {
      const walletStore = useWalletStore();
      return walletStore.walletNameFor(conditionOrAction.value);
    } else {
      return conditionOrAction.value;
    }
  }

  apply(transaction) {
    if (this.hasConditionsMatch(transaction)) {
      transaction[this.action.column] = this.action.value;
    }

    return transaction;
  }

  #hasConditionMatch(transaction, condition) {
    if (condition.operator === CONTAINS_OPERATOR) {
      return transaction[condition.column]?.includes(condition.value) ?? false;
    } else if (condition.operator === EQUALS_OPERATOR) {
      return transaction[condition.column] === condition.value;
    }

    return false;
  }
}
