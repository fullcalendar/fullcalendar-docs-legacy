---
title: nextDayThreshold
---

How far an event must run into the next day before it renders on that day. It applies when an event's end time spans into another day.

<div class='spec' markdown='1'>
Duration, default: `"09:00:00"` (9am)
</div>

Only affects timed events that appear on whole-days: in month view, basicDay, basicWeek, list views, and Scheduler timeline views with day-sized slots. It does not affect all-day events, or timed events displayed against a time-of-day axis, such as in the agenda views.

For example, with `nextDayThreshold` being the default of 9am, the following event would appear to take up only one day:

```js
{ start: '2014-02-04T20:00:00', end: '2014-02-05T02:00:00' }
// goes from 8pm to 2am the next day
```

Whereas the following event would appear to take up two days:

```js
{ start: '2014-02-04T20:00:00', end: '2014-02-05T10:00:00' }
// goes from 8pm to 10am the next day
```
