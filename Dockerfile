FROM ruby:2.6-alpine as foreman-base-ruby

RUN apk add -U tzdata gettext bash postgresql mariadb npm netcat-openbsd \
     && cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime \
     && apk del tzdata \
     && rm -rf /var/cache/apk/*

ENV FOREMAN_FQDN docker-swarm-01.kstm.lab.net
ENV FOREMAN_DOMAIN kstm.lab.net
ENV BUNDLE_APP_CONFIG='.bundle'

ARG HOME=/home/foreman
WORKDIR $HOME
RUN addgroup --system foreman
RUN adduser --home $HOME --system --shell /bin/false --ingroup foreman --gecos Foreman foreman

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]



FROM foreman-base-ruby as foreman-builder
RUN apk add --update bash git gcc cmake libc-dev build-base \
                         curl-dev libxml2-dev gettext \
                         mariadb-dev postgresql-dev sqlite-dev npm \
     && rm -rf /var/cache/apk/*


ENV RAILS_ENV production
ENV FOREMAN_APIPIE_LANGS en
ENV BUNDLER_SKIPPED_GROUPS "test development openid libvirt journald facter"
ENV DATABASE_URL=sqlite3:tmp/bootstrap-db.sql
ENV BUNDLE_APP_CONFIG='.bundle'
ARG HOME=/home/foreman
USER foreman
WORKDIR $HOME
COPY --chown=foreman . ${HOME}/

# Adding missing gems, for tzdata see https://bugzilla.redhat.com/show_bug.cgi?id=1611117
RUN echo gem '"rdoc"' > bundler.d/container.rb && echo gem '"tzinfo-data"' >> bundler.d/container.rb
RUN bundle install --without "${BUNDLER_SKIPPED_GROUPS}" \
    --binstubs --clean --path vendor --jobs=5 --retry=3 && \
  rm -rf vendor/ruby/*/cache/*.gem && \
  find vendor/ruby/*/gems -name "*.c" -delete && \
  find vendor/ruby/*/gems -name "*.o" -delete
RUN npm install --no-optional
RUN \
  make -C locale all-mo && \
  bundle exec rake assets:clean assets:precompile db:migrate &&  \
  bundle exec rake db:seed apipie:cache:index && rm -f tmp/bootstrap-db.sql
RUN ./node_modules/webpack/bin/webpack.js --config config/webpack.config.js \
  && npm run analyze && rm -rf public/webpack/stats.json
RUN rm -rf vendor/ruby/*/cache vendor/ruby/*/gems/*/node_modules

FROM foreman-base-ruby

ARG HOME=/home/foreman
ARG RAILS_ENV=production
ENV RAILS_SERVE_STATIC_FILES=true
ENV RAILS_LOG_TO_STDOUT=true
ENV BUNDLE_APP_CONFIG='.bundle'

USER foreman
WORKDIR ${HOME}
COPY --chown=foreman . ${HOME}/
COPY --from=foreman-builder /usr/bin/entrypoint.sh /usr/bin/entrypoint.sh
COPY --from=foreman-builder --chown=foreman:foreman ${HOME}/.bundle/config ${HOME}/.bundle/config
COPY --from=foreman-builder --chown=foreman:foreman ${HOME}/Gemfile.lock ${HOME}/Gemfile.lock
COPY --from=foreman-builder --chown=foreman:foreman ${HOME}/vendor/ruby ${HOME}/vendor/ruby
COPY --from=foreman-builder --chown=foreman:foreman ${HOME}/public ${HOME}/public
RUN echo gem '"rdoc"' > bundler.d/container.rb && echo gem '"tzinfo-data"' >> bundler.d/container.rb

RUN date -u > BUILD_TIME

# Start the main process.
CMD "bundle exec bin/rails server"

EXPOSE 3000/tcp
EXPOSE 5910-5930/tcp
