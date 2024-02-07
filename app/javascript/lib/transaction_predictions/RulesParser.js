export const CONTAINS_OPERATOR = 'contains';
export const EQUALS_OPERATOR = 'equals';
export const AVAILABLE_OPERATORS = [CONTAINS_OPERATOR, EQUALS_OPERATOR];

export class RulesParser {
  constructor(rulesJson) {
    this.rules = JSON.parse(rulesJson);
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

  hasConditionsMatch(transaction) {
    return this.conditions.reduce((result, condition) => {
      return result && this.#hasConditionMatch(transaction, condition);
    }, true);
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
