---
layout: post
title:  Migration to Jekyll
date:   2022-06-30 12:00:00 -0800
categories: blogging jekyll
---
A blog is a must-have for anyone wishing to continue their technical learning. With a blog, you have the opportunity to organize, formalize, and share your technical notes. The process of reviewing your findings and converting them to a coherent post can highlight gaps in your knowledge and lead to further research and a better understanding of the subject.
  
I have had a blog for some time now, but it mostly laid untouched as a Digital Ocean WordPress PaaS-like instance. In part, the cumbersome process for getting ideas and notes into Wordpress and was to blame. Looking to solve this, I began searching for an alternative that met a few criteria: low cost, painless to use, and low maintenance. 

Given this, I chose to move from WordPress to Jekyll on GitHub Pages. Laid out is a comparison of the platforms, the migration process, and tips for posting and maintaining.

## Platform Overviews

WordPress is a free and open source platform for building websites. You can self-host WordPress for free, use the hosted free-tier from WordPress.com, or pay for other hosted options. These other options include higher tiers from [WordPress.com](https://wordpress.com/pricing/), [BlueHost](https://www.bluehost.com/web-hosting/signup), [GoDaddy](https://www.godaddy.com/hosting/wordpress-hosting), [Kinsta](https://www.godaddy.com/hosting/wordpress-hosting), among various others, with various pricing models. Prior to this migration, I was using Digital Ocean's [WordPress droplet](https://marketplace.digitalocean.com/apps/wordpress) which ran me about $5 per month.

On the other hand, Jekyll is a static site generator that powers GitHub Pages (it has no dependency on GitHub Pages for hosting and can be used independently as well). With GitHub Pages, you can configure a GitHub repository that is used as the source for your site. A primary use for this is to have a `/doc` directory in your project's repository which houses the documentation for your software and provides a nice website to browse. The other use case is to have the repository dedicated to the site and use GitHub Pages to host an independent static site, as I describe here.

## Why Migrate

### My Needs for a Blog Host

In my use case, I needed something meeting the following criteria:

* Quick and simple to use: Getting an idea into a draft should not take too much effort. The more effort needed to start writing, the less that is written overall.
* Easy to maintain: Maintaining the host's Operating System and on top of WordPress, it's plugins and themes gets old fairly quick.
* Low cost: No more than \$5 - \$10 per month.

### Cons of WordPress

WordPress as a full-blown Content Management System (CMS) is overkill for a simple site that only contains blog articles. Additionally, this introduces more maintenance and security concerns. With my WordPress droplet instance, the underlying Ubuntu OS needed maintained as well as WordPress, WordPress plugins and themes. Sucuri's 2021 edition of their yearly [Hacked Website Report](https://sucuri.net/reports/2021-hacked-website-report/) shows the continued trend that outdated an outdated core CMS (like WordPress) and vulnerable plugins share the blame as points of compromise. This can be avoided with automatic OS updates through Ubuntu's [unattended-upgrades package](https://help.ubuntu.com/community/AutomaticSecurityUpdates) and ensuring [automatic updates for WordPress](https://wordpress.org/documentation/article/configuring-automatic-background-updates/), plugins, and themes were configured. Do note that as of WordPress 3.7, the core of WordPress is generally configured to automatically update by default. However, other defaults on WordPress are still lacking in secuirty, especially in the realm of authentication. Many instances have no option for Multi-Factor Authentication or require a third-party plugin to do so. Login attempts have no limit on failures. Again, a third party [fail2ban plugin ](https://wordpress.org/plugins/wp-fail2ban/) fills the gap. In short, it is very much so possible to get a secure WordPress instance, but it definitely takes some up front work and baby-sitting compared to other options.

Security aside, another consideration is backups. The free tier on WordPress.com includes a "time machine" feature to provide file revision history. However, backups are not included until you reach the business tier at \$25 per month. Other hosted options include better pricing for the backup feature, such as The Deluxe tier on GoDaddy at \$11.99 per month. On the Digital Ocean side, you can enable backups at the droplet level for 20% to the cost of the Droplet. Each successful back is charged at 5% of the droplet's total cost for the month ([Droplet Backup Pricing](https://docs.digitalocean.com/products/images/backups/details/pricing/)). Another option is to manually manage the backup of the files and database, which you can do for free. This is a manual process but you again can use a third-party plugin to automate backups while also assuming more risk in terms of security. Documentation on using phpMyAdmin to manually backup WordPress can be found [here](https://wordpress.org/documentation/article/wordpress-backups/).

### The Case for Jekyll on GitHub Pages


Uses markdown. Why markdown? It is simple. Talk about markdown with obsidian too. Mention that I will do a post on that as well.

Support for larger files  
https://docs.github.com/en/repositories/working-with-files/managing-large-files/about-git-large-file-storage

Can install a CMS if you want. Look into feature parity with WordPress  
https://github.com/jekyll/jekyll-admin


Jekyll plugin for gists  
https://github.com/jekyll/jekyll-gist

Costs money for WordPress. $5 a month on digital ocean. At this time, WordPress.com does offer a free plan, limited to 1GB storage, no plugins, limited themes. Unable to install plugins or themes. Additionally, you are shown ads.



## Migration Process

### Determining a Method for Migration

Given the small amount of posts on my WordPress site, a manual migration was on the table. Factoring in the time needed to learn how jekyll import works and implementing it, I was better off copying my posts in plain text. (Sometimes the specialized tool for the job is not actually the right tool for the job). Another factor to consider is whether I figure I will run into this situation again. If the answer may be yes, then it still make sense to learn jekyll import just to save my future self time.

I will concede that I was nearly at the limit where the time to manually migrate broke even with learning the jekyll import tool.

https://github.com/jekyll/jekyll-import

### Manual Migration

Talk about how I copied the text, dumped it into a file, downloaded the pictures. Then just mark it up with markdown and link the images.

## Building a Development Container

https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll/creating-a-github-pages-site-with-jekyll

### Container Requirements
GitHub Pages seems fairly cross-compatible between different versions of Ruby and gems. However, it is best to not bet on that and instead work on your site using the same versions in use by GitHub Pages.

The best method to do this is with containers. This provides a neat development environment without worrying that your operating system's repositories don't have the correct version of ruby you are looking for, or crudding up your install.

[Here](https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll/creating-a-github-pages-site-with-jekyll) GitHub documentation passes by using the github-pages gem. The gem has dependencies that match up with what GitHub Pages uses.

If you look through the dependencies (listed [here](https://rubygems.org/gems/github-pages)), you will notice that some of what is in your Gemfile can be removed as it is already called as a dependency. Looking at version 288, I see the following gems can be removed from your Gemfile:

* jekyll
* minima
* jekyll-feed

I have added a few additional plugins for my site, one of which is jekyll-gist. This is also a dependency of github-pages so you can again remove it. Be sure to look through the dependencies and clean up your Gemfile as needed.

As for matching the version of Ruby, you can check out the versions of various bits in use by GitHub Pages [here](https://pages.github.com/versions/). At the time of this writing it is Ruby 2.7.4. We can then use `FROM ruby:2.7.4` in our Dockerfile as the Ruby container version 2.7.4 runs that same version of Ruby.

You can subscribe to the github-pages gem is on GitHub tp get notified of new releases. This is useful to update your local github-pages gem or rebuilt the development container so it pulls that in. To subscribe, navigate to the [repository](https://github.com/github/pages-gem) and select Watch -> Custom -> Check Releases -> Apply.

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
![GitHub-Pages Release Subscription](../assets/images/github-pages-release-subscription.png)

### Container Build

The repository for this blog contains a Dockerfile I use to built the development container with podman. This container is what I use to locally serve the site so I can double check new pages or posts as needed.

To built the container, run the following from the root of the repository:

```
podman build -t blog-dev .
podman create --name blog-dev -v .:/app:Z -p 4000:4000 blog-dev
podman create --name blog-dev -v .:/app:Z -p 4000:4000 docker.io/ldavidson12/jekyll-blog-dev
podman start blog-dev
```

https://github.com/jekyll/jekyll-compose


podman exec -it blog-dev bundle exec jekyll post "My New Post"

The site will now be available at localhost:4000.

### Pushing the image to Docker Hub

I've made the container image available on Docker Hub. Feel free to use the image rather than building it yourself.

[ldavidson12/jekyll-blog-dev on DockerHub](https://hub.docker.com/r/ldavidson12/jekyll-blog-dev)

For the curious, the process for pushing a local image to Docker Hub with podman is the same as with docker:

```
podman login docker.io
podman push localhost/jekyll-blog-dev:latest docker.io/ldavidson12/jekyll-blog-dev:latest
```

## Continued Operations

### Maintenance

Keeping up with supported jekyll, bundle, and gem versions. No more server updates. No more dealing with WordPress updates, and updates to themes and plugins.

### Publishing Process

A new post will typically start as a draft. Draft posts are not published by GitHub Pages, so you can commit these to your published branch without exposing them early. These drafts live in the _drafts folder at the root of your site (the folder does not exist by default so you may need to `mkdir _drafts`). When working locally, these drafts are also not published unless the `--drafts` switch is provided to `jekyll serve`. The container image I built runs this by default. To additionally facilitate the writing process, the jekyll server switch for live-reloading the site is used.  
Note `CMD ["bundle", "exec", "jekyll", "serve", "--host=0.0.0.0", "--livereload", "--drafts"]` in the Dockerfile.  
[]

(Can also mention how live reload works. Record a video of dual pane view of Marker. Show live reloading in action)
Using drafts. `mkdir _drafts`. Drafts flag on `bundle exec jekyll serve`. Can also mention live reload. (Record a video of dual pane view of Marker). Show live reloading 

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
https://github.com/jekyll/jekyll-compose


podman exec -it blog-dev bundle exec jekyll post "My New Post"

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