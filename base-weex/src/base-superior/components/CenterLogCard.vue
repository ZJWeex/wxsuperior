<!-- 个人中心-物流卡   -->
<template>
<div class="cardwarp" v-if="logisticsList.length>0" :style="{height:height}">
    <div class="reCards" ref="logCard" :style="{height:2*height}">
        <div class="log-card" v-if="showModel" :style="{height:height}" @click="checkLogDetail(showModel)">
            <div style="flex-direction: row;justify-content:space-between;padding-bottom:10px;">
                <text style="color:#666666;font-size:22px;">最新物流</text>
                <text style="color:#666666;font-size:22px;">{{showModel.acceptTime}}</text>
            </div>
            <div style="flex-direction: row;align-items: center;">
                <image style="width:98px;height:66px;background-color:#fff;" :src="showModel.goodsImage"/>
                <div style="margin-left:10px;">
                    <div style="flex-direction: row;align-items: center;">
                        <image style="width:40px;height:40px;" resize="contain" :src="getStatusInfo(showModel).img"/>
                        <text style="color:#3399ff;font-size:22px;margin-left:20px;">{{showModel.statusStr}}  </text>
                    </div>
                    <text style="color:#666666;font-size:20px;width:480px;lines: 1;text-overflow: ellipsis;">{{showModel.acceptStation}}</text>
                </div>
            </div>
        </div>
        <div class="log-card" v-if="hideModel" :style="{height:height}">
            <div style="flex-direction: row;justify-content:space-between;padding-bottom:10px;">
                <text style="color:#666666;font-size:22px;">最新物流</text>
                <text style="color:#666666;font-size:22px;">{{hideModel.acceptTime}}</text>
            </div>
            <div style="flex-direction: row;align-items: center;">
                <image style="width:98px;height:66px;background-color:#fff;" :src="hideModel.goodsImage"/>
                <div style="margin-left:10px;">
                    <div style="flex-direction: row;align-items: center;">
                        <image style="width:40px;height:40px;" resize="contain" :src="getStatusInfo(hideModel).img"/>
                        <text style="color:#3399ff;font-size:22px;margin-left:20px;">{{hideModel.statusStr}}  </text>
                    </div>
                    <text style="color:#666666;font-size:20px;width:480px;lines: 1;text-overflow: ellipsis;">{{hideModel.acceptStation}}</text>
                </div>
            </div>
        </div>
    </div>
    <!-- 蒙层界面 -->
    <div class="mask-all">
        <wxc-overlay v-if="showMask" :show="true" opacity="0.86" 
            :hasAnimation="false"
            @wxcOverlayBodyClicked="wxcOverlayBodyClicked"></wxc-overlay>
        <div class="mask-content" v-if="showMask">
            <!-- 设置轮播图 -->
            <slider class="banner" infinite="true" :index="sliderIndex">
                <div v-for="(item,index) in logisticsList" :key="index" 
                     class="banner-margin">
                     <div class="banner-content">
                         <logisticsFlow :logInfo="{logisticCode:item.logisticCode,mainImg:item.goodsImage}" 
                                        :styles="{position: 'absolute',left: 0,right: 0,top: 0,bottom: 0}" 
                                        @onClick="clickAction"></logisticsFlow>
                     </div>
                </div>
                <indicator v-if="logisticsList.length>1" class="indicator"></indicator>
            </slider>
            <div style="position: absolute;right:60px;top:10px;height:60px;justify-content: center;" @click="lookAllAction">
                <text style="color:#fff;font-size:26px;">查看全部</text>
            </div>
            <div class="xPoint" @click="wxcOverlayBodyClicked">
                <wxc-icon name="close" :icon-style="{color:'#fff'}" @wxcIconClicked="wxcOverlayBodyClicked"></wxc-icon>
            </div>
        </div>
    </div>
</div>
</template>

<script>
import { WxcOverlay,WxcIcon } from 'weex-ui';
import logisticsFlow from "@/base-superior/components/logisticsFlow.vue";
import navigation from "@/base-superior/components/NavigationBar.vue";
const storage = weex.requireModule("storage");
const animation = weex.requireModule('animation')
const modal = weex.requireModule('modal');

export default {
    components: { WxcOverlay,WxcIcon, logisticsFlow },
    props:{
        height:{
            type:Number,
            default:150
        },
        logisticsList:{
            type:Array,
            default:function(){
                return [
                    {
                        id: "885025967796690944",
                        addTime: "2019-04-15 19:55:39",
                        deleteStatus: "false",
                        goodsImage:"",
                        acceptStation: "【上海市】快件离开【五角场】已发往【上海】",
                        acceptTime: "2019-04-15 19:09:58",
                        logisticCode: "640128181947",
                        shipperName: "中通快递",
                        state: "0",//0:在途中;1:已揽收;2:疑难;3:已签收;4:退签;5:同城派送中;6:退回;7:转单; -1:暂无物流信息
                        statusStr: "在途中" //在途中,已签收
                    }
                ]
            }
        },
    },
    data() {
        return {
            timer: null,
            showMask:false,
            //用于交替轮播更新数据
            showModel:null,
            hideModel:null,
            sliderIndex:0,
        }
    },
    created() {
        this.restartTimer()
    },
    mounted: function() {
        console.log("mounted")
    },
    destroyed: function () {
        if(this.timer){
            clearInterval(this.timer);
            this.timer = null
        }
        console.log('在页面被销毁时调用,但该方法并没有调用');
    },
    watch: {
        logisticsList(newValue, oldValue){
            this.restartTimer()
        }
    },
    methods: {
        restartTimer: function(){
            const self = this;
            var numberCode = 1;
            if(self.logisticsList.length>1 && !this.timer){
                self.showModel = self.logisticsList[0];
                self.hideModel = self.logisticsList[1];
                self.timer = setInterval(()=>{

                    self.sliderAnimation(function(){
                        self.showModel = self.hideModel 
                    }, function(){
                        numberCode += 1;
                        if(numberCode>=self.logisticsList.length){
                            numberCode = 0;
                        }
                        self.hideModel = self.logisticsList[numberCode];
                    });
                    
                },3000); 
            } else if (this.logisticsList.length <= 1) {
                clearInterval(this.timer);
                this.timer = null
                if(self.logisticsList.length==1){
                    self.showModel = self.logisticsList[0]
                }
            }
        },
        //隐藏弹框
        overlayMaskHide:function(){
            if(this.showMask){
                this.wxcOverlayBodyClicked();
            }
        },
        //跳转物流详情页方法
        clickAction:function(){
            if(this.showMask){
                this.wxcOverlayBodyClicked();
            }
            storage.setItem("Order_logisticCode",this.showModel.logisticCode,event => {});
            navigation.push({ url: "order_logistic_detail.html", title: "物流详情" },event => {});
        },
        //查看全部
        lookAllAction:function(){
            console.log('查看全部')
            if(this.showMask){
                this.wxcOverlayBodyClicked();
            }
            this.$emit('onClick',{})
        },
        //向上的轮播图 block1：处理前一张物流卡，block2：处理后一张物流卡
        sliderAnimation:function(block1, block2){
            const self = this;
            let el = self.$refs.logCard
            let height = self.height;
            animation.transition(el, {
                styles: {
                    transform: 'translateY(-' + height + ')',
                },
                duration: 300, //ms
                timingFunction: 'ease',
                needLayout: false,
                delay: 0 //ms
            }, function() {
                block1()
                setTimeout(() => {
                    block2()    
                    animation.transition(el, {
                        styles: {
                            transform: 'translateY(0)',
                        },
                        duration: 0, //ms
                        timingFunction: 'ease',
                        needLayout: false,
                        delay: 0 //ms
                    }, function() {
                    })                             
                }, 300);
            })
        },
        //获取状态图
        getStatusInfo:function(model){
            //已发货，已揽件，运输中，派送中， 已签收
            //0:在途中;1:已揽收;2:疑难;3:已签收;4:退签;5:派送中;6:退回;7:转单; -1:暂无物流信息
            var cong ={
                img:'/web/assets/sup/sup_personal_yunshuzhong.png',
                width:'74',
                height:'33',
            }
            if(model.state==0){
                cong ={
                    img:'/web/assets/sup/sup_personal_yifahuo.png',
                    width:'40',
                    height:'30',
                }
            }else if(model.state==1){
                cong ={
                    img:'/web/assets/sup/sup_personal_yilanjian.png',
                    width:'37',
                    height:'32',
                }
            }else if(model.state==2){
                cong ={
                    img:'',
                    width:'40',
                    height:'30',
                }
            }else if(model.state==3){
                cong ={
                    img:'/web/assets/sup/sup_personal_yiqianshou.png',
                    width:'40',
                    height:'40',
                }
            }else if(model.state==4){
                cong ={
                    img:'',
                    width:'40',
                    height:'30',
                }
            }else if(model.state==5){
                cong ={
                    img:'/web/assets/sup/sup_personal_peisongzhong.png',
                    width:'39',
                    height:'37',
                }
            }else if(model.state==6){
                cong ={
                    img:'',
                    width:'40',
                    height:'30',
                }
            }else if(model.state==7){
                cong ={
                    img:'',
                    width:'40',
                    height:'30',
                }
            }

            return cong;
        },
        //查看物流详情
        checkLogDetail:function(item){
            console.log('查看物流详情')
            var indexValue = 0;
            this.logisticsList.forEach((element,index) => {
                if(element.id == item.id){
                    indexValue = index;
                }
            });
            this.sliderIndex = indexValue;
            console.log('index:',indexValue)
            this.showMask = true;
        },
        wxcOverlayBodyClicked () {
            this.showMask = false;
        },
        /**
         * 导航栏左侧按钮点击事件
         */
        leftButtonClicked () {
            console.log(this.showMask);
            
            if (this.showMask) {
                this.wxcOverlayBodyClicked()
                return false
            } 
            return true
        }
    }
}
</script>

<style scoped>
.cardwarp {
    background-color: #f6f6f6;
    border-radius: 20px;
    margin-left: 30px;
    margin-right: 30px;
    margin-bottom: 30px;
    overflow: hidden;
}
.log-card {
    flex: 1;
    background-color: #f6f6f6;
    padding: 20px;
    border-radius: 20px;
}

.mask-all{
    position: fixed;
    width: 750px;
    /*兼容H5异常*/
    z-index: 99999;
}
.mask-content {
    position: fixed;
    top: 80px;
    left: 0;
    right: 0;
    bottom: 60px;
}
.banner {
    flex-direction: row;
    width: 750px;
    flex: 1;
    margin-bottom: 100px;
}
.banner-margin {
    position: absolute;
    left: 0px;
    right: 0px;
    top: 0px;
    bottom: 0px;
}
.banner-content {
    position: absolute;
    left: 40px;
    right: 40px;
    top: 80px;
    bottom: 0px;
    border-radius: 20px;
    flex-direction: row;
    justify-content: center;
    align-items: center;
    overflow: hidden;
    background-color: #ffffff;
}
.indicator {
    position: absolute;
    left: 200px;
    width: 350px;
    top: 30px;
    height: 30px;
    item-color: #999999;
    item-selected-color: #ffffff;
}
.xPoint {
    position: absolute;
    bottom:0px;
    left:345px;
    width:60px;
    height:60px;
    border-radius:60px;
    border-color:#fff;
    border-width:2px;
    justify-content: center;
    align-items: center;
}

</style>
