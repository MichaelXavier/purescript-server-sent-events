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


exports.setOnErrorImpl = function(eventSource, handler) {
  return function() {
    eventSource.onerror = handler;
  };
};


exports.setOnMessageImpl = function(eventSource, handler) {
  return function() {
    eventSource.onmessage = handler;
  };
};

exports.setOnOpenImpl = function(eventSource, handler) {
  return function() {
    eventSource.onopen = handler;
  };
};

exports.eventDataImpl = function(event) {
  return event.data;
};

exports.readyStateImpl = function(target) {
  return function() {
    return target.readyState;
  };
};

exports.withCredentialsImpl = function(target) {
  return target.withCredentials;
};

exports.urlImpl = function(target) {
  return target.url;
};

exports.closeImpl = function(eventSource) {
  return function() {
    eventSource.close()
  };
};
