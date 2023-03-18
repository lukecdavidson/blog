---
layout: post
title: Making Containers with Podman
---
podman can tag multiple tags at once by specifying -t multiple times. Can be useful for tagging a version and also tagging as latest at the same time.

Can create a ruby environment blog2test on desktop has the Dockerfile
podman build -t ruby-env .
podman run -v .:/app:Z -d -t ruby-env
podman exec -it $container /bin/bash
