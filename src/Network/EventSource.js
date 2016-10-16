"use strict";

exports.newEventSourceImpl1 = function(url) {
  return function() {
    return new EventSource(url);
  };
};


exports.newEventSourceImpl2 = function(url, config) {
  return function() {
    return new EventSource(url, config);
  };
};


exports.setOnMessageImpl = function(eventSource, handler) {
  return function() {
    eventSource.onmessage = handler;
  };
};

exports.setOnOpenImpl = function(eventSource, handler) {
  return function() {
    eventSource.onopen = function(e) {
      handler(e)();
    };
  };
};

exports.eventDataImpl = function(event) {
  return event.data;
};

exports.readyStateImpl = function(target) {
  return target.readyState;
};

exports.urlImpl = function(target) {
  return target.url;
};
