Spine = require('spine')
Person = require('models/person')
Customgrade = require('models/customgrade')
Grade = require('models/grade')
require('spine/lib/ajax')

# 创建企业模型
class Goodconsult extends Spine.Model
	@configure 'Goodconsult', 'id',"proid","userid","type","content","time","reply","replytime"

	@extend Spine.Model.Ajax

	@url: '? cmd=ProductConsult'

	@fetch: (params) ->
		fields = @attributes
		params or= 
			data:{ filter: fields, token: $.fn.cookie 'PHPSESSID' } 
			processData: true
		super(params)

	# 取未读的已回复咨询数
	@unreadReply:->
		n = 0
		n++ for item in @all() when item.type is 1
		n

	getCustomName:->
		item = Person.find @userid
		item?.nick or item?.username

	getCustomGrade:->
		Customgrade.findByAttribute @userid

	getGrade:->
		item = @getCustomGrade()
		Grade.find(item.gradeid).names

module.exports = Goodconsult
