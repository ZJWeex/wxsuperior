<template>
    <wxc-popup  ref='wxcPopup'
                popup-color="#f2f2f2" 
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
                    <image style="width:68px;height:68px;margin-right: 22px;" src="/web/assets/sup/sup_cart_wechat.png"/>
                    <text style="color:#333333;font-size:28px;">微信支付</text>
                </div>
                <div>
                    <wxc-icon name="more" :icon-style="{color:'#999999',fontWeight: 'bolder'}"></wxc-icon>
                </div>
            </div>
            <div style="height:2px;flex:1;background-color:#e9e9e9;"></div>
            <div class="spacebetween-div" @click="payClick(2)">
                <div style="flex-direction: row;align-items: center;">
                    <image style="width:68px;height:68px;margin-right: 22px;" src="/web/assets/sup/sup_cart_alipay.png"/>
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
import { WxcPopup, WxcIcon } from "weex-ui";
import Fetch from "@/base-superior/Fetch.js";

const modal = weex.requireModule("modal");

export default {
    components: { WxcPopup, WxcIcon },
    props: {
        show: {
            type: Boolean,
            default: false
        },
        orderId: {
            type: String,
            default: ""
        }
    },
    data() {
        return {
            payTypeStr: ""
        };
    },
    created() {},
    methods: {
        popupOverlayBottomClick: function(event) {
            this.$emit("cancalClick", event);
        },
        payClick: function(payType) {
            this.$refs.wxcPopup.hide();
            const self = this;
            self.$emit("paymentProgress", { option: 1, des: "获取支付信息" });

            var payTypeStr = "";
            if (payType == 1) {
                payTypeStr = "weChatpay";
            } else if (payType == 2) {
                payTypeStr = "alipay";
            }
            var clientType = "youxuan";
            if (weex.config.env.appName == "superior") {
                //优选
                clientType = "youxuan";
            } else if (
                weex.config.env.appName == "buyer" ||
                weex.config.env.appName == "IOS-buyer"
            ) {
                //消费者普通版
                clientType = "release";
            } else if (weex.config.env.appName == "IOS-buyer-preview") {
                //消费者抢先版
                clientType = "test";
            } else if (weex.config.env.appName == "IOS-buyer-pro") {
                //消费者专业版
                clientType = "professional";
            }

            var paras = {};

            paras.payType = payTypeStr;
            paras.orderIdJSON = '["' + this.orderId + '"]';
            paras.clientType = clientType;
            paras.orderType = "Superoir";

            self.payTypeStr = payTypeStr;

            Fetch.request(
                "order_pay_for_superior.json",
                paras,
                function(jsonString) {
                    var data = JSON.parse(jsonString);
                    if (data.op_flag !== 'success') {
                        var ret = {
                            result: "fail",
                            data: '拉起支付失败，请稍后重试'
                        };
                        self.$emit("paymentProgress", { option: 400, des: ret });
                        self.$emit("paymentResult", ret);
                        return
                    }
                    self.$emit("paymentProgress", {
                        option: 2,
                        des: "拉起第三方支付"
                    });

                    data.payType = payTypeStr;
                    if (
                        WXEnvironment.platform === "android" ||
                        WXEnvironment.platform === "iOS"
                    ) {
                        self.addEventListener();
                        weex.requireModule("Payment").Pay(data, function(
                            event
                        ) {});
                    } else {
                        modal.toast({ message: "暂不支持web支付" });
                        self.$emit("paymentProgress", {
                            option: 3,
                            des: "暂不支持H5拉起支付"
                        });
                    }
                },
                function(error) {
                    var ret = {
                            result: "fail",
                            data: '拉起支付失败，请稍后重试'
                    };
                    self.$emit("paymentResult", ret);
                    self.$emit("paymentProgress", { option: 400, des: error });
                }
            );
        },
        addEventListener() {
            var self = this;
            var globalEvent = weex.requireModule("globalEvent");
            var payType = self.payTypeStr;
            if (payType === "weChatpay") {
                payType = "微信支付";
            } else if (payType === "alipay") {
                payType = "支付宝";
            }
            globalEvent.addEventListener("PayBack", function(event) {
                if (event.code == "0") {
                    var ret = {
                        result: "success",
                        data: "支付成功",
                        payType: payType
                    };
                    self.$emit("paymentResult", ret);
                } else {
                    var ret = {
                        result: "fail",
                        data: event.msg,
                        payType: payType
                    };
                    self.$emit("paymentResult", ret);
                }
                globalEvent.removeEventListener("PayBack");
            });
        }
    }
};
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
