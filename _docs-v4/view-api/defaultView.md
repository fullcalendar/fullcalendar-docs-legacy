---
title: defaultView
---

The initial view when the calendar loads.

<div class='spec' markdown='1'>
String
</div>

A name of any of the available views, such as `'dayGridWeek'`, `'timeGridDay'`, `'listWeek'`.

If omitted, the calendar shows the default view of the first plugin to register one. Plugins register in the order of the [plugins](plugin-index) array, each one after its dependencies. The defaults are `'dayGridMonth'` for DayGrid, `'timeGridWeek'` for TimeGrid, and `'timelineDay'` for Timeline. The resource plugins depend on these, so they start in a non-resource view: `'dayGridMonth'` for Resource DayGrid, `'timeGridWeek'` for Resource TimeGrid, and `'timelineDay'` for Resource Timeline. Set `defaultView` to start in a resource view.
