<template>
    <div class="wrapper">
        <navigation :title="title"/>
        <list v-if="goods" class="info-list" :style="{height: listHeight}">
            <cell class="image-cell">
                    <image class="image-goods" :src='goods.cardImageUrl' />
                    <image class="helper" resize="contain" src="/web/assets/sup/sup_giftVocher_helper.png" @click="helperAction" />
            </cell>
            <cell v-for="item in goods.giftCardInfo" :key="item.templateId" style="">
                <div class="item-cell">
                    <div class="item-info">
                            <text style="color: #333333; font-size: 32px;">{{item.cardAmount}}元面值</text>
                            <div class="item" style="flex-direction: row; margin-left: 30px; ">
                                <text style="color: #cb1b45; font-size: 30px;">¥</text>
                                <text style="color: #cb1b45; font-size: 40px; ">{{item.cardAmount}}</text>
                            </div>
                        </div>
                        <div class="item-operator" v-if="parseInt(item.cardCount) > 0">
                            <image v-if="item.count > 0" style="width:72px;height:42px;" resize="contain" src="/web/assets/sup/sup_cart_reduce.png" @click="reduceGoodsCountClick(item)" />
                            <text v-if="item.count > 0" style="width: 55px; text-align: center; font-size: 40px;">{{item.count}}</text>
                            <image style="width:72px;height:42px;" resize="contain" src="/web/assets/sup/sup_cart_add.png" @click="addGoodsCountClick(item)" />
                        </div>
                        <div class="item-operator" v-else-if="payable">
                            <div class="pay-disable">
                                <text style="color: #ffffff; font-size:32px; ">已售罄</text>
                            </div>
                        </div>
                </div>
            </cell>
        </list>

        <div v-if="goods" class="bottom-buy" :style="{height: bottomHeight}">
            <div v-if="payable" style="flex-direction: row; align-items: center;">
                <text style="text-align: right; font-size: 30">合计：</text>
                <text style="width: 130px; text-align: left; font-size: 30; color: #cb1b45;">¥{{payable}}</text>
            </div>
            <div v-if="payable" class="pay-enbale" @click="settlementAction">
                <text style="color: #ffffff; font-size:32px; ">去结算</text>
            </div>
            <div v-if="!payable" class="pay-disable">
                <text style="color: #ffffff; font-size:32px; ">全部售罄</text>
            </div>
        </div>
        <div v-else>
            <text>{{error}}</text>
        </div>
    </div>
</template>

<script>
import navigation from "@/base-superior/components/NavigationBar.vue";
import Fetch from "@/base-superior/Fetch.js";
import Define from "@/base-superior/Define.js";

const modal = weex.requireModule("modal");
const storage = weex.requireModule("storage");

export default {
    components: {navigation, },
    data() {
        return {
            supGoodsId: "",
            bottomHeight: 120,
            listHeight: navigation.pageHeight(false) - 120,
            goods: null,
            error: '',
            payable: null,
            title: null,
        }
    },
    created() {
         //加载商品数据
        var that = this;
        storage.getItem('goods_giftVoucher', event => {
            console.log(event)
            var goods = JSON.parse(event.data)
            that.supGoodsId = goods.goodsId;
            that.title = goods.goodsName
            that.loadData();
        });
    },
    methods: {
        loadData: function() {
            var param = { goodsId: this.supGoodsId };
            var that = this;
            Fetch.post("superiorGiftCardDetail.json",param,function(jsonString) {
                    console.log('商品详情' + jsonString)
                    var result = JSON.parse(jsonString);
                    if (result.op_flag == 'success') {
                        that.goods = result.obj
                        var giftCardInfo = []
                        that.goods.giftCardInfo.forEach(element => {
                            var card = {}
                            for (var key in element){
                                card[key] = element[key]
                            }
                            if (parseInt(card.cardCount) > 0) {
                                that.payable = '0'
                            }
                            card.count = '0'
                            giftCardInfo.push(card)
                        });
                        that.goods.giftCardInfo = giftCardInfo
                    } else {
                        that.error = result.info
                    }
                },function(err) {
                    modal.toast({message: err,duration: 0.3});
                }
            );
        },
        reduceGoodsCountClick:function(goodsModel){
            if (goodsModel.count <= 0) {
                return 
            }
           goodsModel.count = String(parseInt(goodsModel.count) - 1)
           this.reloadSettlement()
        },
        //商品添加操作
        addGoodsCountClick:function(goodsModel){
            if((parseFloat(this.payable) + parseFloat(goodsModel.cardAmount)) > 1000 
            || parseInt(goodsModel.cardCount) <=  parseInt(goodsModel.count)) {
                modal.toast({ message: "已达到最大数量", duration: 1.0 });
                return
            }
            goodsModel.count = String(parseInt(goodsModel.count) + 1)
            this.reloadSettlement()
        },
        reloadSettlement(){
            var settlementPrice = 0
            this.goods.giftCardInfo.forEach(element => {
                settlementPrice += parseInt(element.count) * parseFloat(element.cardAmount)
            });
            this.payable = String(settlementPrice)
        },
        settlementAction(){
            var self = this
            if (this.payable <= 0) {
                modal.toast({
                    message: '请先选购商品'
                })
                return
            }
             storage.getItem('JESSIONID', event=>{
                    var sessionid = event.data;
                    //没有登录则跳转登录界面
                    if(sessionid != 'undefined' && sessionid.length >0){
                        self.toSettlement()
                    }else{
                        navigation.push({url:'login_login.html'}, event =>{});
                    }   
            });
            
        },
        toSettlement(){
            var goods = {}
            goods.goodsId = this.goods.giftCardInfo[0].goodsId
            var cards = []
            this.goods.giftCardInfo.forEach(element => {
                if (element.count > 0) {
                    var card = {}
                    card.templateId = element.templateId
                    card.goodsNum = element.count
                    element.count = '0'
                    cards.push(card)
                }
            });
            goods.goodsInfo = cards

            storage.setItem('goods_giftVoucher_settlement',  JSON.stringify(goods), event=>{})

            let url = 'goods_giftVoucher_settlement.html'
            navigation.push({url:url, title: '提交订单'}, event =>{})
            this.reloadSettlement()
        },
        helperAction(){
            let url = 'goods_giftVoucher_helper.html'
            navigation.push({url:url, title: '礼品卡常见问题'}, event =>{})
        },
    },
}
</script>

<style scoped>
.wrapper{
    align-items: center;
    width: 750px;
    background-color: white;
}
.info-list{
    height: 120px; 
    width: 750px; 
    align-items: center;
}
.image-cell{
    width: 750px; 
    height:480px; 
    justify-content: center;
    align-items: center;
}
.image-goods{
    width: 716px;
    height: 438px;
}
.item-cell{
    margin-left: 17px;
    width: 716px;
    height: 116px;
    margin-top: 12px;
    margin-bottom: 12px;
    border-width : 1px;
    border-color: #d5d5d8;
    flex-direction: row;
    align-items: center;
    justify-content: space-between;
    border-radius: 10px;
}
.item-info{
    margin-left: 20px;
    /* justify-content: center; */
}
.item{
    align-items: flex-end;
}
.item-operator{
    flex-direction: row;
    margin-right: 20px;
    align-items: center;
}
.bottom-buy{
    width: 750px; 
    background-color: #dddddd;
    flex-direction: row;
    justify-content: flex-end;
    align-items: center;
}
.helper{
    width:72px;
    height:42px;
    position: absolute;
    top: 30px;
    right: 20px;     
}
.pay-enbale{
    background-color: #cb1b45; 
    border-radius: 10px; 
    margin-right: 20px;
    padding-left: 20px;
    padding-right: 20px;
    padding-top: 10px;
    padding-bottom: 10px;
}
.pay-disable{
    background-color: #999999; 
    border-radius: 10px;
    margin-right: 20px; 
    padding-left: 20px;
    padding-right: 20px;
    padding-top: 5px;
    padding-bottom: 5px;
}
</style>
