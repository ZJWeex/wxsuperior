<template>
    <div class='wrapper'>
        <navigation title="物流详情" />
        <div v-if="logisticList.length" style="flex:1;">
            <div class="package-prompt">
                <div class="package-background"></div>
                <text class="package-text">{{logisticCount}}个包裹已发货</text>
            </div>
            <list class="wuliu-list">
                <cell v-for="item in logisticList" :key="item">
                    <div class="package-item" @click="checkItem(item)">
                        <div class="package-status">
                            <text class="package-item-text" :style="{flex:4}" style="color: #ff0033">{{item.stateStr}}</text>

                            <text class="package-item-text" :style="{flex:6}" v-if="item.shipperName&& item.shipperName.length">{{item.shipperName}}:{{item.logisticCode}}</text>
                            <text class="package-item-text" :style="{flex:4}" v-else>配货中</text>
                        </div>
                        <text v-if="Array.isArray(item.traces) && item.traces.length>0" class="package-item-text">{{item.traces[0].acceptStation}}</text>
                        <text v-else class="package-item-text">暂时没有跟踪记录</text>
                        <scroller class="goods-list" scroll-direction='horizontal' show-scrollbar='false'>
                            <div v-for="(goods,index) in item.goods" :key="index">
                                <image class="goods-image" :src='goods.goodImg' @click="checkItem(item)"/>
                            </div>
                            <div style="width: 20px;"></div>
                        </scroller>
                        <text class="package-item-text">共{{item.goods.length}}件商品</text>
                    </div>
                </cell>
            </list>
        </div>
    </div>
</template>

<script>
import navigation from "@/base-superior/components/NavigationBar.vue";
import Fetch from "@/base-superior/Fetch.js";

const modal = weex.requireModule("modal");
const storage = weex.requireModule("storage");

export default {
    components: { navigation },
    data() {
        return {
            logisticList: [],
            logisticCount: 1
        };
    },
    created() {
        var self = this;
        // self.loadLogisticInfo("4697175519693120688");

        storage.getItem('order_logistic_list_OrderID', event=>{
            if (event.result == "success") {
                self.loadLogisticInfo(event.data)
                if(WXEnvironment.platform != 'Web'){
                    storage.removeItem("order_logistic_list_OrderID", {});
                }
            }
        })
    },
    methods: {
        checkItem: function(item) {
            if (!item.logisticCode || item.logisticCode.length == 0) {
                return;
            }
            storage.setItem("Order_logisticCode",item.logisticCode,event => {});
            navigation.push({ url: "order_logistic_detail.html", title: "物流详情" },event => {});
        },
        //加载物流信息
        loadLogisticInfo: function(orderId) {
            const self = this;
            var param = { orderId: orderId };
            Fetch.post("superior/orderLogistsiclist.json",param,function(respone) {
                console.log('orderLogistsiclist:',respone)
                    var result = JSON.parse(respone);
                    if (result.op_flag == "success") {
                        self.logisticList = result.objs;
                        self.logisticCount = result.logisticCount;
                    } else {
                        modal.toast({ message: result.info });
                    }
                },
                function(err) {
                    modal.toast({ message: err });
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
    background-color: #f5f4f9;
}
.package-prompt {
    height: 80px;
    width: 750px;
    justify-content: center;
}
.package-background {
    position: absolute;
    background-color: #ff0033;
    height: 80px;
    width: 750px;
    top: 0;
    left: 0;
    opacity: 0.12;
}
.package-text {
    font-size: 32px;
    margin-left: 30px;
    color: #ff0033;
}
.package-item {
    background-color: #ffffff;
    width: 750px;
    /* height: 330px; */
    margin-bottom: 20px;
    padding-top: 20px;
    padding-left: 30px;
    padding-bottom: 20px;
}
.package-status {
    flex-direction: row;
    justify-content: space-between;
    margin-right: 30px;
}
.wuliu-list {
    width: 750px;
    flex: 1;
}
.goods-list {
    flex-direction: row;
    height: 154px;
    width: 720px;
}
.goods-image {
    width: 200px;
    height: 134px;
    margin-top: 10px;
    margin-right: 10px;
    border-color: #ff0033;
    border-width: 1px;
}
.package-item-text {
    margin-top: 5px;
    margin-bottom: 5px;
    font-size: 32px;
    color: #666666;
}
</style>
