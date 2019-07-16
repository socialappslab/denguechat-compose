FROM ruby:2.3.0
MAINTAINER Cristhian Parra <cdparra@gmail.com>
ENV PROJECT_HOME /home/dengue
RUN groupadd dengue
RUN useradd dengue -m -g dengue -s /bin/bash
RUN passwd -d -u dengue
RUN printf "deb http://archive.debian.org/debian/ jessie main\ndeb-src http://archive.debian.org/debian/ jessie main\ndeb http://security.debian.org jessie/updates main\ndeb-src http://security.debian.org jessie/updates main" > /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y sudo nodejs
RUN apt-get install -y imagemagick
RUN echo "dengue ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/dengue
RUN chmod 0440 /etc/sudoers.d/dengue
RUN mkdir -p ${PROJECT_HOME}
RUN chown dengue:dengue ${PROJECT_HOME}
RUN chown -R dengue:dengue ~/.gem
RUN chown -R dengue:dengue /usr/local/bundle
ADD deploy.sh deploy.sh
ADD deploy.localdev.sh deploy.localdev.sh
RUN chmod 777 deploy.sh
RUN chmod 777 deploy.localdev.sh
USER dengue
RUN mkdir ${PROJECT_HOME}/denguetorpedo
RUN cd ${PROJECT_HOME}/denguetorpedo
RUN gem install rails -v 4.2.5
RUN gem install bundler
RUN sudo ln -s /usr/bin/convert /usr/local/bin/convert
RUN gem install puma -v '2.11.2' --source 'http://rubygems.org/' -- --with-cppflags=-I/usr/local/opt/openssl/include
