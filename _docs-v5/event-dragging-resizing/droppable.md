---
title: droppable
---

Determines if events [from other calendars](other-calendar-dragging) can be dropped onto the calendar.

<div class='spec' markdown='1'>
Boolean, *default*: `false`
</div>

The receiving calendar must also have [editable](editable) set to `true` to accept events from other calendars.

This setting does not affect [external elements](external-dragging) (`Draggable` or `ThirdPartyDraggable`), which can be dropped regardless. Use [dropAccept](dropAccept) to filter those.
