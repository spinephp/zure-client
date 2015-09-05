Spine	= require('spine')
Good = require('models/good')
Grade = require('models/grade')
Theeval = require('models/theeval')
Goodeval = require('models/goodeval')
Evalreply = require('models/evalreply')
Goodlabel = require('models/goodlabel')
Custom = require('models/custom')
Customgrade = require('models/customgrade')
Person = require('models/person')
Country = require('models/country')
User = require('models/user')
Default = require('models/default')

$		= Spine.$

class Goodevals extends Spine.Controller
	className: 'goodevals'
  
	elements:
		'div.tabsbox-eval':'tabsEl'

	events:
		'click article p button':'btnClick'
		'click article ul li p a':'reBtnClick'
		'click article >div input[type=submit]':'replyClick'
		'click article ul li div input[type=submit]':'reReplyClick'
		'click article ul li >a':'repliorClick'
		'click article ul li span':'replyAllClick'
		'click .evalperson li:first-child img':'customClick'
		'click .evalperson li a':'customClick'
		'click dl+div button':'evaluationClick'
		'mouseenter article ul li':'inReply'
		'mouseleave article ul li':'outReply'


	constructor: ->
		super
		@active @change
		@token = $.fn.cookie('PHPSESSID')
		
		@good = $.Deferred()
		@grade = $.Deferred()
		@label = $.Deferred()
		@country = $.Deferred()
		@customgrade = $.Deferred()
		@default = $.Deferred()
		Good.bind "refresh",=>@good.resolve()
		Goodlabel.bind "refresh",=>@label.resolve()
		Grade.bind "refresh",=>@grade.resolve()
		Customgrade.bind "refresh",=>@customgrade.resolve()
		Country.bind "refresh",=>@country.resolve()
		Default.bind "refresh",=>@default.resolve()
		Evalreply.bind "refresh",=>
			ids = []
			i = 0
			theeval = Theeval.first()
			ids[i++] = theeval.userid if not Person.exists theeval.userid
			ids[i++] = rec.userid for rec in Evalreply.all() when rec.userid not in ids and not Person.exists rec.userid
			Person.append ids  if ids.length > 0

		Person.bind "refresh",=>
			ids = (rec.country for rec in Person.all())
			condition = [{ field: "id", value: ids, operator: "in" }]
			params =
				data:{cond: condition,filter: Country.attributes,token:$.fn.cookie 'PHPSESID'}
				processData: true
			Country.fetch params
		Theeval.bind "refresh",=>
			theeval = Theeval.first()
			ids = []
			ids[0] = theeval.id if Evalreply.findByAttribute('evalid',theeval.id) is null
			Evalreply.append ids if ids.length > 0

			ids = []
			ids[0] = theeval.userid if Customgrade.findByAttribute('userid',theeval.userid) is null
			Customgrade.append ids if ids.length > 0

		Default.bind "change",=>
			if @item?
				@item.default = Default.first()
				@render()

		Evalreply.bind "change",=>
			if @item?
				@item.evalreplys = Evalreply
				@render()

		Goodlabel.fetch()
		Grade.fetch()

		Goodeval.bind "beforeUpdate", =>
			Goodeval.url = "woo/index.php"+Goodeval.url if Goodeval.url.indexOf("woo/index.php") is -1
			Goodeval.url += "&token="+@token unless Goodeval.url.match /token/

		Evalreply.bind "beforeCreate beforeUpdate", =>
			#Evalreply.url = "woo/index.php"+Evalreply.url if Evalreply.url.indexOf("woo/index.php") is -1
			Evalreply.url += "&token="+@token unless Evalreply.url.match /token/
  
	render: ->
		@html require("views/goodreview")(@item)
	
	change: (params) =>
		try
			$.when(@good,@country,@default,@grade,@customgrade,@label).done =>
				if Theeval.exists params.id
					theeval = Theeval.find params.id
					default1 = Default.first()
					customgrades = Customgrade.first()
					persons = Person.find theeval.userid
					@item = 
						eval:theeval
						evalreplys:Evalreply
						person:persons
						grade:Grade.find customgrades.gradeid
						labels:Goodlabel
						country:Country.find persons.country
						default:default1
					@render()
		catch err
			@log "file: good.option.one.coffee\nclass: Goodevals\nerror: #{err.message}"

	evaluationClick:(e)->
		e.stopPropagation()
		location.href = "? cmd=Member#/members/appraise"

	btnClick:(e)->
		e.stopPropagation()
		try
			throw 'Not logged!' if User.count() is 0
			id = $(e.target).closest('article').attr('data-id')
			name = $(e.target).attr 'name'
			if name is 'useful' # 点击了 [有用] 按键
				throw 'Operator is invalid!' if User.first().name is @item.person.username
				oldUrl = Goodeval.url
				if @item.eval.id is id
					@item.eval.bind 'save',(data)=>
						throw data.error if data.error?
					@item.eval.useful++ 
					@item.eval.save()
					@render()
			else if name is 'reply' # 点击了 [回复] 按键
				obj = $(e.target).closest('p')
				rname = @item.person.username
				unless obj.next().prop("tagName") is 'DIV'
					reply = Default.first().translate 'Reply'
					obj.after "<div><label>#{reply} #{rname}: </label><input type='text' name='reply' /><input type='submit' value='#{reply}' /></div>"
		catch err
			alert err
		finally
			Goodeval.url = oldUrl
			#@navigate('/orders',@params.order.id,'show')

	reBtnClick:(e)->
		e.stopPropagation()
		e.preventDefault()
		obj = $(e.target).closest('p')
		unless obj.next().prop("tagName") is 'DIV'
			id = $(e.target).closest('li').attr('data-id')
			rname = @item.default.toPinyin Evalreply.getPersonName(id)
			reply = @item.default.translate 'Reply'
			obj.after "<div><label>#{reply} #{rname}: </label><input type='text' name='reply' /><input type='submit' value='#{reply}' /></div>"

	_now:()->
		datetime = new Date()
		year = datetime.getFullYear()
		month = if datetime.getMonth() + 1 < 10 then "0" + (datetime.getMonth() + 1) else datetime.getMonth() + 1
		date = if datetime.getDate() < 10 then "0" + datetime.getDate() else datetime.getDate()
		hour = if datetime.getHours()< 10 then "0" + datetime.getHours() else datetime.getHours()
		minute = if datetime.getMinutes()< 10 then "0" + datetime.getMinutes() else datetime.getMinutes()
		second = if datetime.getSeconds()< 10 then "0" + datetime.getSeconds() else datetime.getSeconds()
		year + "-" + month + "-" + date+" "+hour+":"+minute+":"+second

	_saveReply:(target,pId)->
		try
			id = target.closest('article').attr('data-id')
			txt = $.trim target.prev().val()
			unless txt is ''
				try
					oldUrl = Evalreply.url
					item = new Evalreply {evalid:id,userid:'?userid',parentid:pId,content:txt,time:@_now()}
					item.bind 'save',(data)=>
						throw data.error if data.error?
					item.save()
				catch err
					throw err
				finally
					Evalreply.url = oldUrl
		catch err
			@log err

	replyClick:(e)->
		e.stopPropagation()
		@_saveReply $(e.target),0

	reReplyClick:(e)->
		e.stopPropagation()
		@_saveReply $(e.target),$(e.target).closest('li').attr('data-id')

	inReply:(e)->
		e.stopPropagation()
		obj = $(e.target).find('p')
		if obj.find('a').length is 0		
			reply = Default.first().translate 'Reply'
			obj.append "<a href='#'>#{reply}</a>"

	outReply:(e)->
		e.stopPropagation()
		obj = $(e.target).find('p')
		obja = obj.find('a')
		if obja.length > 0		
			unless obj.next().prop("tagName") is 'DIV'
				obja.remove()

	customClick:(e)->
		e?.stopPropagation()
		e?.preventDefault()
		parent = $(e.target).closest('ul')
		if $(parent).hasClass 'evalperson'
			customid = $(parent).attr 'data-id'
			@log customid

	repliorClick:(e)->
		e?.stopPropagation()
		e?.preventDefault()
		customid = $(e.target).attr 'data-id'
		@log customid

	replyAllClick:(e)->
		e?.stopPropagation()
		e?.preventDefault()
module.exports = Goodevals