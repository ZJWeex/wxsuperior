<template>
    <div class='wrapper'>
        <navigation title="订单详情"/>
        <scroller class='wrapper' :style="{'margin-bottom': (orderInfo.orderStatus && orderInfo.orderStatus != '0')?140:20,}" v-if="orderInfo.orderStatus">
            <div>
                <div class="orderStatusZone" v-if="orderInfo.orderStatus != '-10' && orderInfo.orderStatus != '0'">
                    <div class="row">
                        <div class="orderStatusItem | orderStatusItemSpace" :style="{'background-color': color.color1 }">
                            <text style="color: white; font-size: 24"> 待付款</text>
                        </div>
                        <div class="orderStatusItem | orderStatusItemMask" ></div>
                    </div>
                    <div class="row">
                        <div class="orderStatusItem | orderStatusItemSpace" :style="{'background-color': color.color2 }">
                            <text style="color: white; font-size: 24"> 待准备</text>
                        </div>
                        <div class="orderStatusItem | orderStatusItemMask"></div>
                    </div>
                    <div class="row">
                        <div class="orderStatusItem | orderStatusItemSpace" :style="{'background-color': color.color3 }">
                            <text style="color: white; font-size: 24"> 准备中</text>
                        </div>
                        <div class="orderStatusItem | orderStatusItemMask"></div>
                    </div>
                    <div class="row">
                        <div class="orderStatusItem | orderStatusItemSpace" :style="{'background-color': color.color4 }">
                            <text style="color: white; font-size: 24"> 配送中</text>
                        </div>
                        <div class="orderStatusItem | orderStatusItemMask"></div>
                    </div>
                    <div class="row">
                        <div class="orderStatusItem | orderStatusItemSpace" :style="{'background-color': color.color5 }">
                            <text style="color: white; font-size: 24"> 已完成</text>
                        </div>
                        <div class="orderStatusItem | orderStatusItemMask"></div>
                    </div>
                </div>
                <div class="orderStatusZone" v-else-if="orderInfo.orderStatus == '0'">
                    <text style="color: #ff0033; font-size: 24">已取消</text>
                </div>
            </div>
            <div class="featureZone">
                <div class="row | space-between" style="padding:25px; padding-bottom: 15px;">
                    <div class="row">
                        <image style="width:42px; height: 42px;" :src='storeIcon'/>
                        <text style="margin-left: 10px; font-size: 28px; color: #333333">{{orderInfo.supplierName}}</text>
                    </div>
                    <text style="font-size: 28px; color: #333333">共{{totalGoodsNum}}件</text>
                </div>
                <div style="padding-bottom: 20px;" v-for="Goods in orderInfo.supGoodsList" :key="Goods.supGoodsId">
                    <div class="row | space-between | topLine" style="padding:20px; padding-right: 30px;">
                        <div class="row">
                            <image style="width:156px; height: 113px; margin-right: 15px;"  :src='Goods.mainImgURL'/>
                            <div class="goodsInfo" style="width: 380px;">
                                <text style="font-size: 30px; color: #333333; lines:1;">{{Goods.supGoodsName}}</text>
                                <text style="font-size: 24px; color: #999999;">{{Goods.supGoodsSpecs}}</text>
                            </div>
                        </div>
                        <div class="goodsInfo" style="align-items: flex-end;">
                            <text style="font-size: 30px; color: #333333">{{Goods.supStorePrice}}</text>
                            <text style="font-size: 24px; color: #999999;">x{{Goods.count}}</text>
                        </div>
                    </div>
                    <div>
                        <div class="AfterSale" v-if="Goods.superiorGoodsAfterSale == 'true'" >
                            <text style="font-size: 24px; color: #999999;">已售后</text>
                        </div>
                    </div>
                </div>
            </div>
            <div class="featureZone" style="padding: 30px;">
                <text style="font-size: 28px; padding-bottom: 20px;">结算信息</text>

                <div class="settlementItem">
                    <text style="font-size: 28px; color: #666666;">订单金额:</text>
                    <text style="font-size: 24px; color: #666666;">￥{{orderInfo.totalPrice}}</text>
                </div>
                <div class="settlementItem">
                    <text style="font-size: 28px; color: #666666;">优惠金额:</text>
                    <text style="font-size: 24px; color: #fe0034;">-￥{{orderInfo.discountPrice}}</text>
                </div>
                <div class="settlementItem">
                    <text style="font-size: 28px; color: #666666;">满减金额:</text>
                    <text style="font-size: 24px; color: #fe0034;">-￥{{orderInfo.minusPrice}}</text>
                </div>
                <div class="settlementItem">
                    <text style="font-size: 28px; color: #666666;">配送金额:</text>
                    <text style="font-size: 24px; color: #666666;">￥{{orderInfo.shipPrice}}</text>
                </div>
                
                <!-- 余额支付 -->
                <div class="settlementItem" v-if="orderInfo.cardPrice > 0" style="border-top-width: 1px; margin-top: 15px; padding-top: 30px; border-top-color: whitesmoke;">
                    <text style="font-size: 28px;">余额支付:</text>
                    <text style="font-size: 24px; color: #666666;">￥{{orderInfo.cardPrice}}</text>
                </div>
                <!-- 未支付？第三方支付 -->
                <div class="settlementItem" v-if="orderInfo.payPrice > 0">
                    <text style="font-size: 28px; margin-left: 28px;">{{orderInfo.payName}}:</text>
                    <div style="flex-direction: row;">
                        <image style="width:32px; height: 32px;" :src='payTypeIcon' v-if="payTypeIcon.length"/>
                        <text style="font-size: 24px; color: #666666;">￥{{orderInfo.payPrice}}</text>
                    </div>
                    
                </div>

                <div style="border-top-width: 1px; margin-top: 15px; padding-top: 30px; padding-bottom: 0px; border-top-color: whitesmoke; align-items: flex-end;">
                    <text style="font-size: 28px;">实付￥{{orderInfo.payablePrice}}</text>
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
                  <div class="row" style="padding-bottom: 15px; padding-top: 15px;">
                    <text style="font-size: 28px; color: #666666; margin-left: 28px;">收货人:</text>
                    <text style="font-size: 28px; color: #666666; margin-left: 28px;">{{orderInfo.trueName}}</text>
                </div>
                <div class="address-row" style="padding-bottom: 15px; padding-top: 15px;">
                    <div>
                        <text style="font-size: 28px; color: #666666;">收货地址:</text>
                        <!-- <text style="font-size: 28px; color: white;">收</text> -->
                    </div>
                    <text style="font-size: 28px; color: #666666; margin-left: 28px; lines:2; width: 500px;">{{orderInfo.addressInfo}}</text>
                </div>
            </div>
        </scroller> 
        <div class="row" v-if="orderInfo.orderStatus && orderInfo.orderStatus != '0'" style="width: 750px;height: 120px; position: absolute;left: 0px; bottom:0px; justify-content: flex-end; padding: 30px; background-color: white;">
            <text class="operatorButton" style="color: #666666; border-color: #666666;" v-if="orderInfo.orderStatus == '10' || ((orderInfo.orderStatus == '16' || orderInfo.orderStatus == '20') && orderInfo.hasBdActived=='true')" @click="showAlert(0)">取消订单</text>
            <text class="operatorButton" style="color: #ff0033; border-color: #ff0033;" v-if="orderInfo.orderStatus == '10'" @click="showAlert(1)">立即支付</text>
            <web ref="webview" style="width: 0px; height: 0px" v-if="orderInfo.orderStatus != '0'" :src='weburl'></web>
            <text class="operatorButton" style="color: #ff0033; border-color: #ff0033;" v-if="(orderInfo.canDelayConfirm=='true' && orderInfo.hadDelay=='false') && (orderInfo.orderStatus == '35' || orderInfo.orderStatus == '108')" @click="showAlert(2)">延迟收货</text>
            <text class="operatorButton" style="color: #ff0033; border-color: #ff0033;" v-if="orderInfo.orderStatus == '35' || orderInfo.orderStatus == '108'" @click="showAlert(3)">确认收货</text>
            
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
            storeIcon: '/web/assets/order/super_storeIcon.png',
            orderId:'',
            orderInfo: {},
            weburl: 'http://www.taocaimall.com',
            totalGoodsNum: '',
            payTypeIcon:'',
            orderStatus: '',
            distanceBottom: 20,
        }
    },
    watch: {
        orderStatus(newStatus, oldStatus) {
            if (this.oldStatus != '' || newStatus != oldStatus) {
                var channel = new BroadcastChannel('OperatorOrderStatus');
                channel.postMessage(newStatus);
            }
        }
    },
    created() {
        var self = this //825538179094585344
        // storage.setItem('OrderDetail_OrderId', '827330664556662784')//825522958814232576  825522732258902016    799319606295171073
        storage.getItem('OrderDetail_OrderId', event=>{
            console.log('event')
            if (event.result == 'success' && event.data!= 'undefined') {
                self.orderId = event.data
                self.getOrderInfo()
                storage.removeItem('OrderDetail_OrderId',event => {})
            }
        })
    },
    methods: {
        getOrderInfo: function () {
            var self = this
            self.showLoading = true
            Fetch.post('buyer/querySuperiorOrderForm.json', {'supOrderFormId': this.orderId}, function(jsonString){
                var result = JSON.parse(jsonString)
                console.log(result)
                self.orderInfo = result.orderInfo
                self.initOrderStatus()
                self.initTotalGoodsCount()
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
            Fetch.post('buyer/cancelSuperiorOrderForm.json', {supOrderFormId: this.orderId}, function(jsonString){
                var data = JSON.parse(jsonString)
                modal.toast({
                    message: data.info,
                })
                if (data.op_flag == 'success') {
                    self.orderInfo.orderStatus = '0'
                    self.initOrderStatus()
                }
                self.showLoading = false
            }, function(error){
                modal.toast({
                    message: error,
                })
                self.showLoading = false
            })
        },
        delay: function (){
            var self = this
            Fetch.post('/buyer/delayConfirmSuperiorOrderForm.json', {supOrderFormId: this.orderId}, function(jsonString){
                var data = JSON.parse(jsonString)
                modal.toast({
                    message: data.info,
                })
                if (data.op_flag == 'success') {
                    self.orderInfo.hadDelay = 'true'
                }
                self.showLoading = false
            }, function(error){
                modal.toast({
                    message: error,
                })
                self.showLoading = false
            })
        },
        confirm: function (){
            var self = this
            Fetch.post('/buyer/confirmSuperiorOrderForm.json', {supOrderFormId: this.orderId}, function(jsonString){
                var data = JSON.parse(jsonString)
                modal.toast({
                    message: data.info,
                })
                if (data.op_flag == 'success') {
                    self.orderInfo.orderStatus = '50'
                    self.initOrderStatus()
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
            switch (custom) {
                case 0:
                this.alert.message = "确认取消订单？"
                    break;
                case 1:
                    this.isBottomShow = true
                    return;
                    break;
                case 2:
                this.alert.message = "确认延迟收货？"
                    break;
                case 3:
                this.alert.message = "我已经收到商品并签收，确认无误？"
                    break;
            }
            this.alert.custom = custom;
            this.alert.showAlert = true
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
            switch (this.alert.custom) {
                case 0:
                    this.cancel()
                    break;
                case 1:
                    break;
                case 2:
                    this.delay()
                    break;
                case 3:
                    this.confirm()
                    break;
            }
        },
        //支付结果回调
        popupPaymentResult:function(ret){
            const self = this;
            self.isBottomShow = false;
             if(ret.result == 'success'){
                self.orderInfo.orderStatus = '20'
                self.orderInfo.payName = ret.payTypeStr
                self.initOrderStatus()
             }
             modal.toast({message:ret.data,duration: 0.3})
        },
        paymentProgress: function (event){
            switch (event.option) {
                case 1:
                    this.showLoading = true
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
            switch (this.orderInfo.payName) {
                case "微信":
                    this.payTypeIcon = '/web/assets/order/order_w.png'
                    break;
                case "支付宝":
                    this.payTypeIcon = '/web/assets/order/order_z.png'
                    break;
                case "余额支付":
                    this.payTypeIcon = '/web/assets/order/exchange_account.png'
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
    width: 20px; position: 
    absolute; left: 0px; 
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
.address-row{
    flex-direction: row;
    align-items: flex-start;
}
.space-between{
    justify-content: space-between;
}
.topLine {
    border-top-width: 1px;
    border-top-color: #f5f4f9;
}
.goodsInfo{
    height: 80px;
    justify-content: space-between;
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
.AfterSale{
    margin-left: 20px;
    width: 100px; 
    align-items: center;
    justify-content: center;
    height: 40px;
    border-radius:20px;
    border-color: #999999;
    border-width: 1px;
}
</style>
