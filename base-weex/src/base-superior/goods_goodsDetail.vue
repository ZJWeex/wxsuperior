<template>
  <div @viewappear="viewappear">
    <navigation title="商品详情"
                    :use-default-return='isDisplayRule == false' 
                    @wxcMinibarLeftButtonClicked="isDisplayRule =false"/>
    <list class="list">
      <cell v-for="(item, index) in dataList" :key="index" :index="index">
        <div v-if="item.type === 'banner'">
          <deitail-banner :goodsImgURLs='item.goodsImgs'></deitail-banner>
          <!-- 实时监控 -->
          <div v-if="item.peasantLink.length > 0 && item.peasantLink != undefined" class="monitoring" @click="webOnClick(item.peasantLink,2)">
              <image style="width:92px;height:86px;" src='/web/assets/sup/sup_goodsDetail_jiankong.png'/>
          </div>
        </div>
        <div v-if="item.type === 'info'">
          <div class="info">
            <text class="shoppingName">{{item.goodsName}}</text>
            <text class="shoppingDes">{{item.goodsDescribe}}</text>
            <text class="price">¥{{item.storePrice}}</text>
            <div class="priceInfo">
              <text class="originalPrice | deleline">¥{{item.goodsPrice}}</text>
              <text class="originalPrice"> 已售{{item.saleNum}}份</text>
            </div>
            <div v-if="item.cloudLink.length > 0 && item.cloudLink != undefined" class="traceBtn" @click="webOnClick(item.cloudLink,1)">
                <image style="width:200px;height:41px" src='/web/assets/sup/sup_goodsDetail_trace.png'/>
            </div>
          </div>
        </div>
        <div v-if="item.type === 'spec'">
          <spec-cells :selectId='item.selectGoodsId' :specs='item.goodsSpecs' @changeItem="onChangeItem"></spec-cells>
        </div>
        <div v-if="item.type === 'active'" class="active-div" @click="activeOnClick(item.supSubjectId)">
            <div style="flex-direction: row;align-items: center;flex:1;">
                <text class="active-mark">满减</text>
                <text class="active-text">{{ item.activeInfo }}</text>
            </div>
            <wxc-icon v-if="item.supSubjectId" name="more" @wxcIconClicked="activeOnClick(item.supSubjectId)"></wxc-icon>
        </div>
        <div v-if="item.type === 'ruleTel'">
          <rule-tel :dataModel='item' :isBottomShow="isDisplayRule" @displayRule="isDisplayRule = $event"></rule-tel>
        </div>
        <div v-if="item.type === 'singeImg'">
          <div v-for="(source, i) in item.gpImgURLs" :key="i">
            <image class="singeImg" :style="{height:item.imgHeight}" :src="source" />
          </div>
        </div>
      </cell>
    </list>
    <!-- 底部菜篮子 -->
    <BottomCart class="bottomCart" :goodsModel="goodsModel"></BottomCart>
  </div>
</template>

<script>
import DeitailBanner from "@/base-superior/components/DeitailBanner.vue";
import SpecCells from "@/base-superior/components/SpecCells.vue";
import RuleTel from "@/base-superior/components/RuleTel.vue";
import BottomCart from "@/base-superior/components/BottomCart.vue";
import Define from "@/base-superior/Define.js";
import Fetch from "@/base-superior/Fetch.js";
import navigation from "@/base-superior/components/NavigationBar.vue";
import { WxcIcon } from 'weex-ui';

var modal = weex.requireModule("modal");
var animation = weex.requireModule("animation");
const storage = weex.requireModule("storage");


export default {
    components: {navigation, WxcIcon, DeitailBanner, SpecCells, RuleTel, BottomCart },
    name: "商品详情",
    data() {
        return {
            // requestdata: weex.config.requestdata,
            supGoodsId: "",
            goodsModel:{},
            dataList: [],
            isWeb: WXEnvironment.platform === "Web",
            isDisplayRule: false,
        };
    },
    created: function() {
        var that = this;

        //key确定唯一性，防止误删
        storage.getItem(Define.kSuperior_goods_id, event => {
            console.log(Define.kSuperior_goods_id + " ===" + event.data);
            that.supGoodsId = (event.data === "undefined") ? "817497735164923904" : event.data;
            if(WXEnvironment.platform !== "Web"){
                storage.removeItem(Define.kSuperior_goods_id, event => {});
            }
            console.log(Define.kSuperior_goods_id + "=" + that.supGoodsId);
            that.loadData();
        });
    },

    methods: {
        viewappear(){
            //界面显示
            const DetailViewappearChannel = new BroadcastChannel("goodsDetail_viewappear");
            DetailViewappearChannel.postMessage('viewappear')
        },
        //加载商品数据
        loadData: function() {
            var param = { supGoodsId: this.supGoodsId };
            var that = this;
            Fetch.post("superiorGoodsDetail.json",param,function(jsonString) {
                    console.log('商品详情' + jsonString)
                    var result = JSON.parse(jsonString);
                    that.supGoodsId = result.goodsDetail.supGoodsId;
                    that.goodsModel = result.goodsDetail;
                    that.resultHandle(result);
                    
                },function(err) {
                    modal.toast({message: err,duration: 0.3});
                }
            );
        },
        resultHandle: function(ret) {
            this.dataList = [];
            var result = ret.goodsDetail;
            //banner
            if (result.goodsImgURLs) {
                this.dataList.push({
                    type: "banner",
                    goodsImgs: result.goodsImgURLs,
                    peasantLink: result.peasantLink
                });
            }
            //info
            this.dataList.push({
                type: "info",
                goodsName: result.supGoodsName,
                goodsDescribe: result.supGoodsDescribe,
                goodsPrice: result.supGoodsPrice,
                storePrice: result.supStorePrice,
                saleNum: result.supGoodsSaleNum,
                cloudLink: result.cloudLink
            });
            //spec
            /*
       result.productGoodsList = [{supGoodsAliasName:'腱子肉', supGoodsId:'676877695078371328',selfFlag:'true'},
                               {supGoodsAliasName:'纯真酸奶', supGoodsId:'764587003762225152',selfFlag:'false'}]
                               */
            this.dataList.push({
                type: "spec",
                goodsSpecs: result.productGoodsList,
                selectGoodsId: result.supGoodsId
            });
            //active
            if(result.activtyPower && result.activtyPower.length>0){
                var activeStr = '';
                result.activtyPower.forEach(element => {
                    activeStr = activeStr+"满"+element.fullPrice+"减"+element.minusPrice+"  ";
                });
                this.dataList.push({
                    type: "active",
                    activeInfo: activeStr,
                    supSubjectId: result.supSubjectId
                });
            }
            //ruleTel
            this.dataList.push({
                type: "ruleTel",
                policy: result.policy,
                shippingInstructions: result.shippingInstructions,
                policyInstructions: result.policyInstructions,
                scopeInstructions: result.scopeInstructions,
                servicePhone: result.servicePhone
            });
            //singeImg
            this.dataList.push({
                type: "singeImg",
                gpImgURLs: result.gpImgURLs,
                imgHeight: result.gpImgPhotos.height
            });
        },
        onImageLoad: function(index, event) {
            var that = this;
            console.log(
                "width=" +
                    event.size.naturalWidth +
                    ",height=" +
                    event.size.naturalHeight
            );
            if (event.success) {
                var imageEl = event.target;
                if (WXEnvironment.platform === "Web") {
                    imageEl.style.width = event.size.naturalWidth + "px";
                    imageEl.style.height = event.size.naturalHeight + "px";
                } else {
                    animation.transition(
                        imageEl,
                        {
                            styles: {
                                width: event.size.naturalWidth + "px",
                                height: event.size.naturalHeight + "px"
                            },
                            duration: 0, //此处需设置为0
                            timingFunction: "ease",
                            delay: 0,
                            needLayout: true
                        },
                        function(e) {
                            console.log("fail" + e.message);
                        }
                    );
                }
            }
        },
        //查看追溯或查看实时监控
        webOnClick:function(url,type){
            if(url != undefined && url.length > 0){
                var title = ''
                if(type == 1){
                    title = '追溯信息'
                }else if(type == 2){
                    title = '智农监控'
                }
                var objc = {url:url,
                            title:title}
                storage.setItem('web_url',JSON.stringify(objc),event =>{})
                navigation.push(
                    {
                        url: "setting_agreementWeb.html",
                        title:objc.title,
                        animated: "true"
                    },
                    event => {
                        console.log("结果回调");
                    }
                );
            }
        },
        //活动点击事件
        activeOnClick:function(supSubjectId){
            if(supSubjectId != undefined && supSubjectId.length > 0){
                //活动主题ID
                storage.setItem(Define.kSubjectId, supSubjectId,event =>{})
                navigation.push({url:'active_subject.html', title:'主题活动'}, event =>{});
            }
        },
        onChangeItem: function(goodsId) {
            console.log("goodsId" + goodsId);
            this.supGoodsId = goodsId;
            this.loadData();
        }
    }
};
</script>

<style scoped>
.list {
    width: 750px;
    flex: 1;
    background-color: white;
}
.monitoring {
    position:absolute;
    top: 60px;
    right: 40px;
}
.info {
    justify-content: center;
    align-items: center;
}
.shoppingName {
    font-size: 36px;
    margin: 10px;
}
.shoppingDes {
    font-size: 28px;
    color: #999999;
    margin: 5px;
}
.price {
    font-size: 40px;
    color: red;
    margin: 5px;
}
.priceInfo {
    flex-direction: row; 
    align-items: center;
}
.originalPrice {
    font-size: 24px;
    color: #999999;
    margin: 5px;
}
.traceBtn {
    flex-direction: row;
    align-items: center;
    margin-top: 10px;
    margin-bottom: 20px;
}
.active-div {
    flex-direction: row;
    align-items: center;
    padding: 10px;
    border-top-width: 20px;
    border-top-color:#f5f5f5; 
    width: 750px;
}
.active-mark {
    margin:10px;
    padding-left: 5px;
    padding-right: 5px;
    color:brown;
    border-color:brown;
    border-width:2px;
    border-radius:10px;
    font-size: 28px;
}
.active-text {
    color:#333333;
    font-size:26px;
    flex: 1;
}
.deleline {
    text-decoration: line-through;
}
.spec {
    flex-direction: row;
    flex-wrap: wrap;
    margin-left: 20px;
    margin-right: 40px;
}
.singeImg {
    width: 750;
    height: 600;
}
.bottomCart {
    height: 100px;
    width: 750px;
}
</style>
