import useCategoryStore from '~/stores/CategoryStore.js';
import useWalletStore from '~/stores/WalletStore.js';

export const CONTAINS_OPERATOR = 'contains';
export const EQUALS_OPERATOR = 'equals';
export const AVAILABLE_OPERATORS = [CONTAINS_OPERATOR, EQUALS_OPERATOR];

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

  get action() {
    return this.rules.action;
  }

  set conditions(conditions) {
    this.rules.conditions = conditions;
  }

  set action(action) {
    this.rules.action = action;
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
