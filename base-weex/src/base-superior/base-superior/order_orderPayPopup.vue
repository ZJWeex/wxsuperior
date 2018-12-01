<template>
    <wxc-popup popup-color="#f2f2f2" 
               :show="show" 
               @wxcPopupOverlayClicked="popupOverlayBottomClick" 
               pos="bottom" 
               height="360">
        <div class="content">
            <div class="title-div">
                <text style="font-size: 28px;color:#333333;">支付方式</text>
            </div>
            <div class="spacebetween-div" @click="payClick(1)">
                <div style="flex-direction: row;align-items: center;">
                    <image style="width:68px;height:68px;margin-right: 22px;" src="/web/assets/carticon/cart_wechat.png"/>
                    <text style="color:#333333;font-size:28px;">微信支付</text>
                </div>
                <div>
                    <wxc-icon name="more" :icon-style="{color:'#999999',fontWeight: 'bolder'}"></wxc-icon>
                </div>
            </div>
            <div style="height:2px;flex:1;background-color:#e9e9e9;"></div>
            <div class="spacebetween-div" @click="payClick(2)">
                <div style="flex-direction: row;align-items: center;">
                    <image style="width:68px;height:68px;margin-right: 22px;" src="/web/assets/carticon/cart_alipay.png"/>
                    <text style="color:#333333;font-size:28px;">支付宝支付</text>
                </div>
                <div>
                    <wxc-icon name="more" :icon-style="{color:'#999999',fontWeight: 'bolder'}"></wxc-icon>
                </div>
            </div>
        </div>
    </wxc-popup>
</template>

<script>
import { WxcPopup, WxcIcon } from 'weex-ui';
import Fetch from "@/base-superior/Fetch.js";

const Payment = weex.requireModule('Payment')
const modal = weex.requireModule('modal');

export default {
    components: { WxcPopup, WxcIcon },
    props:{
        show:{
            type: Boolean,
            default:false
        },
        orderId:{
            type: String,
            default:''
        }
    },
    data() {
        return {

        }
    },
    created() {

    },
    methods: {
        popupOverlayBottomClick:function(event){
            this.$emit('cancalClick', event);
        },
        payClick:function(payType){
            this.popupOverlayBottomClick()
            const self = this;
            self.$emit('paymentProgress', {option: 1, des: '获取支付信息'});

            var payTypeStr = '';
            if(payType == 1){
                payTypeStr = 'weChatpay'
            }else if(payType == 2){
                payTypeStr = 'alipay'
            }
            var paras = {}

            paras.payType = payTypeStr
            paras.orderIdJSON = '["'+this.orderId + '"]'
            paras.clientType = 'youxuan'
            paras.orderType = 'Superoir'

            Fetch.request('order_pay_for_superior.json', paras, function(jsonString){
                self.$emit('paymentProgress', {option: 2, des: '拉起第三方支付'});

                var data = JSON.parse(jsonString)
                data.payType = payTypeStr
                if (WXEnvironment.platform === 'android' || WXEnvironment.platform === 'iOS') {
                     weex.requireModule('Payment').Pay(data, function(event){
                        if (event.code == '0') {
                            var ret = {
                                reslut:'success',
                                data:"支付成功",
                                payType: payTypeStr,
                            }
                            self.$emit('paymentResult', ret);
                        }else{
                            var ret = {
                                reslut:'fail',
                                data: event.msg,
                                payType: payTypeStr,
                            }
                            self.$emit('paymentResult', ret);
                        }
                     })
                }else{
                    modal.toast({message:'web不支持'})
                    self.$emit('paymentProgress', {option: 3, des: '暂不支持H5拉起支付'});
                }
                
            }, function(error){
                var ret = {
                                reslut:'fail',
                                data: event.msg,
                            }
                self.$emit('paymentResult', ret);
            })
        },
    }
}
</script>

<style scoped>
.content {
    padding-left: 22px; 
    padding-right: 22px;
    padding-top: 22px;
}
.title-div {
    padding-bottom: 22px;
    border-bottom-color: #e0e0e0;
    border-bottom-width: 2px;
}
.spacebetween-div {
    flex-direction: row;
    align-items: center;
    justify-content: space-between;
    height: 120px;
}
</style>
