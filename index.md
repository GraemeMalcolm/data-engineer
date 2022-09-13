---
title: Online Hosted Instructions
permalink: index.html
layout: home
---

# Exercises

Exercises for [icrosoft Learn](https://docs.microsoft.com/training/) training.

{% assign labs = site.pages | where_exp:"page", "page.url contains '/Instructions/Labs'" %}
| Exercise |
| --- | --- | 
{% for activity in labs  %}| [{{ activity.lab.title }}{% if activity.lab.type %} - {{ activity.lab.type }}{% endif %}]({{ site.github.url }}{{ activity.url }}) |
{% endfor %}

