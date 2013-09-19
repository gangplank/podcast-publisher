Agile Weekly Maker
==================

Adds intro, outro, levelates, converts to mp3, uploads to S3, marks as
public and prints out the public http url.

Installation
------------

Install to applications: http://cdn.conversationsnetwork.org/Levelator-2.1.1.dmg

    brew install sox lame s3cmd phantomjs

Usage
-----

Edit blog_post.json with the information for this episode

    ./post_produce.sh $FILE

Your input file must be a '.wav'.
The output file will be located in the same directory as the input file,
but with the .mp3 extension.

You might want to `tail -f phantom_result.txt` to see output of the
wordpress post as it goes.

The last line of output from the program should contain the public http
url to the mp3 on S3

