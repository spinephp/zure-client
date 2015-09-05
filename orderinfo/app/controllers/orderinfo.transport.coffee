Spine   = require('spine')
Transport = require('models/transport')
Consignee = require('models/consignee')
$       = Spine.$

class Show extends Spine.Controller
  className: 'show'
  
  events:
    'click .edit': 'edit'
    
  elements: 
    'dl dt span': 'editEl'
  
  constructor: ->
    super
    @active @change
    Transport.bind('refresh change', @render)
   
  render: =>
    @item = Transport.getCurrent()
    @html require('views/showtransport')(@item)
    
  change: (params) =>
    @item = Transport.getCurrent()
    @render()
    if params?
      i = parseInt(params.match[0][15..])
      @setEditTip(i)
    
  setEditTip:(editor)->
    tem = $.trim($('div.edit.active dl dt span').text())
    tem.replace(/[^\[]+(?=\])/g, (word)-> tem = word)
    $(@editEl).html("如需修改，请先#{tem}")
    
  edit: ->
    @navigate('/orderinfo', 'edit2')

class Edit extends Spine.Controller
  className: 'edit'
  
  events:
    'submit form': 'submit'
    'click .save': 'submit'
    
  elements: 
    'form': 'form'
    
  constructor: ->
    super
    @active @change
  
  render: ->
    @html require('views/fmTransport')(transports:Transport.all(),curid:Transport.getCurrent().id)
    
  change: (params) =>
    @render()
    if sessionStorage.chargeid? > 1
      $("input[value=2]").attr("enabled","false")

    
  submit: (e) =>
    e.preventDefault()
    key = $(@form).serializeArray()[0]
    item = Transport.find(key.value)
    Transport.setCurrent(item)
    item.charge = sessionStorage.charge if item.chargeid=='2'
    @navigate('/orderinfo')

class Transports extends Spine.Stack
  className: 'transports stack'
    
  controllers:
    show: Show
    edit: Edit
    
module.exports =  Transports