class TeamItem extends Spine.Controller
  elements:
    'input': 'input'
  
  events:
    'blur input': 'save'
    'click .remove': 'remove'
    
  constructor: ->
    super
    throw('record required') unless @record
  
  render: ->
    @replace @view('team_selector/item')(@record)
    @el
    
  save: ->
    @record.use = @input.val()
    @record.save()
    @record = @record.reload()
    
  remove: ->
    @record.selected = false
    @record.save()
    @record = @record.reload()

class App.TeamSelector extends Spine.Controller
  className: 'teamSelector'
    
  elements:
    '.items': 'itemsEl'
    
  constructor: ->
    super
    @render()
    App.Friend.bind 'refresh change', @render
  
  render:  =>
    records = App.Friend.selected()
    @html @view('team_selector/index')()
    
    for record in records
      item = new TeamItem(record: record)
      @itemsEl.append(item.render())
    
    @el.toggleClass('empty', !records.length)