[![Build Status][build-status-shield]][build-status-url]
[![Latest Release][release-shield]][release-url]
[![MIT License][license-shield]][license-url]

<div align="center">
  <a href="https://github.com/roooodcastro/finance-micromanager">
    <img src="app/javascript/images/monogram.svg" alt="Project Logo" width="256px" height="256px">
  </a>

  <h1 align="center">Finance MicroManager</h1>

  <p align="center">
    Finance MicroManager is a personal finance management tool designed to allow users in meticulously tracking
    day-to-day expenses. With a user-friendly interface, this web-based application ensures you have complete control
    and visibility into your financial life. Input and monitor your expenditures with great detail, allowing you to
    make informed decisions about your budget, savings, and financial goals. Finance MicroManager provides the tools
    you need to navigate and manage your finances effectively. Start taking control of your financial future today!
  </p>
</div>

## About The Project

### Features

#### Transaction tracking

*TODO*

#### Categories and Subcategories

*TODO*

#### Profiles and Wallets

*TODO*

#### Reconciliations

*TODO*

#### Transaction Automations

*TODO*

#### Honourable mentions:

- Support for English and Brazilian Portuguese languages
- Mobile-first responsive layout
- Nice charts in dashboard with insights of your finances for the selected month

### Built With

* [![Kubernetes][kubernetes-shield]][kubernetes-url]
* [![Ruby on Rails][rails-shield]][rails-url]
* [![Vue][Vue.js]][Vue-url]
* [![Bootstrap][Bootstrap.com]][Bootstrap-url]
* [![Font Awesome][fontawesome-shield]][fontawesome-url]


## Self-hosting

*TODO*

### Prerequisites

*TODO*

### Installation

*TODO*

## Roadmap

**This list is not prioritised, and does not follow any particular order.**

- [ ] Landing page showcasing the project
- [ ] Dark Mode
- [ ] Better insights and statistics in category and wallet page
- [ ] Admin area
- [ ] New user onboarding/walkthrough
- [ ] Authorization management
- [ ] User can easily undo destructive actions
- [ ] Comprehensive transaction search
- [ ] Allow for more complex transaction automation schedules
  - [ ] "first/last day of month"
  - [ ] "first/last business day of month" - will require integration with calendar and new user settings
- [ ] Transaction Predictions (form automations to speed up the creation of transactions)
- [ ] Splitting transactions into multiple sub-transactions of different categories
- [ ] Autocomplete transaction names when creating transactions
- [ ] Batch importing of transactions
- [ ] New Transaction types:
  - [ ] Balance transfer between wallets
  - [ ] Balance transfer between profiles (with currency conversion support)
- [ ] Credit card support (allow users to create transactions that will only be paid in the future)
- [ ] Suggest common categories when creating a new profile
- [ ] Allow the user to translate categories and subcategories
  - [ ] Provide "library" of common category names and translations
- [ ] User can specify icons for categories
- [ ] Categories can be manually ordered
- [ ] User can define monthly budgets for each category/subcategory
- [ ] 50/30/20 rule tracking and insights
- [ ] Allow user to choose different period types (week, quarter, year instead of just month)
- [ ] Keyboard shortcuts
- [ ] Omniauth
- [ ] Notifications and notification centre
  - [ ] Native notifications
- [ ] User can add avatar photo
- [ ] Use ActiveCable to stream all changes to the frontend
- [ ] Decouple backend from frontend and convert frontend into SPA
- [ ] Service Worker for adding basic PWA support

The issue and feature tracking is still not in a public platform, but it will eventually be moved to GitHub Issues.


## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create.
Any contributions you make are **greatly appreciated**.

If you want to report a bug, or if you have a suggestion that would make this better, please fork the repo and create
a pull request. You can also simply open an issue describing the suggestion or bug.
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b my-amazing-feature`)
3. Commit your Changes (`git commit -m 'Implement some AmazingFeature'`)
4. Push to the Branch (`git push origin my-amazing-feature`)
5. Open a Pull Request


## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

[release-shield]: https://img.shields.io/github/v/release/roooodcastro/finance-micromanager?style=flat-square
[release-url]: https://github.com/roooodcastro/finance-micromanager/releases
[build-status-shield]: https://img.shields.io/github/actions/workflow/status/roooodcastro/finance-micromanager/rubyonrails.yml?style=flat-square
[build-status-url]: https://github.com/roooodcastro/finance-micromanager/actions
[license-shield]: https://img.shields.io/github/license/roooodcastro/finance-micromanager.svg?style=flat-square
[license-url]: https://github.com/roooodcastro/finance-micromanager/blob/master/LICENSE.txt
[rails-shield]: https://img.shields.io/badge/Ruby%20on%20Rails%207.0-D30100?style=flat-square&logo=rubyonrails&logoColor=FFFFFF
[rails-url]: https://rubyonrails.org/
[Vue.js]: https://img.shields.io/badge/Vue.js%203-35495E?style=flat-square&logo=vuedotjs&logoColor=4FC08D
[Vue-url]: https://vuejs.org/
[Bootstrap.com]: https://img.shields.io/badge/Bootstrap%205.3-563D7C?style=flat-square&logo=bootstrap&logoColor=white
[Bootstrap-url]: https://getbootstrap.com
[kubernetes-shield]: https://img.shields.io/badge/Kubernetes-326CE5?style=flat-square&logo=kubernetes&logoColor=white
[kubernetes-url]: https://kubernetes.io/
[fontawesome-shield]: https://img.shields.io/badge/Font%20Awesome-528DD7?style=flat-square&logo=fontawesome&logoColor=white
[fontawesome-url]: https://kubernetes.io/
