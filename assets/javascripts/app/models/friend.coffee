class App.Friend extends Spine.Model
  @configure 'Friend', 'name', 'selected', 'use'
  @limit: 5
  
  selected: false
  
  @selected: -> 
    @select (record) -> record.selected
    
  filter: (query) ->
    return true unless query
    query   = query.toLowerCase()
    compare = @name.toLowerCase()
    compare.indexOf(query) isnt -1
    
  toggle: ->
    @selected = !@selected
    @save()
    
  validate: ->    
    count = @constructor.selected().length + 1
    if @selected and count > @constructor.limit
      return 'Too many selected'