#!/usr/bin/env node
'use strict';

/*
  Installs some standard 'nix-ish configuration files and sofware
*/

/******************/
/* Module imports */
/******************/

const _ = require('lodash');
const colors = require('colors/safe');
const commandExists = require('command-exists');
const helpers = require('../lib/helpers');
const inquirer = require('inquirer');
const log = require('log-defer');
const ora = require('ora');
const prompt = require('prompt');
const request = require('request-promise'); // NOTE: these are not native ES6 promises, it uses bluebird, but this includes .finally which is nice

/****************/
/* Globals etc. */
/****************/

const VERSION = '0.0.1';
const argv = require('yargs')
  .usage(colors.yellow(`$0 - clone a user's profile to another target user in the same environment`))
  .alias('h', 'help')
  .option('a', {
    alias: 'application-name',
    default: 'tradingview',
    description: 'the application name the profile is stored under (tradingview|webPlatform|etc)',
    type: 'string'
  })
  .option('admin', {
    description: 'admin username or username:password -- if no password is provided you will be prompted',
    group: authGroup,
    type: 'string'
  })
  .option('cu', {
    alias: 'client-username',
    description: `client's username`,
    group: authGroup,
    type: 'string'
  })
  .option('d', {
    alias: 'dry-run',
    default: false,
    describe: 'perform a dry-run of the process, gets the profile only, does not save',
    type: 'boolean'
  })
  .option('e', {
    alias: 'environment',
    choices: ['production', 'staging'],
    default: 'staging',
    description: 'the environment to retrieve and store profiles to',
    type: 'string'
  })
  .alias ('v', 'version')
  .help()
  .version(VERSION)
  .argv;

  let cl = helpers.consoleLogger;
  let exec = require('child_process').exec;
  let spinner = new ora();
