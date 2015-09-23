
Spine   = require('spine')
Orderstate = require('models/orderstate')
Order = require('models/order')

$       = Spine.$

class manageOrder  extends Spine.Controller
  
	constructor: (params) ->
		super params
		@token = $.fn.cookie('PHPSESSID')
		@params = params
		Order.bind "beforeUpdate", =>
			Order.url = "woo/index.php"+Order.url if Order.url.indexOf("woo/index.php") is -1
			Order.url += "&token="+@token unless Order.url.match /token/
	
	eco:->
		'show'

# �������
class orderCheck extends manageOrder

	elements:
		"button":"buttons"
		"input[type=checkbox]":"constractEl"
  
	events:
		'click button': 'pass'
  
	constructor: (params) ->
		super params

	eco: ->
		'check'

	pass: (e) => # �� �����ͨ������ ��ȡ�������� �������
		e.stopPropagation()
		oldUrl = Order.url
		try
			threw "Ԥ���L���ʱ���֮�ʹ��� 100��" if @params.order.downpayment + @params.order.guarantee > 100
			i = $('button',@el).index e.target
			if i is 0
				if $(@constractEl).is(":checked")
					@params.order.stateid = 2 # ǩ���ͬ
				else
					if @params.order.downpayment is 0
						if @params.order.shipdate is 0
							if @params.order.guarantee isnt 100
								@params.order.stateid = 9 # ֧������
							else
								@params.order.stateid = 10 # ׼������
						else
							@params.order.stateid = 4 # ׼������
					else
						@params.order.stateid = 3 # Ԥ����
			else
				@params.order.stateid = 14 #ȡ������
			@params.order.save()
			@navigate('/orders',@params.order.id,'show')
		catch err
			alert err.message
		finally
			Order.url = oldUrl

# ǩ���ͬ
class orderPrint extends manageOrder

	elements:
		"button":"buttons"
  
	events:
		'click button': 'printed'
  
	constructor: (params) ->
		super params

	eco: ->
		'print'

	printed: (e) => # �� �����ͨ������ ��ȡ�������� �������
		e.preventDefault();
		e.stopPropagation();
		oldUrl = Order.url
		try
			i = $('button',@el).index e.target
			if i is 0 # ȷ�Ϻ�ͬ
				if @params.order.downpayment is 0
					if @params.order.shipdate is 0
						if @params.order.guarantee isnt 100
							@params.order.stateid = 9 # ֧������
						else
							@params.order.stateid = 10 # ׼������
					else
						@params.order.stateid = 4 # ׼������
				else
					@params.order.stateid = 3 # Ԥ����
			else if i is 1 # �鿴��ͬ
				window.open("?cmd=Contract&orderid=#{@params.order.id}&token=#{@token}")
			else # ȡ������
				@params.order.stateid = 14 # ȡ������
			@params.order.save()
			@navigate('/orders',@params.order.id,'show')
		catch err
			@log err
		finally
			Order.url = oldUrl

class orderReturned extends manageOrder

	constructor: (params) ->
		super params

	eco: ->
		'returned'

# Ԥ����
class orderAdvance extends manageOrder

	elements:
		"button":"buttons"
  
	events:
		'click button': 'prepaid'
  
	constructor: (params) ->
		super params

	eco: ->
		'advance'

	prepaid: (e) => # �� �����ͨ������ ��ȡ�������� �������
		e.stopPropagation()
		oldUrl = Order.url
		try
			i = $('button',@el).index e.target
			if i is 0 # ����� [��Ԥ��] ����
				@params.order.stateid = 4 #׼������
			else if i is 1 # �鿴��ͬ
				window.open("?cmd=Contract&orderid=#{@params.order.id}&token=#{@token}")
			else # ȡ������
				@params.order.stateid = 14 # ȡ������
			@params.order.save()
			@navigate('/orders',@params.order.id,'show')

		catch err
			@log err
		finally
			Order.url = oldUrl

# ֧������
class orderPayment extends manageOrder

	elements:
		"button":"buttons"
  
	events:
		'click button': 'payment'
  
	constructor: (params) ->
		super params

	eco: ->
		'payment'

	payment: (e) => # �� �����ͨ������ ��ȡ�������� �������
		e.stopPropagation()
		oldUrl = Order.url
		try
			i = $('button',@el).index e.target
			if i is 0 # ����� [��֧��] ����
				@params.order.stateid = 10 # ׼������
			else if i is 1 # �鿴��ͬ
				window.open("?cmd=Contract&orderid=#{@params.order.id}&token=#{@token}")
			else # ȡ������
				@params.order.stateid = 14 # ȡ������
			@params.order.save()
			@navigate('/orders',@params.order.id,'show')

		catch err
			@log err
		finally
			Order.url = oldUrl

# ׼������
class orderShip extends manageOrder

	elements:
		"button":"buttons"
  
	events:
		'click button': 'ship'
  
	constructor: (params) ->
		super params

	eco: ->
		'ship'

	ship: (e) => # �� �����ͨ������ ��ȡ�������� �������
		e.stopPropagation()
		oldUrl = Order.url
		try
			i = $('button',@el).index e.target
			if i is 0 # ����� [�ѷ���] ����
				@params.order.stateid = 11 # �ȴ��ͻ��ջ�
				@params.order.save()
				@navigate('/orders',@params.order.id,'show')
			else if i is 1 # �鿴��ͬ
				window.open("?cmd=Contract&orderid=#{@params.order.id}&token=#{@token}")

		catch err
			@log err
		finally
			Order.url = oldUrl

# �ȴ��ͻ��ջ�
class orderReceive extends manageOrder

	elements:
		"button":"buttons"
  
	events:
		'click button': 'receive'
  
	constructor: (params) ->
		super params

	eco: ->
		'receive'

	receive: (e) => # �� �����ͨ������ ��ȡ�������� �������
		e.stopPropagation()
		oldUrl = Order.url
		try
			i = $('button',@el).index e.target
			if i is 0 # ����� [���ջ�] ����
				@params.order.stateid = if @params.order.guarantee > 0 then 12 else 13
			else if i is 1 # �鿴��ͬ
				window.open("?cmd=Contract&orderid=#{@params.order.id}&token=#{@token}")
			@params.order.save()
			@navigate('/orders',@params.order.id,'show')

		catch err
			@log err
		finally
			Order.url = oldUrl

# �ȴ��ͻ�֧���ʱ���
class orderQA extends manageOrder

	elements:
		"button":"buttons"
  
	events:
		'click button': 'qa'
  
	constructor: (params) ->
		super params

	eco: ->
		'qa'

	qa: (e) => # �� �����ͨ������ ��ȡ�������� �������
		e.stopPropagation()
		oldUrl = Order.url
		try
			i = $('button',@el).index e.target
			if i is 0 # ����� [��֧��] ����
				@params.order.stateid = 13 # ���
			else if i is 1 # �鿴��ͬ
				window.open("?cmd=Contract&orderid=#{@params.order.id}&token=#{@token}")
			@params.order.save()
			@navigate('/orders',@params.order.id,'show')

		catch err
			@log err
		finally
			Order.url = oldUrl

class CurrentState extends Spine.Controller
	className: 'currentstate'
  
	constructor: ->
		super

		@active @change

		@order = $.Deferred()
		@orderstate = $.Deferred()

		Order.bind "refresh",=>@order.resolve()
		Orderstate.bind "refresh",=>@orderstate.resolve()

		Spine.bind "transportchange",(carriagecharge) =>
			@item.order.carriagecharge = parseFloat carriagecharge

		Spine.bind "paymentchange",(ainput)=>  # �󶨶����ʱ����ʱ��ڸı䴦�����
			@item.order[ainput.attr("name")] = parseInt ainput.val()
  
	render: =>
		@html require("views/stateorder#{@eco}")(@item)
	
	change: (params) =>
		try
			$.when( @order,@orderstate).done =>
				if Order.exists params.id
					order = Order.find params.id
					@item = 
						order:order
						state:Orderstate.find order.stateid
					mode = params.match[0].substr(-4)
					if mode is 'edit'
						state = switch parseInt order.stateid
							when 1
								new orderCheck el:@el,order:order
							when 2
								new orderPrint el:@el,order:order
							when 3
								new orderAdvance el:@el,order:order
							when 4,5,6,7,8
								new orderReturned el:@el,order:order
							when 9
								new orderPayment el:@el,order:order
							when 10
								new orderShip el:@el,order:order
							when 11
								new orderReceive el:@el,order:order
							when 12
								new orderQA el:@el,order:order
					else
						state = new manageOrder el:@el,order:order
					@eco = state.eco()
					@render()
		catch err
			@log "file: sysadmin.order.current.coffee\nclass: CurrentState\nerror: #{err.message}"

module.exports = CurrentState