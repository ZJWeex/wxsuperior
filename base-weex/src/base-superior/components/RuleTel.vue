<!-- 服务规则、联系客服组件  -->
<template recyclable>
  <div>
      <div class="separator"></div>
      <div class="content">  
        <div class="subItem" @click="ruleClick">
           <image style="width:40px;height:40px" src='https://s3.cn-north-1.amazonaws.com.cn/h5.taocai.mobi/down/debug.IPA/weexIcon/seticon/setup_notice.png'/>
           <text style="margin-left: 20px">服务规则</text>
       </div>
       <div class="line"></div>
       <div class="subItem">
          <div v-if="isWeb">
            <a class="aItem" href="tel:10086">
              <image style="width:40px;height:40px" src='https://s3.cn-north-1.amazonaws.com.cn/h5.taocai.mobi/down/debug.IPA/weexIcon/seticon/setup_us.png'/>
              <text style="margin-left: 20px">联系客服</text>
            </a>
          </div>
          <div v-else>
            <div class="subItem" @click="telClick">
               <image style="width:40px;height:40px" src='https://s3.cn-north-1.amazonaws.com.cn/h5.taocai.mobi/down/debug.IPA/weexIcon/seticon/setup_us.png'/>
               <text style="margin-left: 20px">联系客服</text>
               <web ref="webview" style="width: 1px; height: 20px" src=''></web>
            </div>
          </div>
       </div>
    </div>
    <wxc-popup popup-color="#ffffff"
               :show="isBottomShow"
               @wxcPopupOverlayClicked="popupOverlayBottomClick"
               pos="bottom"
               :height="[dataModel.scopeInstructions.length>22?'700':'500']">
      <div class="popup-content">
        <div style="flex-direction: row;margin-bottom:10px;align-items: center;">
          <image class="popup-img" src="/web/assets/goods_detail/qit.png"/>
          <text class="popup-title">{{ dataModel.policy }}</text>
        </div>
        <div style="flex-direction: row;margin-bottom:10px;">
          <image class="popup-img" src="/web/assets/goods_detail/fh.png"/>
          <div style="flex:1;">
            <text class="popup-title">发货说明</text>
            <text class="popup-subtitle">{{dataModel.shippingInstructions}}</text>
          </div>
        </div>
        <div style="flex-direction: row;margin-bottom:10px;">
          <image class="popup-img" src="/web/assets/goods_detail/thh.png"/>
          <div style="flex:1;">
            <text class="popup-title">退换货说明</text>
            <text class="popup-subtitle">{{ dataModel.policyInstructions }}</text>
          </div>
        </div>
        <div style="flex-direction: row;margin-bottom:10px;">
          <image class="popup-img" src="/web/assets/goods_detail/psfw.png"/>
          <div style="flex:1;">
            <text class="popup-title">配送范围</text>
            <text class="popup-subtitle">{{dataModel.scopeInstructions }}</text>
          </div>
        </div>
      </div>
    </wxc-popup>
  </div>
</template>

<script>
const modal = weex.requireModule("modal");
import { WxcPopup } from "weex-ui";
export default {
  components: { WxcPopup },
  props: ['dataModel'],
  data(){
    return {
      isWeb: WXEnvironment.platform === 'Web',
      isBottomShow: false,
    }
  },
  methods: {
      ruleClick: function() {
          // modal.toast({message:'服务规则'})
          this.isBottomShow = true;
      },
      popupOverlayBottomClick:function(){
        this.isBottomShow = false;
      },
      telClick: function() {
        var that = this;
          modal.confirm({
            message: '联系客服:' + this.dataModel.servicePhone,
            okTitle: '确定',
            cancelTitle: '取消'
          }, function(value){
            if(value === '确定') {
              if (WXEnvironment.platform === 'Web'){
                //web 获取属性getAttribute
                // modal.toast({message:'web页不支持拨打电话'})
                var webEl = that.$refs['webview'];
                console.log('web = '+ webEl.$el)
                webEl.$el.setAttribute('src',"tel:10086")
                 var webview = weex.requireModule('webview');
                webview.reload( webEl.$el);

              }else if(WXEnvironment.platform === 'iOS'){
                //使用定义的that,不要使用this
                var webEl = that.$refs.webview;
                //设置两次，否则弹出框取消后就不会再弹出
                webEl.setAttr('src',"")
                webEl.setAttr('src',"tel:" + that.dataModel.servicePhone)
                var webview = weex.requireModule('webview');
                webview.reload(webEl);
                setTimeout(function(){
                  //重置，否则滑动iOS还会弹出拨打电话弹框
                  webEl.setAttr('src',"")
                },500);
                
              }else if(WXEnvironment.platform === 'android'){
                //android使用上述方法无效
                //采用原生交互
                //  Superior.telCall(that.dataModel.servicePhone)
              }
            }
          })
      }
  }
};
</script>

<style scoped>
.content {
  height: 110px;
  /* background-color: rebeccapurple; */
  flex-direction: row;
}
.separator {
  height: 20px;
  width: 750px;
  background-color: #f5f5f5;
}
.subItem {
  width: 370px;
  justify-content: center;
  align-items: center;
  flex-direction: row;
}
.aItem {
  width: 370px;
  justify-content: center;
  align-items: center;
  flex-direction: row;
}
.line {
  width: 2px;
  margin-top: 20px;
  margin-bottom: 20px;
  background-color: #d9d9d9;
}
.popup-content {
    padding: 40px;
}
.popup-img {
  margin-right: 10px;
  width:36px;
  height:36px;
  margin-top:5px;
  /* background-color:#f0f0f0; */
}
.popup-title {
  color:#333333;
  font-size: 32px;
}
.popup-subtitle {
  color:#666666;
  font-size: 28px;
}
</style>
