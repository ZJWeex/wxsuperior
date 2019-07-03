<template>
    <div class='wrapper'>
        <div class="header" :style="{width:width}" @click="goLogisticDetailClicked">
            <image class="header-background" src='/web/assets/sup/sup_order_logistic_headbg.png' />
            <div class="status-zone">
                <image class="status-image" v-if="data.State=='0'" src='/web/assets/sup/sup_order_logistic_transport.png' />
                <image class="status-image" v-else-if="data.State=='3'" src='/web/assets/sup/sup_order_logistic_sign.png' />
                <image class="status-image" v-else-if="data.State=='1'" src='/web/assets/sup/sup_order_logistic_took.png' />
                <text class="status-text" v-if="data.State=='0'">在途中</text>
                <text class="status-text" v-else-if="data.State=='3'">已签收</text>
                <text class="status-text" v-else-if="data.State=='1'">待揽收</text>
                <text class="status-text" v-else>{{data.orderStatus}}</text>
            </div>
            <div class="header-info" :style="{width:width}">
                <image class="img" :src="mainImg" />
                <div style="flex-direction: row;align-items: center;justify-content: space-between;">
                    <div v-if="data.LogisticCode" class="header-right">
                        <div>
                            <text class="info-text" :style="{width:width-260}">{{data.goodsName}}</text>
                            <text class="info-text">共{{data.number}}件</text>
                        </div>
                        <text class="info-text" :style="{lines:2}">{{data.ShipperName}}:{{data.LogisticCode}}</text>
                    </div>
                    <wxc-icon v-if="cheakDetail" name="more" :icon-style="{color:'#fff'}" @wxcIconClicked="goLogisticDetailClicked"></wxc-icon>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import { WxcIcon } from 'weex-ui';
import Fetch from "@/base-superior/Fetch.js";

export default {
    components: { WxcIcon },
    props: {
        data: {
            type: Object,
            default: null
        },
        mainImg: {
            type: String
        },
        width: {
            type: Number,
            default: 750
        },
        cheakDetail:{
            type:Boolean,
            default:false
        }
    },
    data() {
        return {
            
        }
    },
    created() {

    },
    methods:{
        goLogisticDetailClicked:function(){
            if(!this.cheakDetail)return;
            this.$emit('onClick',{})
        }
    }
    
};
</script>

<style scoped>
.header {
    height: 240px;
}
.header-background {
    height: 235px;
    position: absolute;
    left: 0;
    right: 0;
    top: 0;
    border-top-left-radius: 20px;
    border-top-right-radius: 20px;
}
.status-zone {
    height: 80px;
    flex-direction: row;
    justify-content: center;
    align-items: center;
}
.status-image {
    height: 40px;
    width: 40px;
    margin-right: 20px;
}
.status-text {
    color: #ffffff;
    font-size: 36px;
}
.header-info {
    padding-left: 40px;
    padding-right: 40px;
    flex-direction: row;
    align-items: center;
}
.img {
    border-width: 2px;
    border-radius: 5px;
    border-color: #f0f0f0;
    width: 150px;
    height: 110px;
}
.header-right {
    /* height: 120px; */
    flex: 1;
    padding-left: 20px;
}
.info-text {
    color: #ffffff;
    font-size: 28px;
    lines:1;
    text-overflow: ellipsis;
}
</style>
