---
layout: post
title:  "Migration to Jekyll"
date:   2022-06-30 12:00:00 -0800
categories: blogging jekyll
---
# Building a Development Container

```
podman build -t blog-dev .
podman create --name blog-dev -v .:/app:Z -p 4000:4000 blog-dev
podman start blog-dev
```

https://github.com/jekyll/jekyll-compose
