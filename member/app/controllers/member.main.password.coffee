Spine   = require('spine')

Custom = require('models/custom')
Person = require('models/person')
Default = require('models/default')
$       = Spine.$

class myPassword extends Spine.Controller
	className: 'mypassword'

	elements:
		".tabs":'tabsEl'
		'input[name=shownoread]':'noreadEl'
		'input[name=selectall]':'selectallEl'
		'input[name=verifycode]':'verifycodeEl'
  
	events:
		'click input[name=selectall]': 'selectallChange'
		'click .message-action button:eq(0)':'markRead'
		'click form input[type=submit]':'submit'
		'click form ul li a':'checkmodeChange'
  
	constructor: ->
		super
		@active @change
		@checkmode = 0
			
		@person = $.Deferred()
		@default = $.Deferred()

		Custom.bind "ajaxError",(record,xhr,settings,error) ->
			console.log record+xhr.responseText

		Person.bind "refresh",=> @person.resolve()
		Custom.bind "refresh",=>
			if Custom.count() > 0
				Person.fetch()
			else
				@navigate "/members/login"
		Default.bind "refresh",=> @default.resolve()
		Default.bind "change",=>
			if @item?
				@item.defaults = Default.first()
				@render()

		Custom.fetch()

		Custom.bind "beforeUpdate beforeDestroy", ->
			Custom.url = "woo/index.php"+Custom.url if Custom.url.indexOf("woo/index.php") is -1
			Custom.url += "&token="+sessionStorage.token unless Custom.url.match /token/

	render: ->
		@html require("views/password")(@item)
	
	change: (params) =>
		try
			$.when(@person,@default).done( =>
				if Person.count() > 0
					@item = 
						members:Custom.first()
						mode:@checkmode
						defaults:Default.first()
					@render()
				else
					@navigate "/members/login"
			)
		catch err
			@log "file: member.main.message.coffee\nclass: myPassword\nerror: #{err.message}"

	checkmodeChange:(e)->
		@checkmode = parseInt $(e.target).attr 'data-mode'
		@item = 
			members:Custom.first()
			mode:@checkmode
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

	submit:(e)->
		e.stopPropagation()
		e.preventDefault()
		switch @checkmode
			when 1
				url = '? cmd=SendVerifyEmail'
				data = 
					type:'UpdatePassword'
					token:sessionStorage.token
					code:$(@verifycodeEl).val()
					language:sessionStorage.language
				$.get url,data

module.exports = myPassword