Spine   = require('spine')
Bill = require('models/bill')
Billfree = require('models/billfree')
Billsale = require('models/billsale')
Billcontent = require('models/billcontent')
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
    Bill.bind('refresh change', @render)
    Billfree.bind('refresh change', @render)
    Billsale.bind('refresh change', @render)
    Billcontent.bind('refresh change', @render)
  
  render: =>
    rec = Bill.getCurrent()
    billcur = Billcontent.getCurrent()
    content = billcur?.name || "No content"
    typeid = parseInt( rec?.id )
    curBill = if typeid is 1 then Billfree else Billsale
    curname = curBill.getCurrent()
    name = curname?.name || "No Bill"
    type = rec?.name || "No Bill Type"
    @item = {"type":type,"name":name,"content":content}
    @html require('views/showbill')(@item)
    
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
    @navigate('/orderinfo', 'edit3')

class Edit extends Spine.Controller
  className: 'edit'
  
  events:
    'submit form': 'submit'
    'click .save': 'submit'
    'click a[data-edit]': 'edit'
    'click a[data-delete]': 'delete'
    'click input[name=bill]': 'billchange'
    'click input[name=billtype]': 'billtypechange'
    'click input[name=receiptheader]': 'receiptheaderchange'
    
  elements: 
    'form': 'form'
    
  constructor: ->
    super
    @active @change

    Billfree.bind "beforeUpdate beforeDestroy", ->
      Billfree.url = "woo/index.php"+Billfree.url if Billfree.url.indexOf("woo/index.php") is -1
      Billfree.url += "&token="+sessionStorage.token unless Billfree.url.match /token/
  
  render: ->
    @html require('views/fmBill')({billfrees:Billfree.all(),billsales:Billsale,billcontents:Billcontent.all()})
    
  change: (params) =>
    @render()
    rec = Bill.getCurrent()
    content = Billcontent.getCurrent().id
    typeid = parseInt( rec?.id )
    curBill = if typeid is 1 then Billfree else Billsale
    itemid = curBill.getCurrent()?.id
    if typeid is 1
      if itemid?
        $("input[name=bill][value=#{itemid}]").click()
      else
        $("input[name=bill][value=0]").click()
        $("input[name=billtype][value=1]").click()
    else if typeid is 2
      $("input[name=bill][value=0]").click()
      $("input[name=billtype][value=2]").click()
    $("input[name=billcontent][value=#{content}]").click()
      
    
  submit: (e) ->
    e.preventDefault()
    key = $(@form).serializeArray()
    console.log key
    if key[0].value isnt '0' and key[2].value isnt '2'
      Billfree.setCurrent(Billfree.find(key[0].value))

    # 编辑或新增收据
    else if key[1].value is '1' and key[2].value is '2'
      Bill.setCurrent(Bill.find('1')) # 设置当前票据类型为收据
      item = if key[0].value isnt '0' then Billfree.findByAttribute("id",key[0].value) else new Billfree
      item.__proto__.name = key[3].value

      Billfree.url += "&token="+sessionStorage.token unless Billfree.url.match /token/
      item.save()
      Billfree.setCurrent(item) # 设置当前收据

    # 编辑或新增增值税发票
    else if key[1].value is '2' 
      Bill.setCurrent(Bill.find('2'))
      item = Billsale.first() || Billsale.create()
      for k in key[4..9]
        item.__proto__[k.name] = k.value
      item.save()

    # 设置当前票据内容
    Billcontent.setCurrent(Billcontent.find(key[4].value))

    @navigate('/orderinfo')
    
  edit: (e)->
    id = $(e.target).attr 'data-edit'
    $("div .newbill").addClass("active")
    $("input[name=billtype][value=1]").click()
    if id isnt ''
      item = Billfree.find(id)
      $("input[name=receiptheader][value=2]").click()
      $("input[name=receipcompany]").val item.name
    
  delete: (e)->
    oldUrl = Billfree.url
    try
      id = $(e.target).attr 'data-delete'
      item = Billfree.find(id)
      item.destroy() if confirm('确实要删除该收货人吗?')
    catch err
      @log err
    finally
      Billfree.url = oldUrl

  billchange: (e) ->
    value = $(e.target).attr 'value'
    $("span[data-edit]").removeClass("active")
    if value is '0'
      $("div .newbill").addClass("active")
      $("input[name=billtype][value=1]").click()
    else
      $("div .newbill").removeClass("active")
      $("span[data-edit=#{value}]").addClass("active")

  billtypechange: (e) ->
    value = $(e.target).attr 'value'
    $("div[data-billtype]").removeClass("active")
    $("div[data-billtype=#{value}]").addClass("active")

  receiptheaderchange: (e) ->
    value = $(e.target).attr 'value'
    if value is '1'
      $(".receiptheader").removeClass("active")
    else
      $(".receiptheader").addClass("active")

class Bills extends Spine.Stack
  className: 'bills stack'
    
  controllers:
    show: Show
    edit: Edit
    
module.exports =  Bills