import { querySelectorAll } from './lib/util'
import './styles/homepage/main.scss'

document.addEventListener('DOMContentLoaded', function () {
  initAnimationTriggers()
  initTechSelector()
})

function initAnimationTriggers() {
  var observer = new IntersectionObserver(function (entries) {
    entries.forEach(function (entry) {
      if (entry.isIntersecting) {
        entry.target.classList.add('hp-animation-trigger--triggered')
        observer.unobserve(entry.target)
      }
    })
  }, { threshold: 0.75 })

  querySelectorAll('.hp-animation-trigger').forEach(function (triggerEl) {
    observer.observe(triggerEl)
  })
}

// The split selector (>=tablet) and the accordion selector (<tablet) are both rendered,
// and CSS media queries determine which one is visible.
function initTechSelector() {
  var currentTech = 'react'
  var accordionExpanded = {} // overrides whether currentTech is expanded in the accordion

  function isAccordionExpanded(techName) {
    return techName in accordionExpanded
      ? accordionExpanded[techName]
      : techName === currentTech
  }

  function setTech(techName) {
    currentTech = techName
    render()
  }

  function toggleAccordion(techName) {
    accordionExpanded[techName] = !isAccordionExpanded(techName)
    render()
  }

  function render() {
    querySelectorAll('[data-tech-code]').forEach(function (el) {
      el.classList.toggle(
        'hp-space-editor__code--selected',
        el.getAttribute('data-tech-code') === currentTech
      )
    })

    querySelectorAll('[data-tech-verbage]').forEach(function (el) {
      el.hidden = el.getAttribute('data-tech-verbage') !== currentTech
    })

    querySelectorAll('[data-tech-tab]').forEach(function (el) {
      var isCurrent = el.getAttribute('data-tech-tab') === currentTech

      el.setAttribute('aria-selected', isCurrent)
      el.querySelector('.hp-tech-icon').classList.toggle('hp-tech-icon--selected', isCurrent)
      el.querySelector('.hp-tech-title').classList.toggle('hp-tech-title--selected', isCurrent)
    })

    querySelectorAll('[data-tech-accordion]').forEach(function (el) {
      var isExpanded = isAccordionExpanded(el.getAttribute('data-tech-accordion'))
      var headEl = el.querySelector('.hp-tech-accordion__item-head')

      headEl.setAttribute('aria-pressed', isExpanded)
      el.querySelector('.hp-tech-accordion__item-toggle')
        .classList.toggle('hp-tech-accordion__item-toggle--selected', isExpanded)
      el.querySelector('.hp-tech-icon').classList.toggle('hp-tech-icon--selected', isExpanded)
      el.querySelector('.hp-tech-accordion__item-rich-title').hidden = !isExpanded
      el.querySelector('.hp-tech-accordion__item-plain-title').hidden = isExpanded
      el.querySelector('.hp-tech-accordion__item-body').hidden = !isExpanded
    })
  }

  function onActivate(el, handler) {
    el.addEventListener('click', handler)
    el.addEventListener('keydown', function (ev) {
      if (ev.key === 'Enter' || ev.key === ' ') {
        ev.preventDefault()
        handler()
      }
    })
  }

  querySelectorAll('[data-tech-tab]').forEach(function (el) {
    onActivate(el, function () {
      setTech(el.getAttribute('data-tech-tab'))
    })
  })

  querySelectorAll('[data-tech-accordion]').forEach(function (el) {
    onActivate(el.querySelector('.hp-tech-accordion__item-head'), function () {
      toggleAccordion(el.getAttribute('data-tech-accordion'))
    })
  })

  render()
}
