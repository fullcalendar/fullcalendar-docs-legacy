---
title: eventInteractive
---

Setting to `true` will cause all events to be focusable/tabbable. Setting to `false` makes them non-interactive.

<div class='spec' markdown='1'>
Boolean, default: unset
</div>

When set, this calendar-wide option wins. When left unset, each event's own `interactive` boolean of the [event object](event-parsing) decides. When that is also unset, events are interactive if an [eventClick](eventClick) handler is defined.

Events with a `url` always render as links and are always interactive, regardless of these settings.
