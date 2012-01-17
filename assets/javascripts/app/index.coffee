#= require json2
#= require jquery
#= require spine

#= require_tree ./lib
#= require_self
#= require_tree ./models
#= require_tree ./controllers
#= require_tree ./views

$ = jQuery

class App extends Spine.Controller  
  constructor: ->
    super
    
    @friendSelector = new App.FriendSelector
    @teamSelector   = new App.TeamSelector
    
    @append @friendSelector
    @append @teamSelector
    
    create = $('<article />').addClass('create')
    create.append($('<a />').text('Create your team!').addClass('cta'))
    @append create

window.App = App