# イメージ
FROM ruby:3.1

# 環境変数
ENV TZ Asia/Tokyo
ENV LANG C.UTF-8

# 開発用パッケージインストール
RUN apt-get update -qq && \
    apt-get install -y vim build-essential libpq-dev default-mysql-client postgresql-client && \
    apt-get clean && \
    rm -rf /var/cache/apt

# 作業ディレクトリ
WORKDIR /backend

# コピー
COPY ./Gemfile /backend/Gemfile
COPY ./Gemfile.lock /backend/Gemfile.lock
COPY ./docker-entrypoint.sh /docker-entrypoint.sh

# バンドルインストール
RUN bundle install --path vendor/bundle

# ポート
EXPOSE 3000

# コマンド
CMD ["/bin/bash", "/docker-entrypoint.sh"]
