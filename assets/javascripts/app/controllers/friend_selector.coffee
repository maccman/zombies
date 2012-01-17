$ = jQuery

class FriendItem extends Spine.Controller
  events:
    'click': 'toggle'
    
  constructor: ->
    super
    throw('record required') unless @record
    @record.bind 'change', @render
  
  render: =>
    @replace @view('friend_selector/item')(@record)
    @el.toggleClass('selected', @record.selected)
    @el
    
  toggle: ->
    @record.toggle()
    
  filter: (query) ->
    @el.toggle @record.filter(query)

class App.FriendSelector extends Spine.Controller
  tagName: 'article'
  className: 'friendSelector'
  
  elements:
    '.items': 'itemsEl'
    'header input': 'inputEl'
    'header .status': 'statusEl'
    
  events:
    'keyup header input': 'filter'
    'click header input': 'filter'
    
  constructor: ->
    super
    
    App.Friend.bind 'refresh', @addAll
    App.Friend.bind 'change', @toggled
    
    @render()
    @load()
    
  load: ->
    @el.addClass('loading')
    $.getJSON '/friends.json', (records) =>
      @el.removeClass('loading')
      App.Friend.refresh(records)
    
  render: ->
    @items = []
    @html @view('friend_selector/index')(limit: App.Friend.limit)
    
  addOne: (record) =>
    item = new FriendItem(record: record)
    @items.push(item)
    @itemsEl.append(item.render())
  
  addAll: (records) =>
    @addOne(record) for record in records
  
  filter: ->
    @itemsEl.hide()
    query = @inputEl.val()
    for item in @items
      item.filter(query)
    @itemsEl.show()
  
  toggled: =>
    count = App.Friend.selected().length
    @statusEl.text("#{count} out of #{App.Friend.limit} friends selected")