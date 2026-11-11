---
title: eventLeave
---

Triggered on a calendar after one of its events is [dropped onto another calendar](other-calendar-dragging).

It fires after the drop, just before the event is removed from this calendar.

<div class='spec' markdown='1'>
function( *info* ) { }
</div>

`info` is a plain object with the following properties:

<table>

<tr>
<th>draggedEl</th>
<td markdown='1'>
The HTML element that was being dragged.
</td>
</tr>

<tr>
<th>event</th>
<td markdown='1'>
An [Event object](event-object) that is leaving.
</td>
</tr>

<tr>
<th>view</th>
<td markdown='1'>
The current [View Object](view-object).
</td>
</tr>

</table>

This callback will be fired before the receiving calendar's [drop](drop) and [eventReceive](eventReceive) callbacks are fired.
