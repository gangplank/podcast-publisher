system = require('system')
env  = system.env
args = JSON.parse system.args[1]
args.bitly_link = system.args[2]

# moment = require './moment.js' //in phantom 1.7 you would have to do something like that
phantom.injectJs("./moment.js")

page = require('webpage').create()
page.viewportSize = width: 1024, height: 768

login = ->
  console.log 'going to future tweets'
  page.open "http://futuretweets.com/login/"


fill_login_form = ->
  console.log 'fill_login_form'

  page.evaluate (env) ->
    console.log 'filling in form'
    document.getElementById("username_or_email").value = env.TWITTER_USERNAME
    document.getElementById("password").value = env.TWITTER_PASSWORD
    document.getElementById("oauth_form").submit()
  , env

wait_for_oauth = ->
  console.log "waiting for oauth"

make_tweet_1 = ->
  time = "#{args.publish_date.year}-#{args.publish_date.month}-#{args.publish_date.day} #{args.publish_date.hour - 0 + 7 + 2}:#{args.publish_date.minute}"
  make_tweet time

make_tweet_2 = ->
  time = "#{args.publish_date.year}-#{args.publish_date.month}-#{args.publish_date.day}"
  console.log "raw time #{time}"
  monday = moment(time).add("days", 4).format("YYYY-MM-DD")
  new_time = monday + " 20:00"
  console.log new_time
  make_tweet new_time #monday at 1pm + 7

make_tweet = (time) ->
  tweet = args.title
  tweet += " (#{args.guest_twitter})" if args.guest_twitter
  tweet += " #{args.bitly_link}"
  console.log "entering tweets"
  page.evaluate (tweet, time) ->
    document.getElementById("id_content").value = tweet
    document.getElementById("id_publish").value = time
    document.getElementById("twitter-schedule-form").submit()
  , tweet, time


render = ->
  console.log 'rendering'
  page.render '/tmp/test.png'
  next_step()

exit = ->
  console.log 'exiting'
  phantom.exit()

steps = [
  login
  fill_login_form
  wait_for_oauth
  make_tweet_1
  make_tweet_2
  render
  exit
]

next_step = -> steps.shift()()
page.onLoadFinished = -> next_step()

next_step()
