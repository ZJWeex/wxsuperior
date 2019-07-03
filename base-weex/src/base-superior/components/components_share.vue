<template>
    <wxc-popup ref="wxcPopup" popup-color="#f2f2f2" 
               :show="show" 
               @wxcPopupOverlayClicked="popupOverlayBottomClick" 
               pos="bottom" 
               height="440">
        <div class="content">
            <div class="title-div">
                <div style="height: 2px; width:200px; background-color: #999999"></div>
                <text style="font-size: 38px;"> 分享给好友 </text>
                <div style="height: 2px; width:200px; background-color: #999999"></div>
            </div>

            <div class="spacebetween-div">
                <div class="item"  v-for="(share, index) in platform" :key="index" @click="shareMessage(share,index)" style="margin-right: 20px;margin-left: 20px;">
                    <image style="width:120px; height:120px;" :src="share.icon"/>
                    <text style="color:#333333;font-size:28px; margin-top:20px">{{share.platformName}}</text>
                </div> 
            </div>

            <div style="height: 2px; width:750px; background-color: #999999; margin-top:20px"></div>
            <div class="bottom" @click="popupOverlayBottomCancelClick">
                <text style="font-size: 38px;color:#666666;">取消</text>
            </div>
            
        </div>
    </wxc-popup>
</template>

<script>
import { WxcPopup, WxcIcon } from 'weex-ui';
import Fetch from "@/base-superior/Fetch.js";

const modal = weex.requireModule('modal');
var globalEvent = weex.requireModule('globalEvent');

export default {
    components: { WxcPopup, WxcIcon },
    props:{
        show:{
            type: Boolean,
            default:false
        },
        shareInfo:{
            type: Object,
            default:{}
        }
    },
    data() {
        return {
            platform:[
                {
                    icon:'/web/assets/platform/umsocial_wechat_timeline.png',
                    platformName: '微信朋友圈',
                },
                {
                    icon:'/web/assets/platform/umsocial_wechat.png',
                    platformName: '微信好友',
                },
            ]
        }
    },
    created() {
    },
    methods: {
        popupOverlayBottomClick:function(event){
            this.$emit('cancelShare', {});
        },
        popupOverlayBottomCancelClick:function(event){
            this.$refs.wxcPopup.hide()
        },
        shareMessage(event, index){
            if (WXEnvironment.platform.toLowerCase() != 'ios' && WXEnvironment.platform.toLowerCase() != 'android') {
                modal.toast({
                            message: '暂不支持Web分享',
                            duration: 1.0
                        });
                this.popupOverlayBottomCancelClick()
                return 
            }
            if (!weex.supports('@module/SocialShare.sendMessage')) {
                modal.toast({
                            message: '请升级客户端至最新版本',
                            duration: 1.0
                        });

                this.popupOverlayBottomCancelClick()
                return 
            }
            

                var title = this.shareInfo.title
                var subtitle = this.shareInfo.subtitle
                var shareIcon = this.shareInfo.shareIcon
                var shareLink = this.shareInfo.shareUrl

                var SocialShare = weex.requireModule('SocialShare')
                SocialShare.sendMessage(String(index), 
                                        title, 
                                        subtitle,
                                        shareIcon, 
                                        shareLink);

                var self = this
                globalEvent.addEventListener("WEEXSocialShare", function (event) {
                    if (event.msg && event.msg.length) {
                        modal.toast({
                            message: event.msg
                        })
                    }
                    globalEvent.removeEventListener('WEEXSocialShare')
                    self.popupOverlayBottomCancelClick(null)
                })
            
        },
    }
}
</script>

<style scoped>
.content {
    width: 750px;
}
.title-div {
    margin-top: 40px;
    height: 60px;
    justify-content: center;
    align-items: center;
    flex-direction: row;
}
.spacebetween-div {
    padding-left: 60px;
    padding-right: 60px;
    width: 750px;
    flex-direction: row;
    justify-content: space-around;
    align-items: center;
}
.item{
    width: 180px;
    height: 200px;
    align-items: center;
    justify-content: center;
}
.bottom{
    height: 118px;
    justify-content: center;
    align-items: center;
}
</style>
