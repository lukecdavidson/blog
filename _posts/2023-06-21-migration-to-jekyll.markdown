---
layout: post
title:  Migration to Jekyll
date:   2023-06-20 20:00:00 -0800
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

Security aside, another consideration is backups. The free tier on WordPress.com includes a "time machine" feature to provide file revision history. However, backups are not included until you reach the business tier at \$25 per month. Other hosted options include better pricing for the backup feature, such as The Deluxe tier on GoDaddy at \$11.99 per month. On the Digital Ocean side, you can enable backups at the droplet level for 20% to the cost of the Droplet. Each successful backup is charged at 5% of the droplet's total cost for the month ([Droplet Backup Pricing](https://docs.digitalocean.com/products/images/backups/details/pricing/)). Another option is to manually manage the backup of the files and database, which you can do for free. This is a manual process but you again can use a third-party plugin to automate backups while also assuming more risk in terms of security. Documentation on using phpMyAdmin to manually backup WordPress can be found [here](https://wordpress.org/documentation/article/wordpress-backups/).

### The Case for Jekyll on GitHub Pages

A big draw to GitHub pages for me was the use of markdown. It is simple and familiar as I am a frequent user of Obsidian. Markdown allows me to type without having to think about stopping to instert "blocks" of different HTML elements like is done with the Wordpress editor.

However, if you prefer a CMS, you can install the jekyll-admin [plugin](https://github.com/jekyll/jekyll-admin). This provides similar CMS features to Wordpress. In the case that you include a lot of code in your blog posts, Jekyll also has a [plugin](https://github.com/jekyll/jekyll-gist) to easily insert gists right into posts. Meanwhile, for the free hosted WordPress, you are given 1GB storage and no option to install plugins or themes. Not to forget you are served ads.

## Method for Migration

Given the small amount of posts on my WordPress site, a manual migration was on the table. Factoring in the time needed to learn how [jekyll import](https://github.com/jekyll/jekyll-import) works and the unlikelyhood of needing to use it again, I was better off copying my posts in plain text and reformatting in markdown, which is what I ended up doing.

## Development Container

### Container Requirements

GitHub Pages seems fairly compatible across different versions of Ruby and gems. However, you can use the [github-pages](https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll/creating-a-github-pages-site-with-jekyll) gem to ensure your local environment is close as possible to what will be built and visible on your GitHub. As it often is, the way I chose to get a consistent environment is with containers.

If you look through the dependencies (listed [here](https://rubygems.org/gems/github-pages)), you will notice that some of what is in your Gemfile can be removed as it is already called as a dependency. Looking at version 288, I see the following gems can be removed from your Gemfile:

* jekyll
* minima
* jekyll-feed

I have added a few additional plugins for my site, one of which is jekyll-gist. This is also a dependency of github-pages so you can again remove it. Be sure to look through the dependencies and clean up your Gemfile as needed.

As for matching the version of Ruby, you can check out the versions of various bits in use by GitHub Pages [here](https://pages.github.com/versions/). At the time of this writing it is Ruby 2.7.4. We can then use `FROM ruby:2.7.4` in our Containerfile as the Ruby container version 2.7.4 runs that same version of Ruby.

You can subscribe to the github-pages gem is on GitHub tp get notified of new releases. This is useful to update your local github-pages gem or rebuilt the development container so it pulls that in. To subscribe, navigate to the [repository](https://github.com/github/pages-gem) and select Watch -> Custom -> Check Releases -> Apply.

![GitHub-Pages Release Subscription](../assets/images/github-pages-release-subscription.png)

### Container Build

The repository for this blog contains a Containerfile I use to built the development container with podman, which is also uploaded to [Dockerhub](https://hub.docker.com/r/ldavidson12/jekyll-blog-dev). This container is what I use to locally serve the site so I can double check new pages or posts as needed.

To build and start the container, run the following from the root of the repository:

```
podman build -t blog-dev .
podman create --name blog-dev -v `pwd`:/app:Z -p 4000:4000 blog-dev
podman start blog-dev
```

The site will now be available at localhost:4000.

## Publishing Process

A new post will typically start as a draft. Draft posts are not published by GitHub Pages, so you can commit these to your published branch without exposing them early. These drafts live in the _drafts folder at the root of your site (the folder does not exist by default so you may need to `mkdir _drafts`). When working locally, these drafts are also not published unless the `--drafts` switch is provided to `jekyll serve`. The container image I built runs this and live-reloading

In addition, I make use of the jekyll-compose plugin. Compose introduces shortcuts for managing posts. You can create a new draft with the `draft` subcommand, in the context of running in a container: `podman exec blog-dev jekyll draft "$Title"`.

For drafting up the posts, I use the app Marker. Marker provides a dual-pane view (raw markdown and rendered) and includes a few themes and spell-checking. To the publish a draft run `podman exec blog-dev jekyll publish $DraftPath`. If you instead want to create a new post directly, use the `post` subcommand for jekyll. With a post ready, you can then git push to GitHub where your page will automatically build.
