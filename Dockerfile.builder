FROM quay.io/ohadlevy/foreman-base:6825
ENV RAILS_ENV=production
ENV FOREMAN_APIPIE_LANGS=en
ENV BUNDLER_SKIPPED_GROUPS="test development openid libvirt journald"

RUN \
  microdnf install redhat-rpm-config git \
    gcc-c++ make bzip2 gettext tar \
    libxml2-devel libcurl-devel ruby-devel \
    mysql-devel postgresql-devel libsq3-devel && \
  microdnf clean all

ARG HOME=/home/foreman
USER 1001
WORKDIR $HOME
COPY --chown=1001:1001 . ${HOME}/
# Adding missing gems, for tzdata see https://bugzilla.redhat.com/show_bug.cgi?id=1611117
RUN echo gem '"rdoc"' > bundler.d/container.rb && echo gem '"tzinfo-data"' >> bundler.d/container.rb
RUN bundle install --without "${BUNDLER_SKIPPED_GROUPS}" \
    --binstubs --clean --path vendor --jobs=5 --retry=3 && \
  rm -rf vendor/ruby/*/cache/*.gem && \
  find vendor/ruby/*/gems -name "*.c" -delete && \
  find vendor/ruby/*/gems -name "*.o" -delete
RUN npm install --no-optional
