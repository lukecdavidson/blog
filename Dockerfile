FROM ruby:2.7.4
WORKDIR /app
ENV GEM_HOME="/usr/local/bundle"
ENV PATH $GEM_HOME/bin:$GEM_HOME/gems/bin:$PATH
COPY Gemfile ./
RUN bundle install
CMD ["bundle", "exec", "jekyll", "serve", "--host=0.0.0.0", "--livereload", "--drafts"]
