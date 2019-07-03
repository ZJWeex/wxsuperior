<template>
    <div class='wrapper' @viewappear="viewappear">
        <navigation title="购物车" 
                   :leftButton="navLeftButton"
                   :right-text="navRightText"
                   @wxcMinibarRightButtonClicked="editRightButtonClick">
        </navigation>
        <list class="list">
             
            <!-- <header>
                <div v-if="orderStartPrice>0" :style="{'background-color':'#ffffff','border-top-color':isAndroid?'#f0f0f0':'','border-top-width':'1px'}">
                    <text class="baoyou-text">全场满{{orderStartPrice}}元包邮</text>
                </div>
            </header> -->

            <cell v-for="(item, i) in cartList" :key="i" :index="i">
                <shoppingCartCell :cartItem="item" 
                                  :editEnable="editEnable"
                                  :jessionId="jessionId">
                </shoppingCartCell>
            </cell>
        </list>
        <wxc-result 
              :type="resultPageType"
              :custom-set="customSet"
              :show="showResult"
              :wrap-style="{top:navHeight}"
              padding-top="232"
              @wxcResultButtonClicked="wxcResultButtonClicked">
        </wxc-result>
        <!-- 底部结算信息 -->
        <div v-if="cartList.length>0" class="bottom-finish">
            <div style="flex-direction: row;align-items: center;">
                <div class="select-mark" @click="selectAllClick">
                    <image v-if="selectAll" class="select-img"  src="/web/assets/sup/sup_cart_check.png" @click="selectAllClick"/>
                    <image v-else class="select-img"  src="/web/assets/sup/sup_cart_uncheck.png" @click="selectAllClick"/>
                </div>
                <text style="font-size:30px;color:#333333;">全选</text>
            </div>
            <div v-if="editEnable==false" style="flex-direction: row;align-items: center;">
                <text style="font-size:32px;color:#333333;">总计:</text>
                <text style="font-size:26px;color:#ff0033;">¥</text>
                <text style="font-size:36px;color:#ff0033;">{{submitTotalPrice}}</text>
            </div>
            <div v-if="editEnable" class="settlement-btn" @click="deleAlertClick">
                <text style="color:#ffffff;font-size:40px;">删除</text>
                <!-- 目的调用计算方法 -->
                <text v-if="submitTotalPrice<0" style="width:0;height:0;"></text>
            </div>
            <div v-else class="settlement-btn" @click="submitOrderClick">
                <text style="color:#ffffff;font-size:36px;">去结算</text>
            </div>
        </div>
        <wxc-loading :show="loading" need-mask=false type="default"></wxc-loading>
    </div>
</template>

<script>
import Fetch from "@/base-superior/Fetch.js";
import Define from "@/base-superior/Define.js";
import navigation from "@/base-superior/components/NavigationBar.vue";
import { WxcResult,WxcLoading, Utils } from 'weex-ui';
import shoppingCartCell from '../base-superior/shopping_cartCell.vue';
import DB from "../base-superior/shopping_cartdb.js"

const modal = weex.requireModule('modal');
const storage = weex.requireModule("storage");

function getNavHeight () {
    const { env } = weex.config;
    var navHeight = 88;
    if (env.platform.toLowerCase() === 'ios') {
        navHeight = Utils.env.isIPhoneX() ? 176*375*env.scale/env.deviceWidth : 128*375*env.scale/env.deviceWidth;
    } else if (env.platform.toLowerCase() === 'android') {
        navHeight = 88;
    }
    return navHeight + 2;
}

export default {
    components: { WxcResult,WxcLoading, navigation, shoppingCartCell },
    data() {
        return {
            isAndroid:WXEnvironment.platform === 'android',
            navHeight:getNavHeight(),
            customSet:{noGoods: { button: '去逛逛', content: '购物车暂无商品！', desc: '' }},
            resultPageType:'noGoods',
            showResult:false,
            loading:false,
            navLeftButton:'',
            editEnable:false,
            selectAll:true,
            orderStartPrice:0,
            cartList:[],
            jessionId: ''
        }
    },
    watch:{
        cartList:{
            handler(newValue, oldValue) {
                newValue.forEach((element,index) => {
                    if(element.supGoodsList.length == 0){
                        this.cartList.splice(index,1)
                        // modal.alert({message:"监听到了"})
                    }
                });
                if(newValue.length == 0){
                    this.showResult = true;
                    this.orderStartPrice = 0;
                }else{
                    this.showResult = false;
                }
                //更新数据
                storage.setItem(Define.kLocal_Cart, JSON.stringify(this.cartList), event=>{})
                if(WXEnvironment.platform.toLowerCase() != 'web'){
                    DB.postBadgeNotification();
                }
            },
            deep: true
        },
    },
    computed:{
        submitTotalPrice:function(){
            const self = this;
            var totalPrice = 0.00;
            var unselected = true;
            for (let i = 0; i < this.cartList.length; i++) {
                const group = this.cartList[i];
                //计算分组金额
                var groupPrice = 0.00;
                for (let j = 0; j < group.supGoodsList.length; j++) {
                    const itemGoods = group.supGoodsList[j];
                    //选中的商品,区分商品是否失效
                    if(itemGoods.expiryStatus == 'false'){
                        if(itemGoods.selected == undefined ||itemGoods.selected){
                            var itemTotalPrice = itemGoods.count*itemGoods.supStorePrice;
                            groupPrice =Number(groupPrice) + Number(itemTotalPrice);
                        }else{
                            unselected = false;
                        } 
                    }else{
                        if(this.editEnable){
                            //编辑状态下，失效商品选中改变全选按钮
                            if(itemGoods.selected == false){
                                unselected = false;
                            }
                            
                        }
                    }  
                }
                //满减金额reducedPrice计算
                if(group.activityPower.length >0){
                  var reducedPrice =  self.recursiveActivityReducedPrice(group.activityPower,groupPrice,0)
                    groupPrice =Number(groupPrice) - Number(reducedPrice);
                    if(groupPrice<0){
                        groupPrice = 0.00;
                    }
                }

                totalPrice += groupPrice;
            }
            this.selectAll = unselected;
            return totalPrice.toFixed(2);
        },
        navRightText:function(){
            //导航按钮
            if(this.cartList.length == 0){
                return ''
            }
            var text = this.editEnable?'完成':'管理';
            return text;
        },
    },
    created() {
        const self = this;
        storage.getItem(Define.kGoodsDetail_Cart,event=>{
            storage.removeItem(Define.kGoodsDetail_Cart,event => {})
            if(event.data != 'undefined'){
                self.navLeftButton = '/web/assets/sup/sup_setting_supermarkets_fh.png'
            }
            self.loadDataHandle();
        });
        storage.getItem('JESSIONID', event=>{
            //登录状态先显示本地数据，防止网络加载慢而无数据展示
            var sessionid = event.data;
            self.jessionId = sessionid
            if(sessionid != 'undefined'){
                storage.getItem(Define.kLocal_Cart,function(ret){
                    if(ret.data != "undefined"){
                        var reslut = JSON.parse(ret.data);
                        self.cartList = reslut;
                    }else{
                        self.cartList = [];
                    }
                })
            }
        })
        //提交订单完成后刷新
        const refreshChannel = new BroadcastChannel("refreshChannel");
        refreshChannel.onmessage = function (event){
            console.log("refreshChannel："+event.data);
            self.loadDataHandle();
            refreshChannel.close();
        };
    },
    methods: {
        viewappear(){
            const self = this;
            console.log('viewappear')
            storage.getItem('JESSIONID', event=>{
                self.jessionId = event.data; 
            });
            self.loadDataHandle();
        },
        //递归法
        recursiveActivityReducedPrice:function(activityArray,groupPrice,index){
            const self = this;
            var reducedPrice=0;//减免金额
            if(activityArray.length == 1){
                const activity = activityArray[index];
                if(activity.fullPrice<=groupPrice){
                   reducedPrice = activity.minusPrice;
                }
            }else if(activityArray.length > 1){
                 if(index >activityArray.length-1){
                     index = activityArray.length-1;
                 }
                 if(index == activityArray.length-1){
                    const activity1 = activityArray[index];
                    const activity = activityArray[index-1];
                    if(activity1.fullPrice>groupPrice){
                        reducedPrice = activity.minusPrice; 
                    }else{
                        reducedPrice = activity1.minusPrice;
                    }
                }else if(index == 0){
                     const activity = activityArray[index];
                    if(activity.fullPrice<=groupPrice){
                        index = index+1;
                       var obc = self.recursiveActivityReducedPrice(activityArray,groupPrice,index);
                       return obc;
                    }
                }else{
                    const activity1 = activityArray[index];
                    const activity = activityArray[index-1];
                    if(activity1.fullPrice>groupPrice){
                        reducedPrice = activity.minusPrice;  
                    }else{
                       index = index+1;
                       var obc = self.recursiveActivityReducedPrice(activityArray,groupPrice,index);
                       return obc;
                    }
                }
            }

            return reducedPrice;
        },
        //导航编辑按钮
        editRightButtonClick:function(){
            this.editEnable = !this.editEnable;
        },
        
        //选中全部
        selectAllClick:function(){
            this.selectAll = !this.selectAll;
            for (let index = 0; index < this.cartList.length; index++) {
                const item = this.cartList[index];
                this.$set(item,'selected',this.selectAll)
                item.supGoodsList.forEach(element => {
                    this.$set(element,'selected',this.selectAll)
                });
            }
            
        },
        //刷新按钮
        wxcResultButtonClicked:function(){
            if(this.resultPageType == 'noGoods'){
                if(this.navLeftButton.length > 0){
                    navigation.pop({}, event =>{});
                }else{
                    //tabbar切换
                    navigation.push({switchTab:'0', title:'淘菜猫优选商城'}, event =>{});
                }
            }else{
                this.loadDataHandle();
            } 
        },
        //显示数据处理
        loadDataHandle:function(){
            const self = this;
            storage.getItem('JESSIONID', event=>{
                var sessionid = event.data;
                storage.getItem(Define.kLocal_Cart,function(ret){
                    if(ret.data != "undefined"){
                        var reslut = JSON.parse(ret.data);
                        self.cartList = reslut;
                    }else{
                        self.cartList = [];
                        self.resultPageType = 'noGoods';
                    }
                    if(sessionid != 'undefined' && sessionid.length > 0){
                        self.loadCartListData();
                    }
                });
                 
             });
        },
        //加载购物车列表
        loadCartListData:function(){
            var self = this;
            self.loading = true;
            Fetch.post('buyer/superiorwechatGoodsCartList.json',{}, function(respone){
                self.loading = false;
                var result = JSON.parse(respone)
                console.log("购物车："+respone);
                if(result.op_flag == 'success'){
                    self.resultPageType = 'noGoods';
                    var list = result.bgcs;
                    self.orderStartPrice = Number(result.orderStartPrice);
                    DB.updateItems(list,event=>{
                        self.cartList = JSON.parse(event.data);
                    })  
                }else{
                    self.resultPageType = 'errorPage';
                     modal.toast({message:result.info})
                }
            }, function(err){
                self.loading = false;
                if(err.indexOf('网络不可用') != -1){
                    self.resultPageType = 'noNetwork';
                    self.cartList = [];
                }else{
                    self.resultPageType = 'errorPage';
                    self.cartList = [];
                    console.log('错误信息:'+err)
                    // modal.toast({message:'错误信息:'+err})
                }
             });
        },
        //购物车删除点击事件
        deleAlertClick:function(){
            const self = this;
            modal.confirm({message:'确定删除商品吗？',
                           okTitle:'确定',
                           cancelTitle:'取消'},function(result){
                               if(result == '确定'){
                                   self.deleGoodsHandle()
                               }
                           })
        },
        //购物车删除交互
        deleGoodsHandle:function(){
            const self = this;
            storage.getItem('JESSIONID', event=>{
                var sessionid = event.data;
                if(sessionid == 'undefined' || sessionid.length == 0){
                    var newlist = [];
                     self.cartList.forEach((groupSection,i) => {
                        var newSupGoodsList = [];
                        groupSection.supGoodsList.forEach((model,j) => {
                            if(model.selected==false){
                                newSupGoodsList.push(model);
                            }
                        })
                        groupSection.supGoodsList = newSupGoodsList;
                        if(newSupGoodsList.length > 0){
                            newlist.push(groupSection)
                        }
                    });
                    self.cartList = newlist;
                    self.editEnable = false;
                 }else{
                    var bgcIds = '';
                    self.cartList.forEach(groupSection => {
                        groupSection.supGoodsList.forEach(model => {
                            if(model.selected==undefined || model.selected){
                                bgcIds +=","+model.bgcId;
                            }
                        })
                    });
                    if(bgcIds.length > 0){
                        self.deleGoodsEvent(bgcIds);
                    }else{
                        modal.toast({message:'请选择要删除的商品'})
                    }
                 }
            });
            
        },
        //删除商品
        deleGoodsEvent:function(bgcId){
            const self = this;
           var param = {bgcId:bgcId}
           var url = 'buyer/delBuyerGoodsCart.json';
           Fetch.post(url, param, function(respone){
            //    console.log('删除：'+respone)
               var result = JSON.parse(respone)
                if(result.op_flag == 'success'){
                    var bgcIds = [];
                    if(bgcId.indexOf(',') != -1){
                        bgcIds = bgcId.split(',')
                    }else{
                        bgcIds.push(bgcId);
                    }
                    var existList = [];
                    for (let i = 0; i < self.cartList.length; i++) {
                        const elSecton = self.cartList[i];
                        var existGoodsList = [];
                        for (let j = 0; j < elSecton.supGoodsList.length; j++) {
                            const element = elSecton.supGoodsList[j];
                            if(element.selected==false){
                                existGoodsList.push(element);
                            }
                        }
                        elSecton.supGoodsList = existGoodsList;
                        if(existGoodsList.length > 0){
                            existList.push(elSecton);
                        }
                    }
                    modal.toast({message:'删除成功！',duration:0.3})
                    self.cartList = existList;
                    self.editEnable = false;
                }else{
                    modal.toast({message:result.info})
                }
           }, function(err){
               modal.toast({message:err})
           });

        },
        //点击去结算按钮
        submitOrderClick: function(){
            const self = this;
             var goodsData = [
                        /*{"count":"1",
                          "supGoodsId":"820395360468004864",
                          "subjectId":"1",
                          "supCartId":"",
                          "bgcId":"829443996058374144"
                          },
                        {"count":"2",
                        "supGoodsId":"817497735164923904",
                        "subjectId":"1",
                        "supCartId":"",
                        "bgcId":"829443995697664000"
                        }*/];
            this.cartList.forEach(groupSection => {
                groupSection.supGoodsList.forEach(model => {
                    if((model.selected==undefined || model.selected)&&model.expiryStatus == 'false') {
                        var data = {
                            count:model.count.toString(),//数量
                            supGoodsId:model.supGoodsId,//商品ID
                            subjectId:model.supSubjectId,//主题ID
                            supCartId:model.supCartId,//购物车ID
                            bgcId:model.bgcId //菜篮子id
                        }
                        goodsData.push(data);
                    }
                })
            });
            if(goodsData.length >0){
                storage.getItem('JESSIONID', event=>{
                    var sessionid = event.data;
                    //没有登录则跳转登录界面
                    if(sessionid != 'undefined' && sessionid.length >0){
                        storage.setItem('submitOrderData',JSON.stringify(goodsData),event =>{})
                        navigation.push({url:'shopping_orderSubmit.html','pop':true, title:'提交订单'}, event =>{});
                    }else{
                        navigation.push({url:'login_login.html'}, event =>{});
                    }   
                });
            }else{
                modal.toast({message:'请选择商品',duration:0.3})
            }
            
        },
        
    }
}
</script>

<style scoped>
.wrapper { 
    /* justify-content: center; */
    align-items: center;
}
.rowcenter{
    flex-direction: row;
    align-items: center;
}
.list {
    width: 750px;
    flex: 1;
    margin-bottom: 110px;
    background-color: white;
}

.bottom-finish {
    flex-direction: row;
    justify-content: space-between;
    align-items: center;
    position: absolute;
    height: 110px;
    bottom: 0px;
    right: 0;
    left: 0;
    border-top-color: #f0f0f0;
    border-top-width: 2px;
}
.baoyou-text{
    flex: 1;
    color:#333333;
    font-size:26px;
    font-weight: bold;
    padding:20px; 
}
.select-mark {
    width:76px;
    height:72px;
    margin-right:10px;
    margin-left:10px;
    align-items: center;
    justify-content: center;
}
.select-img{
    width:36px;
    height:36px;
    /* background-color:red; */
}
.settlement-btn {
    justify-content: center;
    align-items: center;
    height:76px;
    width:152px;
    border-radius: 10px;
    margin-right: 20px;
    margin-left: 20px;
    background-color:red;
}
</style>
