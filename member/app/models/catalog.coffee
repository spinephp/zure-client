
class Catalog
	@tools: [
		{"name":["Order center","订单中心"],option:[{name:["My orders","我的订单"],action:"order"},{name:["My concern","我的关注"],action:"carefly"},{name:["My complain","我的投诉"],action:"complain"}]}
		{"name":["Account center","帐户中心"],option:[{name:["Account Info","帐户信息"],action:"account"},{name:["Account balance","帐户余额"],action:"balance"},{name:["Consumption","消费记录"],action:"spending"},{name:["Edit Password","修改密码"],action:"password"}]}
		{"name":["Community center","社区中心"],option:[{name:["Goods review","商品评价/晒单"],action:"appraise"},{name:["Buying consult","购买咨询"],action:"consult"},{name:["Groom","推荐有礼"],action:"groom"},{name:["Messages","消息精灵"],action:"message"}]}
	]
	
	@all:-> @tools
	
module.exports = Catalog