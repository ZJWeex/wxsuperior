<template>
    <div class='wrapper' @viewappear="viewappear">
        <navigation :title="title" />
        <waterfall class="waterfall" column-count=2 column-gap=20 left-gap=20 right-gap=20>
            <header class="header" v-if="headerImgURL.length>0">
                <image class="header-banner" :src="headerImgURL" />
            </header>
            <cell class="cell" v-for="item in list" :key="item.mainImgURL">
                <div class="item" @click="onItemclick(item)">
                    <image class="itemPhoto" resize="contain" :src="item.mainImgURL" />
                    <div class="sub-content">
                        <text class="item-name">{{ item.supGoodsName }}</text>
                        <text class="item-des">{{ item.supGoodsSpecs }}</text>
                        <div style="flex-direction: row;align-items: center;">
                            <text style="color:#ff0033;font-size:30px">¥</text>
                            <text style="color:#ff0033;font-size:44px">{{ item.supStorePrice }}</text>
                        </div>
                    </div>
                    <div class="add-content" @click="addActionClick(item)">
                        <div class="add-div">
                            <text class="add-text">+</text>
                        </div>
                    </div>
                </div>
            </cell>
            <div ref="fixed" class="fixedItem">
                <ButtonItem title="" :imgSize= {width:50,height:50} 
                  img="https://s3.cn-north-1.amazonaws.com.cn/h5.taocai.mobi/down/debug.IPA/weexIcon/goodsIcon/shopping_cart2x.png" 
                  :badge='cartGoodsCount' 
                  :textCong="{font:22,color:'#999',dotTop:-10,dotRight:-10}" 
                  @onclick="goToShoppingCart"></ButtonItem>
            </div>
        </waterfall>
    </div>
</template>

<script>
import Fetch from "@/base-superior/Fetch.js";
import Define from "@/base-superior/Define.js";
import DB from "@/base-superior/base-superior/shopping_cartdb.js"
import navigation from "@/base-superior/components/NavigationBar.vue";
import ButtonItem from "@/base-superior/components/ButtonItem.vue";

const modal = weex.requireModule("modal");
const navigator = weex.requireModule("navigator");
const storage = weex.requireModule("storage");

export default {
    components: { ButtonItem, navigation },
    data() {
        return {
            title: "主题活动",
            page: 1,
            supSubjectId: "", //活动ID
            cartGoodsCount: 0,
            headerImgURL:'',
            list: []
        };
    },
    created() {
        var self = this;
        DB.getCounts(function(count){
            self.cartGoodsCount = count;
        })
        storage.getItem(Define.kSubjectId, event => {
            console.log(Define.kSubjectId + " ===" + event.data);
            if (event.data && event.data != "undefined") {
                this.supSubjectId = event.data;
                storage.removeItem(Define.kSubjectId, event => {});

                this.loadListData();
                this.loadActiveMainImg();
            }
        });
    },
    methods: {
        viewappear(){
            var self = this;
            DB.getCounts(function(count){
                self.cartGoodsCount = count;
            })
        },
        //跳转购物车
        goToShoppingCart: function() {
            storage.getItem('fromCart',function(ret){
                storage.removeItem('fromCart', event => {});
                if(ret.data != 'undefined'){
                    navigator.pop({},event=>{});
                }else{
                    storage.setItem(Define.kGoodsDetail_Cart,'active_suject',event=>{})
                    navigator.push({url:'shopping_index.html', title:'购物车'}, event =>{});
                }
            })

        },
        //item点击事件
        onItemclick:function(item){
            storage.setItem(Define.kSuperior_goods_id,item.supGoodsId,event =>{})
             let url = 'goods_goodsDetail.html'
             navigator.push({url:url, title:'商品详情'}, event =>{});
        },
        //添加购物车事件
        addActionClick:function(item){
             var self = this;
            storage.getItem('JESSIONID', event=>{
                 var sessionid = event.data;
                 var goodsData = {
                                    "expiryStatus": "false",//失效状态
                                    "supplierId": '',//供货商id
                                    "checkScope": "1",
                                    "useNormalFlag": "true",//能否使用普通优惠券
                                    "count": "1",
                                    "goodsImgURLs": '',
                                    "supSubjectId": self.supSubjectId,//主题id
                                    "orderStartPrice": "",//满免邮费金额
                                    "supGoodsSpecs": item.supGoodsSpecs,//规格如200g/盒
                                    "activityPower": item.subjectActivityPower,
                                    "supCartId": "",
                                    "bgcId": '',//菜篮子id
                                    "shipPrice": "",//配送费
                                    "supGoodsName": item.supGoodsName,
                                    "supGoodsInventory": item.supGoodsInventory,//库存量
                                    "supGoodsId": item.supGoodsId,//优品商品id
                                    "mainImgURL": item.mainImgURL,
                                    "name": "",
                                    "mainHeight": "541",
                                    "supStorePrice": item.supStorePrice,//现价
                                    "mainWidth": "750"
                                }
                 if(sessionid == 'undefined' || sessionid.length == 0){
                    //存入本地数据库            
                    DB.setItem(goodsData,event=>{
                        var message = '加入购物车失败'
                        if(event.result == 'success'){
                            message = '加入购物车成功'
                            self.cartGoodsCount =self.cartGoodsCount + 1;
                        }
                        modal.toast({message:message,
                                duration:0.5}); 
                    });
                 }else{
                     self.addCartToServer(item,ret =>{
                         //存入本地数据库            
                        DB.setItem(goodsData,event=>{
                            var message = '加入购物车失败'
                            if(event.result == 'success'){
                                message = '加入购物车成功'
                                self.cartGoodsCount =self.cartGoodsCount + 1;
                            }
                            modal.toast({message:message,
                                    duration:0.5}); 
                        });
                     });
                 }
             });
        },
        //加入购物车
        addCartToServer: function(item,callback) {
            const self = this;
            //加入购物车所需参数
           var param = {num: "1",//商品数量
                        type: "add",//操作类型添加
                        supSubjectId:self.supSubjectId,//主题id
                        supGoodsId:item.supGoodsId};//商品ID
        //   console.log('参数:'+JSON.stringify(param));
          Fetch.post("buyer/addSuperiorGoodsCart.json",param,function(jsonString) {
              console.log('get:'+jsonString);
              let responeObjc = JSON.parse(jsonString);
              if(responeObjc.op_flag === 'success'){
                  callback(responeObjc.op_flag);
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
                 modal.toast({message:err}); 
           });
        },
        //加载主题活动列表数据
        loadListData: function() {
            const self = this;
            var param = {
                supSubjectId: this.supSubjectId,
                currentPage: this.page.toString()
            };
            Fetch.post("superiorGoodsList.json",param,function(respone) {
                    var result = JSON.parse(respone);
                    var result_data = { //返回的数据结构
                        op_flag:'success',
                        supGoodsSupplierList: [
                            {
                                supplierId: "供货商id",
                                name: "供货商名称",
                                supGoodsList: [
                                    {
                                        supGoodsId: "优品商品id",
                                        supGoodsName: "优品名称",
                                        supGoodsPrice: "原价",
                                        supStorePrice: "现价",
                                        supGoodsSpecs: "规格  如 200g/盒",
                                        mainWidth: "图片宽度",
                                        mainHeight: "图片高度",
                                        mainImgURL: "商品图片",
                                        supGoodsInventory: "库存",
                                        supGoodsSaleNum: "销量",
                                        subjectActivityPower: [],
                                    }
                                ],
                            }
                        ]
                    };
                    if (result.op_flag == "success") {
                        var mergeList = [];
                        result.supGoodsSupplierList.forEach(element => {
                            mergeList = mergeList.concat(element.supGoodsList);
                        });
                        
                        if(self.page<=1){
                            self.list = mergeList;
                        }else{
                            self.list.concat(mergeList);
                        }

                    } else {
                        modal.toast({ message: result.info });
                    }
                },
                function(err) {
                    modal.toast({ message: "错误信息:" + err });
                }
            );
        },
        //获取主题活动图片
        loadActiveMainImg: function() {
            const self = this;
            var param = { supSubjectId: this.supSubjectId };
            Fetch.post("superiorSubjectGPList.json",param,function(respone) {
                    var result = JSON.parse(respone);
                    console.log('图片数据：'+respone);
                    if (result.op_flag == "success") {
                        if(result.subjectBannerImgURLs.length>0){
                            self.headerImgURL = result.subjectBannerImgURLs[0];
                        }
                    }else{
                        console.log(result.info)
                    }
                },
                function(err) {
                    console.log("错误信息："+err)
                }
            );
        }
    }
};
</script>

<style scoped>
.wrapper {
    align-items: center;
}
.waterfall {
    width: 750px;
    flex: 1; 
}
.header-banner {
    width: 750px;
    height: 590px;
    background-color: #f0f0f0;
}

.item {
    align-items: center;
    border-width: 2px;
    border-color: #c8c8c8;
    margin-top: 10;
    margin-bottom: 10;
}
.itemPhoto {
    width: 330;
    height: 260;
    /* background-color: #f0f0f0; */
}
.item-name {
    color: #333333;
    font-size: 36px;
}
.item-des {
    color: #666666;
    font-size: 28px;
    padding-top: 5px;
    padding-bottom: 5px;
}
.sub-content{
    align-self: flex-start;
    padding-bottom: 20px;
    padding-left: 14px;
    padding-right: 14px;
    /* background-color: #00cc99; */
}
.add-content {
    position: absolute;
    bottom: 5px;
    right: 5px;
    padding: 20px;
}
.add-div {
    align-items: center;
    justify-content: center;
    border-width:2px;
    border-color:#ff0033;
    width:40px;
    height:40px;
    border-radius:20px;
}
.add-text { 
    color:#ff0033;
    font-size:60px;
    font-weight: 200;
    padding-bottom: 10px;
}

.fixedItem {
    position: fixed;
    width: 100;
    height: 100;
    background-color: #f0f0f0;
    right: 32;
    bottom: 80;
    border-radius: 50;
    align-items: center;
    justify-content: center;
}

</style>
