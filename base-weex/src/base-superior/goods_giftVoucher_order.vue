<template>
    <div class='wrapper'>
        <navigation title="订单详情"/>
        <scroller class='wrapper' v-if="orderInfo.orderStatus" :style="{'margin-bottom': (orderInfo.orderStatus && orderInfo.orderStatus != '0' && orderInfo.orderStatus != '8' && orderInfo.orderStatus != '30') ? 140 : 20,}">
            <div>
                <div class="orderStatusZone" v-if="orderInfo.orderStatus != '-10' && orderInfo.orderStatus != '0' && orderInfo.orderStatus != '8'">
                    <div class="row">
                        <div class="orderStatusItem | orderStatusItemSpace" :style="{'background-color': color.color1 }">
                            <text style="color: white; font-size: 24px;"> 待付款</text>
                        </div>
                        <div class="orderStatusItem | orderStatusItemMask" ></div>
                    </div>
                    <div class="row">
                        <div class="orderStatusItem | orderStatusItemSpace" :style="{'background-color': color.color2 }">
                            <text style="color: white; font-size: 24px;"> 待准备</text>
                        </div>
                        <div class="orderStatusItem | orderStatusItemMask"></div>
                    </div>
                    <div class="row">
                        <div class="orderStatusItem | orderStatusItemSpace" :style="{'background-color': color.color3 }">
                            <text style="color: white; font-size: 24px;"> 准备中</text>
                        </div>
                        <div class="orderStatusItem | orderStatusItemMask"></div>
                    </div>
                    <div class="row">
                        <div class="orderStatusItem | orderStatusItemSpace" :style="{'background-color': color.color4 }">
                            <text style="color: white; font-size: 24px;"> 配送中</text>
                        </div>
                        <div class="orderStatusItem | orderStatusItemMask"></div>
                    </div>
                    <div class="row">
                        <div class="orderStatusItem | orderStatusItemSpace" :style="{'background-color': color.color5 }">
                            <text style="color: white; font-size: 24px;"> 已完成</text>
                        </div>
                        <div class="orderStatusItem | orderStatusItemMask"></div>
                    </div>
                </div>
                <div class="orderStatusZone" v-else-if="orderInfo.orderStatus == '0' || orderInfo.orderStatus == '8'">
                    <text style="color: #ff0033; font-size: 24px;" v-if="orderInfo.orderStatus == '0'">已取消</text>
                    <text style="color: #ff0033; font-size: 24px;" v-else>已关闭</text>
                </div>
            </div>
            <div class="featureZone">
                    <div class="row | space-between | topLine" style="padding:20px; padding-right: 30px;" v-for="Goods in orderInfo.supGoodsList" :key="Goods.supGoodsId">
                        <text style="text-align: left; color: #333333; font-size: 28px; flex: 7">{{Goods.supGoodsName}}</text>
                        <text style="text-align: center; color: #ff0033; font-size: 32px; flex: 1; ">x{{Goods.count}}</text>
                        <text style="text-align: right; color: #ff0033; font-size: 32px;flex: 2; ">{{Goods.supStorePrice}}</text>
                    </div>
            </div>
            <div class="featureZone" style="padding: 30px;">
                <text style="font-size: 28px; padding-bottom: 20px;">结算信息</text>

                <div class="settlementItem">
                    <text style="font-size: 28px; color: #666666;">订单金额:</text>
                    <text style="font-size: 26px; color: #666666;">¥{{orderInfo.totalPrice}}</text>
                </div>
                <div class="settlementItem">
                    <text style="font-size: 28px; color: #666666;">优惠金额:</text>
                    <text style="font-size: 26px; color: #fe0034;">-¥{{orderInfo.discountPrice}}</text>
                </div>
                <!-- 第三方支付 -->
                <div class="settlementItem" v-if="orderInfo.payPrice > 0" :style="{'border-top-width': (orderInfo.cardPrice > 0) ? 0 : 1, 'padding-top': 30, 'border-top-color': 'whitesmoke',}">
                    <!-- 支付宝支付 -->
                    <text style="font-size: 28px;" v-if="orderInfo.payName == '支付宝'">支付宝支付:</text>
                    <!-- 微信支付 -->
                    <text style="font-size: 28px;" v-else-if="orderInfo.payName == '微信支付'">微信支付:</text>
                    <!-- 未支付 -->
                    <text style="font-size: 28px;margin-left: 28px;" v-else>{{orderInfo.payName}}:</text>

                    <div style="flex-direction: row;align-items: center;">
                        <image v-if="payTypeIcon.length" style="width:24px; height: 24px;margin-right:5px;" :src='payTypeIcon'/>
                        <!-- 第三方支付金额 -->
                        <text style="font-size: 24px; color: #666666;" v-if="orderInfo.payPrice>0">¥{{orderInfo.payPrice}}</text>
                    </div>
                    
                </div>


                <div style="border-top-width: 1px; margin-top: 15px; padding-top: 30px; padding-bottom: 0px; border-top-color: whitesmoke; align-items: flex-end;">
                    <text style="font-size: 28px;">实付¥{{orderInfo.payablePrice}}</text>
                </div>
            </div>
            <div class="featureZone" style="padding: 30px;">
                <text style="font-size: 28px; padding-bottom: 20px;">订单信息</text>
                
                <div class="row" style="padding-bottom: 15px; padding-top: 15px;">
                    <text style="font-size: 28px; color: #666666;">订单编号:</text>
                    <text style="font-size: 28px; color: #666666; margin-left: 28px;">{{orderInfo.supOrderFormNo}}</text>
                </div>
                  <div class="row" style="padding-bottom: 15px; padding-top: 15px;">
                    <text style="font-size: 28px; color: #666666;">下单时间:</text>
                    <text style="font-size: 28px; color: #666666; margin-left: 28px;">{{orderInfo.addTime}}</text>
                </div>
            </div>
        </scroller>
        <!-- 底部区域 -->
        <div class="bottom-div" v-if="orderInfo.orderStatus && orderInfo.orderStatus != '0' && orderInfo.orderStatus != '8' && orderInfo.orderStatus != '30'">
            <text class="operatorButton" style="color: #666666; border-color: #666666;" v-if="orderInfo.orderStatus == '10' || ((orderInfo.orderStatus == '16' || orderInfo.orderStatus == '20') && orderInfo.hasBdActived=='true' && (!orderInfo.orderType || orderInfo.orderType != '2'))" @click="showAlert(0)">取消订单</text>
            <text class="operatorButton" style="color: #ff0033; border-color: #ff0033;" v-if="orderInfo.orderStatus == '10'" @click="showAlert(1)">立即支付</text>
            
            <text class="giftVoucher" v-else @click="checkCardInfo">查看礼品卡</text>
        </div>

    
        <wxc-loading :show="showLoading"
                :need-mask='true'>
        </wxc-loading>
        <wxc-dialog :title="alert.message"
                :show="alert.showAlert"
                main-btn-color='#ff0033'
                :show-no-prompt="false"
                @wxcDialogCancelBtnClicked="wxcDialogCancelBtnClicked"
                @wxcDialogConfirmBtnClicked="wxcDialogConfirmBtnClicked">
        </wxc-dialog>
        <payPopup :show="isBottomShow"
                  :orderId="orderId"
                  @cancalClick="cancalPopupClick" 
                  @paymentProgress='paymentProgress'
                  @paymentResult="popupPaymentResult"></payPopup>
    </div>
</template>


<script>
import Fetch from '@/base-superior/Fetch.js'
import navigation from "@/base-superior/components/NavigationBar.vue";
import GlobalDefine from '@/base-superior/Define.js'
import { WxcLoading, WxcPopup, WxcDialog, WxcIcon} from 'weex-ui'
import payPopup from "../base-superior/order_orderPayPopup.vue";

const modal = weex.requireModule('modal');
const storage = weex.requireModule('storage');
var globalEvent = weex.requireModule('globalEvent')

export default {
    components: {navigation, WxcLoading, WxcPopup, WxcDialog, WxcIcon, payPopup},
    data() {
        return {
            alert: {
                showAlert: false,
                title:'',
                message: '',
                custom: 0,
            },
            color:{
                color1: 'gray',
                color2: 'gray',
                color3: 'gray',
                color4: 'gray',
                color5: 'gray',
            },
            showLoading: false,
            isBottomShow: false,
            storeIcon: '/web/assets/sup/sup_order_super_storeIcon.png',
            orderId:'',
            orderInfo: {},
            weburl: 'http://www.taocaimall.com',
            totalGoodsNum: '',
            payTypeIcon:'',
            orderStatus: '',
            distanceBottom: 20,
            bottomDivHeight: 120,
            inPayment: false,
        }
    },

    created() {
        var self = this //825538179094585344
        storage.getItem('OrderDetail_OrderId', event=>{
            console.log('event')
            if (event.result == 'success' && event.data!= 'undefined') {
                self.orderId = event.data
                self.showLoading = true
                self.getOrderInfo()
            }
        })
    },
    methods: {
        postnotices: function () {
            var channel = new BroadcastChannel('OperatorOrderStatus');
            channel.postMessage('OperatorOrderStatus');
        },
        getOrderInfo: function () {
            var self = this
            Fetch.post('buyer/querySuperiorOrderForm.json', {'supOrderFormId': self.orderId}, function(jsonString){
                var result = JSON.parse(jsonString)
                console.log(result)
                if(result.op_flag == 'success'){
                    self.orderInfo = result.orderInfo
                    self.initOrderStatus()
                    self.initTotalGoodsCount()
                }else{
                    modal.toast({
                        message: result.info,
                    })
                }
                self.showLoading = false
            }, function(error) {
                modal.toast({
                    message: error,
                })
                self.showLoading = false              
            })
        },
        cancel: function (){
            var self = this
            Fetch.post('buyer/cancelSuperiorOrderForm.json', {supOrderFormId: self.orderId}, function(jsonString){
                var data = JSON.parse(jsonString)
                modal.toast({
                    message: data.info,
                })
                if (data.op_flag == 'success') {
                    self.orderInfo.orderStatus = '0'
                    self.initOrderStatus()
                    self.postnotices()
                }
                self.showLoading = false
            }, function(error){
                modal.toast({
                    message: error,
                })
                self.showLoading = false
            })
        },
        showAlert: function (custom) {
            if (custom == 0) { 
                this.alert.message = "确认取消订单？"
                this.alert.custom = custom;
                this.alert.showAlert = true
            } else {
                this.isBottomShow = true
            }
        },
        wxcDialogCancelBtnClicked: function(){
            this.alert.showAlert = false
        },
        cancalPopupClick: function(){
            this.isBottomShow = false
        },
        wxcDialogConfirmBtnClicked: function(){
            this.alert.showAlert = false
            this.showLoading = true
            this.cancel()
        },
        //支付结果回调
        popupPaymentResult:function(ret){
            this.isBottomShow = false;
            if(ret.result == 'success'){
                this.orderInfo.orderStatus = '50'
                this.orderInfo.payName = ret.payTypeStr
                this.initOrderStatus()
                this.postnotices()
            }
            this.getOrderInfo()
            this.inPayment = false

            this.loading = false
            modal.toast({message:ret.data,duration: 0.3})
            this.removeEventListener()
        },
        paymentProgress: function (event){
            switch (event.option) {
                case 1:
                    this.inPayment = true
                    this.showLoading = true
                    this.addEventListener()
                    break;
                case 2:
                    this.showLoading = false
                    break; 
                case 3:
                    
                    break;
                default:
                    break;
            }

        },
        initOrderStatus: function(){
            //订单状态显示  订单状态 0:已取消 8:后台关闭订单 10待付款 16货到付款 20支付完成-待准备 30准备中  35配送中  40已收货-待评价 50已评价-已完成  108标记已完成  111待修改
            switch (this.orderInfo.orderStatus) {
                case '108': //108标记已完成
                case '50':  //50已评价-已完成
                case '40':  //40已收货-待评价
                    this.color.color5 = 'orangered'
                case '35': //35配送中
                    this.color.color4 = 'orangered'
                case '30':  //30准备中
                    this.color.color3 = 'orangered'
                case '20':  //20支付完成-待准备
                    this.color.color2 = 'orangered'
                case '16':  //16货到付款
                case '10':
                    this.color.color1 = 'orangered'
                default:
                    break;
            }
            console.log('this.orderInfo.payName' + this.orderInfo.payName)
            switch (this.orderInfo.payName) {
                case "微信支付":
                    this.payTypeIcon = '/web/assets/sup/sup_order_order_w.png'
                    break;
                case "支付宝":
                    this.payTypeIcon = '/web/assets/sup/sup_order_order_z.png'
                    break;
                case "优惠抵扣":
                    this.payTypeIcon = '/web/assets/sup/sup_order_exchange_account.png'
                break;
                default:
                    break;
            }
            this.orderStatus = this.orderInfo.orderStatus
        },
        initTotalGoodsCount: function(){
            var that = this
            var num = 0
            that.orderInfo.supGoodsList.forEach(element => {
                num = num + parseInt(element.count);
            });
            that.totalGoodsNum = num.toString();
        },
        checkCardInfo(){
            navigation.push({url: 'exchange_exchangeCard.html', title: '商品兑换'}, event =>{});
        },
        addEventListener(){
            //iOS支付是否点击顶部返回监听
            var self = this
            globalEvent.addEventListener("WXApplicationDidBecomeActiveEvent", function (e) {
                console.log("WXApplicationDidBecomeActiveEvent");
                //支付回调和应用激活，先后无序；故延时处理
                setTimeout(()=>{
                        self.getOrderInfo();
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
    align-items: center;
    background-color: #f5f4f9;
}
.orderStatusZone{
    width: 750px;
    flex-direction: row;
    justify-content: center;
    height: 100px;
    align-items: center;
    background-color: white;
}
.orderStatusItem{
    width: 120px;
    height: 40px;
    background-color: orangered;
    border-top-right-radius: 20px;
    border-bottom-right-radius: 20px;
    align-items: center;
    justify-content: center;
}
.orderStatusItemMask{
    background-color: white; 
    width: 20px; 
    position: absolute; 
    left: 0px; 
    right:0px;
}
.orderStatusItemSpace{
    margin-right: 2px;
    margin-left: 2px;
}
.featureZone{
    width: 720px;
    margin-left: 15px;
    margin-right: 15px;
    margin-top: 20px; 
    background-color: white;
}
.row{
    flex-direction: row;
    align-items: center;
}

.space-between{
    justify-content: space-between;
}
.topLine {
    border-top-width: 1px;
    border-top-color: #f5f4f9;
}
.settlementItem{
    flex-direction: row;
    align-items: center;
    justify-content: space-between;
    padding-bottom: 15px;
    padding-top: 15px;
}
.operatorButton {
    font-size: 28px; 
    padding-top: 5px; 
    padding-bottom: 5px; 
    padding-left: 25px; 
    padding-right: 25px; 
    border-width: 1px; 
    border-radius: 40px; 
    margin-left:15px;
}

.bottom-div{
    flex-direction: row;
    align-items: center;
    width: 750px;
    height: 120px;
    position: absolute;
    left: 0px;
    bottom: 0px;
    justify-content: flex-end;
    padding: 30px;
    background-color: white;
}
.giftVoucher{
    padding-top: 5px; 
    padding-bottom: 5px; 
    padding-left: 25px; 
    padding-right: 25px; 
    border-radius: 10px; 
    font-size: 28px; 
    color: #ffffff; 
    background-color: #cb1b45;
}
</style>
