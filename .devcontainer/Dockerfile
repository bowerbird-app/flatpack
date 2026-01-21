# Use Ruby 3.2.3 as base image
FROM ruby:3.2.3

# Install dependencies
RUN apt-get update -qq && \
    apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    npm \
    postgresql-client \
    redis-tools \
    git \
    curl \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Install Git LFS
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && \
    apt-get install -y git-lfs

# Set working directory
WORKDIR /workspace

# Set environment variables
ENV BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_BIN=/usr/local/bundle/bin \
    GEM_HOME=/usr/local/bundle \
    PATH=/usr/local/bundle/bin:$PATH

# Install bundler
RUN gem install bundler

# Keep container running
CMD ["bash", "-l"]
