Spine	= require('spine')
Good = require('models/good')
Grade = require('models/grade')
Goodeval = require('models/goodeval')
Gooduse = require('models/gooduse')
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
		'article p button':'btnsEl'
		'.paging':'barPageEl'
		'.paging a':'btnPageEl'

	events:
		'click article p button':'btnClick'
		'click article ul li p a':'reBtnClick'
		'click article >div input[type=submit]':'replyClick'
		'click article ul li div input[type=submit]':'reReplyClick'
		'click article >p a':'seeSingle'
		'click .paging a':'pagingClick'
		'click dl+div button':'evaluationClick'
		'mouseenter article ul li':'inReply'
		'mouseleave article ul li':'outReply'


	constructor: ->
		super
		@active @change
		@token = $.fn.cookie('PHPSESSID')
		@currPage=[0,0,0,0]
		
		@good = $.Deferred()
		@gooduse = $.Deferred()
		@grade = $.Deferred()
		@label = $.Deferred()
		@country = $.Deferred()
		@customgrade = $.Deferred()
		@default = $.Deferred()
		Good.bind "refresh",=>@good.resolve()
		Gooduse.bind "refresh",=>@gooduse.resolve()
		Goodlabel.bind "refresh",=>@label.resolve()
		Grade.bind "refresh",=>@grade.resolve()
		Customgrade.bind "refresh",=>@customgrade.resolve()
		Country.bind "refresh",=>@country.resolve()
		Default.bind "refresh",=>@default.resolve()
		Evalreply.bind "refresh",=>
			ids = []
			i = 0
			ids[i++] = rec.userid for rec in Goodeval.all() when rec.userid not in ids and not Person.exists rec.userid
			ids[i++] = rec.userid for rec in Evalreply.all() when rec.userid not in ids and not Person.exists rec.userid
			Person.append ids if ids.length>0

		Person.bind "refresh",=>
			ids = []
			i = 0
			ids[i++] = rec.country for rec in Person.all() when rec.userid not in ids
			condition = [{ field: "id", value: ids, operator: "in" }]
			params =
				data:{cond: condition,filter: Country.attributes,token:$.fn.cookie 'PHPSESSID'}
				processData: true
			Country.fetch params
		Goodeval.bind "refresh",=>
			ids = []
			i = 0
			ids[i++] = rec.id for rec in Goodeval.all() when rec.id not in ids and Evalreply.findByAttribute('evalid',rec.id) is null
			Evalreply.append ids if ids.length > 0

			ids = []
			i = 0
			ids[i++] = rec.userid for rec in Goodeval.all() when rec.userid not in ids and Customgrade.findByAttribute('userid',rec.userid) is null
			Customgrade.append ids if ids.length > 0
		Default.bind "change",=>
			if @item?
				@item.default = Default.first()
				@render()

		Goodlabel.fetch()

		Goodeval.bind "beforeUpdate", =>
			Goodeval.url = "woo/index.php"+Goodeval.url if Goodeval.url.indexOf("woo/index.php") is -1
			Goodeval.url += "&token="+@token unless Goodeval.url.match /token/

		Evalreply.bind "beforeCreate beforeUpdate", =>
			Evalreply.url = "woo/index.php"+Evalreply.url if Evalreply.url.indexOf("woo/index.php") is -1
			Evalreply.url += "&token="+@token unless Evalreply.url.match /token/
  
	render: ->
		$(@tabsEl).tabs('destroy') if $(@el).hasClass 'ui-tabs'
		@html require("views/goodeval")(@item)
		$(@tabsEl).tabs()
		$(@btnPageEl).button()
		@_setPageButtons()
	
	change: (params) =>
		try
			$.when(@good,@gooduse,@country,@default,@grade,@customgrade,@label).done =>
				if Good.exists params.id
					good = Good.find params.id
					default1 = Default.first()
					evals = Goodeval.findAllByAttribute 'proid',parseInt params.id
					stars = [[0..5],[4..5],[2..3],[0..1]]

					# 统计分类评价数量
					numbers = [evals.length,0,0,0]
					for eval in evals
						for i in [1..3]
							numbers[i]++ if eval.star in stars[i]

					# 统计指定评价的产品中，各种标签出现的数量
					labelkind = []
					labelkind[label.id] = 0 for label in Goodlabel.all()
					for eval in evals when eval.label isnt 0
						for label in Goodlabel.all()
							labelkind[label.id]++ unless (eval.label & (1<<(label.id-1))) is 0

					@item = 
						good:good
						evals:evals
						feel:Gooduse
						evalkinds:["All evaluation","Good","Medium","Poor"]
						evalstars:stars
						evalsum:numbers
						evalpages:
							records:5
							current:@currPage
						evalreplys:Evalreply
						persons:Person
						customgrades:Customgrade.all()
						labels:Goodlabel
						labelkinds:labelkind
						default:default1
					@render()
		catch err
			@log "file: good.option.one.coffee\nclass: Goodevals\nerror: #{err.message}"

	evaluationClick:(e)->
		e.stopPropagation()
		location.href = "? cmd=Member#/members/appraise"
	
	# 查看晒单帖
	seeSingle:(e)->
		e.stopPropagation()
		e.preventDefault()
		id = $(e.target).parent().attr 'data-id'
		location.href = "? cmd=GoodsEval&sid="+id

	btnClick:(e)->
		e.stopPropagation()
		try
			if User.count() is 0
				@log 'login'
			id = $(e.target).closest('article').attr('data-id')
			name = $(e.target).attr 'name'
			if name is 'useful' # 点击了 [有用] 按键
				oldUrl = Goodeval.url
				for eval in @item.evals
					if eval.id is id
						eval.bind 'save',(data)=>
							if data.error?
								switch data.error
									when 'Not logged!'
										@log data.error
						eval.useful++ 
						eval.save()
						@render()
			else if name is 'reply' # 点击了 [回复] 按键
				obj = $(e.target).closest('p')
				rname = Goodeval.find(id).getCustomName()
				unless obj.next().prop("tagName") is 'DIV'
					reply = Default.first().translate 'Reply'
					obj.after "<div><label>#{reply} #{rname}: </label><input type='text' name='reply' /><input type='submit' value='#{reply}' /></div>"
		catch err
			@log err
		finally
			Goodeval.url = oldUrl
			#@navigate('/orders',@params.order.id,'show')

	reBtnClick:(e)->
		e.stopPropagation()
		e.preventDefault()
		obj = $(e.target).closest('p')
		unless obj.next().prop("tagName") is 'DIV'
			id = $(e.target).closest('li').attr('data-id')
			rname = Evalreply.getPersonName(id)
			reply = Default.first().translate 'Reply'
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
						if data.error?
							switch data.error
								when 'Not logged!'
									@log data.error
					item.save()
					@render()
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

	# 评价分页控制
	pagingClick:(e)->
		e?.stopPropagation()
		kind = parseInt $(e.target).parent().attr 'page-kind',10
		lastPage = Math.ceil @item.evalsum[kind]/@item.evalpages.records
		btnValue = $(e.target).attr 'data-page'
		switch btnValue
			when 'first'
				@CurrPage[kind] = 0
			when 'prev'
				@CurrPage[kind]-- if @CurrPage[kind] > 0
			when 'last'
				@CurrPage[kind] = lastPage
			when 'next'
				@CurrPage[kind]++ if @CurrPage[kind] < lastPage
			else
				@CurrPage[kind] = parseInt(btnValue,10)-1
		@render()

	_setPageButtons:->
		for page,kind in $(@barPageEl)
			btns = $(page).find 'a'
			btns.removeClass 'currentpage'
			$(btns).button 'disabled':false
			$(btns[@currPage[kind]+2]).addClass 'currentpage'
			$(btns[@currPage[kind]+2]).button 'disabled':true
			lastPage = Math.ceil @item.evalsum[kind]/@item.evalpages.records
			if @currPage[kind] is 0
				$(btns[0..1]).button 'disabled':true
			if @currPage[kind]+1 is lastPage
				$(btns[-2..]).button 'disabled':true
module.exports = Goodevals