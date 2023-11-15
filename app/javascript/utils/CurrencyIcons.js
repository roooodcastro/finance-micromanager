export function faIconForCurrency(currencyName) {
    const iconMapping = {
      eur: 'euro-sign',
      usd: 'dollar-sign',
      brl: 'brazilian-real-sign',
      gbp: 'sterling-sign',
      jpy: 'yen-sign',
    };

    return iconMapping[currencyName] ?? 'wallet';
}
