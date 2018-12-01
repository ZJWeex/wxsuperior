<!-- 底部加入购物车组件 -->
<template>
  <div class="inCart">
    <div class="left-content">
      <ButtonItem class="homeIcon" title="首页"
                  :imgSize= {width:45,height:45}
                  img="https://s3.cn-north-1.amazonaws.com.cn/h5.taocai.mobi/down/debug.IPA/weexIcon/goodsIcon/home2x.png" 
                  :textCong="{font:22,color:'#999'}" 
                  @onclick="gobackHome"></ButtonItem>
      <ButtonItem class="cartIcon" title="购物车"
                  :imgSize= {width:45,height:45} 
                  img="https://s3.cn-north-1.amazonaws.com.cn/h5.taocai.mobi/down/debug.IPA/weexIcon/goodsIcon/shopping_cart2x.png" 
                  :badge='cartGoodsCount' 
                  :textCong="{font:22,color:'#999',dotTop:-10,dotRight:20}" 
                  @onclick="gobackCart"></ButtonItem>
    </div>
    <div v-if="supGoodsIdExist>0" class="right-content" @click="addToCart">
      <text class="add-cart-text">加入购物车</text>
    </div>
    <div v-else class="right-contentenble">
      <text class="add-cart-text">加入购物车</text>
    </div>
  </div>
</template>

<script>
import ButtonItem from "@/base-superior/components/ButtonItem.vue";
import Fetch from "@/base-superior/Fetch.js";
import Define from "@/base-superior/Define.js";
import DB from "@/base-superior/base-superior/shopping_cartdb.js"

const navigator = weex.requireModule('navigator')
var modal = weex.requireModule("modal");
const storage = weex.requireModule("storage");

export default {
    components: { ButtonItem },
    props: {
        goodsModel: {
            type: Object, //加入购物车所需参数
            default: () => ({
                num: "1",
                supSubjectId: "",//主题id
                supGoodsId: "",//商品ID
                type: "add" //操作类型未添加
            })
        }
    },
    data() {
        return {
            cartGoodsCount: 0,
        };
    },
    computed:{
        supGoodsIdExist:function(){
            var str = '';
            if(this.goodsModel.supGoodsId == undefined){
                str = ''
            }else{
                str = this.goodsModel.supGoodsId;
            }
            return str.length;
        },
    },
    created() {
        var self = this;
        const DetailViewappearChannel = new BroadcastChannel("goodsDetail_viewappear");
        DetailViewappearChannel.onmessage = function (event){
            console.log('通道名称：',event.data)
              DB.getCounts(function(count){
                self.cartGoodsCount = count;
            }) 
        }
        DB.getCounts(function(count){
            self.cartGoodsCount = count;
        })
    },
    methods: {
        //添加购物车:分登录和游客模式
        addToCart:function(){
            // modal.alert({message:JSON.stringify(this.goodsModel)})
             var self = this;
            storage.getItem('JESSIONID', event=>{
                 var sessionid = event.data;
                 if(sessionid == 'undefined' || sessionid.length == 0){
                    self.saveDataLocal(self.goodsModel,function(ent){
                        var message = '加入购物车失败'
                        if(ent.result == 'success'){
                            message = '加入购物车成功'
                            self.cartGoodsCount +=1;
                        }else if(ent.data == '库存不足'){
                            message = '库存不足'
                        }
                        modal.toast({message:message,
                                duration:0.5}); 
                    })
                 }else{
                     DB.getItem(self.goodsModel.supGoodsId,function(ret){
                         if (ret.data != 'undefined' && ret.data.length > 0){
                             var item = JSON.parse(ret.data)
                            if(item.count>=self.goodsModel.supGoodsInventory){
                                modal.toast({message:'库存不足'})
                            }else{
                                self.addCartToServer();
                            }
                         }else{
                             if(self.goodsModel.supGoodsInventory > 0){
                                 self.addCartToServer();
                             }else{
                                 modal.toast({message:'库存不足'})
                             }
                         }
                     });
                     
                 }
             });
        },
        addCartToServer: function(e) {
            const self = this;
            //加入购物车所需参数
           var param = {num: "1",//商品数量
                        type: "add",//操作类型添加
                        supSubjectId:this.goodsModel.supSubjectId,//主题id
                        supGoodsId:this.goodsModel.supGoodsId};//商品ID
        //   console.log('参数:'+JSON.stringify(param));
          Fetch.post("buyer/addSuperiorGoodsCart.json",param,function(jsonString) {
              console.log('get:'+jsonString);
              //sessionId;touristId
              let responeObjc = JSON.parse(jsonString);
              if(responeObjc.op_flag === 'success'){
                  //存入本地
                 self.saveDataLocal(self.goodsModel,event=>{})
                  self.cartGoodsCount +=1;
                 responeObjc = {op_flag:"success",
                  info:'加入购物车成功',
                  goodsCart_id:'xx',
                  count:'1',}
                  modal.toast({message:responeObjc.info,
                                duration:0.3});
              }else{
                  modal.toast({
                    message: responeObjc.info,
                    duration: 0.3
                }, function (value) {
                    console.log('alert callback', value)
                })
              }
                 
            },function(err) {
                console.log("err:" + err);
                 modal.toast({message:"err:"+err}); 
           });
        },
        //数据保存本地
        saveDataLocal:function(goodsModel,callback){
            const self = this;
             var goodsData = {
                        "expiryStatus": "false",//失效状态
                        "supplierId": goodsModel.supplierId,//供货商id
                        "checkScope": "1",
                        "useNormalFlag": "true",//能否使用普通优惠券
                        "count": "1",
                        "goodsImgURLs": goodsModel.goodsImgURLs,
                        "supSubjectId": goodsModel.supSubjectId,//主题id
                        "orderStartPrice": "",//满免邮费金额
                        "supGoodsSpecs": goodsModel.supGoodsSpecs,//规格如200g/盒
                        "activityPower": goodsModel.activtyPower,
                        "supCartId": "",
                        "bgcId": goodsModel.superiorBuyerGoodsCart_id,//菜篮子id
                        "shipPrice": "",//配送费
                        "supGoodsName": goodsModel.supGoodsName,
                        "supGoodsInventory": goodsModel.supGoodsInventory,//库存量
                        "supGoodsId": goodsModel.supGoodsId,//优品商品id
                        "mainImgURL": goodsModel.goodsImgURLs[0],
                        "name": "",
                        "mainHeight": "541",
                        "supStorePrice": goodsModel.supStorePrice,//现价
                        "mainWidth": "750"
                    }
            DB.getItem(goodsData.supGoodsId,function(ret){
                if (ret.data != 'undefined' && ret.data.length > 0){
                    var item = JSON.parse(ret.data)
                    if(item.count>=goodsData.supGoodsInventory){
                        var event = {
                            result:'fail',
                            data:'库存不足'
                        }
                        callback(event);
                    }else{
                        //存入本地数据库            
                        DB.setItem(goodsData,event=>{
                            callback(event);
                        });
                    }
                }else{
                    //存入本地数据库            
                    DB.setItem(goodsData,event=>{
                        callback(event);
                    });
                }
            })
        },
        gobackHome: function() {
            navigator.go(-100,event=>{});
            // navigator.pop({},function(value){});
        },
        gobackCart: function() {
            storage.setItem(Define.kGoodsDetail_Cart,'FromGoodsDetail',event=>{})
            setTimeout(()=>{
                navigator.push({url:'shopping_index.html', title:'购物车'}, event =>{});
            },300)
            
        },
    }
};
</script>

<style scoped>
.inCart {
    flex-direction: row;
    /* background-color: #41b883; */
}
.left-content {
    flex: 6;
    flex-direction: row;
    align-items: center;
    background-color: white;
    top: 0px;
    bottom: 0px;
    left: 0px;
}
.right-content {
    flex: 5;
    flex-direction: row;
    justify-content: center;
    align-items: center;
    background-color: #ff0033;
    top: 0px;
    bottom: 0px;
    right: 0px;
}
.right-contentenble {
    flex: 5;
    flex-direction: row;
    justify-content: center;
    align-items: center;
    background-color: #d9d9d9;
    top: 0px;
    bottom: 0px;
    right: 0px;
}
.add-cart-text {
    color: white;
    font-size: 34px;
}
.homeIcon {
    margin-left: 40px;
    margin-right: 20px;
    flex: 1;
}
.cartIcon {
    margin-left: 20px;
    margin-right: 40px;
    flex: 1;
}
</style>
