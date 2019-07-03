<template>
        <wxc-mask 
                height='700'
                width="700"
                border-radius="10"
                duration="0"
                mask-bg-color="#FFFFFF"
                :has-animation="false"
                :has-overlay="true"
                :show-close="false"
                :overlay-can-close='false'
                :show="show"
                @wxcMaskSetHidden="wxcMaskSetHidden">
            <div style="padding: 30px;">
                <div class="titleZone" style="height: 80px;">
                    <text style="font-size: 40px;">实物商品兑换卡兑换规则</text>
                </div>
                <div v-for="(item, index) in helper" :key="index">
                    <text class="question" style="font-size: 32px;color: #d0104c;" v-if="index%2 == 0">{{item}}</text>
                    <text class="answer" style="font-size: 28px;margin-bottom: 30px;" v-else>{{item}}</text>
                </div>
                <wxc-icon name="close" style="position: absolute; right: 15px; top: 15px;" @wxcIconClicked="wxcMaskSetHidden"></wxc-icon>
            </div>
        </wxc-mask>
</template>
<script>
import {WxcMask, WxcIcon} from 'weex-ui';

export default {
    components: {WxcMask, WxcIcon},
    props: {
        show: {
                type: Boolean,
                default: false
            },
    },
    data() {
        return {
            helper:[
                    '1.兑换收货地址怎么填写?',
                    '输入兑换码，弹出地址页面，选择要配送的地址或可以添加新的地址。',
                    '2.怎样兑换成功？',
                    '输入兑换地址，并确认无误，商品完成订单结算。（即完成兑换）',
                    '3.未兑换成功兑换码是否还能使用？',
                    '未兑换成功，兑换码可以一直使用，直至兑换成功。',
                    '4.兑换卡有没有有效期？',
                    '需在卡面有效期之内完成兑换，逾期失效。',
            ],
        }
    },
    created () {

    },
    methods:{
        wxcMaskSetHidden (event) {
            console.log('sadasds')
            this.$emit('wxcMaskSetHidden', {});
        }
    }
}
</script>

<style>
.titleZone{
    height: 80px;
    align-items: center;
    justify-content: center;
}
.question{
    font-size: 32px;
    color: #d0104c;
}
.answer{
    font-size: 28px;
}
</style>
