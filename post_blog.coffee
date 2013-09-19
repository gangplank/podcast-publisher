system = require('system')
env    = system.env
args = JSON.parse system.args[1]
args.podcast_url = system.args[2]

page = require('webpage').create()
page.viewportSize = width: 1024, height: 768

login = ->
  console.log "opening: #{env.BLOG_ADMIN_URL}"
  page.open env.BLOG_ADMIN_URL

fill_login_form = ->
  console.log 'fill_login_form'

  page.evaluate (env) ->
    jQuery('#user_login').val env.BLOG_USERNAME
    jQuery('#user_pass').val env.BLOG_PASSWORD
    jQuery('#wp-submit').click()
  , env

goto_new_post = ->
  console.log 'goto_new_post'
  page.open "#{env.BLOG_ADMIN_URL}/post-new.php"


fill_post_info = ->
  console.log 'fill_post_info'
  page.evaluate ({args,env}=options) ->
    jQuery('#content-html').click()
    jQuery('#title').val args.title
    jQuery('#content').val args.blurb
    jQuery('#_integrum_episode_number').val args.episode_number
    jQuery('#powerpress_url_podcast').val args.podcast_url

    jQuery('.curtime .edit-timestamp').click()
    jQuery('#mm').val args.publish_date.month
    jQuery('#jj').val args.publish_date.day
    jQuery('#aa').val args.publish_date.year
    jQuery('#hh').val args.publish_date.hour
    jQuery('#mn').val args.publish_date.minute
    jQuery('.curtime .save-timestamp').click()

    jQuery("#in-category-#{env.BLOG_CATEGORY_NUMBER}").prop("checked", true) # Agile Weekly Podcast category

    for tag in args.tags
      jQuery("#new-tag-post_tag").val tag
      jQuery(".button.tagadd").click()

  , args: args, env: env

  next_step()

publish = ->
  console.log 'publish'
  page.evaluate ->
    jQuery('#publish').click()

render = ->
  console.log 'rendering'
  page.render '/tmp/test.png'
  next_step()

get_shortlink = ->
  short_link = page.evaluate ->
    return jQuery('#shortlink').val()

  console.log "short_link(#{short_link})"
  next_step()


exit = ->
  console.log 'exiting'
  phantom.exit()

steps = [
  login
  fill_login_form
  goto_new_post
  fill_post_info
  publish
  render
  get_shortlink
  exit
]

next_step = -> steps.shift()()
page.onLoadFinished = -> next_step()

next_step()
