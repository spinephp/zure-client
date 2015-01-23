
class Catalog
	@tools: [
		{"name":"站点管理",option:[{name:"站点信息",action:""},{name:"新闻管理",action:"news"},{name:"留言管理",action:"leaveword"}],right:0}
		{"name":"经营管理",option:[{name:"客户管理",action:"custom"},{name:"产品管理",action:"good"},{name:"订单管理",action:"order"}],right:0}
		{"name":"生产管理",option:[{name:"进度管理",action:"progress"}],right:0}
		{"name":"劳资管理",option:[{name:"员工管理",action:"employee"}],right:0}
	]
	
	@all:-> @tools
	
module.exports = Catalog