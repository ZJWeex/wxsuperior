<template>
<!-- 售后/退款列表 -->
    <div class='wrapper'>
        <navigation title="售后/退款"/>
        <list class="list">
            <cell class="cell" v-for="(goods,index) in refundList" :key="index">
                <div class="goods-zone">
                    <image class="goods-img" :src="goods.goodsImage" />
                    <div class="goods-info">
                        <div style="width: 380px;">
                            <text class="goods-name">{{goods.goodsName}}</text>
                            <text class="goods-des">{{goods.aliasName}}</text>
                        </div>
                        <div>
                            <text class="goods-name">¥{{goods.returnPrice}}</text>
                            <text class="goods-count">x{{goods.quantity}}</text>
                        </div>
                    </div>
                </div>
                <div class="info-bar">
                    <image class="refund-icon" src='/web/assets/sup/sup_refund_icon.png' />
                    <text class="refund-text">{{goods.refund}}</text>
                </div>
                <div class="buttom-op-bar">
                    <div class="buttom-op-buttton" @click="checkDetail(goods)">
                        <text class="buttom-op-buttton-text">查看详情</text>
                    </div>
                </div>
            </cell>
        </list>
        <wxc-result type="noGoods" :show="loading==false && refundList.length==0" :custom-set="customSet" :wrap-style="{top:176}" padding-top="232">
        </wxc-result>
    </div>
</template>

<script>
import navigation from "@/base-superior/components/NavigationBar.vue";
import Fetch from "@/base-superior/Fetch.js";
import { WxcResult } from "weex-ui";

const modal = weex.requireModule("modal");
const storage = weex.requireModule("storage");

export default {
    components: { navigation, WxcResult },
    data() {
        return {
            customSet: {
                noGoods: {
                    button: null,
                    content: "暂无售后/退款订单",
                    desc: "",
                    pic: "/web/assets/sup/sup_homeSearch_noData_cry.png"
                }
            },
            refundList: [],
            loading: true
        };
    },
    created() {
        this.loadListData();
    },
    methods: {
        //加载订单列表数据
        loadListData: function() {
            const self = this;
            Fetch.post("superior/afterSaleList.json",{},function(respone) {
                    self.loading = false;
                    var result = JSON.parse(respone);
                    console.log('afterSaleList:',respone)
                    if (result.op_flag == "success") {
                        self.refundList = result.objs;
                    } else {
                        modal.toast({ message: result.info });
                    }
                },
                function(err) {
                    modal.toast({ message: err });
                }
            );
        },
        checkDetail: function(goods) {
            storage.setItem("order_refundGoods_detail",goods.afterSale_id,event => {});
            navigation.push({ url: "order_refundGoods_detail.html", title: "售后/退款" },event => {});
        }
    }
};
</script>

<style scoped>
.wrapper {
    align-items: center;
    background-color: #f5f4f9;
}
.list {
    width: 750px;
}
.cell {
    margin-bottom: 20px;
    background-color: white;
}
.goods-zone {
    margin-top: 30px;
    height: 185px;
    background-color: #fafafa;
    padding-left: 30px;
    padding-right: 30px;
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
    margin-top:20px;
    color: #666666;
    font-size: 24px;
    align-self: flex-end;
}
.info-bar {
    height: 68px;
    border-bottom-width: 1px;
    border-bottom-color: #f0f0f0;
    padding-left: 36px;
    flex-direction: row;
    /* justify-content: center; */
    align-items: center;
}
.refund-icon {
    width: 36px;
    height: 36px;
    margin-right: 20px;
}
.refund-text {
    font-size: 24px;
    color: #333333;
}
.buttom-op-bar {
    height: 110px;
    align-items: flex-end;
    justify-content: center;
    padding-right: 30px;
}
.buttom-op-buttton {
    width: 152px;
    height: 46px;
    border-color: #ff0023;
    border-width: 1px;
    border-radius: 23px;
    align-items: center;
    justify-content: center;
}
.buttom-op-buttton-text {
    color: #ff0023;
    font-size: 28px;
}
</style>
