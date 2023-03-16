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

https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll/creating-a-github-pages-site-with-jekyll

https://pages.github.com/versions/
has ruby 2.7.4 listed as a dep, so i put that in the dockerfile
`FROM ruby:2.7.4`
You can use this to build your site to start. Then move to the development container
https://rubygems.org/gems/github-pages
This has the plugins that are a dependency of github-pages gem. Things like jekyll-gist, jekyll-feed and minima are in there so we can edit the default jekyll gemfile and remove them.

Versions used by github pages. Useful for setting the dependcy version in the container. Can go through setting versions for specific gems in the Gemfile.
https://pages.github.com/versions/
https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll#installing-jekyll
https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll/testing-your-github-pages-site-locally-with-jekyll

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

A new post will typically start as a draft. Draft posts are not published by GitHub Pages, so you can commit these to your published branch without exposing them early. These drafts live in the _drafts folder at the root of your site (the folder does not exist by default so you may need to `mkdir _drafts`). When working locally, these drafts are also not published unless the `--drafts` switch is provided to `jekyll serve`. The container image I built runs this by default. To additionally facilitate the writing process, the jekyll server switch for live-reloading the site is used.  
Note `CMD ["bundle", "exec", "jekyll", "serve", "--host=0.0.0.0", "--livereload", "--drafts"]` in the Dockerfile.  

(Can also mention how live reload works. Record a video of dual pane view of Marker. Show live reloading in action)

Use jekyll compose and Marker. Mention the settings I like for Marker.

* Theme
* Dual Pane
* Spell checking
* Word wrap
* GitHub css

Using a local remote for drafts:
You can create a branch for drafts. Howver, github pages won't publish drafts so even if you pushed to master (and github pages is building off of master) you won't have to worry about the article being up early.

If you don't want your drafts public but want to work on them from multiple workstations, consider setting up a remote that is local to your network.

I have a filesever that I use as a local git repository storage. I can utilize this to add a second remote to my repo, allowing pushing and pulling of drafts between my laptop and desktop.

Basics of working with remotes can be found [here](https://git-scm.com/book/en/v2/Git-Basics-Working-with-Remotes).

Adding the repo on the server:
sudo -u git mkdir /srv/git/blog.git
sudo -u git git init --bare /srv/git/blog.git

Adding the remote on my workstations:
git remote add drafts git@filesrv:/srv/git/blog.git



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