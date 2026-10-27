---
title: nowIndicatorSnap
since_version: 6.1.19
---

Whether the [now indicator](nowIndicator) jumps to the start of each time unit instead of tracking the exact time.

<div class='spec' markdown='1'>
`true`/`false`/`'auto'`, *default*: `'auto'`
</div>

When snapping, the indicator sits at the start of the current unit and moves once the next unit begins. Otherwise it moves to the exact current [now](now) once a minute.

The unit depends on the view. In **TimeGrid** views it is the minute, so the indicator moves every minute either way. In **Timeline** views it comes from the [slotDuration](slotDuration): the hour for `'01:00'` slots, the day for `{ days: 1 }` slots.

`'auto'` snaps in Timeline views when the slot duration is a single unit, such as one hour, or is measured in days or longer. With 30-minute slots, for example, it tracks the exact time.
