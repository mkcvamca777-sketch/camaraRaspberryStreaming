#ifndef SAFETY_WATCHDOG_H
#define SAFETY_WATCHDOG_H

#include <Arduino.h>

typedef void (*WatchdogTimeoutCallback)();

class SafetyWatchdog {
public:
    SafetyWatchdog(unsigned long timeoutMs = 400, WatchdogTimeoutCallback callback = nullptr);

    void begin();
    void feed();
    void check();
    bool isExpired() const;

private:
    unsigned long _timeoutMs;
    unsigned long _lastFeedTime;
    bool _isExpired;
    WatchdogTimeoutCallback _callback;
};

#endif // SAFETY_WATCHDOG_H
