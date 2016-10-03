# jekyll-centos7
FROM openshift/base-centos7
MAINTAINER Steven Mirabito <smirabito@csh.rit.edu>

# Inform about software versions being used inside the builder
ENV JEKYLL_VERSION=3.2.1

# Labels used in OpenShift to describe the builder image
LABEL io.k8s.description="Platform for building Jekyll-based static sites" \
      io.k8s.display-name="Jekyll 3.2.1" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="jekyll,3.2.1,static"

# Install required packages
RUN yum install -y epel-release && \
yum install -y ruby ruby-devel nginx && \
yum clean all -y

# Install Jekyll and Bundler with RubyGems
RUN gem install jekyll bundler

# Copy the S2I scripts to /usr/libexec/s2i, since openshift/base-centos7
# image sets io.openshift.s2i.scripts-url label that way
COPY ./.s2i/bin/ /usr/libexec/s2i

# Copy the nginx configuration
COPY ./etc/ /etc

# Link the nginx logs to stdout/stderr
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
ln -sf /dev/stderr /var/log/nginx/error.log

# Create the nginx pid directory and chown all nginx directories to the run user
RUN mkdir -p /var/run/nginx && \
chown -R 1001:1001 /var/run/nginx && \
chown -R 1001:1001 /var/log/nginx && \
chown -R 1001:1001 /var/lib/nginx && \
chown -R 1001:1001 /usr/share/nginx && \
chown -R 1001:1001 /etc/nginx

# Make the content of /opt/app-root and nginx folders owned by 1001 and drop privileges
RUN chown -R 1001:1001 /opt/app-root
USER 1001

# Set the default port for applications built using this image
EXPOSE 8080

# Set the default CMD for the image when executed directly
CMD ["/usr/libexec/s2i/usage"]
