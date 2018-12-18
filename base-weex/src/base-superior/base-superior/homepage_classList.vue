<!-- 优选分类数据  -->
<template>
<div class="wrapper">
    <scroller class="in-scroller" alwaysScrollableVertical='true' 
            scroll-direction="vertical" 
            loadmoreoffset="10" 
            @loadmore="loadmore">
        <refresh class="refresh" @refresh="onrefresh" 
                :display="refreshing ? 'show' : 'hide'" 
                @pullingdown="onpullingdown">
            <text class="indicator-text">{{refreshText}}</text>
            <loading-indicator class="indicator"></loading-indicator>
        </refresh>

        <div class="content">
            <div v-for="(model,i) in lists" :key="i">
                <div v-if="model.bigImage =='true'">
                    <div class="bigcell" @click="cellClick(model)">
                        <image class="bigImg" resize="contain" :src="model.goodsImage"/>
                        <div class="textcontent">
                            <text class="textName" style="width: 340px;lines: 2;text-overflow: ellipsis;margin-top: 20px; ">{{model.supGoodsName}}</text>
                            <text class="textDes" style="width: 340px;lines: 2;text-overflow: ellipsis;">{{model.supGoodsDescribe}}</text>
                            <div class="text-price">
                                <text style="font-size: 30px;color: #ff0033">¥</text>
                                <text style="font-size: 36px;color: #ff0033">{{model.storePrice}}</text>
                            </div>
                        </div>
                    </div> 
                </div>
                <div v-else>
                    <div class="smallcell" @click="cellClick(model)"> 
                        <image class="smallImg" resize="contain" :src="model.goodsImage"/>
                        <div>
                            <text class="textName">{{model.supGoodsName}}</text>
                            <text class="textDes">{{model.supGoodsDescribe}}</text>
                            <div class="text-price">
                                <text style="font-size: 30px;color: #ff0033">¥</text>
                                <text style="font-size: 34px;color: #ff0033">{{model.storePrice}}</text>
                            </div>
                        </div>  
                    </div>
                </div> 
            </div>
        </div>
        <div v-if="isBottom" class="wrapper">
            <text style="padding:30px;color:#d9d9d9;font-size:28px;">--  食品安全和膳食营养是我们的底线  --</text>
        </div>
        <!-- 加载更多 -->
        <loading v-if="!isBottom" class="loading" @loading="onloading" :display="loadinging ? 'show' : 'hide'">
            <text class="indicator-text">{{loadingText}}</text>
            <loading-indicator class="indicator"></loading-indicator>
        </loading>
    </scroller>
</div>
</template>

<style scoped>
.wrapper {
    align-items: center;
    background-color: #FFFFFF;
  }
.in-scroller {
    flex: 1;
    width: 750px;
    flex-direction: column;
}
.content {
    width: 750px;
    flex-direction: row;
    flex-wrap: wrap;
    padding-top: 10px;
    /* justify-content: flex-start; */
    /* align-items: center; */
}
.bigcell {
    margin-top: 1px;
    margin-bottom: 1px;
    flex-direction: row;
    background-color:white;
}
.bigImg{
    width: 354px;
    height: 260px;
}
.smallcell {
    background-color:white;
    margin-bottom: 2px;
    margin-left: 1px;
    margin-right: 1px;
}
.smallImg{
    width: 372px;
    height: 240px;
}
.textcontent{
    justify-content: space-around;
    flex-direction: column;
    margin-left: 20px;
    margin-right: 20px;
}
.text-price{
    flex-direction: row;
    align-items: center;
    margin-left: 20px;
    margin-bottom: 20px;
}
.textName{
    lines: 1;
    margin-bottom: 10px;
    text-overflow: ellipsis;
    font-size: 34px;
    font-weight: bold;
    width: 335px;
    margin-left: 10px;
    margin-right: 10px;
    color: #333 
}
.textDes {
    lines: 1;
    text-overflow: ellipsis;
    font-size: 28px;
    width: 335px;
    margin-left: 10px;
    margin-right: 10px;
    color: #666 
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

<script>
import Fetch from '@/base-superior/Fetch.js'
import Define from "@/base-superior/Define.js";

const modal = weex.requireModule("modal");
const navigator = weex.requireModule('navigator')
const storage = weex.requireModule("storage");

export default {
    //定义属性
    props: {
        classId: {
            default:4
        },
    },
     data() {
         return {
             refreshing: false,
             refreshText:'下拉刷新',
             isBottom:false,
             loadinging: false,
             loadingText: '',
             page:1,
             lists: []
         }
     },
     created() {
         const self = this;
         if (WXEnvironment.platform.toLowerCase() === 'web'){
             this.loadData();
         }else{
             const tabSelectedChannel = new BroadcastChannel("home_TabSelected");
            tabSelectedChannel.onmessage = function(event){
                // modal.alert({message:'data='+event.data+"id="+self.classId})
                if(event.data == self.classId){
                    if(self.lists.length == 0){
                        self.loadData();
                    }
                }
            };
         }
         
     },
     mounted: function () {
         
     },
     methods: {
          //加载数据
          loadData: function() {
              var that = this;
              var param = {'id': that.classId,'currentPage':that.page}
              let uri = 'superiorGoods/byClass.json';
              
              Fetch.post(uri, param, function(jsonStr){
                  setTimeout(() => {
                      that.refreshing = false;
                      that.loadinging = false;
                      that.loadingText ='';
                    }, 1000)
                  
                //   console.log('byClass:'+jsonStr);
                  if(that.page > 1) {
                      let arrayList = JSON.parse(jsonStr).goodsList;
                      if(arrayList.length == 0){
                          that.isBottom = true;
                      }else{
                          //拼接一个数组
                        that.lists = that.lists.concat(arrayList);
                      }
                      
                  }else{
                      that.lists = JSON.parse(jsonStr).goodsList;
                  } 

              },function(err){
                  console.log('err:'+err);
              })
          },
          //点击事件
          cellClick: function(model){
              console.log('商品：'+model.supGoodsName)
              storage.setItem(Define.kSuperior_goods_id,model.goodsId,event =>{})
             let url = 'goods_goodsDetail.html'
             navigator.push({url:url, title:'商品详情'}, event =>{
             });
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
                this.page = this.page + 1;
                this.loadData();
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
     }

}
</script>
