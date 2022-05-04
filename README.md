# Capsule App

Web application for Capsule system that allows users to receive the messages from their time capsule that they sent before, users can also share the capsules with friends so that they can receive their capsule messages at the same time in the future.

Please also note the Web API that it uses: https://github.com/ISS-Security-Jeemby/capsule-api

## Install

Install this application by cloning the *relevant branch* and use bundler to install specified gems from `Gemfile.lock`:

```shell
bundle install
```

## Test

This web app does not contain any tests yet :(

## Execute

Launch the application using:

```shell
rake run:dev
```

The application expects the API application to also be running (see `config/app.yml` for specifying its URL)