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
		else # ����ղصĿ�ݼ�
			ctrl = if (navigator.userAgent.toLowerCase()).indexOf('mac') isnt -1 then 'Command/Cmd' else 'CTRL'
			alert('���ʧ��\n�����Գ���ͨ����ݼ�' + ctrl + ' + D ���뵽�ղؼ�~')

	sethomepage: ->
		if document.all # ����IE
			document.body.style.behavior = 'url(#default#homepage)'
			document.body.setHomePage(document.URL)
		else # ���Ͽ����ҵ����û����ҳ�Ĵ��룬���ǵ��ȡ���Ļ�����Bug����˽����ֶ�����
			alert("������ҳʧ�ܣ����ֶ����ã�")

module.exports = Headers