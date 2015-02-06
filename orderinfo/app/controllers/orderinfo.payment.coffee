Spine   = require('spine')
Payment = require('models/payment')
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
    Payment.bind('refresh change', @render)
   
  render: =>
    if Payment.count()
      @item = Payment.getCurrent()
      @html require('views/showpayment')(@item)
    
  change: (params) =>
    @render()

	#其它项目修改时，给出提示，并阻止编辑本项目
    if params
      i = parseInt(params.match[0][15..])
      @setEditTip(i)
    
  setEditTip:(editor)->
    tem = $.trim($('div.edit.active dl dt span').text())
    tem.replace(/[^\[]+(?=\])/g, (word)-> tem = word)
    $(@editEl).html("如需修改，请先#{tem}")
   
  edit: ->
    @navigate('/orderinfo', 'edit1')

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
    @html require('views/fmPayment')(payments:Payment.all(),curid:Payment.getCurrent().id)
    
  change: (params) =>
    @render()
    
  submit: (e) ->
    e.preventDefault()
    key = $(@form).serializeArray()[0]
    Payment.setCurrent(Payment.find(key.value))
    @navigate('/orderinfo', 'edit2')
    
class Payments extends Spine.Stack
  className: 'payments stack'

  controllers:
    show: Show
    edit: Edit
    
module.exports =  Payments