import _ from 'lodash';

class Csrf {
  constructor() {
    this.token = null;
  }

  getToken() {
    return this.token;
  }

  refreshToken() {
    const token = document.querySelector('meta[name="csrf-token"]')?.content;
    if (_.isEmpty(token)) {
      throw new Error('CSRF TOKEN not found!');
    } else {
      this.token = token;
    }
  }
}

export default new Csrf();
