# Facebook Zombies

An example application showing how to use the Facebook friend API and create a friend selector using [Spine](http://spinejs.com).

See the blog post for more information.

## Interesting code

The most interesting code is under [assets/javascripts/app/controllers/friend_selector.coffee](https://github.com/maccman/zombies/blob/master/assets/javascripts/app/controllers/friend_selector.coffee). This is a Spine Controller that creates a Facebook friend selector, allowing users to toggle multiple selected friends.

## Usage

1. Setup env variables
1. Run: `bundle install`
1. Run: `be rackup`

## Env variables

You'll need to set the env variables `FACEBOOK_APP_ID` and `FACEBOOK_SECRET` as detailed in the [Heroku Facebook guide](https://devcenter.heroku.com/articles/facebook).