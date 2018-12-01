<template>
    <div>
        <!-- header1 有活动 满xx减x -->
        <div v-if="cartItem.supGoodsList.length>0 &&cartItem.activityPower.length>0" class="header">
            <div style="flex-direction: row;justify-content: space-between;border-top-color:#f0f0f0;border-top-width:20px;border-bottom-color:#f0f0f0;border-bottom-width:2px;">
                <div style="flex-direction: row;flex:1;">
                    <image v-if="cartItem.selected == undefined || cartItem.selected" class="select-img" resize="contain" src="/web/assets/carticon/cart_check.png" @click="selectHeaderClick()" />
                    <image v-else class="select-img" resize="contain" src="/web/assets/carticon/cart_uncheck.png" @click="selectHeaderClick()" />
                    <text style="height:30px;margin-top:24px;color:#ff0033;font-size:18px;padding-left:5px;padding-right:5px;border-color:#ff0033;border-width:2px;border-radius:5px;">满减</text>
                    <text style="font-size:24px;padding:20px;flex:1;">{{ headerShowInfo() }}</text>
                </div>
                <text v-if="showCouDan" style="color:#ff0033;font-size:20px;padding-top:24px;padding-right:24px;" @click="addOnItemAction(cartItem.subjectId)">去凑单 ></text>
            </div>
        </div>
        <div v-else style="border-top-color:#f0f0f0;border-top-width:20px;"></div>
        <!-- cell -->
        <div v-if="cartItem.supGoodsList.length>0" v-for="goodsItem in cartItem.supGoodsList" :key="goodsItem.supGoodsId">
            <!-- 失效商品 -->
            <div v-if="goodsItem.expiryStatus == 'true'">
                <div class="cell-content">
                    <image class="select-img" />
                    <image style="width:206px;height:156px;background-color:#f0f0f0;" :src="goodsItem.mainImgURL" />
                    <div style="flex:1;margin-left:20px;margin-right:20px;">
                        <text class="goods-name">{{ goodsItem.supGoodsName }}</text>
                        <text class="goods-price">¥{{ goodsItem.supStorePrice }}</text>
                        <text class="goods-des">{{goodsItem.supGoodsSpecs}}</text>
                    </div>
                    <div class="mask">
                        <div v-if="editEnable">
                            <image v-if="goodsItem.selected == undefined || goodsItem.selected" class="select-img" resize="contain" src="/web/assets/carticon/cart_check.png" @click="selectCellClick(goodsItem)" />
                            <image v-else class="select-img" resize="contain" src="/web/assets/carticon/cart_uncheck.png" @click="selectCellClick(goodsItem)" />
                        </div>
                        <div v-else class="select-img"></div>
                        <text class="invalid-text"> 已失效 </text>
                    </div>
                </div>
            </div>
            <div v-else class="cell-content">
                <image v-if="goodsItem.selected == undefined || goodsItem.selected" class="select-img" resize="contain" src="/web/assets/carticon/cart_check.png" @click="selectCellClick(goodsItem)" />
                <image v-else class="select-img" resize="contain" src="/web/assets/carticon/cart_uncheck.png" @click="selectCellClick(goodsItem)" />
                <image style="width:206px;height:156px;background-color:#f0f0f0;" :src="goodsItem.mainImgURL" />
                <div style="flex:1;margin-left:20px;margin-right:20px;">
                    <text class="goods-name">{{ goodsItem.supGoodsName }}</text>
                    <text class="goods-price">¥{{ goodsItem.supStorePrice }}</text>
                    <div style="flex-direction: row;justify-content: space-between;align-items: center;">
                        <text class="goods-des">{{goodsItem.supGoodsSpecs}}</text>
                        <div style="flex-direction: row;align-items: center;">
                            <image style="width:72px;height:42px;" resize="contain" src="/web/assets/carticon/cart_reduce.png" @click="reduceGoodsCountClick(goodsItem)" />
                            <text>{{ goodsItem.count }}</text>
                            <image style="width:72px;height:42px;" resize="contain" src="/web/assets/carticon/cart_add.png" @click="addGoodsCountClick(goodsItem)" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <!-- 失效商品invalid-header -->
        <div v-if="cartItem.invalidGoodsList" class="invalid-header">
            <div style="flex-direction: row;align-items: center;border-top-color:#f0f0f0;border-top-width:20px;border-bottom-color:#f0f0f0;border-bottom-width:2px;">
                <image class="select-img" />
                <text style="color:#ff0033;font-size:18px;padding-left:5px;padding-right:5px;border-color:#ff0033;border-width:2px;border-radius:5px;">失效</text>
                <text style="font-size:24px;padding:12px;">因配送范围、库存原因导致失效的商品</text>
            </div>
        </div>
        <!-- 失效商品invalid-cell -->
        <div v-if="cartItem.invalidGoodsList" class="invalid-cell" v-for="(invalidGoods,y) in cartItem.invalidGoodsList" :key="y">
            <div class="cell-content">
                <image class="select-img" />
                <image style="width:206px;height:156px;background-color:#f0f0f0;" :src="invalidGoods.mainImgURL" />
                <div style="flex:1;margin-left:20px;margin-right:20px;">
                    <text class="goods-name">{{ invalidGoods.supGoodsName }}</text>
                    <text class="goods-price">¥{{ invalidGoods.supStorePrice }}</text>
                    <text class="goods-des">{{invalidGoods.supGoodsSpecs}}</text>
                </div>
                <div class="mask">
                    <image class="select-img" resize="contain" src="/web/assets/carticon/cart_check.png" />
                    <text style="margin-left:30px;height:40px;width:140px;border-radius:20px;background-color:rgba(0,0,0,0.5);font-size:18px;color:#ffffff;text-align: center;padding-top:5px;">超出配送范围、失效、下架</text>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import Fetch from "@/base-superior/Fetch.js";
import Define from "@/base-superior/Define.js";
import DB from "../base-superior/shopping_cartdb.js"

const modal = weex.requireModule("modal");
const navigator = weex.requireModule("navigator");
const storage = weex.requireModule("storage");

export default {
    components: {},
    props: {
        editEnable: {
            type:Boolean,
            default:false
        },
        cartItem: {
            type: Object,
            default: () => ({
                            "supGoodsList": [{
                                "expiryStatus": "false",//失效状态
                                "supplierId": "14",//供货商id
                                "checkScope": "1",
                                "useNormalFlag": "true",//能否使用普通优惠券
                                "count": "2",
                                "goodsImgURLs": ["http://tcmdefaultbucket-1253294191.cossh.myqcloud.com/img/upload/img/upload/advert/2371bddd-a259-42f4-b460-ba04b948aa0c.jpg"],
                                "supSubjectId": "740336040308068352",//主题id
                                "orderStartPrice": "99",//满免邮费金额
                                "supGoodsSpecs": "2.5kg/箱",//规格如200g/盒
                                "supCartId": "",
                                "bgcId": "829909968742072320",//菜篮子id
                                "shipPrice": "10",//配送费
                                "supGoodsName": "剑川花心洋芋",
                                "supGoodsInventory": "974",//库存量
                                "supGoodsId": "820390354377437184",//优品商品id
                                "mainImgURL": "http://tcmdefaultbucket-1253294191.cossh.myqcloud.com/img/upload/img/upload/advert/c583fc7a-08a0-40db-9ac4-c43dd536714d.jpg_middle.jpg",
                                "name": "淘菜猫优选旗舰店",
                                "mainHeight": "541",
                                "supStorePrice": "18.00",//现价
                                "mainWidth": "750"
                            }],
                            "subjectId": "740336040308068352",
                            "activityPower": [{
                                "minusPrice": "20.00",
                                "fullPrice": "199.00"
                            }]
                        })
        }
    },
    data() {
        return {
            showCouDan:false,//是否显示凑单
        };
    },
    created() {
        storage.getItem('JESSIONID', event=>{
          var sessionid = event.data;
           weex.config.sessionid = sessionid;     
        });
        // 还差多少钱享受包邮(第一次是undefined)
        console.log("还差多少钱享受包邮:"+this.cartItem.lackPrice);
    },
    methods: {
        //分区说明信息
        headerShowInfo:function(){
            const self = this;
            var str = ''
            if(this.cartItem.selected == false){
                this.cartItem.activityPower.forEach(activity => {
                    str = str+ "满"+activity.fullPrice+"元减"+activity.minusPrice+"元   ";
                });
                if(str.length > 0){
                    self.showCouDan = true;
                }
            }else{
                //计算分组金额
                var groupPrice = 0.00;
                for (let j = 0; j < this.cartItem.supGoodsList.length; j++) {
                    const itemGoods = this.cartItem.supGoodsList[j];
                    //选中的商品,区分商品是否失效
                    if(itemGoods.expiryStatus == 'false'){
                        if(itemGoods.selected == undefined ||itemGoods.selected){
                            var itemTotalPrice = itemGoods.count*itemGoods.supStorePrice;
                            groupPrice =Number(groupPrice) + Number(itemTotalPrice);
                        }
                    } 
                }
                if(this.cartItem.activityPower && this.cartItem.activityPower.length > 0){
                    var obj = self.recursiveActivityInfo(self.cartItem.activityPower,groupPrice,0)
                    str = obj.info;
                    self.showCouDan = obj.showCouDan;
                }
                
            }

            return str;
        },
        //递归法
        recursiveActivityInfo:function(activityArray,groupPrice,index){
            const self = this;
            var showCouDan = true;
            var str = ''
            if(activityArray.length == 1){
                const activity = activityArray[index];
                if(activity.fullPrice>groupPrice){
                    let lackPrice = Number(activity.fullPrice) - Number(groupPrice);
                    lackPrice = lackPrice.toFixed(2)>0?lackPrice.toFixed(2):0.00; 
                    str = "满"+activity.fullPrice+"元减"+activity.minusPrice+"元,还差"+lackPrice+"元即享";
                }else{
                    str = "已减"+activity.minusPrice+"元"
                    showCouDan = false
                }
            }else if(activityArray.length > 1){
                 if(index >activityArray.length-1){
                     index = activityArray.length-1;
                 }
                 if(index == activityArray.length-1){
                    const activity1 = activityArray[index];
                    const activity = activityArray[index-1];
                    if(activity1.fullPrice>groupPrice){
                        let lackPrice = Number(activity1.fullPrice) - Number(groupPrice);
                        lackPrice = lackPrice.toFixed(2)>0?lackPrice.toFixed(2):0.00;
                        str = "已减"+activity.minusPrice+"元，再买"+lackPrice+"减"+activity1.minusPrice+"元"
                    }else{
                        str = "已减"+activity1.minusPrice+"元"
                        showCouDan = false
                    }
                }else if(index == 0){
                     const activity = activityArray[index];
                    if(activity.fullPrice>groupPrice){
                        let lackPrice = Number(activity.fullPrice) - Number(groupPrice);
                        lackPrice = lackPrice.toFixed(2)>0?lackPrice.toFixed(2):0.00; 
                        str = "满"+activity.fullPrice+"元减"+activity.minusPrice+"元,还差"+lackPrice+"元即享";
                    }else{
                        index = index+1;
                       var obc = self.recursiveActivityInfo(activityArray,groupPrice,index);
                       return obc;
                    }
                }else{
                    const activity1 = activityArray[index];
                    const activity = activityArray[index-1];
                    if(activity1.fullPrice>groupPrice){
                        let lackPrice = Number(activity1.fullPrice) - Number(groupPrice);
                        lackPrice = lackPrice.toFixed(2)>0?lackPrice.toFixed(2):0.00; 
                        str = "已减"+activity.minusPrice+"元，再买"+lackPrice+"减"+activity1.minusPrice+"元"
                    }else{
                       index = index+1;
                       var obc = self.recursiveActivityInfo(activityArray,groupPrice,index);
                       return obc;
                    }
                }
            }

            return {info:str,showCouDan:showCouDan};
        },
        //选中header
        selectHeaderClick:function(){
            if(this.cartItem.selected == undefined){
                this.$set(this.cartItem,'selected',false);
            }else{
                this.$set(this.cartItem,'selected',!this.cartItem.selected);
            }
           for (let index = 0; index < this.cartItem.supGoodsList.length; index++) {
               var element = this.cartItem.supGoodsList[index];
               this.$set(element,'selected',this.cartItem.selected);
           }
        },
        //选中cell
        selectCellClick:function(goodsModel){
            //selected是否选中，自己添加
            if(goodsModel.selected == undefined){
                this.$set(goodsModel,'selected',false);
            }else{
                this.$set(goodsModel,'selected',!goodsModel.selected);
            }
            var unselected = true;
            for (let index = 0; index < this.cartItem.supGoodsList.length; index++) {
                const element = this.cartItem.supGoodsList[index];
                if(element.selected == false){
                    unselected = false;
                    break;
                }
            }
            this.cartItem.selected = unselected;
        },
        //商品减少操作
        reduceGoodsCountClick:function(goodsModel){
            if(goodsModel.count>1){
                this.changeGoodsCountEvent(goodsModel,false);
                goodsModel.count = parseInt(goodsModel.count) - 1;
            }else{
                const self = this;
                modal.confirm({
                    message:'确定要删除该商品吗？',
                    okTitle:'确定',
                    cancelTitle:'取消'
                },function (value) {
                    if(value == "确定"){
                        self.changeGoodsCountEvent(goodsModel,false);
                    }
                });
            }
        },
        //商品添加操作
        addGoodsCountClick:function(goodsModel){
            // goodsModel.supGoodsInventory = 20;
            if(goodsModel.count<goodsModel.supGoodsInventory){
                goodsModel.count = parseInt(goodsModel.count) + 1;
                this.changeGoodsCountEvent(goodsModel,true);
            }else{
                modal.toast({message:"没那么多库存了～"})
            }
        },
        //改变商品数量
        changeGoodsCountEvent:function(objc,isAdd){
            const self = this;
            if(weex.config.sessionid == 'undefined' || weex.config.sessionid.length == 0){
                DB.changeItemCount(objc.supGoodsId,isAdd ? 'add':'sub',event => {
                })
                if(!isAdd && objc.count <= 1){
                    for (let j = 0; j < self.cartItem.supGoodsList.length; j++) {
                        const element = self.cartItem.supGoodsList[j];
                        if(element.supGoodsId == objc.supGoodsId){
                            self.cartItem.supGoodsList.splice(j,1);
                            modal.toast({message:'删除成功！',duration:0.3})
                        }
                    }
                }
                return;
            }
           //如果减少且商品数量为1时，调用删除操作
           if(!isAdd && objc.count <= 1){
               this.deleAGoodsEvent(objc.bgcId);
               return;
           }
           let operationType = isAdd ? 'add':'sub';
           var param = {
               type:operationType,//操作类型
               supGoodsId:objc.supGoodsId,//商品ID
               supSubjectId:objc.supSubjectId,//主题ID
               num:'1',
           }
           var url = 'buyer/addSuperiorGoodsCart.json'

           Fetch.post(url, param, function(respone){
            //    modal.alert({message:"修改："+ JSON.stringify(respone)})
               var result = JSON.parse(respone)
                if(result.op_flag == 'success'){
                    if(isAdd){
                         modal.toast({message:'成功添加',duration: 0.3})
                    }else{
                        modal.toast({message:'成功减去',duration: 0.3})
                    }
                }else{
                    modal.toast({message:result.info})
                    if(isAdd){
                        objc.count = parseInt(objc.count) - 1;
                    }else{
                        objc.count = parseInt(objc.count) + 1;
                    }
                }
           }, function(err){
               modal.toast({message:'错误信息:'+err})
               if(isAdd){
                    objc.count = parseInt(objc.count) - 1;
                }else{
                    objc.count = parseInt(objc.count) + 1;
                }
           });
        },
         //删除单个商品
        deleAGoodsEvent:function(bgcId){
            const self = this;
           var param = {bgcId:bgcId}
           var url = 'buyer/delBuyerGoodsCart.json';
           Fetch.post(url, param, function(respone){
            //    console.log('删除：'+respone)
               var result = JSON.parse(respone)
                if(result.op_flag == 'success'){
                    for (let j = 0; j < self.cartItem.supGoodsList.length; j++) {
                            const element = self.cartItem.supGoodsList[j];
                            if(element.bgcId == bgcId){
                                self.cartItem.supGoodsList.splice(j,1);
                            }
                        }
                    modal.toast({message:'删除成功！',duration:0.3})

                }else{
                    modal.toast({message:result.info})
                }
           }, function(err){
               modal.toast({message:'错误信息:'+err})
           });

        },
        //去凑单
        addOnItemAction:function(subjectId){
            //活动主题ID
            storage.setItem(Define.kSubjectId,subjectId,event =>{})
            navigator.push({url:'active_subject.html', title:'主题活动'}, event =>{});
            storage.setItem('fromCart','fromCart',event =>{})
        },
    }
};
</script>

<style scoped>
.wrapper {
    justify-content: center;
    align-items: center;
}
.cell-content{
    flex-direction: row;
    align-items: center;
    padding-top: 20px;
    padding-bottom: 20px;
    flex: 1;
}
.select-img{
    width:76px;
    height:36px;
    margin-right:10px;
    margin-left:10px;
    margin-top:20px;
    margin-bottom:18px;
    /* background-color:red; */
}
.goods-name {
    font-size: 30px;
    color: #333333;
}
.goods-price {
    font-size: 32px;
    color: #ff0034;
}
.goods-des {
    font-size: 24px;
    color: #999999;
    flex:1;
    lines:2;
    text-overflow:ellipsis;
}
.mask {
    flex-direction: row;
    align-items: center;
    position: absolute;
    height: 200px;
    left: 0;
    right: 0;
    top: 0;
    bottom: 0;
    background-color: rgba(245, 245, 245, 0.8);
}
.invalid-text {
    height:40px;
    width:140px;
    border-radius:20px;
    background-color:rgba(0,0,0,0.5);
    font-size:18px;
    color:#ffffff;
    text-align: center;
    padding-top:5px;
    margin-left:30px;
}
</style>
