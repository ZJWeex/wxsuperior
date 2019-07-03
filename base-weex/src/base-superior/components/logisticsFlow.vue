<!-- 物流轨迹流程图   -->
<template>
    <div :style="styles">
        <OLHComponent :data="data" 
                      :cheakDetail="true" 
                      :mainImg="logInfo.mainImg" 
                      :width="width"
                      @onClick="onClickAction"/>
        <list scroll-direction="vertical" show-scrollbar='false'>
            <cell style="margin-left: -15px;">
                <OLDComponent :data="data" v-if="data"/>
            </cell>
        </list>
        <div class="loading-wrapper" v-if="loading">
            <image class="loading" resize="cover" src="https://img.alicdn.com/tfs/TB1CWnby7yWBuNjy0FpXXassXXa-32-32.gif" />
        </div>
    </div>
</template>

<script>
import OLHComponent from "@/base-superior/components/component_order_logistic_header.vue";
import OLDComponent from "@/base-superior/components/component_order_logistic_detail.vue";
import Fetch from "@/base-superior/Fetch.js";

const modal = weex.requireModule("modal");

export default {
    components: { OLHComponent, OLDComponent },
    props: {
        styles: {
            type: Object,
            default: function() {
                return {};
            }
        },
        logInfo: {
            type: Object,
            default: function() {
                return {
                    logisticCode: "", //物流号
                    mainImg: "" //商品图片URL
                };
            }
        }
    },
    data() {
        return {
            data: {
                State: "", //物流状态:0-待揽收,2-在途中,3-签收，其中如果是2而且Traces是空或者Traces不存在，提示“暂无轨迹更新”，4-问题件，直接显示“暂无轨迹更新”；
                ShipperName: "", //物流名称
                LogisticCode: "", //物流单号
                Traces: [
                    /*{
                                "AcceptStation": "到达：上海青浦区华新镇公司华新工业区服务部 已收件",
                                "AcceptTime": "2017 - 05 - 07 19 : 17 : 18"
                            }*/
                ]
            },
            loading: true,
            width: 670,
        };
    },
    created() {
        this.loadLogisticInfo();
    },
    methods: {
        //加载物流信息
        loadLogisticInfo: function() {
            const self = this;
            var param = { logisticCode: this.logInfo.logisticCode };
            Fetch.post("track/superiorLogisticDetail.json",param,function(respone) {
                    console.log("物流:" + respone);
                    self.loading = false;
                    var result = JSON.parse(respone);
                    if (result.op_flag == "success") {
                        if (
                            result.objs.Traces == undefined ||
                            result.objs.Traces.length == 0
                        ) {
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
                    } else {
                        modal.toast({ message: result.info });
                    }
                },
                function(err) {
                    self.loading = false;
                    modal.toast({ message: err });
                }
            );
        },
        onClickAction:function(){
            this.$emit('onClick',{})
        },
    }
};
</script>

<style scoped>
.list {
    flex: 1;
    width: 670px;
}
.loading-wrapper {
    position: absolute;
    top: 0;
    right: 0;
    bottom: 0;
    left: 0;
    background-color: #fff;
    justify-content: center;
    align-items: center;
}
.loading {
    width: 60px;
    height: 60px;
}
</style>
