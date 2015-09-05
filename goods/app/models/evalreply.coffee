Spine = require('spine')
require('spine/lib/ajax')
Person = require('models/person')

# ������ҵģ��
class EvalReply extends Spine.Model
	@configure 'EvalReply', 'id',"evalid","userid","parentid",'content','time'

	@extend Spine.Model.Ajax

	@url: '? cmd=EvalReply'

	@append:(ids)->
		fields = @attributes
		condition = [{field:"evalid",value:ids,operator:"in"}]
		indices = { cond:condition,filter: fields, token: $.fn.cookie 'PHPSESSID' } 
		$.getJSON @url,indices,(data)=>
			@refresh data,clear:false #if data.length > 0

	@getPersonName:(evalid)->
		item = Person.find @find(evalid).userid
		item?.nick or item.username

module.exports = EvalReply
