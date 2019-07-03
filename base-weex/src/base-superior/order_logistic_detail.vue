<template>
    <div class='wrapper'>
        <navigation title="物流详情" />
        <div style="flex:1;width:750px;">
            <list style="flex:1;width:750px;">
                <cell>
                    <OLHComponent :data="data" :mainImg="mainImg" />
                </cell>
                <cell>
                    <OLDComponent :data="data" :showAll="false" v-if="data" />
                </cell>
                <cell>
                    <div style="height:18px;background-color:#f5f4f9;flex:1"></div>
                    <CGComponent />
                </cell>
            </list>
        </div>
    </div>
</template>

<script>
import navigation from "@/base-superior/components/NavigationBar.vue";
import OLHComponent from "@/base-superior/components/component_order_logistic_header.vue";
import OLDComponent from "@/base-superior/components/component_order_logistic_detail.vue";
import CGComponent from "@/base-superior/components/commend_goods.vue";

import Fetch from "@/base-superior/Fetch.js";

const modal = weex.requireModule("modal");
const storage = weex.requireModule("storage");

export default {
    components: { navigation, OLHComponent, OLDComponent, CGComponent },
    data() {
        return {
            logisticNumber: "", //物流号
            mainImg: "", //商品图片URL
            data: {
                State: "", //物流状态:0-待揽收,2-在途中,3-签收，其中如果是2而且Traces是空或者Traces不存在，提示“暂无轨迹更新”，4-问题件，直接显示“暂无轨迹更新”；
                ShipperName: "", //物流名称
                LogisticCode: "", //物流单号
                Traces: []
            }
        };
    },
    created() {
        var self = this;
        storage.getItem("Order_logisticCode", event => {
            console.log("物流订单号:", event.data);
            if (event.data && event.data != "undefined") {
                var logisticCode = event.data;
                self.logisticNumber = logisticCode;
                self.loadLogisticInfo();
                if(WXEnvironment.platform.toLowerCase() != 'web'){
                    storage.removeItem('Order_logisticCode',event => {})
                }
            }
        });
    },
    methods: {
        //加载物流信息
        loadLogisticInfo: function() {
            const self = this;
            var param = { logisticCode: this.logisticNumber };
            Fetch.post(
                "track/superiorLogisticDetail.json",
                param,
                function(respone) {
                    console.log("物流:" + respone);
                    var result = JSON.parse(respone);
                    if (result.op_flag == "success") {
                        if (result.objs.Traces == undefined ||result.objs.Traces.length == 0) {
                            result.objs.Traces = [
                                {
                                    AcceptStation: "暂无轨迹更新",
                                    AcceptTime: ""
                                }
                            ];
                        }
                        let addressInfo ={
                            AcceptStation: result.objs.address,
                            AcceptTime: ""
                        }
                        result.objs.Traces.splice(0,0,addressInfo)
                        self.data = result.objs;
                        self.mainImg = result.objs.mainImgURL;
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
    align-items: center;
    background-color: white;
}
.list {
    width: 750px;
    flex: 1;
}
.header {
    flex-direction: row;
    align-items: center;
    justify-content: space-between;
    border-bottom-width: 2px;
    border-bottom-color: #f0f0f0;
}
.header-left {
    flex-direction: row;
    align-items: center;
    flex: 1;
}
.img {
    border-width: 2px;
    border-radius: 5px;
    border-color: #f0f0f0;
    width: 150px;
    height: 110px;
    margin-left: 24px;
    margin-top: 24px;
    margin-bottom: 24px;
    margin-right: 10px;
}
.cell-content {
    width: 750px;
}
.point {
    position: absolute;
    top: 20px;
    left: 22px;
    width: 16px;
    height: 16px;
    border-radius: 8px;
    background-color: #dddddd;
}
.des-info {
    color: #999999;
    font-size: 28px;
    padding: 10px;
}
.des-highlight {
    color: #31b70d;
    font-size: 28px;
    padding: 10px;
}
.point-highlight {
    top: 20px;
    left: 18px;
    width: 24px;
    height: 24px;
    border-radius: 12px;
    background-color: #31b70d;
    border-width: 4px;
    border-color: rgb(49, 246, 13);
    /* justify-content: space-around */
    position: absolute;
}
.footer {
    height: 40px;
}
.path-class {
    align-items: center;
    width: 60px;
    top: 0px;
    bottom: 0px;
    position: absolute;
    background-color: white;
    overflow: hidden;
}
.path-info {
    position: relative;
    width: 666px;
    margin-left: 60px;
    /* margin-right:24px; */
    border-bottom-width: 2px;
    border-bottom-color: #f9f9f9;
}
.path-line {
    width: 2px;
    background-color: #f0f0f0;
    margin-top: 40px;
    height: 222px;
}
</style>
