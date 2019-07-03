<template>
    <div class='wrapper' @viewappear="viewappear">
        <navigation title="我的订单" :use-default-return='false' 
                    @wxcMinibarLeftButtonClicked="barLeftButtonClicked"/>
        <wxc-tab-page ref="wxc-tab-page"
                :tab-titles="tabTitles"
                :tab-styles="tabStyles"
                title-type="text"
                :tab-page-height="tabPageHeight"
                :needSlider='true'
                wrapBgColor='#fff'
                @wxcTabPageCurrentTabSelected="wxcTabPageCurrentTabSelected">
                <orderList v-for="(item, index) in tabTitles" :key="index"
                            :style="{ height: (tabPageHeight - tabStyles.height) + 'px' }" 
                            :orderType="item.orderType" :ref="'orderList'+index">
                    
                </orderList>
        </wxc-tab-page>
    </div>
</template>

<script>
import {WxcTabPage, Utils, BindEnv } from 'weex-ui';
import navigation from "@/base-superior/components/NavigationBar.vue";
import orderList from "@/base-superior/order_orderList.vue";

const storage = weex.requireModule("storage");
const modal = weex.requireModule('modal');

export default {
    components: { navigation, WxcTabPage, orderList },
    data() {
        return {
            tabTitles:[{title:'全部',orderType:'all'},
                        {title:'待付款',orderType:'order_submit'},//(待付款10）
                        {title:'待发货',orderType:'order_unsend'},//（待发货（待准备：20，准备中：30，部分发货：34））
                        {title:'待收货',orderType:'order_sended'}],//（已发货/待收货（部分发货：34，已发货（配送中）：35，交易完成（已收货、已评价）：40，50））
            tabStyles: {
                        bgColor: '#FFFFFF',
                        titleColor: '#666666',
                        activeTitleColor: '#f52e61',
                        activeBgColor: '#FFFFFF',
                        isActiveTitleBold: false,
                        iconWidth: 0,
                        iconHeight: 0,
                        width: 185,
                        height: 80,
                        fontSize: 28,
                        hasActiveBottom: true,
                        activeBottomColor: '#f52e61',
                        activeBottomHeight: 4,
                        activeBottomWidth: 150,
                        textPaddingLeft: 10,
                        textPaddingRight: 10,
                    },
            tabPageHeight: navigation.pageHeight(false)-1,
            orderType:'',//订单类型
            cuttentIndex:0 //当前索引
        }
    },
    created() {
        var self = this 
        storage.getItem('OrderType', event=>{
            console.log('OrderType:'+event.data)
            var page = Number(event.data);
            if(page == 1){
                // '待付款'
                self.orderType = 'order_submit'
            }else if(page == 2){
                // '待发货'
                self.orderType = 'order_unsend'
            }else if(page == 3){
                // '待收货'
                self.orderType = 'order_sended'
            }else{
                page = 0
                //全部
               self.orderType = 'all'
            }
            
            storage.removeItem('OrderType',event => {})
            //主动触发跳转界面
            self.$refs['wxc-tab-page'].setPage(page,null,false);
        })
        
    },
     mounted: function() {
        console.log("mounted")
    },
    methods: {
        viewappear:function(){
            const self = this;
            //刷新推荐数据
            setTimeout(() => {
                let ref = 'orderList'+self.cuttentIndex;
               let orderListEl = self.$refs[ref][0] 
               if(orderListEl){
                   orderListEl.viewappear()
               }
            }, 100);
            
        },
         wxcTabPageCurrentTabSelected (e) {
            const self = this;
            const index = e.page;
            this.cuttentIndex = index;
            console.log(self.tabTitles[index]);
            /* Unloaded tab analog data request */
            if (!Utils.isNonEmptyArray(self.tabTitles[index])) {
                const tabSelectedChannel = new BroadcastChannel("Order_TabSelected");
                tabSelectedChannel.postMessage(self.tabTitles[index].orderType);

                const refreshCommendGoodsChannel = new BroadcastChannel("refreshCommendGoods");
                 refreshCommendGoodsChannel.postMessage('刷新推荐商品模块');

                setTimeout(() => {
                    Vue.set(self.tabTitles, index, self.tabTitles[index]);
                }, 100);
            }
        },
        wxcPanItemPan (e) {
            if (BindEnv.supportsEBForAndroid()) {
                this.$refs['wxc-tab-page'].bindExp(e.element);
            }
        },
        //返回事件
        barLeftButtonClicked:function(){
            navigation.removeEventListener()
            navigation.pop({pop:true},event=>{});
        },
    }
}
</script>

<style scoped>
.wrapper { 
    width: 750px;
    flex: 1;
}
</style>
