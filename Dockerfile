FROM ubuntu
MAINTAINER phan duc thanh <pdthanh06@gmail.com>

# make sure to use bash
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

################################ make sure the package repository is up to date
RUN apt-get update

RUN apt-get install -y software-properties-common

RUN apt-get install -y build-essential

# setup tools
RUN apt-get install -y python python2.7-dev python-distribute python-pip 
RUN apt-get install -y zlib1g-dev libreadline-dev libyaml-dev \
                       libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev  \
                       libcurl4-openssl-dev libffi-dev

################################ core dev stuff

RUN apt-get install -y tar git curl nano wget dialog net-tools  
RUN apt-get install -y libssl-dev libpq-dev libjpeg-dev

# virtualenv stuff
RUN pip install virtualenv

################################ PostgresSQL & GeoLoc for django

RUN env ARCHFLAGS="-arch i386 -arch x86_64" pip install psycopg2
RUN apt-get install -y binutils libproj-dev gdal-bin

################################ gunicorn
RUN pip install gunicorn

### copy config / scripts stuff
ADD ./root/.bashrc /root/.bashrc
ADD ./root/.gitconfig /root/.gitconfig
ADD ./root/.scripts /root/.scripts

################################ install ruby (from )
ENV RUBY_MAJOR 2.2
ENV RUBY_VERSION 2.2.1
RUN apt-get update \
	&& apt-get install -y bison libgdbm-dev ruby \
	&& rm -rf /var/lib/apt/lists/* \
	&& mkdir -p /usr/src/ruby \
	&& curl -SL "http://cache.ruby-lang.org/pub/ruby/$RUBY_MAJOR/ruby-$RUBY_VERSION.tar.bz2" \
		| tar -xjC /usr/src/ruby --strip-components=1 \
	&& cd /usr/src/ruby \
	&& ./configure --disable-install-doc \
	&& make -j"$(nproc)" \
	&& make install \
	&& apt-get purge -y --auto-remove bison libgdbm-dev ruby \
	&& rm -r /usr/src/ruby

# skip installing gem documentation
RUN echo 'gem: --no-rdoc --no-ri' >> "$HOME/.gemrc"

# install things globally, for great justice
ENV GEM_HOME /usr/local/bundle
ENV PATH $GEM_HOME/bin:$PATH
RUN gem install bundler \
	&& bundle config --global path "$GEM_HOME" \
	&& bundle config --global bin "$GEM_HOME/bin"

# don't create ".bundle" in all our apps
ENV BUNDLE_APP_CONFIG $GEM_HOME