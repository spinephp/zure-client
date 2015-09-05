Spine = require('spine')
require('spine/lib/ajax')

# 创建企业模型
class Goodclass extends Spine.Model
	@configure 'Goodclass', 'id',"parentid","name","name_en","introduction","introduction_en","picture"


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

	longName:->
		rec = @
		name = @name
		while rec.parentid > 0
			rec = Goodclass.find rec.parentid
			name = rec.name+'-'+name	
		name

	childCount:->
		n = 0
		n++ for rec in Goodclass.all() when parseInt(rec.parentid) is parseInt(@id)
		n

module.exports = Goodclass
