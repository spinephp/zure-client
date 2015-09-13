Spine = require('spine')
require('spine/lib/ajax')

# 创建企业模型
class Customaccount extends Spine.Model
	@configure 'Customaccount', 'id',"in","out","lock","note"
	@extend Spine.Model.Ajax
	@url: 'woo/index.php? cmd=CustomAccount'

	@fetch: (params) ->
		condition = [{field:"userid",value:'?userid',operator:"eq"}]
		params or= 
			data:{ cond:condition,filter: @attributes, token: sessionStorage.token } 
			processData: true
		super(params)

	@remainder:->
		sum = 0
		sum += rec.in-rec.out for rec in @all()
		sum

	@lock:->
		sum = 0
		sum += rec.lock for rec in @all()
		sum

	remainder:->
		Customaccount.remainder()

	lock:->
		Customaccount.lock()

	dateDiff:(date1) ->
		type1 = typeof date1
		if (type1 == 'string')
			date1 = @stringToTime(date1)
		else if (date1.getTime)
			date1 = date1.getTime()
		date2 = @stringToTime(@time)
		return (date1 - date2) / (1000 * 60 * 60*24*24); #结果是小时
		
	#字符串转成Time(dateDiff)所需方法
	stringToTime:(string) ->
		f = string.split(' ', 2)
		d = (if f[0]? then f[0] else '').split('-', 3)
		t = (if f[1]? then f[1] else '').split(':', 3)
		return (new Date(
			parseInt(d[0], 10) || null,
			(parseInt(d[1], 10) || 1) - 1,
			parseInt(d[2], 10) || null,
			parseInt(t[0], 10) || null,
			parseInt(t[1], 10) || null,
			parseInt(t[2], 10) || null
		)).getTime()

module.exports = Customaccount
