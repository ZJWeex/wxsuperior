<template>
  <div class="wrapper">
    <scroller class="scroller">
    
      <refresh class="refresh" @refresh="onrefresh" @pullingdown="onpullingdown" :display="refreshing ? 'show' : 'hide'">
         <text class="indicator-text">{{ refreshingPrompt }}</text>
         <loading-indicator class="indicator"></loading-indicator>
      </refresh>

      <div v-for="(ele,index) in requestdata" v-bind:key="index">
        <!-- 单列商品列表 [使用率较高]-->
        <div class="layout5" v-if="ele.layOutType == LayouType_SingleRow">
          <div v-for="group in ele.groups" v-bind:key="group.groupInfo.title">
            <image class="layout5Banner" resize="contain" :src="group.groupInfo.titleImageUrl"/>
            <div class="layout5item" v-for="goods in group.goods" v-bind:key="goods.goodsId" @click="click(goods)">
              <image class="layout5LeftImage" resize="contain" :src="goods.goodsImage"/>
              <div class="layout5Right">
                <!-- 商品名称 -->
                <text class="layout5GoodsName" style="font-size:36;font-weight: bold; marge-top:10px;">{{goods.supGoodsName}}</text>
                <text class="layout5GoodsName" style="color:#808080; font-size:28;">{{goods.supGoodsDescribe}}</text>
                <div style="flex-direction: row; align-items:center;">
                  <text class="layout5GoodsName" style="color:#FF0000; font-size:30;  padding-right: 0px;">￥</text>
                  <text class="layout5GoodsName" style="color:#FF0000; font-size:44;">{{goods.storePrice}}</text>
                  <!-- 活动信息 -->
                  <text v-if="goods.subjectActivityPower && goods.subjectActivityPower.length>0" 
                        class="layout5ActivityDes">满{{Number(goods.subjectActivityPower[0].fullPrice).toFixed(0)}}减{{Number(goods.subjectActivityPower[0].minusPrice).toFixed(0)}}</text>
                </div>
              </div>
            </div>
          </div>
        </div>
        <!--左一右二-->
        <div class="layout2" v-if="ele.layOutType == LayouType_OnePlusTwo">
          <!-- 图片 -->
            <image class="layout2LeftImage" resize="stretch" :src="ele.images[0].imageUrl" @click="click(ele.images[0])"/>
            <div class="layout2RightDiv">
              <image class="layout2RightImage" resize="stretch" :src="ele.images[1].imageUrl" @click="click(ele.images[1])"/>
              <image class="layout2RightImage" resize="stretch" :src="ele.images[2].imageUrl" @click="click(ele.images[2])"/>
            </div>
        </div>
        <!-- 活动海报 -->
        <div class="layout3" v-else-if="ele.layOutType == LayouType_Poster">
          <div v-for="img in ele.images" v-bind:key="img.id">
            <image class="layout3Item" resize="stretch" :src="img.imageUrl" @click="click(img)"/>
          </div>
        </div>
        <!-- 二分海报 -->
        <div class="layout4" v-else-if="ele.layOutType == LayouType_TwoPoster">
          <div v-for="img in ele.images" v-bind:key="img.id">
            <image class="layout4Image" resize="stretch" :src="img.imageUrl" @click="click(img)"/>
          </div>
        </div>
        <!-- 双排活动区 -->
        <div class="layout6" v-else-if="ele.layOutType == LayouType_Biserial">
          <div style="margin-top:12px;" v-for="group in ele.groups" v-bind:key="group.groupInfo.title">
            <image class="layout5Banner" resize="contain" :src="group.groupInfo.titleImageUrl"/>
            <div class="layout6Item">
              <div class="layout6GoodsItem" v-for="goods in group.goods" v-bind:key="goods.goodsId" @click="click(goods)">
                <image class="layout5LeftImage" resize="contain" :src="goods.goodsImage"/>
                <div style="margin-left:15px; ">
                  <!-- 商品名称 -->
                  <text class="layout5GoodsName" style="font-size:36;font-weight: bold; marge-top:10px;">{{goods.supGoodsName}}</text>
                  <text class="layout5GoodsName" style="color: #808080; font-size:28;">{{goods.supGoodsDescribe}}</text>
                  <div style="flex-direction: row; align-items: flex-end;">
                    <text class="layout5GoodsName" style="color:#FF0000; font-size:30;  padding-right: 0px;">￥</text>
                    <text class="layout5GoodsName" style="color:#FF0000; font-size:44;">{{goods.storePrice}}</text>
                    <!-- 活动信息 -->
                    <text v-if="goods.subjectActivityPower.length>0" class="layout5ActivityDes">满{{Number(goods.subjectActivityPower[0].fullPrice).toFixed(0)}}减{{Number(goods.subjectActivityPower[0].minusPrice).toFixed(0)}}</text>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
        <!--页面顶部Banner[使用率最低]-->
        <div v-else-if="ele.layOutType == LayouType_Slider">
         <slider class="layout1" interval="3000" auto-play="true">
            <div v-for="img in ele.images" v-bind:key="img.id">
            <image class="image" resize="stretch" :src="img.imageUrl" @click="click(img)"/>
            </div>
            <indicator class="layout1Indicator"></indicator>
         </slider>
        </div>
      </div>
      <div v-if="requestdata.length>0" class="wrapper">
        <text style="padding:30px;color:#d9d9d9;font-size:28px;">--  食品安全和膳食营养是我们的底线  --</text>
      </div>
    </scroller>
  </div>
</template>

<script>
import Fetch from '@/base-superior/Fetch.js'
import Define from "@/base-superior/Define.js";

const modal = weex.requireModule('modal')
const navigator = weex.requireModule('navigator')
const storage = weex.requireModule("storage");
var globalEvent = weex.requireModule('globalEvent')
const EventAgent = weex.requireModule('EventAgent')
const Superior = weex.requireModule('Superior')
var SuperiorEvent = {}
// var mode=weex.requireModule('myModule');

export default {
  // name: 'App',

  data () {
    return {
      testdata: weex.config.GlobalEvent,
      requestdata: [],
      response:'',
      refreshing: false,
      refreshingPrompt: '',
      LayouType_Slider: 1, // 轮播图
      LayouType_OnePlusTwo: 2, // 1+2展示
      LayouType_Poster: 3, // 单列海报
      LayouType_TwoPoster: 4, // 二分海报
      LayouType_SingleRow: 5, // 单列活动区
      LayouType_Biserial: 6 // 双排活动区
    }
  },
  created: function () {
    //加载数据
    this.loadData()
  },
  methods: {
    //加载数据
    loadData: function() {
       var that =this
      Fetch.get('superior/wechat/layoutConfig.json',{},function(jsonString){
        that.refreshing = false
        that.refreshingPrompt = '下拉刷新'
        console.log('请求成功:' + jsonString)
        that.requestdata = that.formatData(jsonString).objs

      },function(err){
        that.refreshing = false
        modal.toast({
          message: err,
        },function(vaule){})
      })
  
    },
    //点击事件
    click: function (e) {
      
      switch (e.linkType) {
        case 'receiveCouponOpt':
        {
          //新加的类型
        }
          break
        case 'subjectActivity':
        {
          //活动主题Superior.springToActiveView(e)
            storage.setItem(Define.kSubjectId,e.linkDataId,event =>{})
             let url = 'active_subject.html'
             navigator.push({url:url, title:'活动主题'}, event =>{
             });
        }
          break
        case 'goodsActivity':
          {
            //商品详情Superior.springToGoodsView(e)
            storage.setItem(Define.kSuperior_goods_id,e.linkDataId,event =>{})
             let url = 'goods_goodsDetail.html'
             navigator.push({url:url, title:'商品详情'}, event =>{
             });
          }
          break
        case 'imageUrl':
        {
          //web界面Superior.springToWebView(e)
          let title = e.title.length>0?e.title:'商品详情';
          storage.setItem('web_url',JSON.stringify({url:e.linkUrl,title:title}),event =>{})
             let url = 'setting_agreementWeb.html'
             navigator.push({url:url, title:title}, event =>{
             });
        }
          break
        default:
        {
          if(e.goodsId.length > 0){
            //商品详情
            storage.setItem(Define.kSuperior_goods_id,e.linkDataId,event =>{})
            let url = 'goods_goodsDetail.html'
            navigator.push({url:url, title:'商品详情'}, event =>{})
            }
        }
          break
      }
    },
    onrefresh (event) {
      this.refreshing = true
      this.refreshingPrompt = ''
      this.loadData();
    },
    onpullingdown (event) {
    },
    formatData: function(jsonString) {
      if (typeof jsonString == 'string') {
        // modal.toast({message: 'String'})
        try {
          var data=JSON.parse(jsonString);
          return data;
        } catch(e) {
          return jsonString;
        }
      } else {
        return jsonString;
      }
    }
  }
}
</script>

<style scoped>
  .wrapper {
    align-items: center;
    background-color: #FFFFFF;
  }
  .scroller {
    width: 750px;
    border-style: solid;
  }
  .layout1 {
    margin-top: 5px;
    height: 450px;
  }
  .layout1Indicator {
    width: 730px;
    height: 30px;
    item-color: #808080;
    item-selected-color: #FFFFFF;
    item-size: 15px;
    position: absolute;
    bottom: 30px;
  }
  .image {
    width: 750px;
    height: 450px;
  }
  .layout2{
    flex-direction: row;
    margin-top: 12px;
    margin-left: 10px;
    height: 400px;
  }
  .layout2LeftImage{
    width: 360px;
    height: 400px;
  }
  .layout2RightDiv{
    justify-content: space-between;
    left: 10;
    width: 360px;
  }
  .layout2RightImage{
    width: 360px;
    height: 195px;
  }
  .layout3{
    margin-left: 10px;
  }
  .layout3Item{
    margin-top: 12px;
    width: 730px;
    height: 280px;
  }
  .layout4{
    margin-left: 10px;
    width: 730;
    flex: 1;
    flex-direction: row;
    flex-wrap: wrap;
    justify-content: space-between;
  }
  .layout4Image{
    margin-top: 12px;
    width: 360px;
    height: 398px;
  }
  .layout5{
    margin-top: 12px;
    left: 10px;
  }
  .layout5Banner{
    width: 730px;
    height: 140px;
  }
  .layout5item{
    flex-direction: row;
    margin-top: 10px;
    width: 730px;
    height: 240px;
  }
  .layout5LeftImage{
    width: 354px;
    height: 240px;
  }
  .layout5Right{
    width: 376px;
    margin-right: 20px;
    background-color: #FFFFFF;
    justify-content: center;
  }
  
  .layout5GoodsName1{
    padding-right: 10px;
    lines:100;
  }
  .layout5ActivityDes{
    margin-left: 10px;
    border-radius: 6px;
    border-width: 1px;
    border-color: #ea3323;
    color:#ea3323;
    background-color:#ffe3e1;
    padding-left: 5px;
    padding-right:5px;
    font-size: 18px;
  }
  .layout6{
    margin-left: 10px;
  }
  .layout6Item{
    width: 730px;
    flex: 1;
    flex-direction: row;
    flex-wrap: wrap;
    justify-content: space-between;
    /* border-width: 1px; */
  }
  .layout6GoodsItem{
    background-color: #FFFFFF;
    margin-top: 10px;
    height: 480px;
    width: 360px;
    border-width: 1px;
    border-style: solid;
    border-color: whitesmoke;
  }
  .refresh {
    width: 750;
    display: -ms-flex;
    display: -webkit-flex;
    display: flex;
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
</style>
