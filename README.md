# Redmine Time Entries

Redmine の作業記録をするためのコマンドラインツールです。社内向けツールとして作成したので、細かい部分のツメが甘いです。お使いの際にはそのあたりを承知のうえでご利用ください。

## 前提条件

- node
- npm
- coffee-script

## インストール

少なくとも node と npm が導入されている前提で説明します。このツールは CoffeeScript で書かれているので `coffee` コマンドが利用できる必要があります。もし、未導入であれば次のコマンドを実行してインストールします。

```
$ npm install -g coffee-script
```

続いて、コマンド本体をインストールします。

```
$ npm install -g https://github.com/tocky/redmine-time-entries.git
```

## 設定

Redmine の API にアクセスするため、アクセスキーを取得します。アクセスキーは個人設定画面の右ペインにて取得することができます。詳しくはオフィシャルサイトなどを参考にしてください。

次に Redmine の URL とアクセスキーを環境変数に設定します。

```
# redmine.example.com のように指定します
$ export REDMINE_URL='<Redmine URL>'
$ export REDMINE_API_KEY='<Redmine Access Key>'
```

必要に応じて `.bashrc` や `.zshrc` などに追記しましょう。
