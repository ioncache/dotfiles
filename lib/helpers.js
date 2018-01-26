'use strict';

/*
  Some helper functions that can be used in any of the owp-utils
*/

const colors = require('colors/safe');

function log(...args) {
  output('white', args);
}

function info(...args) {
  output('green', args);
}

function warn(...args) {
  output('yellow', args);
}

function error(...args) {
  output('red', args);
}

function debug(...args) {
  output('magenta', args);
}

function output(color, args) {
  for (let arg of args) {
    switch (typeof arg) {
      case 'number':
      case 'string':
        console.log("\n" + colors[color](arg));
        break;
      default:
        console.log("\n", arg);
    }
  }
}

const consoleLogger = {
  debug: debug,
  error: error,
  info: info,
  log: log,
  war: warn
};

module.exports = {
  consoleLogger: consoleLogger
};
