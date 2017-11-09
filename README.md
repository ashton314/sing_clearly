Sing Clearly
============

A rudimentary song lyric checker.

Installation
------------

Requirements:

 - plenv
 - perl v5.26.1
 - carton

Perl can be installed by running `plenv install 5.26.1 && plenv install-cpanm`.

Once Perl is in place, you can run `cpanm Carton && carton install`.

After that, configure where you want the blacklist to live in `sing_clearly.conf`. By default, this is in the `/tmp/` directory.

Background
----------

This web app tries to find a song on [MetroLyrics](http://www.metrolyrics.com) and checks if it has any phrases found in a blacklist.

### Blacklist ###

There is a file (which must be configured in `sing_clearly.conf`) which holds a blacklist of phrases. The lyrics of each song are checked against this blacklist. The match happens on word boundaries, so something like "hello" doesn't register as "hell".

There is an API to add phrases to a blacklist.

The blacklist gets initilized on server start-up by reading a list from [FrontGate](https://www.frontgatemedia.com/a-list-of-723-bad-words-to-blacklist-and-how-to-use-facebooks-moderation-tool/) and inserting it into the blacklist.

Author
------

Ashton Wiersdorf - November 2017
