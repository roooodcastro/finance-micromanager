import { storeToRefs } from 'pinia';
import _ from 'lodash';

import useTransactionPredictionStore from '~/stores/TransactionPredictionStore.js';
import { RulesParser, CONTAINS_OPERATOR, EQUALS_OPERATOR } from '~/lib/transaction_predictions/RulesParser.js';

export class RulesProcessor {
  constructor(transaction, changedColumnName = null) {
    this.transaction = transaction;
    this.changedColumnName = changedColumnName;
  }

  processTransaction() {
    const transactionPredictionStore = useTransactionPredictionStore();
    const { activeTransactionPredictions } = storeToRefs(transactionPredictionStore);

    activeTransactionPredictions.value.forEach((transactionPrediction) => {
      const rulesParser = new RulesParser(transactionPrediction.rulesJson);

      const conditionResults = rulesParser.conditions.map((condition) => {
        const columnName = _.camelCase(condition.column);
        if (condition.operator === CONTAINS_OPERATOR) {
          return this.transaction[columnName]?.toLowerCase()?.includes(condition.value?.toLowerCase());
        } else if (condition.operator === EQUALS_OPERATOR) {
          return this.transaction[columnName]?.toString().toLowerCase() === condition.value.toString().toLowerCase();
        }
        return false;
      });

      if (conditionResults.some(Boolean)) {
        rulesParser.actions.forEach((action) => {
          const columnName = _.camelCase(action.column);
          if (this.changedColumnName !== columnName) {
            this.transaction[columnName] = action.value;
          }
        });
      }
    });

    return this.transaction;
  }
}
