<template>
    <scroller class="wrapper">
        <navigation title="充值" />
        <div class="content">
            <image class="topImg" :src=topImg />
            <!-- <text style="font-size:30px;color:#333333;margin-top:20px;">已兑换{{redeemMoney}}元</text> -->
            <div class="redeemCode-div">
                <input type="text" class="input-number" placeholder="输入兑换码" @change="codechange" @input="codeinput" />
            </div>
            <text class="exchange-text" @click="exchange">立即兑换</text>
            <div class="rules-div">
                <image class="ruleBgImg" :src=ruleBgImg />
                <text style="color:#666666; font-size:30px">{{ruleString}}</text>
                <text style="color:#333333; font-size:26px; margin-top:15px">{{serveTel}}</text>
            </div>
        </div>
        <wxc-loading :show="loading" need-mask=false type="default"></wxc-loading>
    </scroller>
</template>

<script>
import { WxcLoading, WxcPartLoading } from "weex-ui";
import Fetch from "@/base-superior/Fetch.js";
import navigation from "@/base-superior/components/NavigationBar.vue";

const modal = weex.requireModule("modal");
const navigator = weex.requireModule('navigator')

export default {
    components: {navigation, WxcLoading, WxcPartLoading },
    data() {
        return {
            loading: false,
            topImg: "/web/assets/accountBalance/exchange_element.png",
            redeemMoney: '666',
            codeText: "",
            ruleBgImg: '',
            ruleString: '兑换规则\n1、请输入邀请码或兑换码进行兑换；\n2、同一个码同一个用户不可重复兑换；',
            serveTel: '如有问题请联系淘菜猫优选客服：\n400-188-5757'
        };
    },
    created() {
        // var str = "1,2,3,4,5,6";
        // var strs= new Array();
        // strs = str.split(","); //字符分割 
        // console.log(strs);
    },
    methods: {
        //兑换码输入
        codechange: function(event) {
            this.codeText = event.value;
            console.log("codeNumber:", event.value);
        },
        codeinput: function(event) {
            this.codeText = event.value;
            console.log("codeNumber:", event.value);
        },
        exchange: function () {
            console.log("立即兑换")
            let enable = this.codeText.length <= 0;
            if (enable) {
                modal.toast({
                    message: "请输入兑换码",
                    duration: 0.5
                })
            }
            if (enable) return;

            this.loading = true;
            var param = {exchangeCode: this.codeText};
            const self = this;
            Fetch.post(
                "buyer/userCardExchangeOperation.json",
                param,
                function(jsonString) {
                    self.loading = false;
                    //   modal.alert({message:jsonString})
                    var result = JSON.parse(jsonString);
                    if (result.op_flag === "success") {
                        // 兑换成功-发全局通知
                        const redeemCodeChannel = new BroadcastChannel("redeemCodeSuccess");
                        redeemCodeChannel.postMessage("redeemCodeSuccess");
                        console.log("兑换结果", result)
                        var spromptStr = "恭喜您，兑换成功！"+"\n"+"账户余额+"+result.cardAmount
                        if (result.discouponFavorableMoney != "0") {
                            spromptStr = spromptStr + '\n' + '同时获得¥'+result.discouponFavorableMoney+'元优惠券'
                        }
                        modal.alert({
                            message: spromptStr,
                            okTitle: "确定"
                        }, function (value){
                            setTimeout(() => {
                                navigator.pop({
                                    animated: 'true'
                                }, event => {
                                    console.log("结果回调")
                                })
                            }, 500)
                        })
                    } else {
                        modal.toast({
                            message: result.info,
                            duration: 1.0
                        });
                    }
                },
                function(err) {
                    self.loading = false;
                    modal.toast({
                        message:err,
                        duration:0.5
                    })
                }
            );
        }
    }
};
</script>

<style scoped>
.wrapper {
    width: 750px;
    align-items: center;
    background-color: #ffffff;
}
.content {
    width: 750px;
    align-items: center;
    padding-top: 35px;
    padding-left: 25px;
    padding-right: 25px;
    padding-bottom: 25px;
}
.topImg {
    width: 196px;
    height: 145px;
    /* background-color: #f5f5f9; */
}
.redeemCode-div {
    align-items: center;
    border-color: #d9d9d9;
    border-width: 2px;
    border-radius: 10px;
    height: 100px;
    width: 630px;
    margin-top: 70px;
}
.input-number {
    text-align: center;
    font-size: 36px;
    height: 100px;
    flex: 1;
    width: 626px;
    color: #333333;
}
.exchange-text {
    font-size: 36px;
    text-align: center;
    margin-top: 100px;
    height: 100px;
    width: 630px;
    line-height: 100px;
    color: #ffffff;
    background-color: rgb(226, 35, 35);
    border-radius: 10px;
}
.exchange-text:active {
    background-color: rgb(112, 0, 16);
}
.rules-div {
    width: 700px;
    align-items: left;
    margin-top: 55px;
    padding: 35px;
}
.ruleBgImg {
    position: absolute;
    top: 0;
    right: 0;
    bottom: 0;
    left: 0;
    background-color: #f5f5f9;
}
</style>
