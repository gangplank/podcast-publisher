#!/bin/bash

OPTIND=1         # Reset in case getopts has been used previously in the shell.
CONFIG_FILE=config.sh
BLOG_POST_JSON_FILE=blog_post.json

while getopts ":c:j:" opt; do
    case "$opt" in
    c)
      CONFIG_FILE=$OPTARG
      ;;

    j)
      BLOG_POST_JSON_FILE=$OPTARG
      ;;

    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
    esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

source $CONFIG_FILE

SOURCE_FILE=$1

TMP_FILE1=/tmp/out_1.wav
TMP_FILE2=/tmp/out_2.wav
TMP_FILE3=/tmp/out_3.wav
TMP_FILE4=/tmp/out_3.output.wav
OUTPUT_MP3_FILE=`echo "$SOURCE_FILE" | sed -e s/\.wav//`.mp3

rm -f $TMP_FILE1 $TMP_FILE2 $TMP_FILE3 $TMP_FILE4

sox "$SOURCE_FILE" $TMP_FILE1 pad 7
sox -m $INTRO_WAV_FILE $TMP_FILE1 $TMP_FILE2
sox --combine concatenate $TMP_FILE2 $OUTRO_WAV_FILE $TMP_FILE3

/Applications/Levelator.app/Contents/MacOS/Levelator $TMP_FILE3

lame $TMP_FILE4 $OUTPUT_MP3_FILE

echo "uploading to s3"
PODCAST_URL=`s3cmd --config=$S3_CONFIG_FILE put --acl-public --guess-mime-type $OUTPUT_MP3_FILE s3://$S3_BUCKET | grep -o 'http.*'`
echo "S3 url: $PODCAST_URL"

echo "posting to Wordpress"
phantomjs post_blog.coffee "`cat $BLOG_POST_JSON_FILE`" "$PODCAST_URL" | tee phantom_result.txt
# -------

phantom_result=`cat phantom_result.txt`

echo "Wordpress URL: $phantom_result"
short_link=`expr "$phantom_result" : '.*short_link(\(.*\))'`

echo "shortlink is $short_link"
bitly_access_token=`curl -u "$BITLY_USERNAME:$BITLY_PASSWORD" -X POST "https://api-ssl.bitly.com/oauth/access_token"`
echo "auth token is is $bitly_access_token"
url="https://api-ssl.bitly.com/v3/shorten?access_token=$bitly_access_token&longUrl=$short_link"
echo "url is $url"
bitly_json=`curl $url`

echo "bit.ly json is is $bitly_json"

bitly_link=`expr "$bitly_json" : '.*"url": "\([^"]*\)"'`
bitly_link=${bitly_link//"\/"/"/"}
echo "bit.ly link is $bitly_link"

echo "ordering transcription"
curl --data "{\"api_key\":\"${CASTING_WORDS_API_KEY}\", \"url\":\"${PODCAST_URL}\", \"sku\":\"BULK14\"}" https://castingwords.com/store/API4/order_url -H "Content-Type: application/json" | tee transcript.json


echo "scheduling tweet"
phantomjs schedule_tweet.coffee "`cat $BLOG_POST_JSON_FILE`" "$bitly_link"

open /tmp/test.png
