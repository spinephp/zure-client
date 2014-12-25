Spine = require('spine')
Person = require('models/person')
Customgrade = require('models/customgrade')
Grade = require('models/grade')
Country = require('models/country')
require('spine/lib/ajax')

# 创建企业模型
class Goodeval extends Spine.Model
	@configure 'Goodeval', 'id',"proid","userid","label","useideas","star","date","useful","status","feelid"

	@extend Spine.Model.Ajax

	@url: 'index.php? cmd=ProductEval'

	@fetch: (params) ->
		fields = @attributes
		params or= 
			data:{ filter: fields, token: $.fn.cookie 'PHPSESSID' } 
			processData: true
		super(params)

	@append:(ids)->
		fields = @attributes
		condition = [{field:"proid",value:ids,operator:"in"}]
		indices = { cond:condition,filter: fields, token: $.fn.cookie 'PHPSESSID' } 
		$.getJSON @url,indices,(data)=>
			@refresh data,clear:false #if data.length > 0
	kindNames:->
		rec = @
		while rec.parentid > 0
			rec = Goodeval.find rec.parentid
		[rec.names[0].replace('Products',''),rec.names[1].replace('制品','')]
	
	longName:->
		rec = @
		name = @name
		while rec.parentid > 0
			rec = Goodeval.find rec.parentid
			name = rec.name+'-'+name	
		name

	childCount:->
		n = 0
		n++ for rec in Goodeval.all() when parseInt(rec.parentid) is parseInt(@id)
		n

	getCustomName:->
		item = Person.find @userid
		item.nick or item.username

	getCountryNames:->
		item = Person.find @userid
		Country.find(item.country).names

	getCountryCode3:->
		item = Person.find @userid
		Country.find(item.country).code3

	getCustomGrade:->
		Customgrade.findByAttribute @userid

	getGrade:->
		item = @getCustomGrade()
		Grade.find item.gradeid

module.exports = Goodeval
