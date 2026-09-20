#include "safety_watchdog.h"

SafetyWatchdog::SafetyWatchdog(unsigned long timeoutMs, WatchdogTimeoutCallback callback)
    : _timeoutMs(timeoutMs), _lastFeedTime(0), _isExpired(true), _callback(callback) {}

void SafetyWatchdog::begin() {
    _lastFeedTime = millis();
    _isExpired = true; // Por seguridad inicia en estado detenido
    if (_callback) {
        _callback();
    }
}

void SafetyWatchdog::feed() {
    _lastFeedTime = millis();
    _isExpired = false;
}

void SafetyWatchdog::check() {
    if (!_isExpired && (millis() - _lastFeedTime > _timeoutMs)) {
        _isExpired = true;
        if (_callback) {
            _callback(); // Invoca parada inmediata de motores
        }
    }
}

bool SafetyWatchdog::isExpired() const {
    return _isExpired;
}
