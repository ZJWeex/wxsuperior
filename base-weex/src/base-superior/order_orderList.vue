/**
接口地址:
http://api.taocaimall.cn:2422/api/index.php?act=api&tag=9#info_api_140f6969d5213fd0ece03148e62e461e
 */
<template>
    <div class='wrapper'>
        <list class="list">
            <refresh class="refreshAndLoading" :display="refresh" @refresh="onrefresh" @pullingdown="onpullingdown">
                <text class="indicator-text" v-if="refreshingPrompt">刷新我的订单</text>
                <loading-indicator class="indicator"></loading-indicator>
            </refresh>
            <cell v-for="(item,i) in orderList" :key="item.supOrderFormId" :index="i">
                <div class="cellContent" @click="didSelectCellClick(item,i)">
                    <div style="flex-direction: row;align-items: center;justify-content: space-between;height: 100px;">
                        <text style="padding-left:50px;color:#666666;font-size:26px;">{{item.addTime}}</text>
                        <text style="padding-right:30px;color:#f52e61;font-size:28px;">{{item.statusText}}</text>
                    </div>
                    <div class="goods-content" v-for="(goods,index) in item.supGoodsList" :key="index">
                        <image style="width:180px;height:120px;margin:26px;background-color:#fff;" :src="goods.mainImgURL"/>
                        <div style="flex:1;margin-right:26px;">
                            <div style="flex-direction: row;justify-content: space-between;">
                                <text style="color:#333333;font-size:32px;width:380px;">{{goods.supGoodsName}}</text>
                                <text style="color:#333333;font-size:32px;">¥{{goods.supStorePrice}}</text>
                            </div>
                            <div style="flex-direction: row;justify-content: space-between;padding-top:5px;">
                                <text style="color:#666666;font-size:24px;width:380px;">{{goods.supGoodsSpecs}}</text>
                                <text style="color:#666666;font-size:24px;">x{{goods.count}}</text>
                            </div>
                        </div>
                    </div>
                    <div style="height:98px;flex-direction: row;justify-content: flex-end;align-items: center;">
                        <text v-if="item.shipPrice>0" style="margin-right:20px;color:#333333;font-size:28px;">共{{item.goodsCount}}件商品 实付：¥{{item.payablePrice}}（含运费¥{{item.shipPrice}}）</text>
                        <text v-else style="margin-right:20px;color:#333333;font-size:28px;">共{{item.goodsCount}}件商品 实付：¥{{item.payablePrice}}</text>
                    </div>
                    <div v-if="item.buttons.length>0" class="btnSet">
                        <text v-for="(btn,index) in item.buttons" 
                                :key="index" 
                                class="btn-border" 
                                :style="{color:btn.color,'border-color':btn.color}"
                                @click="handleActionClick(btn,item)">{{btn.title}}</text>
                    </div>
                </div>
            </cell>
            <cell v-if="showResultPage">
                <div style="width:750px;height:500px;align-items: center;margin-top:150px;">
                    <image style="width: 320px;height: 320px;" :src="customSet.noGoods.pic"/>
                    <text style="color:#A5A5A5;margin-top:20px;font-size:30px;">{{customSet.noGoods.content}}</text>
                </div>
            </cell>
            <!-- 推荐商品 -->
            <cell v-if="showComment">
                <commendGoods ref="commend"></commendGoods>
            </cell>
            <loading v-if="!showComment" class="refreshAndLoading" :display="loadingMore ? 'show' : 'hide'" @loading="onloading">
                <loading-indicator class="indicator"></loading-indicator>
                <text class="indicator-text">{{loadingPrompt}}</text>
            </loading>
        </list>
        <!-- 各种弹框 -->
        <!-- <wxc-result type="noGoods"
              :show="showResultPage"
              :custom-set="customSet"
              :wrap-style="{top:0}"
              padding-top="132">
        </wxc-result> -->
        <wxc-loading :show="loading" need-mask=false type="default"></wxc-loading>
        <payPopup :show="showPopup"
                  :orderId="paymentItem.supOrderFormId"
                  @cancalClick="cancalPopupClick"
                  @paymentProgress='paymentProgress'
                  @paymentResult="popupPaymentResult"></payPopup>
        <wxc-mask height="250"
              width="700"
              border-radius="20"
              duration="200"
              :has-animation="false"
              mask-bg-color="#FFFFFF"
              :has-overlay="true"
              :show-close="maskShowCong.showClose"
              :show="maskShowCong.maskShow"
              @wxcMaskSetHidden="wxcMaskSetHidden">
            <div class="mask-content">
                <div class="mask-div">
                    <text class="mask-text">{{maskShowCong.content}}</text>
                </div>
                <div class="mask-line"></div>
                <text class="mask-comfirm" @click="changeOrderAddress">{{maskShowCong.btnTitle}}</text>
            </div>
        </wxc-mask>
    </div>
</template>

<script>
import navigation from "@/base-superior/components/NavigationBar.vue";
import commendGoods from "@/base-superior/components/commend_goods.vue";
import Fetch from "@/base-superior/Fetch.js";
import { WxcResult, WxcLoading,WxcMask } from 'weex-ui';
import payPopup from "../base-superior/order_orderPayPopup.vue";

const modal = weex.requireModule('modal');
const storage = weex.requireModule("storage");
var globalEvent = weex.requireModule('globalEvent')

export default {
    components: {navigation, WxcResult, WxcLoading, WxcMask, payPopup,commendGoods },
    props:{
        orderType:{
            type:String,
            default:'all'//订单类型:all全部订单
        }
    },
    data() {
        return {
            customSet:{noGoods: { button: null, content: '您还没下过单', desc: '',pic:'/web/assets/sup/sup_homeSearch_noData_cry.png'}},
            showResultPage:false,
            loading:false,
            showPopup:false,
            paymentItem:{},
            showComment:false,
            maskShowCong:{maskShow:false,showClose:false,content:'',btnTitle:'确定'},
            orderList:[],
            refresh: 'hide',
            loadingMore: false,
            refreshingPrompt: true,
            loadingPrompt:'',
            totalPage: 1,
            currentPage: 0,
            operatorIndex:0,
            inPayment: false,
            currentOrder:null,
        }
    },
    created() {
        
        const self = this;
        if (WXEnvironment.platform.toLowerCase() === "web") {
            self.onrefresh();
        } else {
            const tabSelectedChannel = new BroadcastChannel("Order_TabSelected");
            tabSelectedChannel.onmessage = function(event) {
               
                if (event.data == self.orderType) {
                    if(self.orderList.length==0){
                        self.onrefresh();
                    }
                }
            };
        }
        var channel = new BroadcastChannel('OperatorOrderStatus');
        channel.onmessage = function (event) {
            if (self.operatorIndex < self.orderList.length) {
                self.orderList[self.operatorIndex].orderStatus = event.data
            }    
            self.onrefresh();
        }
        //选择地址的回调数据
        const selectAddressChannel = new BroadcastChannel("selectAddressChannel");
        selectAddressChannel.onmessage = function (event){
            console.log("selectAddressChannel："+event.data);
            var addressModel = JSON.parse(event.data);
            if(self.currentOrder){
                if(addressModel.id == self.currentOrder.addrId){
                    //选的地址和当前地址相同
                }else{
                    self.exchangAddressUpdateOrder(addressModel.id,function(){
                        //切换地址成功后刷新列表
                        self.onrefresh();
                    })
                }
                
            }else{
                 self.onrefresh();
            }
            
        };
    },
    watch: {
        orderList:{
             handler(newValue, oldValue){
                 this.orderList = newValue;
             },
             deep:true
        }
    },
    methods: {
        viewappear(){
            if(this.showComment){
                this.$refs.commend.refreshCommendGoodsModule()
            }
        },
        onrefresh: function(event){
            this.refresh = 'show'
            this.refreshingPrompt = false
            this.currentPage = 1
            this.loadOrderListData()
        },
        onpullingdown: function(event){

        },
        onloading: function(event){
            if (this.currentPage < this.totalPage) {
                this.loadingMore = true
                this.loadingPrompt = ''
                this.currentPage =this.currentPage + 1
                this.loadOrderListData()
            }else{
                this.loadingPrompt = '已为您加载全部订单'
                this.loadingMore = true
                setTimeout(() => {
                    this.loadingMore = false
                }, 1000)
            }
        },
        //加载订单列表数据
        loadOrderListData:function(){
            const self = this;  
           //clientType:"H5";H5 调用必传参数，不屏蔽电子卡订单，其他可不传，会屏蔽电子礼品卡订单。后期优选app 若传“superior” 也不屏蔽电子卡订单。
            var param = {currentPage: this.currentPage.toString(),
                         order_status:self.orderType,
                         clientType:"H5",
                         }
            console.log('全部订单：',param)
            Fetch.post('buyer/listSuperiorOrderForm_v2.json', param , function(respone){
                var result = JSON.parse(respone)
                console.log('订单返回结果：',result)
                if(result.op_flag == 'success'){
                    result.supOfs.forEach(element => {
                        self.orderStatusText(element);
                    });
                    if(result.currentPage == result.totalPage && result.supOfs.length>0){
                        self.showComment = true;
                    }else{
                        self.showComment = false;
                    }
                    if (self.currentPage == 1) {
                        self.orderList = result.supOfs;
                    } else {
                        result.supOfs.forEach(element => {
                            self.orderList.push(element);
                        });
                    }
                    if(self.orderList.length == 0){
                        self.showResultPage = true;
                        self.showComment = true;
                        if(self.orderType.indexOf('order_sended') != -1){
                            self.customSet = {noGoods: { button: null, content: '您没有待收货的订单', desc: '',pic:'/web/assets/sup/sup_homeSearch_noData_cry.png' }};
                        }else if(self.orderType.indexOf('order_unsend') != -1){
                            self.customSet = {noGoods: { button: null, content: '您没有待发货的订单', desc: '',pic:'/web/assets/sup/sup_homeSearch_noData_cry.png' }};
                        }else if(self.orderType.indexOf('order_submit') != -1){
                            self.customSet = {noGoods: { button: null, content: '您没有待付款的订单', desc: '',pic:'/web/assets/sup/sup_homeSearch_noData_cry.png' }};
                        }

                    }else{
                        self.showResultPage = false;
                    }

                    self.currentPage = Number(result.currentPage)
                    self.totalPage = Number(result.totalPage)
                    if (self.currentPage < self.totalPage) {
                        self.loadingPrompt = '加载更多订单'
                    } 
                }else{
                    modal.toast({message:result.info})
                }
                
                self.loadingMore = false
                self.refresh = 'hide'
                self.refreshingPrompt = true
            }, function(err){
                self.loadingMore = false
                self.refresh = 'hide'
                self.refreshingPrompt = true
                modal.toast({message:err})
            });
        },
        //订单状态
        orderStatusText:function(orderModel){
            var str = '';
            var btns = [];
            switch (orderModel.orderStatus) {
                case '0':
                    str = '已取消'
                    break;
                case '8':
                    str = '已关闭'
                    break;    
                case '10':
                    str = '待付款'
                    var button0 = {title:'修改地址',
                                  color:'#999999',
                                  type:'changeAddress'}
                    btns.push(button0)
                    if (orderModel.orderType && orderModel.orderType != '2') {
                        var button1 = {title:'取消订单',
                                    color:'#999999',
                                    type:'cancel'}
                        btns.push(button1)
                    }
                    var button2 = {title:'立即付款',
                                  color:'#ff3333',
                                  type:'pay'}
                    btns.push(button2)
                    break; 
                case '20':
                    str = '待准备'
                    if (orderModel.orderType && orderModel.orderType != '2') {
                        var button1 = {title:'取消订单',
                                    color:'#999999',
                                    type:'cancel'}
                        btns.push(button1)
                    }
                    break;
                case '30':
                    str = '准备中'
                    break;
                case '34':
                    str = '部分发货'
                    if (orderModel.wayBillNumber && orderModel.wayBillNumber != 'sinceOrder') {
                        var button1 = {title:'查看物流',
                                    color:'#666666',
                                    type:'progress'}
                        btns.push(button1)
                    }
                    var button1 = {title:'确认收货',
                                  color:'#f52c57',
                                  type:'confirm'}
                    btns.push(button1)
                    break;
                case '50':
                    str = '已完成'
                    if (orderModel.wayBillNumber && orderModel.wayBillNumber != 'sinceOrder') {
                        var button1 = {title:'查看物流',
                                    color:'#666666',
                                    type:'progress'}
                        btns.push(button1)
                    }
                    break;
                case '35':
                case '108':
                    str = '配送中'
                    if (orderModel.canDelayConfirm=='true' && orderModel.hadDelay=='false') {
                        var button1 = {title:'延迟收货',
                                  color:'#ff0033',
                                  type:'delayConfirm'}
                        btns.push(button1)
                    }
                    if (orderModel.wayBillNumber && orderModel.wayBillNumber != 'sinceOrder') {
                        var button1 = {title:'查看物流',
                                    color:'#666666',
                                    type:'progress'}
                        btns.push(button1)
                    }
                    var button1 = {title:'确认收货',
                                  color:'#f52c57',
                                  type:'confirm'}
                    btns.push(button1)
                    break;
                default:
                    break;
            }
            orderModel.statusText = str;
            orderModel.buttons = btns;
        },
        //点击按钮操作
        handleActionClick:function(button,item){
            const self = this;
            switch (button.type) {
                case 'cancel':
                    {
                        modal.confirm({message:'确定取消订单吗？',
                                      okTitle:'确定',
                                      cancelTitle:'取消'},function (result) {
                                          if(result == '确定'){
                                              self.cancelOrderEvent(item);
                                          }
                                      });
                    }
                    break;
                case 'confirm':
                    {
                        if(item.orderStatus==34){
                            this.currentOrder = item;
                            //部分商品发货弹框
                            this.maskShowCong={ maskShow:true,
                                            showClose:false,
                                            content:'您的订单未全部发货，为了保证交易安全暂不能进行确认收货。',
                                            btnTitle:'确定'}
                        }else{
                            modal.confirm({message:'我已经收到商品并签收，确认无误？',
                                      okTitle:'确定',
                                      cancelTitle:'取消'},function(result){
                                          if(result == '确定'){
                                              self.confirmOrderToEvent(item);
                                          }
                                      }); 
                        }
                    }
                    break;
                case 'pay':
                    {
                       console.log('支付订单');
                       self.showPopup = true;
                       self.paymentItem = item;
                    }
                    break;
                case 'progress':
                    {
                        //物流列表
                        if(item.logistCount>1){
                            storage.setItem('order_logistic_list_OrderID',item.orderId,event =>{})
                            navigation.push({url:'order_logistic_list.html', title:'物流详情'}, event =>{});
                        }else{
                            //物流轨迹
                            storage.setItem('Order_logisticCode',item.wayBillNumber,event =>{})
                            navigation.push({url:'order_logistic_detail.html', title:'物流轨迹'}, event =>{});
                        }
                        
                    }
                    break;
                case 'delayConfirm':
                    {
                       var delay_message = item.notice
                       console.log('延迟收货提示语:'+ delay_message)
                       modal.confirm({message:delay_message,
                                      okTitle:'确定',
                                      cancelTitle:'取消'
                                      },function(result){
                                          if(result == '确定'){
                                              self.delayConfirm(item);
                                          }
                                      }); 
                    }
                    break;
                case 'changeAddress':
                    {
                        this.currentOrder = item;
                        //显示切换地址弹框
                        this.maskShowCong={ maskShow:true,
                                            showClose:true,
                                            content:'因修改配送地址，订单应付金额可能发生变化',
                                            btnTitle:'确定修改'}
                    }
                    break;
                default:
                    break;
            }
        },
        //取消订单
        cancelOrderEvent:function(item){
            const self = this;
           self.loading = true;
            var param = {supOrderFormId:item.supOrderFormId}
            Fetch.post('buyer/cancelSuperiorOrderForm.json', param, function(respone){
                self.loading = false;
                var result = JSON.parse(respone);
                if(result.op_flag == 'success'){
                    //不能触发界面刷新
                    item.orderStatus = '0'
                    item.orderStatusText = '已取消'
                    
                    // self.onrefresh()
                    self.postnotices()
                }else{
                    modal.toast({message:result.info})
                }
            }, function(err){
                self.loading = false;
                modal.toast({message:err})
            });
        },
        //确认收货
        confirmOrderToEvent:function(item){
            const self = this;
            self.loading = true;
            var param = {supOrderFormId:item.supOrderFormId}
            Fetch.post('buyer/confirmSuperiorOrderForm.json', param, function(respone){
                self.loading = false;
                var result = JSON.parse(respone);
                if(result.op_flag == 'success'){
                    item.orderStatus = '50'
                    item.orderStatusText = '已完成'

                    // self.onrefresh()
                    self.postnotices()
                }else{
                    modal.toast({message:result.info})
                }
            }, function(err){
                self.loading = false;
                modal.toast({message:err})
            });
        },
        delayConfirm: function (item){
            var self = this
            self.loading = true;
            Fetch.post('/buyer/delayConfirmSuperiorOrderForm.json', {supOrderFormId: item.supOrderFormId}, function(jsonString){
                 self.loading = false;
                var result = JSON.parse(jsonString);
                if(result.op_flag == 'success'){
                    item.hadDelay = 'true'
                    self.onrefresh()
                }else{
                    modal.toast({message:result.info})
                }
            }, function(err){
                self.loading = false;
                modal.toast({message:err})
            });
        },
        //订单状态发生改变，发送事件
        postnotices: function () {
            var channel = new BroadcastChannel('OperatorOrderStatus');
            channel.postMessage('OperatorOrderStatus');
        },
        //待支付订单更换地址
        exchangAddressUpdateOrder:function(addressId,block){
            var self = this
            self.loading = true;
            var param = {supOrderId: self.currentOrder.supOrderFormId,addrId: addressId}
            Fetch.post('/buyer/exchangAddressUpdateSuperiorOrder.json',param , function(jsonString){
                console.log('exchangAddressUpdateSuperiorOrder:',jsonString);
                 self.loading = false;
                var result = JSON.parse(jsonString);
                if(result.op_flag == 'success'){
                    block()
                }else{
                    modal.toast({message:result.info})
                }
            }, function(err){
                self.loading = false;
                modal.toast({message:err})
            });
        },
        //点击cell跳转
        didSelectCellClick:function(item, index){
            storage.setItem('OrderDetail_OrderId',item.supOrderFormId,event =>{})
            this.operatorIndex = index
            if (item.orderType == 1) {
                navigation.push({url:'goods_giftVoucher_order.html', title:'订单详情'}, event =>{});
            } else {
                navigation.push({url:'order_orderDetail.html', title:'订单详情'}, event =>{});
            }
        },

        //修改代付款订单地址
        changeOrderAddress:function(){
            this.wxcMaskSetHidden();
            //待付款状态
            if(this.currentOrder.orderStatus==10){
                storage.setItem('oderSubmit_selectAddress',JSON.stringify({}),event =>{})
                navigation.push({url:'address_list.html', title:'选择地址'}, event =>{});
            }
            
        },
        wxcMaskSetHidden () {
            this.maskShowCong={ maskShow:false,
                                showClose:false,
                                content:'',
                                btnTitle:''}
        },
        //取消弹框事件
        cancalPopupClick:function(event){
            this.showPopup = false;
        },
        //支付结果回调
        popupPaymentResult:function(ret){
            this.showPopup = false;
            if(ret.result == 'success'){
                if (this.paymentItem.orderType == 1) {
                    this.paymentItem.orderStatus = '50'
                    this.paymentItem.orderStatusText = '已完成'
                } else {
                    this.paymentItem.orderStatus = '20'
                    this.paymentItem.orderStatusText = '待准备'
                }
            }
            this.onrefresh();
            modal.toast({message:ret.data,duration: 0.3})
            this.inPayment = false
            this.loading = false
            this.removeEventListener()
        },
        paymentProgress: function (event){
            switch (event.option) {
                case 1:
                    this.loading = true
                    this.addEventListener()
                    break;
                case 2:
                    this.loading = false
                    break;
                case 400:
                    this.loading = false
                    break; 
                case 3:
                    
                    break;
                default:
                    break;
            }
            this.inPayment = true
        },
        addEventListener(){
            //iOS支付是否点击顶部返回监听
            var self = this
            globalEvent.addEventListener("WXApplicationDidBecomeActiveEvent", function (e) {
                console.log("WXApplicationDidBecomeActiveEvent");
                //支付回调和应用激活，先后无序；故延时处理
                setTimeout(()=>{
                    if (self.inPayment) {
                        self.onrefresh();
                    }
                },1000);
                self.removeEventListener()
            });
        },
        removeEventListener(){
            globalEvent.removeEventListener('WXApplicationDidBecomeActiveEvent')
        },
    }
}
</script>

<style scoped>
.wrapper { 
    width: 750px;
    flex: 1;
}
.list {
    width: 750px;
    flex: 1;
}
.cellContent{
    background-color: #ffffff;
    border-top-color: #f5f4f9;
    border-top-width: 4px;
    border-bottom-color: #f5f4f9;
    border-bottom-width: 18px;
}

.goods-content{
    flex-direction: row;
    align-items: center;
    background-color: #fafafa;
    margin-bottom: 4px;
}

.btnSet {
    flex-direction: row;
    align-items: center;
    justify-content: flex-end;
    border-top-color:#f0f0f0;
    border-top-width:2px;
}
.btn-border {
    height: 60px;
    line-height: 60px;
    padding-left:20px;
    padding-right:20px;
    border-width:2px;
    border-color:#ff3333;
    border-radius:60px;
    color:#ff3333;
    margin-top:16px;
    margin-bottom:24px;
    margin-right: 40px;
    font-size: 28px;
}
.mask-content {
    align-items: center;
}
.mask-div{
    justify-content: center;
    align-items: center;
    height: 160px;
}
.mask-text{
    color:#333333;
    font-size:30px;
    margin-top:30px;
    margin-bottom:30px;
    margin-left:40px;
    margin-right:40px;
}
.mask-line {
    height: 2px;
    background-color:#f5f4f4;
    width: 700px;
}
.mask-comfirm {
    height:80px;
    line-height: 80px;
    color:#ff0033;
    font-size:32px;
    padding-left: 20px;
    padding-right: 20px;
}
/* 加载刷新 */
.indicator-text {
    color: #888888;
    font-size: 30px;
    text-align: center;
    margin-top: 20px;
    margin-bottom: 20px;
}
.indicator {
    margin-top: 16px;
    height: 40px;
    width: 40px;
    color: #888888;
}
.refreshAndLoading {
    width: 750;
    display: -ms-flex;
    display: -webkit-flex;
    display: flex;
    -ms-flex-align: center;
    -webkit-align-items: center;
    -webkit-box-align: center;
    align-items: center;
  }
</style>
