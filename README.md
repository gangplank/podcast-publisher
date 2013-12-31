Podcast Publisher
==================

Adds intro, outro, levelates, converts to mp3, uploads to S3, marks as
public and prints out the public http url.

Installation
------------

Install to applications: http://cdn.conversationsnetwork.org/Levelator-2.1.1.dmg

    brew install lame sox s3cmd phantomjs

Setup S3

    s3cmd --configure

Configuration
-------------

Copy the example config and edit

    cp example.config my_podcast.config

Usage
-----

Edit blog_post.json with the information for this episode

    ./post_produce.sh -c $CONFIG_FILE -j $BLOG_POST_FILE $AUDO_FILE

Your input file must be a '.wav'.
The output file will be located in the same directory as the input file,
but with the .mp3 extension.
