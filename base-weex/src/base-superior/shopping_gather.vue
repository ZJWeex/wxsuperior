<!-- 凑单界面 -->
<template>
    <div class='wrapper' :style="{'background-color':list.length>0?'#ffffff':'#f2f3f4'}">
        <navigation title="商品凑单"/>
        <!-- 顶部 -->
        <div v-if="list.length>0" style="height:80px; justify-content: center;">
            <text v-if="lackPrice>0" style="color:#333333;font-size:36px;padding-left:30px;">实付满{{postagePrice}}元包邮，还差{{lackPrice}}元</text>
            <text v-else style="color:#333333;font-size:36px;padding-left:30px;">实付满{{postagePrice}}元包邮，已包邮</text>
        </div>
        <!-- 商品列表 -->
        <waterfall class="waterfall" column-count="2" column-gap=1>
            <refresh class="refresh" @refresh="onrefresh" 
                :display="refreshing ? 'show' : 'hide'">
                <text class="indicator-text">{{refreshText}}</text>
                <loading-indicator class="indicator"></loading-indicator>
            </refresh>
            <cell class="cell" v-for="item in list" :key="item.supGoodsId">
                <div class="content">
                    <image class="itemImg" resize="contain" :src="item.mainImgURL"/>
                    <div class="contentDes">
                        <text class="item-name">{{ item.supGoodsName }}</text>
                        <text class="item-des">{{ item.supGoodsSpecs }}</text>
                        <div style="flex-direction: row;align-items: center;padding-top:5px;">
                            <text style="color:#ff093c;font-size:30px">¥</text>
                            <text style="color:#ff093c;font-size:44px">{{ item.supStorePrice }}</text>
                        </div>
                    </div>
                    <div class="cartHandle">
                        <div class="add-div" @click="addActionClick(item)">
                            <image style="width:40px; height:40px;" src='/web/assets/sup/sup_homeSearch_addGoods.png' @click="addActionClick(item)"/>
                        </div>
                    </div>
                </div>
            </cell>
            <header v-if="isBottom">
                <div class="bottom-line">
                    <text style="padding:30px;color:#d9d9d9;font-size:28px;">--  食品安全和膳食营养是我们的底线  --</text>
                </div>
                <!-- 目的：android全面屏物理键可隐藏和显示 -->
                <div v-if="isAndroid" style="height:100px;width:750px;"></div>
            </header>
            <!-- 加载更多 -->
            <loading v-if="!isBottom" class="loading" @loading="onloading" :display="loadingmore ? 'show' : 'hide'">
                <text class="indicator-text">{{loadingText}}</text>
                <loading-indicator class="indicator"></loading-indicator>
            </loading>
        </waterfall>
        <!-- 底部显示 -->
        <div v-if="list.length>0" class="bottom">
            <text style="color:#333333;font-size:32px">小计：</text>
            <text style="color:#ff093c;font-size:26px;">¥</text>
            <text style="color:#ff093c;font-size:36px">{{totalPrice}}</text>
            <text class="button" @click="goSettlementClick">去结算</text>
        </div>
        <wxc-result type="noGoods"
              :show="showResultPage"
              :custom-set="customSet"
              :wrap-style="{top:200}"
              padding-top="230">
        </wxc-result>
        <wxc-loading :show="loading" need-mask=false type="default"></wxc-loading>
    </div>
</template>

<script>
import Fetch from "@/base-superior/Fetch.js";
import navigation from "@/base-superior/components/NavigationBar.vue";
import DB from "@/base-superior/shopping_cartdb.js";
import Define from "@/base-superior/Define.js";
import { WxcLoading,WxcResult } from 'weex-ui';
const modal = weex.requireModule('modal');
const storage = weex.requireModule("storage");
export default {
    components: { navigation, WxcLoading, WxcResult },
    data() {
        return {
            isAndroid:WXEnvironment.platform === 'android',
            refreshing: false,
            refreshText:'下拉刷新',
            isBottom:false,
            loadingmore: false,
            loading:false,
            loadingText: '',
            showResultPage:false,
            customSet:{noGoods: { button: null, content: '没有更多商品了～～', desc: '',pic:'/web/assets/sup/sup_homeSearch_noData_cry.png' }},
            list:[],
            tempCartList:[],//保存凑单商品
            page: 1,
            templateId:'',//包邮模版id
            addrId:'',//地址Id
            postagePrice:0,//包邮限制金额
            totalPrice:0,//总金额
        }
    },
    created() {
        const self = this
        //凑单数据
        Define.getItem(Define.kGatherData)
        .then(event => {
            if(event.data && event.data != 'undefined'){
                console.log('传递参数：',event.data)
                let result = JSON.parse(event.data)
                self.templateId = result.templateId
                self.addrId = result.addrId
                self.postagePrice = result.postagePrice
                self.totalPrice = result.totalPrice
            }
        })
        .then(() =>{
            if (WXEnvironment.platform.toLowerCase() !== 'web'){
                   return Define.removeItem(Define.kGatherData)
                    .then(ret =>{console.log('移除成功') })
                }else{
                    return 'web不移除'
                }
        })
        .then(() =>{
            self.loading = true;
            self.loadListData()
        })
        
    },
    computed:{
        lackPrice(){
            var lackPrice = this.postagePrice - this.totalPrice
            if(lackPrice<=0){
                lackPrice = 0
            }
            return lackPrice.toFixed(2);
        },
    },
    methods: {
        //下拉刷新事件
        onrefresh(event) {
            this.refreshing = true
            this.page = 1;
            this.loadListData();  
        },
        //上啦加载
          onloading (event) {
            if(!this.isBottom){
                this.loadingText = 'Loading ...'
                this.loadingmore = true
                setTimeout(() => {
                    this.page = this.page + 1;
                    this.loadListData();
                }, 300)
                
            }    
        },
        //加载商品数据
        loadListData: function() {
            const self = this;
            var param = {
                templateId: this.templateId,
                addrId:this.addrId,
                currentPage: this.page.toString()
            };
            console.log('凑单请求参数：',param)
            Fetch.post("makeUpOrderSuperiorGoodsList.json",param,function(respone) {
                    self.loading = false;
                    self.refreshing = false;
                    self.loadingmore = false;
                    self.loadingText ='';
                    var result = JSON.parse(respone);
                    console.log('主题数据：'+respone);
                    if (result.op_flag == "success") {
                        var mergeList = result.supGoodsList;
                        if(self.page>=Number(result.totalPage)){
                            self.isBottom = true;
                        }

                        if(self.page > 1){
                            if(self.page <= result.totalPage){
                                self.list = self.list.concat(mergeList);
                            }

                        }else{
                            self.isBottom = false;
                            self.list = mergeList;
                            if(self.list.length>0){
                                self.showResultPage = false
                            }else{
                                self.showResultPage = true
                            }
                        }

                    } else {
                        modal.toast({ message: result.info });
                    }
                },
                function(err) {
                    modal.toast({ message: err });
                    self.loading = false;
                    self.refreshing = false;
                   self.loadingmore = false;
                   self.loadingText ='';
                }
            );
        },
        //添加凑单商品
        addActionClick:function(item){
            console.log('添加了一个商品')
            this.tempCartList.push(item)
            this.totalPrice = (Number(this.totalPrice)+Number(item.supStorePrice)).toFixed(2)
            modal.toast({message:'成功添加',duration: 0.3})
        },
        
        //去结算
        goSettlementClick: function(){
            console.log('点击了结算')
            const self = this;
            if(self.tempCartList.length==0){
                navigation.pop({animated:'true'},event=>{})
                return;
            }

            self.loading = true;
            //1.首先把凑单商品同步到购物车
            self.upCartToServer(function(){
                //2.然后重新拉去购物车数据
                DB.loadCartData(function(e){
                    self.loading = false;
                    if(e.result == 'success'){
                        storage.getItem(Define.kLocal_Cart,event=>{
                            let cartList = JSON.parse(event.data)
                            //3.最后转换成可结算的数据
                            self.settlementHandle(cartList)
                        })
                    }
                }) 
            })
            
        },
        //上传凑单商品数据到购物车
        upCartToServer: function(block) {
            const self = this;
            var updataCount = 0;
            for (let j = 0; j < this.tempCartList.length; j++){
                var objc = this.tempCartList[j];
                let supSubjectId = objc.supSubjectId?objc.supSubjectId:''
                //加入购物车所需参数
                var param = {num: "1",//商品数量
                            type: "add",//操作类型添加
                            supSubjectId:supSubjectId,//主题id
                            supGoodsId:objc.supGoodsId};//商品ID
                Fetch.post("buyer/addSuperiorGoodsCart.json", param, function(jsonString) {
                    console.log('get:'+jsonString);
                    let responeObjc = JSON.parse(jsonString);

                    updataCount = Number(updataCount) + 1;
                    let duration = 0
                    if (responeObjc.op_flag === 'fail') {
                        self.loading = false;
                        modal.toast({message:responeObjc.info,duration:0.5})
                        duration = 500
                    } 
                    if(updataCount == self.tempCartList.length){
                        //上传完成重置数组
                        self.tempCartList = []
                        setTimeout(() => {
                            block()
                        },duration)
                        
                    }

                },function(err) {
                    console.log("err:" + err);
                    if(updataCount == self.tempCartList.length){
                        block()
                    } 
                });
            }
            
        },
        //结算处理函数
        settlementHandle:function(cartList){
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
            cartList.forEach(groupSection => {
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

                        const gatherChannel = new BroadcastChannel("GatherTogetherChannel");
                        gatherChannel.postMessage(JSON.stringify(goodsData));

                        navigation.pop({animated:'true'}, event =>{});
                    }else{
                        navigation.push({url:'login_login.html'}, event =>{});
                    }   
                });
            }else{
                modal.toast({message:'请选择商品',duration:0.3})
            }
        }
    }
}
</script>

<style scoped>
.wrapper { 
    width: 750px;
}
.waterfall{
    width: 750px;
    flex: 1;
    /* background-color: aqua; */
}
.content{
    background-color: #ffffff;
    height: 440px;
    border-width: 1px;
    border-color: #f5f5f5; 
}
.itemImg {
    align-self: center;
    width: 330px;
    height: 240px;
    /* background-color: #f0f0f0; */
}
.contentDes{
    align-self: flex-start;
    padding-bottom: 20px;
    padding-left: 20px;
    padding-right: 14px;
    /* background-color: #00cc99; */
}
.item-name {
    color: #333333;
    font-size: 30px;
    padding-top: 20px;
    text-overflow:ellipsis;
    lines:1;
}
.item-des {
    color: #999999;
    font-size: 28px;
    padding-top: 5px;
    padding-bottom: 5px;
    text-overflow:ellipsis;
    lines:1;
}
.cartHandle {
    position: absolute;
    bottom: 10px;
    right: 5px;
    padding: 20px;
}
.add-div {
    position: relative;
    align-items: center;
    justify-content: center;
    flex-direction: row;
    border-width:2px;
    border-color:#ff0033;
    width:40px;
    height:40px;
    border-radius:20px;
}
.bottom-line {
    width: 750px;
    align-items: center;
    background-color: #FFFFFF;
}
.bottom{
    height: 150px;
    width: 750px;
    flex-direction: row;
    align-items: center;
    justify-content: flex-end;
}
.button{
    height: 76px;
    width: 210px;
    line-height: 76px;
    background-color: #ff0033;
    border-radius: 5px;
    color: #ffffff;
    font-size: 36px;
    margin-right: 48px;
    margin-left: 20px;
    text-align: center;
}
.button:active {
    background-color: #ce1c40;
}

.refresh {
    width: 750px;
    height: 140px;
    display: -ms-flex;
    display: -webkit-flex;
    display: flex;
    /* flex-direction: row; */
    /* justify-content: center; */
    -ms-flex-align: center;
    -webkit-align-items: center;
    -webkit-box-align: center;
    align-items: center;
  }
.indicator-text {
    color: #888888;
    font-size: 30px;
    text-align: center;
  }
  .indicator {
    margin-top: 16px;
    height: 40px;
    width: 40px;
    color: #888888;
  }
  .loading {
    width: 750px;
    height: 180px;
    display: -ms-flex;
    display: -webkit-flex;
    display: flex;
    -ms-flex-align: center;
    -webkit-align-items: center;
    -webkit-box-align: center;
    align-items: center;
  }
</style>
