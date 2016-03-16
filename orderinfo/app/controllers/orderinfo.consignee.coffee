Spine   = require('spine')
citySelector   = require('controllers/cityselector')
Consignee = require('models/consignee')
Cart = require('models/cart')
Product = require('models/orderproducts')
$       = Spine.$

class Show extends Spine.Controller
  className: 'show'
  
  events:
    'click .edit': 'edit'
    
  elements: 
    'dl dt span': 'editEl'
  
  constructor: ->
    super
    @active @change
    @calcCarriageCharges();
    Consignee.bind('refresh change', @render)
  
  render: =>
    @item = Consignee.getCurrent()
    @html require('views/showconsignee')(@item)
    
  change: (params) =>
    @render()
    if params?
        i = parseInt(params.match[0][15..])
        @setEditTip(i)
    
  setEditTip:(editor)->
    tem = $.trim($('div.edit.active dl dt span').text())
    tem.replace(/[^\[]+(?=\])/g, (word)-> tem = word)
    $(@editEl).html("如需修改，请先#{tem}")
    
  edit: ->
    @navigate('/orderinfo', 'edit0')
    
  # 取运费编码(配送方式编辑中使用)并计算运费
  calcCarriageCharges: () ->
    # 计算商品总重量
    weight = 0
    Cart.each((rec) ->
      pro = Product.find(rec.id)
      weight += rec.number * pro.weight
    )

    # 取得收货人地址编码
    receipt = Consignee.getCurrent()
    if receipt?
      addr  = receipt.province+receipt.city+receipt.zone

      field = ["chargeid","charge"]        # 要查询的字段，此处为运费分类编码和运费
      cond = [{address:addr}]              # 查询条件，此处为运输目的地地址编码
      parm = {charge:weight}               # 运费方法需要的参数，此处为要运输货物的重量
      urlparams = $.param({filter:field,cond:cond,params:param,token:$.fn.cookie "PHPSESSID"})
      url = "? cmd=CarriageClass&#{urlparams}"
      $.getJSON(url,(result)->
        sessionStorage.chargeid = result[0].chargeid
        sessionStorage.charge = result[0].charge
      )

class Edit extends Spine.Controller
  className: 'edit'
  
  events:
    'submit form': 'submit'
    'click .save': 'submit'
    'click a[data-edit]': 'edit'
    'click a[data-delete]': 'delete'
    'click input[name=selector]': 'consigneechange'
    #'change select': 'citychange'
    
  elements: 
    'form': 'form'
    '.newconsignee input':'inputEl'
    '.newconsignee select':"addressEl"
    
  constructor: ->
    super
    @active @change

    Consignee.bind "beforeUpdate beforeDestroy", ->
      Consignee.url = "woo/index.php"+Consignee.url if Consignee.url.indexOf("woo/index.php") is -1
      Consignee.url += "&token="+$.fn.cookie 'PHPSESSID' unless Consignee.url.match /token/
  
  render: ->
    @html require('views/fmConsignee')({consignees:Consignee.all()})
    
  change: (params) =>
    @render()
    curManId = if Consignee.count() then Consignee.getCurrent().id else 0
    $("input[name=selector][value=#{curManId}]").click()

  submit: (e) ->
    e.preventDefault()
    key = $(@form).serializeArray()
    item = if key[0].value isnt '0' then Consignee.findByAttribute('id',key[0].value) else new Consignee
    Consignee.setCurrent item
    if $("div .newconsignee").hasClass 'active'
      addr = $(@addressEl)
      item["province"] =  addr[0].value
      item["city"] =  addr[1].value[2..]
      item["zone"] =  addr[2].value[4..]
      item[res.name] = res.value for res in key[1..]

    oldUrl = Consignee.url
    Consignee.url += "&token="+$.fn.cookie 'PHPSESSID' unless Consignee.url.match /token/
    item.save()
    Consignee.url = oldUrl

    @navigate('/orderinfo',"edit1")
    
  edit: (e)=>
    id = $(e.target).attr 'data-edit'
    $("div .newconsignee").addClass("active")
    if id isnt ''
      item = Consignee.find(id)
      $(myinput).val(item[$(myinput).attr("name")]) for myinput in $(@inputEl)
      tem = ''
      result = (tem+=item[key] for key in ["province","city","zone"])
      citySelector.Init($(@addressEl),result, on)
    
  delete: (e)->
    oldUrl = Consignee.url
    try
      id = $(e.target).attr 'data-delete'
      item = Consignee.find(id)
      item.destroy() if confirm('确实要删除该收货人吗?')
    catch err
      @log err
    finally
      Consignee.url = oldUrl

  consigneechange: (e) ->
    value = $(e.target).attr 'value'
    $("span[data-edit]").removeClass("active")
    if value is '0'
      $("div .newconsignee").addClass("active")
      $(item).val( '') for item in $(@inputEl)
      citySelector.Init($(@addressEl),['','',''], true)
    else
      $("div .newconsignee").removeClass("active")
      $("span[data-edit=#{value}]").addClass("active")

  # 绑定签收人所在省市区组合框改变事件
    ###
  citychange:=>  
    if !timer
      pos = $("header[data-area=area]")
      timer = setTimeout(->
        tmp = "";
        tmp += item.text() for item in $("div.newconsignee select").find("option:selected") when item.attr("value") isnt '0'
        pos.text(tmp)
        timer = 0
      , 100)
    ###
    
class Receiver extends Spine.Stack
  className: 'receiver stack'
    
  controllers:
    show: Show
    edit: Edit
    
module.exports =  Receiver