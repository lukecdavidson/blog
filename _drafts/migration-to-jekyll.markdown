---
layout: post
title:  "Migration to Jekyll"
date:   2022-06-30 12:00:00 -0800
categories: blogging jekyll
---
# Platform Overviews

Overview of Wordpress.com, wordpress.org, jekyll and github pages

# Why Migrate

## Cons of Wordpress

Mention security vulnerabilities associated with many wordpress sites. Hundreds of login attempts. Fail-to-ban helped but really highlighted that I should pass this headache on to GitHub.

Costs money. $5 a month on digital ocean. At this time, WordPress.com does offer a free plan, limited to 1GB storage, no plugins, limited themes. Unable to install plugins or themes. Additionally, you are shown ads. YOu do get a free domain given like GitHub pages.

https://wordpress.com/pricing/

## The Case for Jekyll on GitHub Pages

Uses markdown. Why markdown? It is simple. Talk about markdown with obsidian too. Mention that I will do a post on that as well.

Support for larger files  
https://docs.github.com/en/repositories/working-with-files/managing-large-files/about-git-large-file-storage

Can install a CMS if you want. Look into feature parity with WordPress  
https://github.com/jekyll/jekyll-admin


Jekyll plugin for gists  
https://github.com/jekyll/jekyll-gist




# Migration Process

## Determining a Method for Migration

Given the small amount of posts on my Wordpress site, a manual migration was on the table. Factoring in the time needed to learn how jekyll import works and implementing it, I was better off copying my posts in plain text. (Sometimes the specialized tool for the job is not actually the right tool for the job). Another factor to consider is whether I figure I will run into this situation again. If the answer may be yes, then it still make sense to learn jekyll import just to save my future self time.

I will concede that I was nearly at the limit where the time to manually migrate broke even with learning the jekyll import tool.

https://github.com/jekyll/jekyll-import

## Manual Migration

Talk about how I copied the text, dumped it into a file, downloaded the pictures. Then just mark it up with markdown and link the images.

# Building a Development Container

```
podman build -t blog-dev .
podman create --name blog-dev -v .:/app:Z -p 4000:4000 blog-dev
podman start blog-dev
```

https://github.com/jekyll/jekyll-compose


podman exec -it blog-dev bundle exec jekyll post "My New Post"


# Pushing the image to Docker Hub

I've made the container image available on Docker Hub. Feel free to use the image rather than building it yourself.

[ldavidson12/jekyll-blog-dev on DockerHub](https://hub.docker.com/r/ldavidson12/jekyll-blog-dev)

For the curious, the process for pushing a local image to Docker Hub with podman is the same as with docker:

```
podman login docker.io
podman push localhost/jekyll-blog-dev:latest docker.io/ldavidson12/jekyll-blog-dev:latest
```

# Continued Operations

## Maintenance

Keeping up with supported jekyll, bundle, and gem versions. No more server updates. No more dealing with Wordpress updates, and updates to themes and plugins.

## Publishing Process

[]

Using drafts. `mkdir _drafts`. Drafts flag on `bundle exec jekyll serve`. Can also mention live reload. (Record a video of dual pane view of Marker). Show live reloading 

Use jekyll compose and Marker. Mention the settings I like for Marker.

* Theme
* Dual Pane
* Spell checking
* Word wrap
* GitHub css

## Shortcuts

alias for `bundle exec jekyll post "Post Name"`
move latest screenshot to jekyll site


```
find $DIR -type f -printf "%T@ %p\n" | 
awk '
BEGIN { recent = 0; file = "" }
{
if ($1 > recent)
   {
   recent = $1;
   file = $0;
   }
}
END { print file; }' |
sed 's/^[0-9]*\.[0-9]* //'
```

write about troubles of using ls and find to get the latest file. Note that you should use nul for find and ls when using them with head or tail. This is because a newline character is valid in filenames. If a filename contained a newline, head and tail would not behave as expected.

As I am just using the screen grabber shipped with Fedora, I will just to an ls on it and get the last line. This is because I expect it to be sorted correctly already and not have files with newline characters in the name.

I thought about overengineering a solution to always the get the file, whether there is newlines or spaces in the path, but I decided against this.