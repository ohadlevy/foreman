
# Base container that is used for both building and running the app
FROM fedora:30 as base
ARG RUBY_MODULE="ruby:2.6"
ARG NODEJS_MODULE="nodejs:11"
ARG HOME=/home/foreman

RUN \
  echo "tsflags=nodocs" >> /etc/dnf/dnf.conf && \
  dnf -y upgrade && \
  dnf -y module install ${RUBY_MODULE} ${NODEJS_MODULE} && \
  dnf -y install mysql-libs mariadb-connector-c postgresql-libs ruby{,gems} rubygem-{rake,bundler} nc hostname \
  # needed for VNC/SPICE websockets
  python python2-numpy && \
  dnf clean all && \
  rm -rf /var/cache/dnf/

WORKDIR $HOME
RUN groupadd -r foreman -f -g 1001 && \
    useradd -u 1001 -r -g foreman -d $HOME -s /sbin/nologin \
    -c "Foreman Application User" foreman && \
    chown -R 1001:1001 $HOME

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

# Temp container that download gems/npms and compile assets etc
FROM base as builder
ARG HOME=/home/foreman
ENV RAILS_ENV=production
ENV FOREMAN_APIPIE_LANGS=en
ENV BUNDLER_SKIPPED_GROUPS="test development openid libvirt journald"

RUN \
  dnf -y install redhat-rpm-config git \
    gcc-c++ make bzip2 \
    libxml2-devel libcurl-devel ruby-devel \
    mysql-devel postgresql-devel libsq3-devel && \
  dnf clean all && \
  rm -rf /var/cache/dnf/

ENV DATABASE_URL=sqlite3:tmp/bootstrap-db.sql

USER 1001
WORKDIR $HOME
RUN mkdir bundler.d && mkdir config
COPY --chown=1001:1001 Gemfile ${HOME}
COPY --chown=1001:1001 bundler.d/* bundler.d/
RUN echo gem \"rdoc\" > bundler.d/container.rb
COPY --chown=1001:1001 config/boot* config/
RUN entrypoint.sh bundle install --without "${BUNDLER_SKIPPED_GROUPS}" \
  --path vendor --jobs 5 --retry 3 && \
  rm -rf vendor/ruby/*/cache/*.gem && \
  find vendor/ruby/*/gems -name "*.c" -delete && \
  find vendor/ruby/*/gems -name "*.o" -delete
COPY --chown=1001:1001 package.json ${HOME}
RUN entrypoint.sh npm install --ignore-scripts --no-optional
COPY --chown=1001:1001 . ${HOME}/
# run bundle/npm install for plugins
RUN entrypoint.sh bundle update
RUN entrypoint.sh npm install --no-optional && entrypoint.sh npm rebuild node-sass --force
RUN  entrypoint.sh make -C locale all-mo && \
 entrypoint.sh bundle exec rake assets:clean assets:precompile db:migrate &&  \
 entrypoint.sh bundle exec rake db:seed apipie:cache:index && rm tmp/bootstrap-db.sql
RUN entrypoint.sh ./node_modules/webpack/bin/webpack.js --config config/webpack.config.js && entrypoint.sh npm run analyze && rm -rf public/webpack/stats.json

# Start the main process.
CMD "bundle exec bin/rails server"

FROM base

ARG HOME=/home/foreman
ARG RAILS_ENV=production
ENV RAILS_SERVE_STATIC_FILES=true
ENV RAILS_LOG_TO_STDOUT true

USER 1001
WORKDIR ${HOME}
COPY --chown=1001:1001 . ${HOME}/
RUN echo gem \"rdoc\" > bundler.d/container.rb
COPY --from=builder /usr/bin/entrypoint.sh /usr/bin/entrypoint.sh
COPY --from=builder --chown=1001:1001 ${HOME}/.bundle/config ${HOME}/.bundle/config
COPY --from=builder --chown=1001:1001 ${HOME}/Gemfile.lock ${HOME}/Gemfile.lock
COPY --from=builder --chown=1001:1001 ${HOME}/vendor/ruby ${HOME}/vendor/ruby
COPY --from=builder --chown=1001:1001 ${HOME}/public ${HOME}/public

RUN date -u > BUILD_TIME

# Start the main process.
CMD "bundle exec bin/rails server"

EXPOSE 3000/tcp
EXPOSE 5910-5930/tcp
