## Rails API Template

[![standard-readme compliant](https://img.shields.io/badge/standard--readme-OK-green.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)

## Table of Contents

- [Motivation](#motivation)
- [Usage](#usage)
- [Features](#features)

## Motivation

In the many rails apps I've built, there are common gems and configurations that I normally use. At times, it's difficult to track the configurations and in which file. I decided to note each of these and just use the power of Rails templates to quickly generate a boilerplate.

## Usage

**Special Instructions For Linux Users**

Add the `rails_api_template.rb` file in your `Home` folder.

In your `.bashrc` file add the following alias:

```bash
alias rails_api_app = rails new -T -d postgresql --api ~m ~/rails_api_template.rb
```

To create a new rails api project:

```bash
$ rails_api_app <app name> <local postgres username> <local postgres password>
# make sure to type in the exact same sequence
```

Start generating json apis.

## Features

1. Readily includes `devise` for authentication
2. Test already configured for `rspec`
3. Uses `pundit` for authorization
4. Uses `jwt` (JSON Web Token) to generate encrypted hash to authenticate requests
5. Automatically creates the first commit and sets the initial git branch to `development`.
