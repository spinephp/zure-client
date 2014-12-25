Spine   = require('spine')
Qiye = require('models/qiye')
Default = require('models/default')
$       = Spine.$

class Yunruis extends Spine.Controller
	className: 'yunruis'
	# 填充内部元素属性
	elements:
		"form":"formEl"
		"img":"vdImg"
	
	# 委托事件
	events:
		"click li a": "qiyeClick"

	constructor: ->
		super
		@active @change
		
		@qiye = $.Deferred()
		@default = $.Deferred()
		Default.bind "refresh",=>@default.resolve() if Default.count() > 0
		Qiye.bind "refresh",=>@qiye.resolve()
		Default.bind "change",=>
			if @item?
				@item.default = Default.first()
				@render()
		
	render: =>
		@html require('views/contact')(@item)

	change: (item) =>
		try
			$.when(@qiye,@default).done =>
				if Qiye.count() > 0
					@item = 
						qiye:Qiye.first()
						default:Default.first()
					@render()
		catch err
			console.log err.message
	
	qiyeClick: (e)->
		id = $(e.target).attr("data-qiyeid")
		url = "index.php? cmd=Qiye&qiyeid=#{id}"
		window.location.assign(url);

module.exports = Yunruis