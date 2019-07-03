<template>
    <div class='wrapper'>
        <navigation/>
        <list class="list">
            <cell class="refund-status-zone">
                <text class="refund-status-text">{{goods.refund}}</text>
                <text style="color:#fff;font-size:26px;padding-top:10px;">{{goods.addTime}}</text>
            </cell>
            <cell>
                <div class="refund-amount-total refund-between">
                    <text class="refund-amount-title">退款总金额</text>
                    <text class="refund-amount-value">￥{{goods.returnPrice}}</text>
                </div>
                <div class="refund-amount-detail refund-between">
                    <div>
                        <text class="refund-amount-detail-text">余额退款</text>
                        <text class="refund-amount-detail-text">第三方支付退款</text>
                    </div>
                    <div>
                        <text class="refund-amount-detail-text">￥{{goods.refundCardAmount}}</text>
                        <text class="refund-amount-detail-text">￥{{(goods.returnPrice-goods.refundCardAmount).toFixed(2)}}</text>
                    </div>
                </div>
            </cell>
            <cell class="goods-zone">
                <image class="goods-img" :src="goods.goodsImage" />
                <div class="goods-info">
                    <div style="width: 450px;">
                        <text class="goods-name">{{goods.goodsName}}</text>
                        <text class="goods-des">{{goods.aliasName}}</text>
                    </div>
                    <div>
                        <text class="goods-name"></text>
                        <text class="goods-count">x{{goods.quantity}}</text>
                    </div>
                </div>
            </cell>
            <cell>
                <text class="refund-info">退款原因：{{goods.reason}}</text>
                <text class="refund-info">退款金额：¥{{goods.returnPrice}}</text>
                <text class="refund-info">申请时间：{{goods.addTime}}</text>
                <text class="refund-info">退款编号：{{goods.afterSale_id}}</text>
            </cell>
        </list>
    </div>
</template>

<script>
import navigation from "@/base-superior/components/NavigationBar.vue";
import Fetch from "@/base-superior/Fetch.js";

const modal = weex.requireModule("modal");
const storage = weex.requireModule("storage");
var globalEvent = weex.requireModule("globalEvent");

export default {
    components: { navigation },
    data() {
        return {
            afterSaleId:'',
            goods: {}
        };
    },
    created() {
        var self = this;
        storage.getItem("order_refundGoods_detail", event => {
            if (event.result == "success") {
                self.afterSaleId = event.data;
                console.log('afterSaleId:',self.afterSaleId);
                storage.removeItem("order_refundGoods_detail", {});
                self.loadAfterSaleDeitalData(self.afterSaleId);
            }
        });
    },
    methods: {
        //加载售后详情接口
        loadAfterSaleDeitalData: function(afterSaleId) {
            const self = this;
            var param = {superiorGoodsAfterSale_id : afterSaleId}
            Fetch.post("superior/afterSaleSuperiorGoods.json",param,function(respone) {
                    self.loading = false;
                    console.log('afterSaleSuperiorGoods:',respone)
                    var result = JSON.parse(respone);
                    if (result.op_flag == "success") {
                        self.goods = result.objs[0];
                    } else {
                        modal.toast({ message: result.info });
                    }
                },
                function(err) {
                    modal.toast({ message: err });
                }
            );
        },
    }
};
</script>

<style scoped>
.wrapper {
    align-items: center;
    /* background-color: #f5f4f9; */
}
.list {
    width: 750px;
}
.refund-status-zone {
    background-color: #ff0033;
    height: 185px;
    padding-left: 64px;
    justify-content: center;
}
.refund-status-text {
    color: white;
    font-size: 41px;
}
.refund-amount-zone {
    padding-left: 46px;
    padding-right: 39px;
}
.refund-amount-total {
    height: 102px;
    align-items: center;
    border-bottom-width: 1px;
    border-bottom-color: #ede9ea;
}
.refund-amount-title {
    color: #333333;
    font-size: 39px;
}
.refund-amount-value {
    color: #ff0033;
    font-size: 39px;
}
.refund-amount-detail {
    height: 144px;
    align-items: center;
}
.refund-amount-detail-text {
    color: #666666;
    font-size: 38px;
}
.refund-between {
    padding-left: 46px;
    padding-right: 39px;
    flex-direction: row;
    justify-content: space-between;
}
.goods-zone {
    margin-top: 10px;
    height: 185px;
    background-color: #fafafa;
    padding-left: 36px;
    padding-right: 36px;
    flex-direction: row;
    align-items: center;
}
.goods-img {
    width: 180px;
    height: 122px;
}
.goods-info {
    flex-direction: row;
    justify-content: space-between;
    align-items: center;
    width: 498px;
    height: 122px;
    padding-left: 15px;
}
.goods-name {
    color: #333333;
    font-size: 32px;
}
.goods-des {
    margin-top:20px;
    color: #666666;
    font-size: 24px;
}
.goods-count {
    margin-top:60px;
    color: #666666;
    font-size: 24px;
}
.refund-info {
    margin-top: 26px;
    margin-left: 36px;
    color: #666666;
    font-size: 29px;
}
</style>
