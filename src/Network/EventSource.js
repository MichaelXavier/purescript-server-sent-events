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
    eventSource.onmessage = function(e) {
      handler(e)();
    };
  };
};

exports.eventDataImpl = function(event) {
  return event.data;
};
