# README

## 説明

SAML 認証サンプルコード<br>
`ruby-saml`を利用した SAML 認証を対応<br>
sp 用の証明書は自前で用意したオレオレ証明書で対応、<br>
idp 用の証明書は idp よりダウンロード<br>

## 設定

### 初期化

```
docker-compose build
docker-compose run --rm backend bundle install
```

### 環境変数ファイル

```
cp -p .env.samples .env.dev
```

### 起動

```
docker-compose up
```

## 滅びの呪文

https://qiita.com/suin/items/19d65e191b96a0079417

```
docker-compose down --rmi all --volumes --remove-orphans
```

## example

https://github.com/onelogin/ruby-saml-example/<br>
https://github.com/mmts1007/saml-memo<br>
https://github.com/onelogin/ruby-saml<br>

## 参考

https://mmts1007.hatenablog.jp/entry/2017/02/05/161926<br>
https://zenn.dev/hukurouo/articles/rails-saml-sso<br>
https://qiita.com/gotchane/items/a3b6ed52afc57c92971e<br>

## SP 証明書作成

```
cd config/saml/sp
openssl genrsa -out private.pem 2048
openssl req -new -key private.pem -out cacert.csr
openssl x509 -days 3650 -in cacert.csr -req -signkey private.pem -out sp.cert
```
