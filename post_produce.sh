#!/bin/bash

intro=intro.wav
outro=outro.wav
tmp_file1=/tmp/out_1.wav
tmp_file2=/tmp/out_2.wav
tmp_file3=/tmp/out_3.wav
tmp_file4=/tmp/out_3.output.wav
output=`echo "$1" | sed -e s/\.wav//`.mp3


rm -f $tmp_file1 $tmp_file2 $tmp_file3 $tmp_file4

sox "$1" $tmp_file1 pad 7
sox -m $intro $tmp_file1 $tmp_file2
sox --combine concatenate $tmp_file2 $outro $tmp_file3

/Applications/Levelator.app/Contents/MacOS/Levelator $tmp_file3

lame $tmp_file4 $output

podcast_url=`s3cmd --config=.s3cfg put --acl-public --guess-mime-type $output s3://SCRUMCast | grep -o 'http.*'`

echo "going to phantom"
phantomjs post_blog.coffee "`cat blog_post.json`" "$podcast_url" > phantom_result.txt
# -------

phantom_result=`cat phantom_result.txt`

echo "phantom result: $phantom_result"
short_link=`expr "$phantom_result" : '.*short_link(\(.*\))'`

echo "shortlink is $short_link"
bitly_access_token=`curl -u "USERNAME:PASSWORD" -X POST "https://api-ssl.bitly.com/oauth/access_token"`
echo "auth token is is $bitly_access_token"
url="https://api-ssl.bitly.com/v3/shorten?access_token=$bitly_access_token&longUrl=$short_link"
echo "url is $url"
bitly_json=`curl $url`

echo "bit.ly json  is is $bitly_json"

bitly_link=`expr "$bitly_json" : '.*"url": "\([^"]*\)"'`
bitly_link=${bitly_link//"\/"/"/"}
echo "bit.ly link is $bitly_link"

echo "scheduling tweet"
phantomjs schedule_tweet.coffee "`cat blog_post.json`" "$bitly_link"

open /tmp/test.png
