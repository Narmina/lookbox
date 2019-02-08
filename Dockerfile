FROM ruby:2.3-alpine
MAINTAINER truenorma@gmail.com

RUN apt-get update && apt-get install -y \
  nodejs
RUN mkdir -p /lookbox
WORKDIR /lookbox

COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install

COPY . ./

EXPOSE 3000

ENTRYPOINT ["bundle", "exec"]

CMD ["rails", "server", "-b", "0.0.0.0"]
