---
title: V3 Release Notes and Upgrade Guide
layout: text
---

Upgrading from FullCalendar version 2 to version 3 should be straightforward for most integrations. Version 3 introduced new features, but only a small number of breaking changes.

## Dependencies and Browser Support

- IE8 is no longer supported.
- The minimum supported jQuery version is now 2.0.0.
- The minimum supported Moment version is now 2.9.0.

Make sure the required versions of jQuery and Moment are loaded before FullCalendar.

## Locale Changes

The `lang` option has been renamed to [`locale`](locale):

```js
$('#calendar').fullCalendar({
  locale: 'es'
})
```

Locale distribution files have also moved and been renamed:

- `lang/` is now `locale/`.
- `lang-all.js` is now `locale-all.js`.

## Removed Options

The following deprecated features have been removed:

- View-option hashes
- `weekMode`
- `axisFormat`

Use view-specific options instead of view-option hashes. Use [`slotLabelFormat`](slotLabelFormat) instead of `axisFormat`.

## Moment Behavior

FullCalendar's ambiguously-timed and ambiguously-zoned Moments no longer alter the behavior of Moment's `isSame`, `isBefore`, and `isAfter` methods.

## Day-Number Markup

The DOM structure of day numbers in month and basic views has changed. Custom CSS or JavaScript that targets those elements might need to be updated.

For the new features and more context, read the [FullCalendar v3 release announcement](https://fullcalendar.io/blog/2016/09/feature-packed-releases). The complete list of changes is available in the [v3.0.0 changelog]({{ site.baseurl }}/releases/fullcalendar/3.0.0/CHANGELOG.txt).
