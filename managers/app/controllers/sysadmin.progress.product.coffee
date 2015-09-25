Spine   = require('spine')
Product   = require('models/orderproducts')
Order   = require('models/order')
Ordersstate   = require('models/ordersstate')
$       = Spine.$

class manageProduct  extends Spine.Controller
  
	constructor: (params) ->
		super params
		@params = params
		Order.bind "beforeUpdate", ->
			Order.url = "woo/index.php"+Order.url if Order.url.indexOf("woo/index.php") is -1
			Order.url += "&token="+$.fn.cookie('PHPSESSID') unless Order.url.match /token/
	
	eco:->
		'show'

# 准备生产
class PrepareProducts extends manageProduct

	elements:
		"button":"buttonEl"
		"input[type=checkbox]":"conditionEl"

	events:
		"click input[type=checkbox]":"condition"
  
	constructor: (params) ->
		super params

	eco: ->
		'prepare'
	
	condition:(e)=>
		check = true
		check = check and $(item).is(":checked") for item in $("input[type=checkbox]",@el)
		$("button",@el).button disabled:not check
		#Spine.trigger "prepareproduction",check

# 成型
class MoldProducts extends manageProduct

	elements:
		"button":"buttonEl"
		"input[type=number]":"conditionEl"

	events:
		"change input[type=number]":"condition"
  
	constructor: (params) ->
		super params

	eco: ->
		'mold'
	
	condition:(e)=>
		check = true
		conditionEl = $(e.target)
		process = ["molding","dry","firing","package"][@params.order.stateid-5]+'number'
		goodid = parseInt conditionEl.parent().parent().attr("data-goodid"),10
		for item in @params.order.products
			if parseInt(item.proid,10) is goodid
				goodamount = item.number 
				item[process] = parseInt conditionEl.val(),10
				#@params.order.products[process+"number"] = item[process]
		check = check and parseInt($(item).val(),10) >= goodamount for item in $("input[type=number]",@el)
		$("button",@el).button disabled:not check

class ProgressProducts extends Spine.Controller
	className: 'progressproducts'

	elements:
		"span.form_hint":"numberEl"

	events:
		"mouseover tbody tr td:nth-child(4)":"shownumbers"
		"mouseout tbody tr td:nth-child(4)":"hidenumbers"
  
	constructor: ->
		super

		@active @change

		@product = $.Deferred()

		Product.bind "refresh",=>@product.resolve()
  
	render: =>
		@html require('views/progressproduct'+@eco)(@item)
		$("body >header h2").text "生产管理->进度管理->"+["生产准备","成型","干燥","烧成","包装"][@item.orders.stateid-4]
		if @eco isnt "show"
			opt = 
				icons:
					primary: "ui-icon-gear"
					secondary: "ui-icon-play"
				disabled: true
			$("button",@el).button(opt).click (event)=>
				oldUrl = Order.url
				try
					if @item.orders.stateid < 8
						@item.orders.stateid++
						# 更新表 ordersstate 
						#Ordersstate.fetch()
					else
						if 100 - @item.orders.guarantee - @item.orders.downpayment > 0 # 支付货款
							@item.orders.stateid++
						else # 准备发货
							@item.orders.stateid += 2
					@item.orders.one "save",=>
						@navigate '/progress' ,@item.orders.id,'show'
					@item.orders.save()
				catch err
					@log err
				finally
					Order.url = oldUrl
		
	shownumbers:(e)->
		$(e.target).find("span").css "display","block"
		false
		
	hidenumbers:(e)->
		$(e.target).find("span").css "display","none"
		false
	
	change: (params) =>
		try
			$.when( @product).done =>
				order = Order.find params.id
				ids = (parseInt(rec.proid,10) for rec in order.products)
				@item = 
					orders:order
					products:Product.select (item)=>parseInt(item.id,10) in ids
				mode = params.match[0].substr(-4)
				if mode is 'edit'
					state = switch parseInt order.stateid
						when 4
							new PrepareProducts el:@el,order:order
						when 5,6,7
							new MoldProducts el:@el,order:order
						when 8
							new MoldProducts el:@el,order:order
									
				else
					state = new manageProduct el:@el,order:order
				@eco = state.eco()
				@render()
		catch err
			@log "file: sysadmin.progress.product.coffee\nclass: ProgressProducts\nerror: #{err.message}"

module.exports = ProgressProducts