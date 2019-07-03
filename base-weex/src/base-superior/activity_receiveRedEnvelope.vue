<template>
    <div class="wrapper">
        <navigation :title="title" 
                    right-button="/web/assets/platform/tcm_share.png" 
                    :use-default-return='isBottomShow == false' 
                    @wxcMinibarRightButtonClicked='wxcMinibarRightButtonClicked'
                    @wxcMinibarLeftButtonClicked="wxcMaskSetHidden"/>
        <scroller style="width: 750px;" :show-scrollbar="false" >
            <div style="width:750px;" v-for="(image,index) in appBackgroundImages" :key="index">
                <div class="topPage" v-if="index == 0" :style="{width: image.width, height: image.height}">
                    <image :style="{width: image.width, height: image.height, }" resize='cover' :src='image.imageRealUrl'/>
                    <div class="receviceButton" @click="receviceAction">
                        <text style="font-size: 32px; color: #ffffff">立即领取</text>
                    </div>
                </div>
                <image v-else :style="{width: image.width, height: image.height, }" resize='cover' :src='image.imageRealUrl'/>
            </div>
        </scroller>

        <tcmShare :show="isBottomShow"
                  :shareInfo="shareInfo"
                  @cancelShare="wxcMaskSetHidden" 
                  @afterShare="afterShare"></tcmShare>
        <wxc-loading :show="loading" need-mask='false' type="default"></wxc-loading>
    </div>    
</template>

<script>
import {Utils, WxcLoading } from 'weex-ui';
import Fetch from "@/base-superior/Fetch.js";
import navigation from "@/base-superior/components/NavigationBar.vue";
import Define from "@/base-superior/Define.js";
import tcmShare from "./components/components_share.vue";

const storage = weex.requireModule("storage");
const modal = weex.requireModule("modal");

function getPageHeight () {
    const { env } = weex.config;
    var navHeight = 88;

    if (env.platform.toLowerCase() === 'ios') {
        navHeight = Utils.env.isIPhoneX() ? 176 : 128;

        // weex默认屏宽就是750px
        navHeight = navHeight * 375*env.scale/env.deviceWidth;
    } else if (env.platform.toLowerCase() === 'android') {
        navHeight = 88;
    }
    console.log('tcmsl', env)
    return env.deviceHeight* 750/env.deviceWidth - navHeight
}


export default {
    components: {navigation, tcmShare, WxcLoading, },
    data() {
        return {
            title: '领取红包',
            appBackgroundImages:[],
            shareInfo: {},
            isBottomShow: false,
            activityId: '',
            loading: false,
        }
    },
    created() {
        var self = this
        storage.getItem(Define.kHomePage_Activity_ReceiveRedEnvelope, event=>{
            if (event.result == 'success') {
                self.activityId = event.data
                self.shareCouponsInfo()
            }
        })
        
    },
     methods: {
        wxcMinibarRightButtonClicked(event){
            this.isBottomShow = true;
            console.log(this.isBottomShow)
        },
        wxcMaskSetHidden(event){
            this.isBottomShow = false;
            console.log(this.isBottomShow)
        },
        afterShare(event){

        },
        receviceAction (){
            var self = this
            storage.getItem('JESSIONID', event=>{
                console.log(event)
                //未登录
                if (event.result == 'success') {
                    self.receviceRedEnvelop()
                } else {
                    navigation.push({url:'login_login.html',
                        title:'登录'}, event =>{
                    });
                }
            })
        },
        receviceRedEnvelop(){
            this.loading = true
            var self = this
            storage.getItem(Define.kPhone, event=>{
                if (event.result == 'success') {
                    var params = {}
                    params.telephone = event.data
                    params.id = self.activityId
                    Fetch.post("getReceiveCouponByTelephone.json", params,function(jsonString) {
                        var result = JSON.parse(jsonString)
                        modal.toast({
                            message: result.info,
                            duration: 1.0
                        });

                        self.loading = false
                    },function(err) {
                        modal.toast({
                            message: err,
                            duration: 1.0
                        });
                        self.loading = false
                    });
                } else {
                    self.loading = false
                }
            })
        },
        shareCouponsInfo(){
            var self = this
            Fetch.post("shareCouponsInfo.json",{"id": this.activityId},function(jsonString) {
                var result = JSON.parse(jsonString)
                if (result.op_flag == "success" && result.couponsInfo) {
                    self.appBackgroundImages = result.couponsInfo.appBackgroundImages

                    var height = getPageHeight()
                    for (let index = 0; index < self.appBackgroundImages.length; index++) {
                        const element = self.appBackgroundImages[index];

                        element.height = height;
                        element.width = 750
                    }

                    console.log(self.appBackgroundImages)
                    var couponsInfo = result.couponsInfo

                    self.title = couponsInfo.activityName

                    var shareInfo = {}
                    shareInfo.shareIcon = couponsInfo.shareIcon 
                    shareInfo.shareUrl = couponsInfo.shareUrl
                    shareInfo.subtitle = couponsInfo.subtitle
                    shareInfo.title = couponsInfo.title
                    self.shareInfo = shareInfo
                }
            },function(err) {
                console.log("err:" + err);
            });
        },
    },
}

</script>


<style scoped>
.wrapper{
    align-items: center;
    width: 750px;
    background-color: white;
}
.header-banner {
    width: 750px;
    height: 590px;
    background-color: #f0f0f0;
}
.receviceButton{
    margin-top: -200px;
    border-radius: 50px;
    background-color: #ff0033;
    padding-bottom: 20px;
    padding-top: 20px;
    padding-left: 150px;
    padding-right: 150px;
    font-size: 32px;
    opacity: 1;
}
.receviceButton:active{
    opacity: .8;
}
.topPage{
    align-items: center;
}
</style>
