<!-- 优选首页  -->
<template>
    <div>
        <navigation title="优选商城"
        left-button=''/>
        <wxc-tab-page ref="wxc-tab-page"
                :tab-titles="tabTitles"
                :tab-styles="tabStyles"
                :needSlider='true'
                @wxcTabPageCurrentTabSelected="wxcTabPageCurrentTabSelected">
                <div v-for="(item, index) in data" :key="index">
                    <HotPage v-if="item.id === 'tuijian'" 
                              class="classlist" 
                              :style="{ height: (tabPageHeight - tabStyles.height) + 'px' }">
                    </HotPage>
                    <ClassList v-else class="classlist" 
                                :classId='item.id'
                                :style="{ height: (tabPageHeight - tabStyles.height) + 'px' }"></ClassList>
                </div>
        </wxc-tab-page>
        <privacyAlert></privacyAlert>
    </div>
</template>
<script>
import {WxcTabPage, Utils, BindEnv } from 'weex-ui';
// import Vue from 'vue'
import Fetch from '@/base-superior/Fetch.js'
import ClassList from "../base-superior/homepage_classList.vue";
import HotPage from "../base-superior/homepage_hotPage.vue";
import privacyAlert from "../base-superior/homepage_privacyAlert.vue";
import navigation from "@/base-superior/components/NavigationBar.vue";

const dom = weex.requireModule('dom');
const modal = weex.requireModule("modal");
const storage = weex.requireModule("storage");

function getPageHeight () {
    const { env } = weex.config;
    var navHeight = 0;
    var tabbarH = 98; 
    if(env.platform.toLowerCase() === 'ios'){
        navHeight = Utils.env.isIPhoneX() ? 176 : 128;
        tabbarH = Utils.env.isIPhoneX() ? 132:tabbarH;
    }else if(env.platform.toLowerCase() === 'android') {
        navHeight = 168;
    }
    return env.deviceHeight / env.deviceWidth * 750 - navHeight - tabbarH;
}
export default {
    components: { navigation, WxcTabPage, ClassList, HotPage, privacyAlert },
    data() {
        return {
            tabTitles:[{'title':'推荐'},{'title':'水果'},{'title':'蔬菜'},{'title':'海鲜'}],
            tabStyles: {
                        bgColor: '#FFFFFF',
                        titleColor: '#666666',
                        activeTitleColor: '#3D3D3D',
                        activeBgColor: '#FFFFFF',
                        isActiveTitleBold: true,
                        iconWidth: 0,
                        iconHeight: 0,
                        width: 200,
                        height: 90,
                        fontSize: 34,
                        hasActiveBottom: true,
                        activeBottomColor: '#FF0033',
                        activeBottomHeight: 6,
                        activeBottomWidth: 120,
                        textPaddingLeft: 10,
                        textPaddingRight: 10
                    },
            tabPageHeight: getPageHeight(),
            //服务器返回数据
            data:[]
        }
    },
    created() {
        //加载tab分类
        this.loadTabData();
    },
    mounted: function () {
        
    },
    methods: {
        //加载tab分类数据
        loadTabData: function(){
            var that = this;

            Fetch.post('superior/wechat/layoutConfig.json',{},function(jsonString) {
                // console.log('post:'+jsonString);
                that.data = JSON.parse(jsonString).classList;
                if(that.data.length > 0){
                    let tuijian = {'id':'tuijian','className':'推荐'};
                    that.data.splice(0,0,tuijian)
                }
                var titleArray = [];
                that.data.forEach(function(item,index){
                   let className = item.className;
                   if(className){
                        titleArray.push({'title':className});
                    } 
                })
                that.tabTitles = titleArray;

            },function(err){ 
                console.log('err:'+err);
            })
        },
        wxcTabPageCurrentTabSelected (e) {
            const self = this;
            const index = e.page;
            console.log(self.tabTitles[index]);
            /* Unloaded tab analog data request */
            if (!Utils.isNonEmptyArray(self.tabTitles[index])) {
                const tabSelectedChannel = new BroadcastChannel("home_TabSelected");
                tabSelectedChannel.postMessage(self.data[index].id);
            setTimeout(() => {
                Vue.set(self.tabTitles, index, self.tabTitles[index]);
            }, 100);
            }
        },
    }
}
</script>

<style scoped>
.classlist {
    width: 750px;
    flex: 1;
}
</style>
