---
title: eventLeave
---

Triggered on a calendar after one of its events is [dropped onto another calendar](other-calendar-dragging).

It fires when the event is released, before the event is removed from this calendar and before the receiving calendar's [drop](drop) and [eventReceive](eventReceive) callbacks.

<div class='spec' markdown='1'>
function( *info* ) { }
</div>

`info` is a plain object with the following properties:

<table>

<tr>
<th>event</th>
<td markdown='1'>
An [Event object](event-object) that is leaving.
</td>
</tr>

<tr>
<th>relatedEvents</th>
<td>an array of other related <a href='event-object'>Event Objects</a> that also left. an event might have other <a href='recurring-events'>recurring event</a> instances or might be linked to other events with the same <code>groupId</code></td>
</tr>

<tr>
<th>revert</th>
<td>a function that can be called to reverse this action</td>
</tr>

<tr>
<th>view</th>
<td markdown='1'>
The current [View Object](view-object).
</td>
</tr>

<tr>
<th>draggedEl</th>
<td markdown='1'>
The HTML element that was being dragged.
</td>
</tr>

</table>

This callback will be fired before the receiving calendar's [drop](drop) and [eventReceive](eventReceive) callbacks are fired.

This callback is fired before [eventRemove](eventRemove).
