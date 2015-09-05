Spine   = require('spine')
Header = require('models/header')
$       = Spine.$

class Headers extends Spine.Controller
	className: 'headers'

	elements:
		".header p":"company"
		".headers ul:first-child dt":"menu",
	
	events:
		"click .header ol li[data-tab=addfavorite]":"addfavorite"
		"click .header ol li[data-tab=sethomepage]":"sethomepage"

	constructor: ->
		super
		@active @change

		Header.bind('refresh change', @render)

	render: =>
		try
			items = Header.all()
			@html require('views/showheader')(items:items)
			$(document).attr("title", items[5].data)
			sessionStorage.token = items[10].data
			Spine.trigger("headerrender",items)
		catch err
			console.log err.message

	change: (item) =>
		@render()

	addfavorite: ->
		items = Header.all()
		domain = items[4].data
		company = items[5].data
		if document.all
			window.external.addFavorite(domain, company)
		else if window.sidebar
			window.sidebar.addPanel(company, domain, "")
		else # 添加收藏的快捷键
			ctrl = if (navigator.userAgent.toLowerCase()).indexOf('mac') isnt -1 then 'Command/Cmd' else 'CTRL'
			alert('添加失败\n您可以尝试通过快捷键' + ctrl + ' + D 加入到收藏夹~')

	sethomepage: ->
		if document.all # 设置IE
			document.body.style.behavior = 'url(#default#homepage)'
			document.body.setHomePage(document.URL)
		else # 网上可以找到设置火狐主页的代码，但是点击取消的话会有Bug，因此建议手动设置
			alert("设置首页失败，请手动设置！")

module.exports = Headers