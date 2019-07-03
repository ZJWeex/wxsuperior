<template>
<!-- 推荐商品 -->
    <div class='wrapper'>
        <div v-if="commendGoodsList.length > 0">
            <text class="commend-title">推荐商品</text>
        </div>
        <div v-if="commendGoodsList.length > 0">
            <div v-for="(item, i) in commendGoodsList" :key="i" @click="didTapGoodsClick(item)" class="commend-content">
                <image style="width:198px; height:134px; background-color:#f0f0f0; margin-left:26px;" :src="item.goodsImgURLs"/>
                <div style="flex:1; margin-left:10px; margin-right:26px;">
                    <text class="commend-goods-name">{{item.supGoodsName}}</text>
                    <text class="commend-goods-desc">{{item.supGoodsSpecs}}</text>
                    <div style="flex-direction: row; justify-content: space-between; align-items: center;">
                        <text class="commend-goods-price">¥{{item.supStorePrice}}</text>
                        <div v-if="item.count>0" style="flex-direction: row;align-items: center;">
                            <div style="width:72px;height:46px;align-items: center;" @click="reduceGoodsClick(item)">
                                <image style="width:46px; height:46px;" resize="contain" src="/web/assets/sup/sup_cart_reduce.png" @click="reduceGoodsClick(item)" />
                            </div>
                            <text style="font-size:30px;">{{item.count}}</text>
                            <div style="width:72px;height:46px;align-items: center;" @click="addGoodsClick(item)">
                                <image style="width:46px; height:46px;" resize="contain" src="/web/assets/sup/sup_cart_add.png" @click="addGoodsClick(item)" />
                            </div>
                        </div>
                        <div v-else style="flex-direction: row; align-items: center;">
                            <div style="width:72px;height:46px;"></div>
                            <text></text>
                            <div style="width:72px;height:46px;align-items: center;" @click="addGoodsClick(item)">
                                <image style="width:46px; height:46px;" resize="contain" src="/web/assets/sup/sup_homeSearch_cartIcon.png" @click="addGoodsClick(item)"/>
                            </div>    
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import Fetch from "@/base-superior/Fetch.js";
import Define from "@/base-superior/Define.js";
import DB from "@/base-superior/shopping_cartdb.js";
import navigation from "@/base-superior/components/NavigationBar.vue";

const storage = weex.requireModule("storage");
const modal = weex.requireModule('modal');

export default {
    components: { },
    props:{
        useClick:{
            type: Boolean,//是否使用内部的跳转事件
            default:true
        },
        supSubjectId:{
            type:String,
            default:''
        }
    },
    data() {
        return {
            commendGoodsList:[],// 推荐商品数组
        }
    },
    created() {
        this.loadCommendGoodsData()
        const self = this;
        const refreshCommendGoodsChannel = new BroadcastChannel("refreshCommendGoods");
        refreshCommendGoodsChannel.onmessage = function(event) {
            console.log('推荐商品：',event);
            self.refreshCommendGoodsModule();
        };
    },
    methods: {
        //点击商品方法
        didTapGoodsClick:function (item){
            if(this.useClick){
                if (item.isGiftCard == "1") {
                    // 礼品卡 商品详情
                    storage.setItem('goods_giftVoucher', JSON.stringify({goodsId:item.supGoodsId,goodsName:item.supGoodsName}),event =>{})
                    let url = 'goods_giftVoucher.html'
                    if(WXEnvironment.platform.toLowerCase() === 'web'){
                        url = '../goods_giftVoucher.html'
                    }
                    navigation.push({url:url, title:item.supGoodsName}, event =>{})
                } else {
                    // 普通商品 商品详情
                    storage.setItem(Define.kSuperior_goods_id, item.supGoodsId, event =>{})
                    let url = 'goods_goodsDetail.html'
                    if(WXEnvironment.platform.toLowerCase() === 'web'){
                        url = '../goods_goodsDetail.html'
                    }
                    navigation.push({url:url, title:'商品详情'}, event =>{});
                }
            }else{
                 this.$emit('onClick',item);
            } 
        },
        //改变商品数量
        changeGoodsCount:function(){
            DB.postBadgeNotification();
            this.$emit('changeGoodsCount',{}); 
        },
        //刷新推荐商品模块
        refreshCommendGoodsModule:function(){
            const self = this;
            let goodsList = this.commendGoodsList.map(function(item){
                        DB.getItem(item.supGoodsId, function(ret) {
                                if (ret.data != 'undefined' && ret.data.length > 0){
                                    var goodsModel = JSON.parse(ret.data)
                                    if (item.supGoodsId == goodsModel.supGoodsId) {
                                        // console.log('找到对应商品111：',goodsModel.count)
                                         item.count = goodsModel.count;
                                    }
                                }else{
                                    // console.log('没有找到对应商品')
                                    item.count = '0'
                                }
                            });
                        return item
                    })

                setTimeout(function (){
                    console.log('刷新推荐商品数据')
                    self.commendGoodsList = goodsList;
                },100)
            
        },
        //加载推荐商品
        loadCommendGoodsData:function () {
            console.log('推荐商品')
            const self = this;
            var param = {};
            Fetch.post("superiorGoodsCommend.json",param,function(jsonString) {
                var result = JSON.parse(jsonString);
                if (result.op_flag === "success") {
                    console.log('推荐商品：',jsonString)
                        
                    self.commendGoodsList = result.goodsList.filter(function(item){
                        if(item.supplier == "淘菜猫优选旗舰店"){
                            // 赋值，与购物车接口返回字段不一致 
                            item.supGoodsName = item.superiorName
                            item.supStorePrice = item.storePrice
                            item.supGoodsPrice = item.goodsPrice
                            item.supGoodsId = item.id
                            item.count = 0
                            DB.getItem(item.supGoodsId, function(ret) {
                                if (ret.data != 'undefined' && ret.data.length > 0){
                                    var goodsModel = JSON.parse(ret.data)
                                    if (item.supGoodsId == goodsModel.supGoodsId) {
                                        console.log('找到对应商品：',goodsModel.count)
                                        // item.count = goodsModel.count;
                                        self.$set(item,"count",goodsModel.count)
                                    }
                                }
                            });
                            return item
                        }
                    })
                        
                } else {
                    modal.toast({
                        message: result.info,
                        duration: 1.0
                    });
                }
            },function(err) {
                modal.toast({
                    message:err,
                    duration:1.0
                })
            });
        },
        //添加商品
        addGoodsClick:function(item){
            if(item.count >= item.inventory){
                modal.toast({message:'库存不足', duration:0.5})
            }else{
                item.count = parseInt(item.count)+1;
                this.addOrReduceEvent(item,true);
            }
            
        },
        //减去商品
        reduceGoodsClick:function(item){
            this.addOrReduceEvent(item,false);
            item.count = parseInt(item.count)-1;
        },
        // 增加/减少 改变商品数量
        addOrReduceEvent:function(objc, isAdd){
            const self = this;
            Define.getItem('JESSIONID')
            .then(ret =>{
                //登陆状态
                var sessionid = ret.data;
                DB.getItem(objc.supGoodsId, function(e){
                    if (e.data != 'undefined' && e.data.length > 0){
                        var item = JSON.parse(e.data)
                        //购物车存在
                        
                        // 网络请求
                        let operationType = isAdd ? 'add':'sub';
                        var param = {
                            type:operationType,//操作类型
                            supGoodsId:objc.supGoodsId,//商品ID
                            supSubjectId:objc.supSubjectId,//主题ID
                            num:'1',
                        }
                        var url = 'buyer/addSuperiorGoodsCart.json'
                        Fetch.post(url, param, function(respone){
                           console.log("修改："+ JSON.stringify(respone))
                            var result = JSON.parse(respone)
                            if(result.op_flag == 'success'){
                                if(isAdd){
                                    // modal.toast({message:'成功添加', duration: 0.3})
                                }else{
                                    // modal.toast({message:'成功减去', duration: 0.3})  
                                }
                                DB.changeItemCount(objc.supGoodsId, isAdd ? 'add':'sub', event => {
                                    //如果减少且商品数量<1时，调用删除操作
                                    if(!isAdd && objc.count < 1){
                                        item.bgcId = result.goodsCart_id
                                        self.deleAGoodsEvent(item);    
                                    }else{
                                        self.changeGoodsCount();
                                    }
                                        
                                })
                            }else{
                                modal.toast({message:result.info})
                                if(isAdd){
                                    objc.count = parseInt(objc.count) - 1;
                                }else{
                                    objc.count = parseInt(objc.count) + 1;
                                }
                            }
                        }, function(err){
                            modal.toast({message:err})
                            if(isAdd){
                                objc.count = parseInt(objc.count) - 1;
                            }else{
                                objc.count = parseInt(objc.count) + 1;
                            }
                                
                        });
                    }else{
                        if(isAdd){
                            //之前购物车不存在
                            if(objc.inventory > 0){
                                self.addCartToServer(objc);
                            }else {
                                modal.toast({message:'库存不足', duration:0.5})
                            }
                        }
                        
                    }
                    
                })
                  
            },reject => {
                //未登陆状态
                DB.getItem(objc.supGoodsId, function(e){
                    if (e.data != 'undefined' && e.data.length > 0){
                        var item = JSON.parse(e.data)
                        if(item.count>1 || !isAdd){
                            //商品存在，修改本地数据库数据
                            DB.changeItemCount(objc.supGoodsId, isAdd ? 'add':'sub', event => {
                                self.changeGoodsCount();
                            })
                        }else{
                            //商品不存在
                            isAdd && self.saveDataLocal(objc,event=>{
                                var message = '加入购物车失败'
                                if(event.result == 'success'){
                                    self.changeGoodsCount();
                                    message = '加入购物车成功' 

                                }else if (ent.data == '库存不足') {
                                    message = '库存不足'
                                }
                                modal.toast({
                                    message:message,
                                    duration:0.5
                                });
                            })
                        }
                    }else{
                        //商品不存在
                        isAdd && self.saveDataLocal(objc,event=>{
                            var message = '加入购物车失败'
                            if(event.result == 'success'){
                                self.changeGoodsCount();
                                message = '加入购物车成功'
                            }else if (ent.data == '库存不足') {
                                message = '库存不足'
                            }
                            modal.toast({
                                message:message,
                                duration:0.5
                            });
                        })
                    }
                })
                    
            })
        },
        //加入购物车
        addCartToServer: function(item) {
            const self = this;
            //加入购物车所需参数
            var param = {num: "1",//商品数量
                        type: "add",//操作类型添加
                        supSubjectId:self.supSubjectId,//主题id
                        supGoodsId:item.supGoodsId};//商品ID
            Fetch.post("buyer/addSuperiorGoodsCart.json", param, function(jsonString) {
                console.log('get:'+jsonString);
                let responeObjc = JSON.parse(jsonString);
                if (responeObjc.op_flag === 'success') {
                    //⚠️保存返回的购物车ID很重要
                    item.bgcId = responeObjc.goodsCart_id;
                    //存入本地
                    self.saveDataLocal(item, event=>{})
                    
                    responeObjc = {op_flag:"success",
                    info:'加入购物车成功',
                    goodsCart_id:'xx',
                    count:'1',}
                    modal.toast({message:responeObjc.info,
                                duration:0.3});
                } else {
                    modal.toast({
                        message: responeObjc.info,
                        duration: 0.3
                    }, function (value) {
                        console.log('alert callback', value)
                    })
               }
            },function(err) {
                console.log("err:" + err);
                modal.toast({message:err}); 
           });
        },
        //数据保存本地
        saveDataLocal:function (item, callback){
            var goodsData = {
                        "expiryStatus": "false",//失效状态
                        "supplierId": item.supplier_id,//供货商id
                        "checkScope": "1",
                        "useNormalFlag": "true",//能否使用普通优惠券
                        "count": "1",
                        "goodsImgURLs": item.goodsImgURLs,
                        "supSubjectId": this.supSubjectId,//主题id
                        "orderStartPrice": "",//满免邮费金额
                        "supGoodsSpecs": item.supGoodsSpecs,//规格如200g/盒
                        "activityPower": [],
                        "supCartId": "",
                        "bgcId": item.bgcId,//菜篮子id
                        "shipPrice": "",//配送费
                        "supGoodsName": item.supGoodsName,
                        "supGoodsInventory": item.inventory,//库存量
                        "supGoodsId": item.supGoodsId,//优品商品id
                        "mainImgURL": item.goodsImgURLs,
                        "name": "",
                        "mainHeight": "541",
                        "supStorePrice": item.supStorePrice,//现价
                        "mainWidth": "750"
                    }
            if (goodsData.supGoodsInventory > 0) {
                //存入本地数据库            
                DB.setItem(goodsData,event=>{
                    callback(event);
                });
            } else {
                var event = {
                    result:'fail',
                    data:'库存不足'
                }
                callback(event);
            }
        },
        //删除单个商品
        deleAGoodsEvent:function(item){
            const self = this;
            var param = {bgcId:item.bgcId}
            // console.log('删除：'+JSON.stringify(item))
            var url = 'buyer/delBuyerGoodsCart.json';
            Fetch.post(url, param, function(respone){
                console.log('删除：'+respone)
                var result = JSON.parse(respone)
                if(result.op_flag == 'success'){
                    modal.toast({message:'删除成功',duration: 0.3})
                    DB.changeItemCount(item.supGoodsId,'sub', event => {
                        self.changeGoodsCount();
                    })
                }else{
                    modal.toast({message:result.info})
                }
            }, function(err){
                modal.toast({message:err})
            });
            
        },

    }
}
</script>

<style scoped>
.wrapper { 
    width: 750px;
    justify-content: center;
}
.commend-title {
    color:#333333;
    font-size:32px; 
    font-weight: bold; 
    padding-left:30px; 
    padding-top:26px; 
    padding-right:30px;
}
.commend-content {
    flex-direction: row;
    align-items: center;
    padding-top: 30px;
    padding-bottom: 30px;
    border-bottom-width: 1px;
    border-bottom-color: #f0f0f0;
}
.commend-goods-name {
    font-size: 32px;
    color: #333333;
}
.commend-goods-desc {
    flex:1;
    font-size: 24px;
    color: #666666;
    text-overflow: ellipsis;
    lines:1;
    height: 50px;
    line-height: 50px;
}
.commend-goods-price {
    font-size: 36px;
    color: #e5354a;
}
</style>
