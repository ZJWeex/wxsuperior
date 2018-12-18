/**
接口地址:
http://api.taocaimall.cn:2422/api/index.php?act=api&tag=9#info_api_140f6969d5213fd0ece03148e62e461e
 */
<template>
    <div class='wrapper'>
        <navigation :title="navBarTitle"/>
        <list class="list">
            <refresh class="refreshAndLoading" :display="refresh" @refresh="onrefresh" @pullingdown="onpullingdown">
                <text class="indicator-text" v-if="refreshingPrompt">刷新我的订单</text>
                <loading-indicator class="indicator"></loading-indicator>
            </refresh>
            <cell v-for="(item,i) in orderList" :key="item.supOrderFormId" :index="i">
                <div class="cell-content" @click="didSelectCellClick(item,i)">
                    <div class="content-top">
                        <div style="flex:1">
                            <text class="address-text">配送地址：{{item.addressInfo}}</text>
                            <text class="order-time">下单时间：{{item.addTime}}</text>
                        </div>
                        <text class="order-state">{{item.statusText}}</text>
                    </div>
                    <div class="content-bottom">
                        <div style="flex-direction: row;align-items: center;">
                            <text style="color:#333333">实付：</text>
                            <text style="color:#ff3333">¥{{ item.payablePrice }}</text>
                        </div>
                        <div style="flex-direction: row;align-items: center;">
                            <text v-for="(btn,index) in item.buttons" 
                                  :key="index" 
                                  class="border-btn" 
                                  :style="{color:btn.color,'border-color':btn.color}"
                                  @click="handleActionClick(btn,item)">{{btn.title}}</text>
                        </div>
                    </div>
                </div>
            </cell>
            <loading class="refreshAndLoading" :display='loadingMore' @loading="onloading">
                <loading-indicator class="indicator"></loading-indicator>
                <text class="indicator-text">{{loadingPrompt}}</text>
            </loading>
        </list>
        <wxc-result type="noGoods"
              :show="showResultPage"
              :custom-set="customSet"
              :wrap-style="{top:176}"
              padding-top="232">
        </wxc-result>
        <wxc-loading :show="loading" need-mask=false type="default"></wxc-loading>
        <payPopup :show="showPopup"
                  :orderId="paymentItem.supOrderFormId"
                  @cancalClick="cancalPopupClick"
                  @paymentProgress='paymentProgress'
                  @paymentResult="popupPaymentResult"></payPopup>
    </div>
</template>

<script>
import navigation from "@/base-superior/components/NavigationBar.vue";
import Fetch from "@/base-superior/Fetch.js";
import { WxcResult, WxcLoading } from 'weex-ui';
import payPopup from "../base-superior/order_orderPayPopup.vue";

const modal = weex.requireModule('modal');
const storage = weex.requireModule("storage");

export default {
    components: {navigation, WxcResult, WxcLoading,payPopup },
    data() {
        return {
            customSet:{noGoods: { button: null, content: '您还没下过单', desc: '' }},
            showResultPage:false,
            loading:false,
            showPopup:false,
            paymentItem:{},
            navBarTitle:'我的订单',
            orderType:'',//订单类型
            orderList:[],
            refresh: 'hide',
            loadingMore: 'hide',
            refreshingPrompt: true,
            loadingPrompt:'',
            totalPage: 1,
            currentPage: 0,
            operatorIndex:0,
        }
    },
    created() {
        var self = this 
        storage.getItem('OrderType', event=>{
            console.log('OrderType:'+event.data)
            self.orderType = event.data;
            if(self.orderType.indexOf('108')!= -1){
                self.navBarTitle = '待收货'
            }else if(self.orderType.indexOf('20')!= -1){
                self.navBarTitle = '待发货'
            }else if(self.orderType.indexOf('10')!= -1){
                self.navBarTitle = '待付款'
            }
            self.onrefresh();
            storage.removeItem('OrderType',event => {})
        })

        var channel = new BroadcastChannel('OperatorOrderStatus');
        channel.onmessage = function (event) {
            if (self.operatorIndex < self.orderList.length) {
                self.orderList[self.operatorIndex].orderStatus = event.data
            }    
            self.onrefresh();
        }
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
        onrefresh: function(event){
            this.refresh = 'show'
            this.refreshingPrompt = false
            this.currentPage = 0
            this.loadOrderListData()
        },
        onpullingdown: function(event){

        },
        onloading: function(event){
            if (this.currentPage < this.totalPage) {
                this.loadingMore = 'show'
                this.loadingPrompt = ''
                this.loadOrderListData()
            }
        },
        //加载订单列表数据
        loadOrderListData:function(){
            const self = this;  

            var param = {currentPage: (this.currentPage + 1).toString(),
                         status:self.orderType}
                         console.log(param)
            Fetch.post('buyer/listSuperiorOrderForm.json', param , function(respone){
                var result = JSON.parse(respone)
                if(result.op_flag == 'success'){
                    result.supOfs.forEach(element => {
                        self.orderStatusText(element);
                    });
                    if (self.currentPage == 0) {
                        self.orderList = result.supOfs;
                    } else {
                        result.supOfs.forEach(element => {
                            self.orderList.push(element);
                        });
                    }
                    if(self.orderList.length == 0){
                        self.showResultPage = true;
                        if(self.orderType.indexOf('108') != -1){
                            self.customSet = {noGoods: { button: null, content: '您没有待收货的订单', desc: '' }};
                        }else if(self.orderType.indexOf('20') != -1){
                            self.customSet = {noGoods: { button: null, content: '您没有待发货的订单', desc: '' }};
                        }else if(self.orderType.indexOf('10') != -1){
                            self.customSet = {noGoods: { button: null, content: '您没有待付款的订单', desc: '' }};
                        }

                    }else{
                        self.showResultPage = false;
                    }

                    self.currentPage = Number(result.currentPage)
                    self.totalPage = Number(result.totalPage)
                    if (self.currentPage < self.totalPage) {
                        self.loadingPrompt = '加载更多订单'
                    } else {
                        self.loadingPrompt = '已为您加载全部订单'
                    }
                }else{
                    modal.toast({message:result.info})
                }
                
                self.loadingMore = 'hide'
                self.refresh = 'hide'
                self.refreshingPrompt = true
            }, function(err){
                self.loadingMore = 'hide'
                self.refresh = 'hide'
                self.refreshingPrompt = true
                modal.toast({message:'错误信息:'+err})
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
                    var button1 = {title:'取消订单',
                                  color:'#999999',
                                  type:'cancel'}
                    btns.push(button1)
                    var button2 = {title:'立即付款',
                                  color:'#ff3333',
                                  type:'pay'}
                    btns.push(button2)
                    break; 
                case '20':
                    str = '待准备'
                    var button1 = {title:'取消订单',
                                  color:'#999999',
                                  type:'cancel'}
                    btns.push(button1)
                    break;
                case '30':
                    str = '准备中'
                    break;
                case '50':
                    str = '已完成'
                    var button1 = {title:'查看物流',
                                  color:'#31b70d',
                                  type:'progress'}
                    btns.push(button1)
                    break;
                case '35':
                    str = '配送中'
                    var button1 = {title:'查看物流',
                                  color:'#31b70d',
                                  type:'progress'}
                    btns.push(button1)
                    var button1 = {title:'确认收货',
                                  color:'#ff0033',
                                  type:'confirm'}
                    btns.push(button1)
                    break;
                case '108':
                    str = '待收货'
                    var button1 = {title:'查看物流',
                                  color:'#31b70d',
                                  type:'progress'}
                    btns.push(button1)
                    var button1 = {title:'确认收货',
                                  color:'#ff0033',
                                  type:'confirm'}
                    btns.push(button1)
                    // if (orderModel.canDelayConfirm=='true' && orderModel.hadDelay=='false') {
                        var button1 = {title:'延迟收货',
                                  color:'#ff0033',
                                  type:'delayConfirm'}
                        btns.push(button1)
                    // }
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
                       modal.confirm({message:'确定收货吗？',
                                      okTitle:'确定',
                                      cancelTitle:'取消'},function(result){
                                          if(result == '确定'){
                                              self.confirmOrderToEvent(item);
                                          }
                                      }); 
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
                        storage.setItem('Order_logisticCode',JSON.stringify({logisticCode:item.wayBillNumber,photos:item.photos}),event =>{})
                        navigation.push({url:'order_logisticDetail.html', title:'物流详情'}, event =>{});
                    }
                    break;
                case 'delayConfirm':
                    {
                       modal.confirm({message:'确定延迟收货吗？',
                                      okTitle:'确定',
                                      cancelTitle:'取消'},function(result){
                                          if(result == '确定'){
                                              self.delayConfirm(item);
                                          }
                                      }); 
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
                    
                    self.onrefresh()
                }else{
                    modal.toast({message:result.info})
                }
            }, function(err){
                 self.loading = false;
                modal.toast({message:'错误信息:'+err})
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

                    self.onrefresh()
                }else{
                    modal.toast({message:result.info})
                }
            }, function(err){
                self.loading = false;
                modal.toast({message:'错误信息:'+err})
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
                modal.toast({message:'错误信息:'+err})
            });
        },
        //点击cell跳转
        didSelectCellClick:function(item, index){
            storage.setItem('OrderDetail_OrderId',item.supOrderFormId,event =>{})
            this.operatorIndex = index
            navigation.push({url:'order_orderDetail.html', title:'订单详情'}, event =>{
            });
        },
        //取消弹框事件
        cancalPopupClick:function(event){
            this.showPopup = false;
        },
        //支付结果回调
        popupPaymentResult:function(ret){
            const self = this;
            self.showPopup = false;
             if(ret.result == 'success'){
                  self.paymentItem.orderStatus = '20'
                  self.paymentItem.orderStatusText = '待准备'
             }
             modal.toast({message:ret.data,duration: 0.3})
        },
        paymentProgress: function (event){
            switch (event.option) {
                case 1:
                    this.loading = true
                    break;
                case 2:
                    this.loading = false
                    break; 
                case 3:
                    
                    break;
                default:
                    break;
            }

        },
    }
}
</script>

<style scoped>
.wrapper { 
    align-items: center;
}
.list {
    width: 750px;
    flex: 1;
    background-color: #f2f3f4;
}
.cell-content {
    background-color: #ffffff;
    border-bottom-color: #f2f2f2;
    border-bottom-width: 20px;
    padding: 24px;
}
.content-top {
    flex-direction: row;
    justify-content: space-between;
    border-bottom-color: #dddddd;
    border-bottom-width: 2px;
    padding-bottom: 24px;
}
.content-bottom {
    flex-direction: row;
    align-items: center;
    justify-content: space-between;
    padding-top: 24px;
}

.address-text {
    font-size: 30px;
    color: #666666;
}
.order-time {
    padding-bottom:24px;
    padding-top:24px;
    font-size: 30px;
    color: #666666;
}
.order-state{
    padding-left:30px;
    font-size: 30px;
    color: #333333;
}

.border-btn {
    padding-top:5px;
    padding-bottom:5px;
    padding-left:10px;
    padding-right:10px;
    border-width:2px;
    border-color:#ff3333;
    border-radius:10px;
    color:#ff3333;
    margin-left:26px;
    font-size: 28px;
}
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
