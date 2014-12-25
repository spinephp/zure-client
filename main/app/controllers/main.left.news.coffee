Spine   = require('spine')
News = require('models/news')
Default = require('models/default')
$       = Spine.$

class Newss extends Spine.Controller
	className: 'newss'
	# 填充内部元素属性
	elements:
		"form":"formEl"
		"img":"vdImg"
	
	# 委托事件
	events:
		"click p a": "myClick"

	constructor: ->
		super
		@active @change
		
		@news = $.Deferred()
		@default = $.Deferred()
		News.bind "refresh",=>@news.resolve()
		Default.bind "refresh",=>@default.resolve() if Default.count() > 0
		Default.bind "change",=>
			if @item?
				@item.default = Default.first()
				@render()
		
	render: =>
		@html require('views/news')(@item)

	change: (item) =>
		try
			$.when(@news,@default).done =>
				if News.count() > 0
					news = if News.count()>10 then News.first(10) else News.all()
					@item = 
						news:news
						default:Default.first()
					@render()
		catch err
			console.log err.message
	
	myClick: (e)->
		obj = $(e.target).attr("data-action")
		switch(obj)
			when "order"
				url = "? cmd=Member#/members/order"
			when "yunrui"
				url = "? cmd=Member#/members"
		window.location.assign(url);

module.exports = Newss