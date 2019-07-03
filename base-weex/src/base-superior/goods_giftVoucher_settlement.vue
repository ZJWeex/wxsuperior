<template>
    <div class="wrapper">
        <navigation title="提交订单"/>
        <list class="wrapper" v-if="orderInfo">
            <cell class="cell">
                <text style="font-size: 32px; margin-bottom: 8px;">订单详情</text>
                <div v-for="(item,index) in orderInfo.giftCardInfo" :key="index" class="cell-goods-goods row">
                    <text style="text-align: left; color: #333333; font-size: 28px; flex: 7; ">{{item.goodsName}}　{{item.cardAmount}}元</text>
                    <text style="text-align: center; color: #ff0033; font-size: 32px; flex: 1; ">x{{item.goodNum}}</text>
                    <text style="text-align: right; color: #ff0033; font-size: 32px; flex: 2; ">{{item.cardAmount}}</text>
                </div>
                <div class="row" style="justify-content: flex-end;">
                    <text style="color: #333333; font-size: 30px;">订单金额：</text>
                    <text style="text-align: right; color: #ff0033; font-size: 32px;">¥{{orderInfo.totalPrice}}</text>
                </div>
            </cell>

            <cell class="cell">
                <div class="row">
                    <div class="row" style="align-items: center; flex: 1; ">
                        <image style="width:34px;height:34px;" src="/web/assets/sup/sup_cart_redpacket.png"/>
                        <text style="color: #333333; font-size: 30px;">  优惠金额</text>
                    </div>
                    <div class="row" style="justify-content: flex-end; align-items: center; flex: 1; " @click="coupon">
                        <div class="coupon"><text style="color: #ffffff; font-size: 30px; ">0</text></div>
                        <wxc-icon name="more" :icon-style="{color:'#999999',fontWeight: 'bolder'}"></wxc-icon>
                    </div>
                    
                </div>
            </cell>
            <cell class="cell">
                <text style="font-size: 32px; ">订单结算</text>
                <div class="cell-goods-goods row">
                    <text style="text-align: left; color: #333333; font-size: 28px; ">订单金额：</text>
                    <text style="text-align: right; font-size: 28px;">¥{{Number(orderInfo.totalPrice).toFixed(2)}}</text>
                </div>
                 <div class="cell-goods-goods row">
                    <text style="text-align: left; color: #333333; font-size: 28px; ">优惠金额：</text>
                    <text style="text-align: right; font-size: 28px;">¥0.00</text>
                </div>
                 <div  class="cell-goods-goods row">
                    <text style="text-align: left; color: #333333; font-size: 28px; ">应付金额：</text>
                    <text style="text-align: right; color: #ff0033; font-size: 28px;">¥{{Number(orderInfo.totalPrice).toFixed(2)}}</text>
                </div>
            </cell>
            <cell class="cell">
                    <div class="spacebetween-div" @click="confirmPayClick(1)">
                        <div style="flex-direction: row;align-items: center;">
                            <image style="width:48px;height:48px;margin-right: 22px;" src="/web/assets/sup/sup_cart_wechat.png"/>
                            <text style="color:#333333;font-size:28px;">微信支付</text>
                        </div>
                        <div>
                            <wxc-icon name="more" :icon-style="{color:'#999999',fontWeight: 'bolder'}" @wxcIconClicked="confirmPayClick(1)"></wxc-icon>
                        </div>
                    </div>
                    <div style="height:2px;flex:1;background-color:#f0f0f0;"></div>
                    <div class="spacebetween-div" @click="confirmPayClick(2)">
                        <div style="flex-direction: row;align-items: center;">
                            <image style="width:48px;height:48px;margin-right: 22px;" src="/web/assets/sup/sup_cart_alipay.png"/>
                            <text style="color:#333333;font-size:28px;">支付宝支付</text>
                        </div>
                        <div>
                            <wxc-icon name="more" :icon-style="{color:'#999999',fontWeight: 'bolder'}" @wxcIconClicked="confirmPayClick(2)"></wxc-icon>
                        </div>
                    </div>
            </cell>
        </list>
        <wxc-loading :show="showLoading" need-mask='false' type="default"></wxc-loading>

    </div>
</template>

<script>
import navigation from "@/base-superior/components/NavigationBar.vue";
import Fetch from "@/base-superior/Fetch.js";
import Define from "@/base-superior/Define.js";
import { WxcIcon, WxcLoading } from 'weex-ui';

const modal = weex.requireModule("modal");
const storage = weex.requireModule("storage");
var globalEvent = weex.requireModule('globalEvent');

export default {
    components: {navigation, WxcIcon, WxcLoading, },
    data() {
        return {
            goods:null,
            orderInfo: null,
            showLoading: false,
            paytype: null,
            orderIds: null,
            topBecomeActive: false,
        }
    },
    created() {
        var self = this
        storage.getItem('goods_giftVoucher_settlement', event=>{
            if (event.result == 'success') {
                self.goods = JSON.parse(event.data)
                self.queryPreorder()
            }
        })
    },
    methods: {
        queryPreorder(){
            var self = this
            Fetch.post('submitOrderGoodsInfo.json', this.goods, jsonString=>{
                self.orderInfo = JSON.parse(jsonString).obj
            }, fail=>{
                modal.toast({
                    message: fail
                })
            })
        },
        confirmPayClick(paytype){
            this.showLoading = true
            this.paytype = String(paytype)
            if (this.orderIds){
                return this.payment()
            }
            var params = {}
            params.totalPrice = this.orderInfo.totalPrice
            params.goodsId = this.orderInfo.giftCardInfo[0].goodsId

            var cards = []
            this.orderInfo.giftCardInfo.forEach(element => {
                var card = {
                    count: element.goodNum,
                    templateId: element.templateId,
                }
                cards.push(card)
            });
            params.giftCardsVos = cards
            var self = this
            Fetch.request('buyer/submit_superiorOrder_giftCard.json', {'superiorGoodsCarInfoVo': JSON.stringify(params)}, jsonString=>{
                console.log(jsonString)
                var result = JSON.parse(jsonString)
                if (result.op_flag == 'success') {
                    self.orderIds = result.supOrderFormId
                    self.payment()
                } else {
                    modal.toast({
                        message: result.info
                    })
                    self.showLoading = false
                }
            }, fail=>{
                self.showLoading = false
                modal.toast({
                    message: fail
                })
            })
        },
        payment(){
            if (!navigation.isIOS() && !navigation.isAndroid()) {
                modal.toast({
                    message: '暂不支持Web支付'
                })
                navigation.push({url:'order_index.html', title:'订单列表', replace:'true'}, event =>{ });  
                self.showLoading = false
                return 
            }

            var payType = this.paytype
            var orderIds = this.orderIds
            var payTypeStr = '';
            if(payType == 1){
                payTypeStr = 'weChatpay'
            }else if(payType == 2){
                payTypeStr = 'alipay'
            }
            var clientType = "youxuan"
            if(weex.config.env.appName == 'superior'){
                //优选
                clientType = "youxuan"
            }else if(weex.config.env.appName == 'buyer' || weex.config.env.appName == 'IOS-buyer'){
                //消费者普通版
                clientType = "release"
            }else if(weex.config.env.appName == 'IOS-buyer-preview'){
                //消费者抢先版
                clientType = "test"
            }else if(weex.config.env.appName == 'IOS-buyer-pro'){
                //消费者专业版
                clientType = "professional"
            }
            
            var param = {
                payType:payTypeStr,
                orderIdJSON:JSON.stringify(orderIds),
                clientType:clientType,
                orderType:'Superoir'
            };

            const self = this;
            Fetch.request('order_pay_for_superior.json', param, function(response){
                // self.showLoading = false;
                console.log(response)
                var result = JSON.parse(response)
                if(result.op_flag == 'success'){
                    result.payType = payTypeStr
                    //已拉起第三方支付sdk
                    self.topBecomeActive = true;
                    self.addEventListener()
                    if (navigation.isIOS() || navigation.isAndroid()) {
                        weex.requireModule('Payment').Pay(result, function(event){})
                    }
                }else{
                    navigation.push({url:'order_index.html', title:'订单列表', replace:'true'}, event =>{ });  
                    modal.toast({message:result.info})
                }

            },function(err){
                self.showLoading = false;
                navigation.push({url:'order_index.html', title:'订单列表', replace:'true'}, event =>{ });
                modal.toast({message:err,duration: 0.3})
            })
        },
        addEventListener(){
            //iOS支付是否点击顶部返回监听
            var self = this
            globalEvent.addEventListener("WXApplicationDidBecomeActiveEvent", function (e) {
                console.log("WXApplicationDidBecomeActiveEvent");
                //支付回调和应用激活，先后无序；故延时处理
                setTimeout(()=>{
                    if(self.topBecomeActive){
                        self.topBecomeActive = false;
                        navigation.push({url:'order_index.html', title:'订单列表', replace:'true'}, event =>{ }); 
                    }
                },1000);
                self.removeEventListener()
            });
            globalEvent.addEventListener("PayBack", function (event) {
                console.log(event)
                self.topBecomeActive = false;
                //code:0支付成功；1支付失败
                var paystr = '支付成功'
                if (event.code != '0') {
                    paystr = event.msg
                }
                modal.toast({message:paystr})
                navigation.push({url:'order_index.html', title:'订单列表', replace:'true'}, event =>{ });
                self.removeEventListener()
            })
        },
        removeEventListener(){
            globalEvent.removeEventListener('WXApplicationDidBecomeActiveEvent')
            globalEvent.removeEventListener('PayBack')
        },
        coupon(){
            modal.toast({
                    message: '暂不可用优惠券'
            })
        }
    },
}
</script>

<style scoped>
.wrapper{
    width: 750px;
    background-color: white;
}
.cell{
    border-top-width: 10px;
    border-top-color: #f5f5f9;
    padding: 24px;
    width: 750px;
}
.cell-goods-goods{
    justify-content: space-between;
    padding-top: 12px;
    padding-bottom: 12px;
}
.row{
    flex-direction: row;
} 
.coupon{
    background-color: #ff0033; 
    width: 40px; 
    height: 40px;
    align-items: center;
    justify-content: center;
    border-radius: 20px;
}
.spacebetween-div {
    flex-direction: row;
    align-items: center;
    justify-content: space-between;
    padding-top: 16px;
    padding-bottom: 16px;
}
</style>

