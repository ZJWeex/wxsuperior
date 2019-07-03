<!-- 提交订单-订单详情展示部分 -->
<template>
    <div class='wrapper'>
        <text class="order-detail">订单详情</text>
        <div v-if="Object.keys(preOrderData.resultMap).length>0">
            <!-- 全场满免包邮商品 -->
            <div class="type1" v-if="preOrderData.resultMap.allGoodsMap.allGoodsList && preOrderData.resultMap.allGoodsMap.allGoodsList.length>0">
                <div class="order-delvieryFee" v-if="Number(preOrderData.resultMap.allGoodsMap.otherFee)>0">
                    <text class="free-limit">运费{{preOrderData.resultMap.allGoodsMap.otherFee}}元，满{{preOrderData.resultMap.allGoodsMap.condtionPrice}}元包邮</text>
                    <div class="in-header" @click="goGatherTogether('all')">
                        <text class="header-text">去凑单</text>
                        <wxc-icon name="more" :icon-style="{color:'#ff0101',fontSize:'40px','margin-right':'10px'}" @wxcIconClicked="goGatherTogether('all')"></wxc-icon>
                    </div>
                </div>
                <div v-else-if="!hasAddress" style="height:40px; border-bottom-width: 2px;border-bottom-color: #f0f0f0;"></div>
                <div v-else class="order-delvieryFee">
                    <text class="free-limit"> 已包邮</text>
                </div>
                
                <div v-if="preOrderData.resultMap.allGoodsMap.allGoodsList.length>0" class="goods-content">
                    <div class="single-goods" v-for="(goods, i) in preOrderData.resultMap.allGoodsMap.allGoodsList" :key="i">
                        <text class="goods-name">{{goods.goodsName}}</text>
                        <text class="goods-count">x{{goods.count}}</text>
                        <text class="goods-price">¥{{goods.goodsPrice}}</text>
                    </div>
                </div>
                <div class="goods-planPrice">
                    <div class="goods-totalprice">
                        <text style="font-size:36px;color:#333333;">订单金额：</text>
                        <text style="font-size:36px;color:#ff0101;">¥{{preOrderData.resultMap.allGoodsMap.otherPrice}}</text>
                    </div>
                </div>
            </div>
            <!-- 组合包邮商品  -->
            <div v-if="preOrderData.resultMap.groups.length>0">
                <div v-for="group in preOrderData.resultMap.groups" :key="group.templateId">
                    <div class="order-singleFee" v-if="group.goodsList.length>0">
                        <text style="margin-left: 22px; font-size:30px;color:#666666;">{{templateName(group)}}</text>
                        <div v-if="Number(group.groupingFee)>0" style="flex-direction: row;">
                            <text class="free-limit">运费{{group.groupingFee}}元，满{{group.condtionPrice}}元包邮</text>
                            <div class="in-header" @click="goGatherTogether(group)">
                                <text class="header-text">去凑单</text>
                                <wxc-icon name="more" :icon-style="{color:'#ff0101',fontSize:'40px','margin-right':'10px'}" @wxcIconClicked="goGatherTogether(group)"></wxc-icon>
                            </div>
                        </div>
                        <div v-else style="flex-direction: row;margin-right:10px">
                            <text class="free-limit"> 已包邮</text>
                        </div>
                    </div>
                    <div v-if="group.goodsList.length>0" class="goods-content">
                        <div class="single-goods" v-for="(goods, i) in group.goodsList" :key="i">
                            <text class="goods-name">{{goods.goodsName}}</text>
                            <text class="goods-count">x{{goods.count}}</text>
                            <text class="goods-price">¥{{goods.goodsPrice}}</text>
                        </div>
                    </div>
                    <div class="goods-planPrice">
                        <div class="goods-totalprice">
                            <text style="font-size:36px;color:#333333;">订单金额：</text>
                            <text style="font-size:36px;color:#ff0101;">¥{{group.totalPrice}}</text>
                        </div>
                    </div>
                </div>
            </div>
            <!-- 单品包邮商品  -->
            <div v-if="preOrderData.resultMap.singleMap&&preOrderData.resultMap.singleMap.singleList&& preOrderData.resultMap.singleMap.singleList.length>0">
                <div class="order-singleFee">
                    <text style="margin-left: 22px; font-size:30px;color:#666666;">单品</text>
                    <div style="flex-direction: row;margin-right:10px">
                        <text class="free-limit">已包邮</text>
                    </div>
                </div>
                <div class="goods-content">
                    <div class="single-goods" v-for="(goods, i) in preOrderData.resultMap.singleMap.singleList" :key="i">
                        <text class="goods-name">{{goods.goodsName}}</text>
                        <text class="goods-count">x{{goods.count}}</text>
                        <text class="goods-price">¥{{goods.goodsPrice}}</text>
                    </div>
                </div>
                <div class="goods-planPrice">
                    <div class="goods-totalprice">
                        <text style="font-size:36px;color:#333333;">订单金额：</text>
                        <text style="font-size:36px;color:#ff0101;">¥{{preOrderData.resultMap.singleMap.singlePrice}}</text>
                    </div>
                </div>
            </div>
        </div> 
        <!-- 超出配送范围的商品 -->
        <div v-if="preOrderData.listWithoutArea.length>0" class="out-container">
            <div class="out-header">
                <text class="out-header-text">超出配送范围</text>
                <text class="out-header-text">不配送</text>
            </div>
            <div class="out-cell">
                <div class="single-goods" v-for="(goods, i) in preOrderData.listWithoutArea" :key="i">
                    <text style="color:#999999;font-size: 30px;flex: 6;">{{goods.goodsName}}</text>
                    <text style="color:#999999;font-size: 30px;flex: 2;text-align: right;">x{{goods.count}}</text>
                    <text class="goods-price-without"></text>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import { WxcIcon } from 'weex-ui';
const modal = weex.requireModule('modal');

export default {
    components: { WxcIcon },
    //定义属性
    props: {
        hasAddress:{
            type:Boolean,
            default:false
        },
        preOrderData: {
            type: Object,
            default:function(){
                return {
                    totalPrice: "0.00",//商品总价
                    condtionPrice:"199", //满额包邮条件
                    listWithinArea:[],
                    listWithoutArea:[],//超出配送范围的商品
                    resultMap:{
                        allGoodsMap:{
                            allGoodsList:[],
                            otherPrice:0,//全场包邮商品总价
                            otherFee:0,//邮费
                            condtionPrice:0 //包邮限制
                            },
                        singleList:[],//单品包邮商品
                        groups:[
                            //组合包邮
                            /*
                            {
                                templateName:'模版名称',
                                templateId:'模版ID',
                                condtionPrice:0,//包邮限制
                                otherFee:0,//邮费
                                goodsList:[],

                            }*/
                        ],
                    }
                } 
            }
        }
    },
    data() {
        return {

        }
    },
    created() {

    },
    
    methods: {
        templateName:function(group){
            if(Number(group.condtionPrice)>Number(group.totalPrice)){
                if(group.templateName.length>6){
                    var subTitle = group.templateName.substr(0,5)
                    return subTitle+'...'
                }else{
                    return group.templateName
                }
            }else{
                return group.templateName;
            }
            
            
        },
        goGatherTogether:function(template){
            var tp = {}
            if(template == 'all'){
                var objc = this.preOrderData.resultMap.allGoodsMap
                tp = {
                    templateId:'',
                    totalPrice:objc.otherPrice,
                    postagePrice:objc.condtionPrice
                }
            }else{
                tp = {
                    templateId:template.templateId,
                    totalPrice:template.totalPrice,
                    postagePrice:template.condtionPrice
                }
            }
            
            this.$emit("gatherTogether",tp)
        },
    }
}
</script>

<style scoped>
.wrapper { 
    width: 750px;
}
.order-delvieryFee{
    flex-direction: row;
    height: 80px;
    justify-content: flex-end;
    align-items: center;
    border-bottom-width: 2px;
    border-bottom-color: #f0f0f0;
}
.order-singleFee{
    flex-direction: row;
    height: 80px;
    justify-content: space-between;
    align-items: center;
    border-bottom-width: 2px;
    border-bottom-color: #f0f0f0;
}
.free-limit{
    margin-right: 22px; 
    font-size:30px;
    color:#666666;
}
.in-header{
    flex-direction: row;
    align-items: center;
}
.header-text {
    font-size:30px;
    color:#ff0101;
}
.order-detail{
    font-size: 32px;
    color:#666666;
    padding-left:22px;
    padding-right:22px;
    padding-top:12px;
    padding-bottom:12px;
    width:750px;  
}
.goods-content {
    padding-left: 22px;
    padding-right: 22px;
    padding-top: 12px;
    padding-bottom: 12px;
    flex-direction: column;
}
.single-goods {
    flex-direction: row;
    align-items: center;
    padding-top: 10px;
    padding-bottom: 10px;   
}
.goods-name {
    font-size: 30px;
    color: #333333;
    flex: 6;
}
.goods-count {
    font-size: 30px;
    color: #ff0101;
    flex: 2;
    text-align: right;
}
.goods-price {
    font-size: 30px;
    color: #ff0101;
    flex: 2;
    text-align: right;
}
.goods-planPrice {
    height: 100px;
    width:750px;
    border-bottom-width: 10px;
    border-bottom-color: #f0f0f0;
    justify-content: center; 
}
.goods-totalprice {
    flex-direction: row;
    align-items: center;
    align-self: flex-end;
    margin-right: 26px;
}
.out-container {
    padding-top: 12px;
    padding-bottom: 12px;
    flex-direction: column;
    background-color: #f6f3f3; 
}
.out-header {
    height: 72px;
    flex: 1;
    flex-direction: row;
    align-items: center;
    justify-content: space-between;
    border-bottom-width: 2px;
    border-bottom-color: #d9d9d9;
}
.out-header-text{
    padding-left: 25px;
    padding-right: 25px;
    font-size: 30px;
    color: #666666;
}
.out-cell {
    padding-top: 40px;
    padding-bottom: 40px;
    padding-right: 25px;
    padding-left: 25px;
}
.goods-price-without {
    font-size:28px;
    color:#999999;
    flex:3;
    text-align:right;
}
</style>
