#= require json2
#= require jquery
#= require spine

#= require_tree ./lib
#= require_self
#= require_tree ./models
#= require_tree ./controllers
#= require_tree ./views

$ = jQuery

$.postJSON = (url, data) ->
  $.ajax
    type: 'POST'
    url: url
    data: JSON.stringify(data)
    contentType: 'application/json'
    processData: false

class App extends Spine.Controller
  events:
    'click .create button': 'create'
  
  constructor: ->
    super
    
    @friendSelector = new App.FriendSelector
    @teamSelector   = new App.TeamSelector
    
    @append @friendSelector
    @append @teamSelector
    
    create = $('<article />').addClass('create')
    create.append($('<button />').text('Create your team!'))
    @append create
    
  create: (e) ->
    selected = App.Friend.selected()
    limit    = App.Friend.limit
    if selected.length < limit
      return alert("You need to select #{limit} friends")
    
    $(e.target).attr('disabled', 'disabled')
    
    $.postJSON('/team', selected).success ->
      alert('Created!')

window.App = App