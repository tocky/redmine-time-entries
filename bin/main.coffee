#!/usr/bin/env coffee

https = require 'https'
readline = require 'readline'
colors = require 'colors'
argv = require('minimist') process.argv.slice(2), {
  string: [
    'project'
    'issue'
    'hours'
    'activity'
    'comments'
  ]
  boolean: [
    'ls'
    'help'
    'version'
  ]
  alias: {
    l: 'l' # Output as lines with detail
    p: 'project'
    i: 'issue'
    t: 'hours'
    a: 'activity'
    c: 'comments'
    h: 'help'
    v: 'version'
  }
}
AsciiTable = require 'ascii-table'

END_POINT = process.env.REDMINE_URL
TE_CXTPATH = '/time_entries'
REDMINE_API_KEY = process.env.REDMINE_API_KEY
ENCODING = 'utf-8'
DEFAULT_HTTP_OPTIONS = {
  host: END_POINT
  port: 443
  path: "#{TE_CXTPATH}.json"
  method: 'GET'
  headers: {
    'X-Redmine-API-Key': REDMINE_API_KEY
    'Content-Type': 'application/json'
  }
  json: true
}

class App
  constructor: (argv) ->
    @argv = argv

  run: ->
    showHelp.call @ if argv.help

    prepare.call @
    list.call @ if argv.list
    regist.call @ if (argv.project or argv.issue) and argv.hours

  #
  # Post new activity log to the server
  #
  regist = ->
    opts = DEFAULT_HTTP_OPTIONS
    opts.method = 'POST'

    req = https.request opts, (res) ->
      body = ''
      res.setEncoding ENCODING
      res.on 'data', (chunk) ->
        body += chunk
      res.on 'end', () ->
        json = JSON.parse body
        if json.errors
          console.error json.errors.join('\n').red
        else if json.time_entry
          console.log '作業時間を登録しました'.green

    # req.write('project_id=62&hours=4&comments=testtest')
    entry = {
      time_entry: {
        hours: argv.hours
      }
    }
    entry.time_entry.project_id = argv.project if argv.project
    entry.time_entry.issue_id = argv.issue if argv.issue
    entry.time_entry.activity_id = argv.activity if argv.activity
    entry.time_entry.comments = argv.comments if argv.comments
    req.end(JSON.stringify entry)

  #
  # Get the list of activity logs and show them up on screen
  #
  list = ->
    opts = DEFAULT_HTTP_OPTIONS
    opts.method = 'GET'

    req = https.request opts, (res) ->
      body = ''
      res.setEncoding ENCODING
      res.on 'data', (chunk) ->
        body += chunk
      res.on 'end', () ->
        json = JSON.parse body
        if argv.l
          outputDetailList(json)
        else
          outputList(json)

    req.end()
    req.on 'error', (err) ->
      console.error err.red

  #
  # Output time entries
  #
  outputList = (json) ->
    table = new AsciiTable 'Time Entries'
    table.setHeading(
      'ID', 'User', 'Date', 'Hours'
    )
    for entry in json.time_entries
      table.addRow(
        entry.id, entry.user.name, entry.spent_on, entry.hours
      )
    console.log table.toString()

  #
  # Output time entries as detail list
  #
  outputDetailList = (json) ->
    table = new AsciiTable 'Time Entries'
    table.setHeading(
      'ID', 'Project ID', 'Project Name', 'Issue ID', 'User', 'Date', 'Hours', 'Activity', 'Comment'
    )
    for entry in json.time_entries
      table.addRow(
        entry.id
        (if entry.project then entry.project.id else '')
        (if entry.project then entry.project.name else '')
        (if entry.issue then entry.issue.id else '')
        entry.user.name
        entry.spent_on
        entry.hours
        entry.activity.name
        entry.comments
      )
    console.log table.toString()

  #
  # Check prerequisites to execute this command
  #
  prepare = ->
    unless process.env.REDMINE_API_KEY
      console.error '環境変数 REDMINE_URL が設定されていません'.red
      process.exit()
    unless process.env.REDMINE_API_KEY
      console.error '環境変数 REDMINE_API_KEY が設定されていません'.red
      process.exit()

  #
  # Show help to use this command
  #
  showHelp = ->
    console.log '''
Redmine の作業時間をコマンドラインから入力するためのユーティリティです

登録済みの作業時間を見る
rte --list [-l]

作業時間を登録する
rte [-p <Project ID> | -i <Issue ID>] -h <Hours> [-a <Activity ID> -c <Comments>]
'''

(new App(argv)).run()
