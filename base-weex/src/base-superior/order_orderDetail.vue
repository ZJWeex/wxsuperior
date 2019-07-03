<template>
    <div class='wrapper'>
        <scroller class='scroller' @scroll="onScroll" 
                v-if="orderInfo.orderStatus" :style="{bottom: (orderInfo.orderStatus && orderInfo.orderStatus != '0' && orderInfo.orderStatus != '8' && orderInfo.orderStatus != '30') ? 120 : 2,}">
            <div class="header">
                <image class="header-bg" ref="headerBg" src="/web/assets/sup/sup_order_header.png"/>
                <div class="navclass" :style="{'margin-top':statusBarH}">
                    <wxc-icon name="back" :icon-style="{color:'#fff'}" @wxcIconClicked="navBackClicked"></wxc-icon>
                    <text style="color:#fff;font-size:36px;" @click="navBackClicked">订单详情</text>
                </div>
                <text style="color:#fff;font-size:36px;margin-top:20px;margin-left:70px;">{{getOrderStatusCong(orderInfo).stateText}}</text>
                <image class="statusImg" :src="getOrderStatusCong(orderInfo).stateImg"/>
            </div>
            <!-- 物流信息 -->
            <div v-if="getOrderStatusCong(orderInfo).logText.length>0" class="logistic-info" @click="cheackLogisticInfo(orderInfo.logistCount)">
                <image style="width:50px;height:50px;margin:20px;" resize="contain" :src="getOrderStatusCong(orderInfo).logImg" />
                <div style="flex:1;">
                    <text style="color:#2588f7;font-size:28px;">{{getOrderStatusCong(orderInfo).logText}}</text>
                    <text v-if="orderInfo.logisticTime" style="color:#999999;font-size:24px;padding-top:20px;">{{orderInfo.logisticTime}}</text>
                </div>
                 <wxc-icon v-if="getOrderStatusCong(orderInfo).isAction" name="more" :icon-style="{color:'#999999'}" @wxcIconClicked="cheackLogisticInfo(orderInfo.logistCount)"></wxc-icon>
            </div>
            <!-- 修改地址 -->
            <div class="change-address" @click="changeAddressClick">
                <image style="width:58px;height:51px;margin:20px;" src="/web/assets/sup/sup_order_weizhi.png" />
                <div style="flex:1;">
                    <text style="color:#666666;font-size:28px;">{{orderInfo.trueName}}  {{orderInfo.telephone}}</text>
                    <text style="color:#999999;font-size:24px;padding-top:20px;">{{orderInfo.addressInfo}}</text>
                </div>
                <wxc-icon v-if="orderInfo.orderStatus==10" name="more" :icon-style="{color:'#999999'}" @wxcIconClicked="changeAddressClick"></wxc-icon>
                <div v-else style="width:30px"></div>
            </div>
            <!-- 订单编号 -->
            <div class="order-info">
                <text style="color:#666666;font-size:24px;">订单编号:{{orderInfo.supOrderFormNo}}</text>
                <text style="color:#999999;font-size:24px;">{{orderInfo.addTime}}</text>
            </div>
            <!-- 订单商品信息 -->
            <div v-if="orderInfo.result&&Object.keys(orderInfo.result).length>0">
                <!-- 全场模版 -->
                <div v-if="orderInfo.result.otherList.length>0">
                    <div style="flex-direction: row; align-items: center;background-color:#ffffff;padding-right:36px;padding-left:36px;padding-top:20px;padding-bottom:20px;justify-content: space-between;">
                        <text style="color:#666666;font-size:30px;"></text>
                        <text v-if="orderInfo.result.otherFee>0" style="color:#666666;font-size:28px;">运费{{orderInfo.result.otherFee}}元，实付{{orderInfo.result.otherPrice}}元包邮</text>
                        <text v-else style="color:#666666;font-size:28px;">已包邮</text>
                    </div>
                    <div class="goods-content">
                        <div class="goods" v-for="Goods in orderInfo.result.otherList" :key="Goods.supGoodsId">
                            <div style="flex-direction: row; align-items: center;">
                                <image :style="{marginBottom:Goods.superiorGoodsAfterSale=='true'?0:26}" style="width:180px;height:120px;margin-left:26px;margin-right:26px;margin-top:26px;background-color:#fff;" :src='Goods.mainImgURL'/>
                                <div style="flex:1;margin-right:26px;">
                                    <div style="flex-direction: row;justify-content: space-between;">
                                        <text style="color:#333333;font-size:32px;width:380px;">{{Goods.supGoodsName}}</text>
                                        <text style="color:#333333;font-size:32px;">¥{{Goods.supStorePrice}}</text>
                                    </div>
                                    <div style="flex-direction: row;justify-content: space-between;padding-top:5px;">
                                        <text style="color:#666666;font-size:24px;width:380px;">{{Goods.supGoodsSpecs}}</text>
                                        <text style="color:#666666;font-size:24px;">x{{Goods.count}}</text>
                                    </div>
                                </div>
                            </div>
                            <div v-if="Goods.superiorGoodsAfterSale == 'true'" style="flex-direction: row;justify-content: flex-end;" @click="refundClick(Goods)">
                                <text v-if="Goods.refund==1" style="height:46px;color:#ff0033;font-size:28px;border-radius: 23px;border-color: #ff0033;border-width: 1px;padding-left:20px;padding-right:20px;margin-bottom:20px;margin-right:40px;">退款中</text>
                                <text v-else-if="Goods.refund==2" style="height:46px;color:#ff0033;font-size:28px;border-radius: 23px;border-color: #ff0033;border-width: 1px;padding-left:20px;padding-right:20px;margin-bottom:20px;margin-right:40px;">退款成功</text>
                            </div>
                        </div>
                    </div>
                </div>
                <!-- 组合模版 -->
                <div v-for="(group,index) in orderInfo.result.groups" :key="index">
                    <div style="flex-direction: row; align-items: center;background-color:#ffffff;padding:36px;justify-content: space-between;">
                        <text style="color:#666666;font-size:30px;">{{group.templateName}}</text>
                        <text v-if="group.groupingFee>0" style="color:#666666;font-size:28px;">运费{{group.groupingFee}}元，实付{{group.templatePrice}}元包邮</text>
                        <text v-else style="color:#666666;font-size:28px;">已包邮</text>
                    </div>
                    <div class="goods-content">
                        <div class="goods" v-for="Goods in group.goodsList" :key="Goods.supGoodsId">
                            <div style="flex-direction: row; align-items: center;">
                                <image :style="{marginBottom:Goods.superiorGoodsAfterSale=='true'?0:26}" style="width:180px;height:120px;margin-left:26px;margin-right:26px;margin-top:26px;background-color:#fff;" :src='Goods.mainImgURL'/>
                                <div style="flex:1;margin-right:26px;">
                                    <div style="flex-direction: row;justify-content: space-between;">
                                        <text style="color:#333333;font-size:32px;width:380px;">{{Goods.supGoodsName}}</text>
                                        <text style="color:#333333;font-size:32px;">¥{{Goods.supStorePrice}}</text>
                                    </div>
                                    <div style="flex-direction: row;justify-content: space-between;padding-top:5px;">
                                        <text style="color:#666666;font-size:24px;width:380px;">{{Goods.supGoodsSpecs}}</text>
                                        <text style="color:#666666;font-size:24px;">x{{Goods.count}}</text>
                                    </div>
                                </div>
                            </div>
                            <div v-if="Goods.superiorGoodsAfterSale == 'true'" style="flex-direction: row;justify-content: flex-end;" @click="refundClick(Goods)">
                                <text v-if="Goods.refund==1" style="height:46px;color:#ff0033;font-size:28px;border-radius: 23px;border-color: #ff0033;border-width: 1px;padding-left:20px;padding-right:20px;margin-bottom:20px;margin-right:40px;">退款中</text>
                                <text v-else-if="Goods.refund==2" style="height:46px;color:#ff0033;font-size:28px;border-radius: 23px;border-color: #ff0033;border-width: 1px;padding-left:20px;padding-right:20px;margin-bottom:20px;margin-right:40px;">退款成功</text>
                            </div>
                        </div>
                    </div>
                </div>
                <!-- 单品模版 -->
                <div v-if="orderInfo.result.singleList.length>0">
                    <div style="flex-direction: row; align-items: center;background-color:#ffffff;padding:36px;justify-content: space-between;">
                        <text style="color:#666666;font-size:30px;">单品</text>
                        <text style="color:#666666;font-size:28px;">已包邮</text>
                    </div>
                    <div class="goods-content">
                        <div class="goods" v-for="Goods in orderInfo.result.singleList" :key="Goods.supGoodsId">
                            <div style="flex-direction: row; align-items: center;">
                                <image :style="{marginBottom:Goods.superiorGoodsAfterSale=='true'?0:26}" style="width:180px;height:120px;margin-left:26px;margin-right:26px;margin-top:26px;background-color:#fff;" :src='Goods.mainImgURL'/>
                                <div style="flex:1;margin-right:26px;">
                                    <div style="flex-direction: row;justify-content: space-between;">
                                        <text style="color:#333333;font-size:32px;width:380px;">{{Goods.supGoodsName}}</text>
                                        <text style="color:#333333;font-size:32px;">¥{{Goods.supStorePrice}}</text>
                                    </div>
                                    <div style="flex-direction: row;justify-content: space-between;padding-top:5px;">
                                        <text style="color:#666666;font-size:24px;width:380px;">{{Goods.supGoodsSpecs}}</text>
                                        <text style="color:#666666;font-size:24px;">x{{Goods.count}}</text>
                                    </div>
                                </div>
                            </div>
                            <div v-if="Goods.superiorGoodsAfterSale == 'true'" style="flex-direction: row;justify-content: flex-end;" @click="refundClick(Goods)">
                                <text v-if="Goods.refund==1" style="height:46px;color:#ff0033;font-size:28px;border-radius: 23px;border-color: #ff0033;border-width: 1px;padding-left:20px;padding-right:20px;margin-bottom:20px;margin-right:40px;">退款中</text>
                                <text v-else-if="Goods.refund==2" style="height:46px;color:#ff0033;font-size:28px;border-radius: 23px;border-color: #ff0033;border-width: 1px;padding-left:20px;padding-right:20px;margin-bottom:20px;margin-right:40px;">退款成功</text>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <!-- 老订单显示布局 -->
            <div v-else class="shopping-header">
                <div class="goods-content">
                    <div class="goods" v-for="Goods in orderInfo.supGoodsList" :key="Goods.supGoodsId">
                        <div style="flex-direction: row; align-items: center;">
                            <image :style="{marginBottom:Goods.superiorGoodsAfterSale=='true'?0:26}" style="width:180px;height:120px;margin-left:26px;margin-right:26px;margin-top:26px;background-color:#fff;" :src='Goods.mainImgURL'/>
                            <div style="flex:1;margin-right:26px;">
                                <div style="flex-direction: row;justify-content: space-between;">
                                    <text style="color:#333333;font-size:32px;width:380px;">{{Goods.supGoodsName}}</text>
                                    <text style="color:#333333;font-size:32px;">¥{{Goods.supStorePrice}}</text>
                                </div>
                                <div style="flex-direction: row;justify-content: space-between;padding-top:5px;">
                                    <text style="color:#666666;font-size:24px;width:380px;">{{Goods.supGoodsSpecs}}</text>
                                    <text style="color:#666666;font-size:24px;">x{{Goods.count}}</text>
                                </div>
                            </div>
                        </div>
                        <div v-if="Goods.superiorGoodsAfterSale == 'true'" style="flex-direction: row;justify-content: flex-end;" @click="refundClick(Goods)">
                            <text v-if="Goods.refund==1" style="height:46px;color:#ff0033;font-size:28px;border-radius: 23px;border-color: #ff0033;border-width: 1px;padding-left:20px;padding-right:20px;margin-bottom:20px;margin-right:40px;">退款中</text>
                            <text v-else-if="Goods.refund==2" style="height:46px;color:#ff0033;font-size:28px;border-radius: 23px;border-color: #ff0033;border-width: 1px;padding-left:20px;padding-right:20px;margin-bottom:20px;margin-right:40px;">退款成功</text>
                        </div>
                    </div>
                </div>
            </div>
            <!-- 结算信息 -->
            <div class="settlement-info" style="padding: 30px;">
                <text style="font-size: 28px; padding-bottom: 20px;">结算信息</text>

                <div class="settlementItem">
                    <text style="font-size: 28px; color: #666666;">订单金额:</text>
                    <text style="font-size: 26px; color: #666666;">¥{{orderInfo.totalPrice}}</text>
                </div>
                <div class="settlementItem">
                    <text style="font-size: 28px; color: #666666;">优惠金额:</text>
                    <text style="font-size: 26px; color: #fe0034;">-¥{{orderInfo.discountPrice}}</text>
                </div>
                <div class="settlementItem">
                    <text style="font-size: 28px; color: #666666;">配送金额:</text>
                    <text style="font-size: 26px; color: #666666;">¥{{orderInfo.shipPrice}}</text>
                </div>
                <div class="settlementItem">
                    <text style="font-size: 28px; color: #666666;">满减金额:</text>
                    <text style="font-size: 26px; color: #fe0034;">-¥{{orderInfo.minusPrice}}</text>
                </div>
                
                <!-- 余额支付 -->
                <div class="settlementItem" v-if="orderInfo.cardPrice > 0" :style="{'border-top-width': (orderInfo.cardPrice <= 0) ? 0 : 1, 'padding-top': 30, 'border-top-color': 'whitesmoke',}">
                    <!-- 余额支付 -->
                    <text style="font-size: 28px;color: #666666;" v-if="orderInfo.cardPrice > 0">余额支付:</text>
                    <div style="flex-direction: row;align-items: center;">
                        <image style="width:24px; height: 24px;margin-right:5px;" src='/web/assets/sup/sup_order_exchange_account.png'/>
                        <!-- 余额支付金额 -->
                        <text style="font-size: 24px; color: #666666;" v-if="orderInfo.cardPrice > 0">¥{{orderInfo.cardPrice}}</text>
                    </div>
                </div>
                <!-- 第三方支付 -->
                <div class="settlementItem" v-if="orderInfo.payPrice > 0" :style="{'border-top-width': (orderInfo.cardPrice > 0) ? 0 : 1, 'padding-top': 30, 'border-top-color': 'whitesmoke',}">
                    <div :style="{'padding-left': (orderInfo.payName === '支付宝' || orderInfo.payName === '微信支付')?'0px':'28px'}">
                        <!-- 支付宝支付 -->
                        <text style="font-size: 28px;color: #666666;" v-if="orderInfo.payName === '支付宝'" >支付宝支付:</text>
                        <!-- 微信支付 -->
                        <text style="font-size: 28px;color: #666666;" v-else-if="orderInfo.payName === '微信支付'">微信支付:</text>
                        <text style="font-size: 28px;color: #666666;" v-else>{{orderInfo.payName}}:</text>
                    </div>

                    <div style="flex-direction: row;align-items: center;">
                        <image v-if="payTypeIcon.length" style="width:24px; height: 24px;margin-right:5px;" :src='payTypeIcon'/>
                        <!-- 第三方支付金额 -->
                        <text style="font-size: 24px; color: #666666;" v-if="orderInfo.payPrice>0">¥{{orderInfo.payPrice}}</text>
                    </div>  
                </div>
                <div style="flex-direction: row;align-items: center;justify-content: space-between;border-top-width: 1px; margin-top: 15px; padding-top: 30px; padding-bottom: 0px; border-top-color: whitesmoke;">
                    <text style="color:#333333;font-size: 32px;">实付款</text>
                    <text v-if="orderInfo.payablePrice>0" style="color:#ff0033;font-size: 28px;">¥{{orderInfo.payablePrice}}</text>
                    <text v-else style="color:#ff0033;font-size: 28px;">¥0.00</text>
                </div>
            </div>
            <!-- 推荐商品 -->
            <div style="background-color:#fff;">
                <div style="height:18px;background-color:#f5f4f9;flex:1"></div>
                <commendGoods></commendGoods>
            </div>
        </scroller>
        <navigation title="订单详情" :style="{opacity: opacity}"/>
        <!-- 底部区域 -->
        <div class="bottom-div" v-if="orderInfo.orderStatus && orderInfo.orderStatus != '0' && orderInfo.orderStatus != '8' && orderInfo.orderStatus != '30'">
            <text class="operatorButton" style="color: #666666; border-color: #666666;" v-if="orderInfo.orderStatus == '10' || ((orderInfo.orderStatus == '16' || orderInfo.orderStatus == '20') && orderInfo.hasBdActived=='true' && (!orderInfo.orderType || orderInfo.orderType != '2'))" @click="showAlert(0)">取消订单</text>
            <text class="operatorButton" style="color: #ff0033; border-color: #ff0033;" v-if="orderInfo.orderStatus == '10'" @click="showAlert(1)">立即支付</text>
            <web ref="webview" style="width: 0px; height: 0px" v-if="orderInfo.orderStatus != '0'" :src='weburl'></web>
            <text class="operatorButton" style="color: #ff0033; border-color: #ff0033;" v-if="(orderInfo.canDelayConfirm=='true' && orderInfo.hadDelay=='false') && (orderInfo.orderStatus == '35' || orderInfo.orderStatus == '108')" @click="showAlert(2)">延迟收货</text>
            <text class="operatorButton" style="color: #ffa800; border-color: #ffa800;" v-if="orderInfo.orderStatus == '35' || orderInfo.orderStatus == '108'" @click="showAlert(3)">确认收货</text>
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
import commendGoods from "@/base-superior/components/commend_goods.vue";

const modal = weex.requireModule('modal');
const animation = weex.requireModule('animation')
const storage = weex.requireModule('storage');

export default {
    components: {navigation, WxcLoading, WxcPopup, WxcDialog, WxcIcon, payPopup, commendGoods},
    data() {
        return {
            statusBarH:navigation.statusBarHeight(),
            opacity:0,
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
        }
    },
    // watch: {
    //     orderStatus(newStatus, oldStatus) {
    //         if (this.oldStatus != '' || newStatus != oldStatus) {
    //             var channel = new BroadcastChannel('OperatorOrderStatus');
    //             channel.postMessage(newStatus);
    //         }
    //     }
    // },
    created() {
        var self = this 
        //选择地址的回调数据
        const selectAddressChannel = new BroadcastChannel("selectAddressChannel");
        selectAddressChannel.onmessage = function (event){
            console.log("selectAddressChannel："+event.data);
            
            var addressModel = JSON.parse(event.data);
            if(self.orderInfo.addrId&&addressModel.id == self.orderInfo.addrId){

                return;
            }
            self.exchangAddressUpdateOrder(addressModel.id,function(){
                //切换地址后刷新商品数据
                self.getOrderInfo();
            })
            
        };
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
        postnotices: function () {
            var channel = new BroadcastChannel('OperatorOrderStatus');
            channel.postMessage('OperatorOrderStatus');
        },
        getOrderInfo: function () {
            var self = this
            self.showLoading = true
            var param = {
                supOrderFormId: self.orderId,
                newOrOld:"new" //new为新版本weex2.0.4
            }
            Fetch.post('buyer/querySuperiorOrderForm.json', param, function(jsonString){
                var result = JSON.parse(jsonString)
                console.log('querySuperiorOrderForm:',jsonString)
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
                    self.getOrderInfo()
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
        delay: function (){
            var self = this
            Fetch.post('/buyer/delayConfirmSuperiorOrderForm.json', {supOrderFormId: self.orderId}, function(jsonString){
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
            Fetch.post('/buyer/confirmSuperiorOrderForm.json', {supOrderFormId: self.orderId}, function(jsonString){
                var data = JSON.parse(jsonString)
                modal.toast({
                    message: data.info,
                })
                if (data.op_flag == 'success') {
                    self.orderInfo.orderStatus = '50'
                    self.getOrderInfo()
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
        //待支付订单更换地址
        exchangAddressUpdateOrder:function(addressId,block){
            var self = this
            self.showLoading = true;
            var param = {supOrderId: self.orderInfo.supOrderFormId,addrId: addressId}
            Fetch.post('/buyer/exchangAddressUpdateSuperiorOrder.json',param , function(jsonString){
                 self.showLoading = false;
                var result = JSON.parse(jsonString);
                if(result.op_flag == 'success'){
                    block()
                }else{
                    modal.toast({message:result.info})
                }
            }, function(err){
                self.showLoading = false;
                modal.toast({message:err})
            });
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
                this.alert.message = this.orderInfo.notice
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
                self.orderInfo.payName = ret.payType
             }
            self.postnotices()
            self.getOrderInfo()
            this.showLoading = false
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
        //获取订单状态
        getOrderStatusCong:function(order){
            let orderStatus = Number(order.orderStatus)
            // console.log('订单状态：',orderStatus)
            var stateCong = {stateText:'',
                          stateImg:'',
                          logImg:'',
                          logText:'',
                          isAction:false}
                          
            //订单状态显示  订单状态 0:已取消 8:后台关闭订单 10待付款 16货到付款 20支付完成-待准备 30准备中 34部分发货  35配送中  40已收货-待评价 50已评价-已完成  108标记已完成  111待修改
            switch (orderStatus) {
                case 0:
                    stateCong.stateText = '交易取消'
                    stateCong.stateImg = '/web/assets/sup/sup_order_guanbi.png'
                    //无物流信息
                    stateCong.logImg = '/web/assets/sup/sup_personal_yifahuo.png'
                    stateCong.logText = '取消交易-您的订单已取消'
                    break;
                case 8:
                    stateCong.stateText = '交易关闭'
                    stateCong.stateImg = '/web/assets/sup/sup_order_guanbi.png'
                    //无物流信息
                    stateCong.logImg = '/web/assets/sup/sup_personal_yifahuo.png'
                    stateCong.logText = '关闭交易-您的订单退款成功'
                    break;
                case 10:
                    stateCong.stateText = '订单待付款'
                    stateCong.stateImg = '/web/assets/sup/sup_order_daifukuan.png'
                    //无物流信息
                    stateCong.logImg = '/web/assets/sup/sup_personal_yifahuo.png'
                    stateCong.logText = '待付款-您的订单未付款，请点击“及时付款”'
                    stateCong.isAction = true;
                    break;
                case 16:
                    stateCong.stateText = '货到付款'
                    stateCong.stateImg = '/web/assets/sup/sup_order_daifukuan.png'
                    //无物流信息
                    stateCong.logImg = '/web/assets/sup/sup_personal_yifahuo.png'
                    break;
                case 20:
                    stateCong.stateText = '订单待准备'
                    stateCong.stateImg = '/web/assets/sup/sup_order_daizhunbei.png'
                    //无物流信息
                    stateCong.logImg = '/web/assets/sup/sup_personal_yifahuo.png'
                    stateCong.logText = '待准备-您已付款，稍后会给您配货'
                    break;
                case 30:
                    stateCong.stateText = '订单准备中'
                    stateCong.stateImg = '/web/assets/sup/sup_order_zhunbeizhong.png'
                    //物流信息
                    stateCong.logImg = '/web/assets/sup/sup_personal_yilanjian.png'
                    stateCong.logText = '准备中-您的订单配货中，请耐心等待'
                    break;
                case 34:
                    stateCong.stateText = '部分发货中'
                    stateCong.stateImg = '/web/assets/sup/sup_order_bufenfahuo.png'
                    //物流信息
                    stateCong.logImg = '/web/assets/sup/sup_personal_yifahuo.png'
                    if(order.signCount>0){
                        stateCong.logText = '该订单已被拆成'+order.logistCount+'个包裹发出，其中'+order.signCount+'个已签收。点击“查看物流”可查看详情。'
                    }else{
                        stateCong.logText = '该订单已被拆成'+order.logistCount+'个包裹发出，点击“查看物流”可查看详情。'
                    }
                    stateCong.isAction = true;
                    break;
                case 35:
                    stateCong.stateText = '订单配送中'
                    stateCong.stateImg = '/web/assets/sup/sup_order_yifahuo.png'
                    //物流信息
                    stateCong.logImg = '/web/assets/sup/sup_personal_peisongzhong.png'
                    if(order.signCount>0){
                        stateCong.logText = '该订单已被拆成'+order.logistCount+'个包裹发出，其中'+order.signCount+'个已签收。点击“查看物流”可查看详情。'
                    }else{
                        stateCong.logText = '该订单已被拆成'+order.logistCount+'个包裹发出，点击“查看物流”可查看详情。'
                    }
                    stateCong.isAction = true;
                    break;
                case 40:
                    stateCong.stateText = '交易完成'
                    stateCong.stateImg = '/web/assets/sup/sup_order_finish.png'
                    //物流信息
                    stateCong.logImg = '/web/assets/sup/sup_personal_yiqianshou.png'
                    stateCong.logText = '交易完成-您的订单已签收，点击“查看物流”可查看详情。'
                    stateCong.isAction = true;
                    break;
                case 50:
                    stateCong.stateText = '交易完成'
                    stateCong.stateImg = '/web/assets/sup/sup_order_finish.png'
                    //物流信息
                    stateCong.logImg = '/web/assets/sup/sup_personal_yiqianshou.png'
                    stateCong.logText = '交易完成-您的订单已签收，点击“查看物流”可查看详情。'
                    stateCong.isAction = true;
                    break;
                case 108:
                    stateCong.stateText = '交易完成'
                    stateCong.stateImg = '/web/assets/sup/sup_order_finish.png'
                    //物流信息
                    stateCong.logImg = '/web/assets/sup/sup_personal_yiqianshou.png'
                    stateCong.logText = '交易完成-您的订单已签收，点击“查看物流”可查看详情。'
                    stateCong.isAction = true;
                    break;
                default:
                    break;
            }
            return stateCong;
        },
        //查看物流信息
        cheackLogisticInfo:function(count){
            console.log('查看物流信息')
            if(!this.getOrderStatusCong(this.orderInfo).isAction){
                return;
            }
            if(this.orderInfo.orderStatus == 10){
                this.showAlert(1)
            }else{
                if(count>1){
                    //物流列表
                    storage.setItem('order_logistic_list_OrderID',this.orderInfo.orderId,event =>{})
                    navigation.push({url:'order_logistic_list.html', title:'物流详情'}, event =>{});
                }else{
                    //物流详情
                    storage.setItem("Order_logisticCode",this.orderInfo.waybillNumber,event => {});
                    navigation.push({ url: "order_logistic_detail.html", title: "物流轨迹" },event => {});
                }
            }
            
        },
        //修改地址
        changeAddressClick:function(){
            console.log('修改地址')
            //待付款状态才可修改地址
            if(this.orderInfo.orderStatus==10){
                //地址不存在需要传一个空对象
                // storage.setItem('oderSubmit_selectAddress',JSON.stringify(this.addressModel?this.addressModel:{}),event =>{})
                storage.setItem('oderSubmit_selectAddress',JSON.stringify({}),event =>{})
                navigation.push({url:'address_list.html', title:'选择地址'}, event =>{});
            }
        },
        //退款详情
        refundClick:function(goods){
            storage.setItem("order_refundGoods_detail",goods.superiorGoodsAfterSale_id,event => {});
            navigation.push({ url: "order_refundGoods_detail.html", title: "售后/退款" },event => {});
        },
        //滑动事件
        onScroll: function(e){
            var  contentOffset = e.contentOffset;
            console.log('contentOffset:',contentOffset.y)
            if(contentOffset.y>-100){
                this.opacity = 0;
            }else{
                let opacity = (Math.abs(contentOffset.y)-100)/100;
                this.opacity = opacity>1.0 ?1.0 : opacity;
            } 
            if(contentOffset.y >= 0){
                var image = this.$refs.headerBg
                var imgH = 300;//图片指定的高度
                var scale = 1+contentOffset.y/imgH;
                animation.transition(image,{
                    styles:{
                        transform:'scale('+scale+') '+'translateY(-'+contentOffset.y/2+')',
                    },
                },function (){});
            }  
        },
        //自定义导航返回
        navBackClicked:function(){
            navigation.pop({pop:true},event=>{});
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
.scroller {
     width: 750px;
     position: absolute;
     top: 0;
     left: 0;
     right: 0;
}
.header {
    height: 300px;
    width: 750px;
}
.header-bg {
    position: absolute;
    top: 0;
    bottom: 0;
    left: 0;
    right: 0;
}
.navclass {
    flex-direction: row;
    align-items: center;
    height: 88px;
    margin-left: 20px;
}
.statusImg {
    position: absolute;
    width: 374px;
    height: 240px;
    bottom: 0;
    right: 100px;
}

.logistic-info {
    flex-direction: row;
    align-items: center;
    background-color: #ffffff;
    padding-top:30px;
    padding-bottom: 30px;
    border-bottom-color: #f0f0f0;
    border-bottom-width: 2px;
}
.change-address {
    flex-direction: row;
    align-items: center;
    background-color: #ffffff;
    padding-top:30px;
    padding-bottom: 30px;
    border-bottom-color: #f0f0f0;
    border-bottom-width: 1px;
}
.order-info {
    flex-direction: row;
    align-items: center;
    justify-content: space-between;
    padding-left:24px;
    padding-right: 24px;
    padding-top:28px;
    padding-bottom: 20px;
    background-color: #ffffff;
}

.goods{
    margin-bottom: 4px;
    border-bottom-width: 10px;
    border-bottom-color: white;
}
.goods-content{
    background-color: #fafafa;
}

.settlement-info{
    width: 750px;
    margin-top: 20px; 
    background-color: white;
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
.afterSale{
    margin-left: 20px;
    width: 100px; 
    align-items: center;
    justify-content: center;
    height: 40px;
    border-radius: 20px;
    border-color: #999999;
    border-width: 1px;
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
    border-top-width: 20px;
    border-top-color: #f5f4f9;
}
</style>
