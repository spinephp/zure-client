Spine	= require('spine')
Goodeval = require('models/goodeval')
Grade = require('models/grade')
Thefeel = require('models/thefeel')
Custom = require('models/custom')
Customgrade = require('models/customgrade')
Person = require('models/person')
Country = require('models/country')
User = require('models/user')
Default = require('models/default')

$		= Spine.$

class Goodfeels extends Spine.Controller
	className: 'goodfeels'
  
	elements:
		'div.tabsbox-eval':'tabsEl'
		'.singleimages >div >img':'showimgEl'
		'.imagesets button':'btnCare'
		'.imgscroll ul li':'scrollImgEl'

	events:
		'click .imgscroll ul li img':'imgsClick'
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
		
		@grade = $.Deferred()
		@country = $.Deferred()
		@customgrade = $.Deferred()
		@default = $.Deferred()
		Grade.bind "refresh",=>@grade.resolve()
		Customgrade.bind "refresh",=>@customgrade.resolve()
		Country.bind "refresh",=>@country.resolve()
		Default.bind "refresh",=>@default.resolve()

		Person.bind "refresh",=>
			ids = (rec.country for rec in Person.all())
			condition = [{ field: "id", value: ids, operator: "in" }]
			params =
				data:{cond: condition,filter: Country.attributes,token:$.fn.cookie 'PHPSESSID'}
				processData: true
			Country.fetch params
		Thefeel.bind "refresh",=>
			thefeel = Thefeel.first()
			ids = []
			ids[0] = thefeel.userid if Customgrade.findByAttribute('userid',thefeel.userid) is null
			Customgrade.append ids if ids.length > 0
			
		Default.bind "change",=>
			if @item?
				@item.default = Default.first()
				@render()

		Grade.fetch()
  
	render: ->
		@html require("views/goodsingle")(@item)
		$(".imagesets .imgscroll").jCarouselLite
			btnNext: ".imagesets .next"
			btnPrev: ".imagesets .prev"
			visible:($('.imagesets').height()-2*$(@btnCare).height())/($(@scrollImgEl).height()+45)
			vertical:true
			auto:1000
			speed:800
	
	change: (params) =>
		try
			$.when(@country,@default,@grade,@customgrade).done =>
				if Thefeel.exists params.id
					thefeel = Thefeel.find params.id
					default1 = Default.first()
					customgrades = Customgrade.findByAttribute 'userid',thefeel.userid
					persons = Person.find thefeel.userid
					@item = 
						feel:thefeel
						person:persons
						grade:Grade.find customgrades.gradeid
						country:Country.find persons.country
						default:default1
					@log @item
					@render()
		catch err
			@log "file: good.option.one.coffee\nclass: Goodfeels\nerror: #{err.message}"

	evaluationClick:(e)->
		e.stopPropagation()
		location.href = "? cmd=Member#/members/appraise"

	imgsClick:(e)->
		e.stopPropagation()
		$(@showimgEl).attr 'src',$(e.target).attr 'src'

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
module.exports = Goodfeels