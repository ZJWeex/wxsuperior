<!-- 优选二级分类数据  -->
<template>
<div class="wrapper">
    <navigationSearch title="搜索商品" :showInput="false"
                        @wxcMinibarMiddleButtonClicked='wxcMinibarMiddleButtonClicked'/>
    <scroller class="scroller" alwaysScrollableVertical='true'
              scroll-direction="vertical"
              loadmoreoffset="10" 
              @loadmore="loadmore">
        <refresh class="refresh" @refresh="onrefresh" 
                :display="refreshing ? 'show' : 'hide'" 
                @pullingdown="onpullingdown">
            <text class="indicator-text">{{refreshText}}</text>
            <loading-indicator class="indicator"></loading-indicator>
        </refresh>
        <div :style="{'background-color':classInfo.class_color}">
            <!-- 显示头图-->
            <div v-if="classInfo.header_disable =='false'&&classInfo.head_icon.length>0" class="header">
                <image style="height:80px;width:750px;" resize="contain" :src="classInfo.head_icon"/>
            </div>
            <!-- 显示分栏名称 -->
            <div  v-else class="header">
                <!-- 商品单列显示时 -->
                <text style="color:#666666;font-size:40px;">{{classInfo.className}}</text>
            </div>
        </div>
        <div class="content" :style="{'background-color':classInfo.class_color}">
            <div v-for="(model,i) in classInfo.goodsList" :key="i">
                <!-- 老版使用bigImage判断使用单排还是双排展示 -->
                <div v-if="(classInfo.layoutType && classInfo.layoutType == 1) || (i == 0 && classInfo.goodsList.length%2 == 1)">
                    <wxc-pan-item  @wxcPanItemClicked="cellClick(model)">
                        <div class="bigcell">
                            <image class="bigImg" resize="contain" :src="model.goodsImage"/>
                            <div class="textcontent">
                                <text class="textName" style="width: 370px;lines: 2;text-overflow: ellipsis;margin-top: 20px; ">{{model.supGoodsName}}</text>
                                <text class="textDes" style="width: 370px;lines: 2;text-overflow: ellipsis;">{{model.supGoodsDescribe}}</text>
                                <div class="text-price">
                                    <text style="font-size: 30px;color: #ff0033">¥</text>
                                    <text style="font-size: 44px;color: #ff0033">{{model.storePrice}}</text>
                                </div>
                            </div>
                        </div>
                    </wxc-pan-item>
                </div>
                <div v-else>
                    <div class="smallcell">
                        <wxc-pan-item  @wxcPanItemClicked="cellClick(model)"> 
                            <image class="smallImg" resize="contain" :src="model.goodsImage"/>
                            <div>
                                <text class="textName">{{model.supGoodsName}}</text>
                                <text class="textDes">{{model.supGoodsDescribe}}</text>
                                <div class="text-price">
                                    <text style="font-size: 30px;color: #ff0033">¥</text>
                                    <text style="font-size: 44px;color: #ff0033">{{model.storePrice}}</text>
                                </div>
                            </div>
                        </wxc-pan-item>  
                    </div>
                </div> 
            </div>
        </div>
        <div v-if="isBottom" :style="{'background-color':classInfo.class_color,'align-items':'center'}">
            <text style="padding:30px;color:#666666;font-size:28px;">--  食品安全和膳食营养是我们的底线  --</text>
        </div>
        <!-- 目的：android全面屏物理键可隐藏和显示 -->
        <div v-if="isAndroid" style="height:100px;width:750px;"></div>
    </scroller>
</div>
</template>

<script>
import Fetch from '@/base-superior/Fetch.js'
import Define from "@/base-superior/Define.js";
import navigationSearch from "@/base-superior/components/NavigationBarSearch.vue";
import { WxcPanItem } from 'weex-ui';
const modal = weex.requireModule("modal");
const storage = weex.requireModule("storage");

export default {
    components: { WxcPanItem, navigationSearch },
     data() {
         return {
             isAndroid:WXEnvironment.platform === 'android',
             refreshing: false,
             refreshText:'下拉刷新',
             isBottom:false,
             classId:'',
             classInfo: {goodsList:[],class_color:'#ffffff',}
         }
     },
     created() {
        const self = this;
        storage.getItem('secondClassItem', event=>{
            console.log(event)
            if (event.result === 'success') {
                let result = JSON.parse(event.data)
                if(result.classId && result.classId != 'undefined'){
                    self.classId = result.classId
                }else{
                    self.classId = result.categoryId;
                }
                this.loadData();
            }
        })
         
     },
     
     methods: {
          //加载数据
          loadData: function() {
              var that = this;
              var param = {'second_class_id': that.classId}
              let uri = 'superior/secondGoods_list.json';
              
              Fetch.post(uri, param, function(jsonStr){
                  setTimeout(() => {
                      that.refreshing = false;
                    }, 1000)
                  var result = JSON.parse(jsonStr)
                  console.log('byClass:'+jsonStr);
                if(result.op_flag == 'success'){
                    that.isBottom = true;
                    /*
                    //测试用
                    result.classInfo.class_color = "#ff0033"
                    result.classInfo.layoutType = '0'
                    */
                    that.classInfo = result.classInfo;
                } 

              },function(err){
                  console.log('err:'+err);
                  modal.toast({
                    message: err,
                  })
                  that.refreshing = false;
              })
          },
          //点击事件
          cellClick: function(model){
              console.log('商品：'+model.supGoodsName)

                if(model.isGiftCard == 'true'){
                    storage.setItem('goods_giftVoucher', JSON.stringify({goodsId:model.goodsId, goodsName:model.supGoodsName}),event =>{})
                    let url = 'goods_giftVoucher.html'
                    navigationSearch.push({url:url, title:model.supGoodsName}, event =>{})
                } else {
                    storage.setItem(Define.kSuperior_goods_id, model.goodsId, event =>{})
                    let url = 'goods_goodsDetail.html'
                    navigationSearch.push({url:url, title:'商品详情'}, event =>{
                    });
                }
             
          },
          //下拉刷新事件
          onrefresh(event) {
              this.refreshing = true
              this.page = 1;
              this.loadData();  
          },
          onpullingdown (event) {

          },
          //上啦加载
          onloading (event) {
            if(!this.isBottom){
                this.loadingText = 'Loading ...'
                this.loadinging = true
                setTimeout(() => {
                    this.page = this.page + 1;
                    this.loadData();
                }, 300)
                
            }
            
        },
        //scroll滚动到底部时触发该事件
        loadmore:function(e){
            const self = this;
            if(WXEnvironment.platform == 'android'){
                self.onloading(e);
                 //loadmore重置函数
                e.target.resetLoadmore();
            }
        },
        wxcMinibarMiddleButtonClicked () {
            console.log('点击搜索')
            // 搜索界面
            navigationSearch.push({url:'homepage_search.html', title:''}, event =>{});
        },
     }

}
</script>

<style scoped>
.wrapper {
    align-items: center;
    background-color: #FFFFFF;
  }
.scroller {
    flex: 1;
    width: 750px;
    flex-direction: column;
}
.content {
    flex-direction: row;
    flex-wrap: wrap;
    padding-top: 10px;
    padding-left: 10px;
    padding-right: 10px;
    justify-content: space-between;
    width: 750px;
}
.header{
    height: 80px;
    width: 750px;
    justify-content: center;
    align-items: center;
}
.header-flex-start {
    color:#666666;
    font-size:40px;
    align-self:flex-start;
    padding-left:56px;
}
.bigcell {
    margin-bottom: 5px;
    width: 730px;
    flex-direction: row;
    background-color:white;
    border-radius: 10px;
}
.bigImg{
    width: 340px;
    height: 260px;
}
.smallcell {
    background-color:white;
    margin-bottom: 10px;
    border-radius: 10px;
}
.smallImg{
    width: 364px;
    height: 240px;
}
.textcontent{
    justify-content: center;
    flex-direction: column;
    margin-left: 10px;
    margin-right: 10px;
}
.text-price{
    flex-direction: row;
    align-items: center;
    margin-left: 20px;
    margin-bottom: 40px;
}
.textName{
    lines: 1;
    margin-bottom: 10px;
    text-overflow: ellipsis;
    font-size: 30px;
    width: 325px;
    margin-left: 20px;
    margin-right: 10px;
    color: #333;
}
.textDes {
    lines: 1;
    text-overflow: ellipsis;
    font-size: 28px;
    width: 325px;
    margin-left: 20px;
    margin-right: 10px;
    color: #666; 
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
  
</style>