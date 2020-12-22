# Secret Santa

![Master](https://github.com/Sillhouette/secret_santa/workflows/Master/badge.svg) ![Develop](https://github.com/Sillhouette/secret_santa/workflows/Develop/badge.svg) ![Coverage](https://github.com/Sillhouette/secret_santa/blob/master/assets/coverage/coverage_badge_total.svg?raw=true)

A small secret santa cli app used to choose recipients of secret santa gifts in a group of people

## Requirements

- Ruby >= 2.6.6

## Installation

### Github

#### Install:
- (ssh) Run `git clone git@github.com:Sillhouette/secret_santa.git && cd secret_santa`
- (http) Run `git clone https://github.com/Sillhouette/secret_santa.git && cd secret_santa`

Setup the commit message template
```
$ git config commit.template .git-templates/pull-request-template.md
```

### Run:
- Use `ruby bin/run.rb` to execute the app

### Tests:
- Use `bundle exec rspec` to run the tests
- Tests include a code coverage check

### Development
- Clone repo
- Run `bundle install` to install dependencies
- Run `git config commit.template .git-templates/pull_request_template.md` to install commit message template

### Contributing
- Fork the repo (`https://github.com/Sillhouette/secret_santa/fork`)
- Run `git config commit.template .git-templates/pull_request_template.md` to install commit message template
- Create your feature branch (`git checkout -b my-new-feature`)
- Add changes (`git add file_name`)
- Commit your changes (`git commit`) 
    - Please follow the commit message template
- Push to the branch (`git push origin my-new-feature`)
- Create a new Pull Request

This project has been licensed under the [MIT open source license](https://github.com/Sillhouette/secret_santa/blob/master/LICENSE.md).
