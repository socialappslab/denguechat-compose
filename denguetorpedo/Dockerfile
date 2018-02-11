FROM ruby:2.2.4
MAINTAINER Cristhian Parra <cdparra@gmail.com>
ENV PROJECT_HOME /home/dengue
RUN groupadd dengue
RUN useradd dengue -m -g dengue -s /bin/bash
RUN passwd -d -u dengue
RUN apt-get update
RUN apt-get install -y sudo nodejs
RUN echo "dengue ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/dengue
RUN chmod 0440 /etc/sudoers.d/dengue
RUN mkdir -p ${PROJECT_HOME}
RUN chown dengue:dengue ${PROJECT_HOME}
RUN chown -R dengue:dengue ~/.gem
RUN chown -R dengue:dengue /usr/local/bundle
ADD deploy.sh deploy.sh
RUN chmod 777 deploy.sh
USER dengue
RUN mkdir ${PROJECT_HOME}/denguetorpedo
RUN cd ${PROJECT_HOME}/denguetorpedo
RUN gem install rails -v 4.2.5
RUN gem install bundler

