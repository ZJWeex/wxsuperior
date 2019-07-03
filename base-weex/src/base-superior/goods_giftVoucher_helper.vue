<template>
    <div class="wrapper">
        <navigation title="礼品卡常见问题"/>
        <list class="helper-list">
            <cell class="cell" v-for="(q, index) in helper" :key="index">
                    <text class="cell-q">{{q[0]}}</text>
                    <text class="cell-a">{{q[1]}}</text>
            </cell>
        </list>

    </div>
</template>

<script>
import navigation from "@/base-superior/components/NavigationBar.vue";
import Fetch from "@/base-superior/Fetch.js";
import Define from "@/base-superior/Define.js";

const modal = weex.requireModule("modal");

export default {
    components: {navigation, },
    data() {
        return {
            helper:[
                ['1.如何使用礼品卡？',
                '绑定礼品卡后，按照淘菜猫优选商城正常购物流程操作，在结算页面选择使用余额支付。'],

                ['2.如何赠送礼品卡？',
                '请前往淘菜猫优选商城“我的-全部订单”查看礼品卡订单详情，点击“查看礼品卡：选择“赠送”，通过微信把礼品卡赠送给朋友，朋友领取后直接绑定淘菜猫优选帐号。'],

                ['3.如何绑定礼品卡？',
                '淘菜猫优选商城“我的-全部订单”查看礼品卡订单详情，点击“查看礼品卡”：选择“自己用”，确认之后即可绑定。'],

                ['4.一个礼品卡可以绑定多个淘菜猫优选账号吗？',
                '每个礼品卡只能被一个帐号绑定一次，其他账号将不能再绑定该卡。'],

                ['5.礼品卡支持兑换现金吗？',
                '本卡为不记名卡、不挂失、不计息、不补办、不兑换现金。'],
                
                ['6.购买的礼品卡可以退卡吗？',
                '礼品卡购买7天内，并且礼品卡未绑定淘菜猫优选帐户，可以联系淘菜猫客服办理退卡，依据国家法律规定，在办理退卡时，需要对购卡用户的身份信息进行留存，所以请提供真实身份信息（姓名，身份证号码）。']
            ]
        }
    },
}
</script>

<style scoped>
.wrapper{
    align-items: center;
    width: 750px;
    background-color: white;
}
.helper-list{
    width: 750px;
}
.cell{
    width: 750px;
    border-bottom-width: 1px;
    border-bottom-color: #f0f0f0;
}
.cell-q{
    width: 750px;
    font-size: 36px;
    padding-left: 24px;
    padding-right: 24px;
    padding-top: 24px;
    padding-bottom: 24px;
}
.cell-a{
    width: 750px;
    font-size: 28px;
    padding-left: 24px;
    padding-right: 24px;
    padding-bottom: 30px;
}
</style>
