Spine = require('spine')
require('spine/lib/ajax')

# 创建企业模型
class Goodclass extends Spine.Model
	@configure 'Goodclass', 'id',"parentid","names","introductions"

	@extend Spine.Model.Ajax

	@url: 'woo/index.php? cmd=ProductClass'

	@fetch: (params) ->
		fields = @attributes
		params or= 
			data:{ filter: fields, token: $.fn.cookie 'PHPSESSID' } 
			processData: true
		super(params)

	parentName:->
		name = "根结点"
		pid = parseInt @parentid,10
		name = Goodclass.find(pid).name if pid > 0
		name

	kindNames:->
		rec = @
		while rec.parentid > 0
			rec = Goodclass.find rec.parentid
		[rec.names[0].replace('Products',''),rec.names[1].replace('制品','')]
	
	longNames:->
		kind = @kindNames()
		[kind[0]+@names[0],kind[1]+@names[1]]

	childCount:->
		n = 0
		n++ for rec in Goodclass.all() when parseInt(rec.parentid) is parseInt(@id)
		n

module.exports = Goodclass
