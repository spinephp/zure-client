Spine   = require('spine')

Sysnotice = require('models/sysnotice')
Default = require('models/default')
$       = Spine.$

class myMessage extends Spine.Controller
	className: 'mymessage'

	elements:
		".tabs":'tabsEl'
		'input[name=shownoread]':'noreadEl'
		'input[name=selectall]':'selectallEl'
		'input[name=selectmessage]':'selectmessageEl'
  
	events:
		'click input[name=shownoread]': 'noreadChange'
		'click input[name=selectall]': 'selectallChange'
		'click .message-action button:eq(0)':'markRead'
		'click .message-action button:eq(1)':'deleteMsg'
  
	constructor: ->
		super
		@active @change

		Sysnotice.bind "beforeUpdate beforeDestroy", ->
			Sysnotice.url = "woo/index.php"+Sysnotice.url if Sysnotice.url.indexOf("woo/index.php") is -1
			Sysnotice.url += "&token="+sessionStorage.token unless Sysnotice.url.match /token/
			
		@sysnotice = $.Deferred()

		Sysnotice.bind "ajaxError",(record,xhr,settings,error) ->
			console.log record+xhr.responseText

		Sysnotice.bind "refresh",=> @sysnotice.resolve()

		Default.bind "change",=>
			if @item?
				@item.defaults = Default.first()
				@render()
				
	render: ->
		@html require("views/message")(@item)
		$(@tabsEl).tabs()
	
	change: (params) =>
		try

			$.when(@sysnotice).done( =>
				@item = 
					messagees:Sysnotice.all()
					shownoread:off
					defaults:Default.first()
				@render()
			)
		catch err
			@log "file: member.main.message.coffee\nclass: myMessage\nerror: #{err.message}"

	noreadChange:(e) ->
		e.stopPropagation()
		if $(@noreadEl).prop('checked')
			@item = 
				messagees:(rec for rec in Sysnotice.all() when rec.readstate is 0)
				shownoread:on
		else
			@item = 
				messagees:Sysnotice.all()
				shownoread:off
		@render()

	selectallChange:(e) ->
		e.stopPropagation()
		$(@selectmessageEl).prop 'checked',$(@selectallEl).prop('checked')

	markRead:(e)->
		e.stopPropagation()
		$(@selectmessageEl).each (i,item)->
			if $(item).prop 'checked'
				rec = Sysnotice.find $(item).attr 'data-id'
				rec.readstate = 1
				oldUrl = Sysnotice.url
				rec.save()
				Sysnotice.url = oldUrl

	deleteMsg:(e)->
		e.stopPropagation()
		$(@selectmessageEl).each (i,item)->
			if $(item).prop 'checked'
				rec = Sysnotice.find $(item).attr 'data-id'
				oldUrl = Sysnotice.url
				rec.destroy()
				Sysnotice.url = oldUrl

module.exports = myMessage