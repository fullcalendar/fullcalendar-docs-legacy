---
title: No-Events Render Hooks
---

In list view, the “No events to display” message.


`noEventsClassNames` - a [ClassName Input](classname-input)

`noEventsContent` - a [Content Injection Input](content-injection)

`noEventsDidMount`

`noEventsWillUnmount`


## Argument

When the above hooks are specified as a function in the form `function(arg)`, the `arg` is an object with the following properties:

- `text` - the message text, from the `noEventsText` option
- `view` - the current [View Object](view-object)
- `el` - the element. only available in `noEventsDidMount` and `noEventsWillUnmount`
