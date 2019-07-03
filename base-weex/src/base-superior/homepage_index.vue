<!-- 优选首页  -->
<template>
    <div @viewappear="updateMessage">
        <div>
            <navigationSearch v-if="miniProgram"
                            :title="navTitle"
                            :showInput='false' 
                            @wxcMinibarMiddleButtonClicked='wxcMinibarMiddleButtonClicked'>
            </navigationSearch>
            <navigationSearch v-else
                            :title="navTitle"
                            :showInput="false" 
                            left-button=''
                            @wxcMinibarMiddleButtonClicked='wxcMinibarMiddleButtonClicked'>
            </navigationSearch>
            <div class="message-box" @click="checkNotification">
                <image class="massage-icon" src='/web/assets/sup/sup_home_notification.png'/>        
                <div class="message-badge" v-if="msgCount">
                    <text class="message-unread">{{msgCount}}</text>
                </div>
            </div>
        </div>

        <wxc-tab-page ref="wxc-tab-page"
                :tab-titles="tabTitles"
                :tab-styles="tabStyles"
                title-type="text"
                :tab-page-height="tabPageHeight"
                :needSlider='true'
                wrapBgColor='#fff'
                @wxcTabPageCurrentTabSelected="wxcTabPageCurrentTabSelected">
                <div v-for="(item, index) in data" :key="index">
                    <HotPage v-if="item.id === 'tuijian'" 
                              class="classlist"
                              @classListPan="classListPan" 
                              :style="{ height: (tabPageHeight - tabStyles.height) + 'px' }">
                    </HotPage>
                    <ClassList v-else class="classlist"
                                @classListPan="classListPan" 
                                :classId='item.id'
                                :style="{ height: (tabPageHeight - tabStyles.height) + 'px' }"></ClassList>
                </div>
        </wxc-tab-page>
        <div class="fixed" @click="pullDownClick"
            :style="{top:navigationHeight+2}">
            <div class="gradient"></div>
            <div class="arrow">
                <wxc-icon v-if="tabTitles.length>0" name="more_unfold" ref='arrowImg' @wxcIconClicked="pullDownClick"></wxc-icon>
                <!-- 图片在andriod上显示角被截掉 -->
                <!-- <image class="arrowImg" ref='arrowImg' resize="contain" src="/web/assets/sup/sup_homepage_down.png"/> -->
            </div>
        </div>
        <popover ref="popover" :show="showPopover"
                 :topoffset="navigationHeight+70"
                 :dataSorce="tabTitles"
                 @didSelectItem="didSelectPopoverItem"
                 @closePopover="closePopover"></popover>
        <privacyAlert v-if="!miniProgram"></privacyAlert>
    </div>
</template>
<script>
import {WxcTabPage, WxcIcon, Utils, BindEnv } from 'weex-ui';
import Fetch from '@/base-superior/Fetch.js'
import ClassList from "../base-superior/homepage_classList.vue";
import HotPage from "../base-superior/homepage_hotPage.vue";
import privacyAlert from "../base-superior/homepage_privacyAlert.vue";
import popover from "../base-superior/homepage_popover.vue";
import navigationSearch from "@/base-superior/components/NavigationBarSearch.vue";
import DB from "../base-superior/shopping_cartdb.js"
import Reftrans from "../base-superior/homepage_reftrans.js"
import AutoLogin from "../base-superior/login_loginOut.js"

const dom = weex.requireModule('dom');
const modal = weex.requireModule("modal");
// var animation = weex.requireModule("animation");
const storage = weex.requireModule("storage");

export default {
    components: { navigationSearch, WxcTabPage, WxcIcon, ClassList, HotPage, privacyAlert,popover },
    data() {
        return {
            tabTitles:[/*{'title':'推荐'},{'title':'水果'},{'title':'蔬菜'},{'title':'海鲜'}*/],
            tabStyles: {
                        bgColor: '#FFFFFF',
                        titleColor: '#666666',
                        activeTitleColor: '#ff093c',
                        activeBgColor: '#FFFFFF',
                        isActiveTitleBold: false,
                        iconWidth: 0,
                        iconHeight: 0,
                        width: 150,
                        height: 70,
                        fontSize: 28,
                        hasActiveBottom: true,
                        activeBottomColor: '#ff093c',
                        activeBottomHeight: 3,
                        activeBottomWidth: 120,
                        textPaddingLeft: 10,
                        textPaddingRight: 10,
                        rightOffset:80
                    },
            tabPageHeight: navigationSearch.pageHeight(true),
            navigationHeight: navigationSearch.navigationHeight(),
            showPopover:false,
            //服务器返回数据
            data: null,
            miniProgram: navigationSearch.miniProgram(),
            hotList: ["豆皮","羊肉","猪肉","牛肉","豆腐","鸡","青团","肉皮","现在","米"],
            defList: ["豆皮","羊肉","猪肉","牛肉"],
            timer: null,
            navTitle:'搜索商品',
            msgCount: null,
            loginChannel: {},
            login: false
        }
    },
    created() {
        // const { env } = weex.config;
        // modal.alert({message:'info:'+env.scale+":"+env.deviceHeight})
        if (weex.config.env.appName == 'superior') {
            AutoLogin.autoLogin();
            DB.postBadgeNotification();
        } else if (weex.config.env.appName.indexOf('buyer') != -1) {
            storage.getItem('tcm_normalLogin',function(e){
                if (e.result == "success") {
                    storage.removeItem('tcm_normalLogin',call=>{})
                    //同步游客购物车数据
                    DB.touristsSynchCartData();
                } else {
                   DB.loadCartData(function(el){
                       
                   });
                }
            })
        }
        //加载tab分类
        this.loadTabData();
        // 热搜关键词
        this.loadHotSearchKeywordsData()

        this.checkUserStatus()
        this.loginChannel =  new BroadcastChannel('login');
        var self = this
        self.loginChannel.onmessage = function (event) {
            self.checkUserStatus()
        }
    },
    mounted: function () {
    },
    methods: {
        //加载tab分类数据
        loadTabData: function(){
            var that = this;

            Fetch.get('superior/wechat/layoutConfig.json',{},function(jsonString) {
                storage.setItem('superior/wechat/layoutConfig.json', jsonString);
                console.log('首页推荐：',jsonString)
                that.data = JSON.parse(jsonString).classList;
                if (that.data.length > 0) {
                    let tuijian = {'id':'tuijian','className':'推荐'};
                    that.data.splice(0,0,tuijian)
                }
                var titleArray = [];
                var tempData = [];
                that.data.forEach(function(item,index) {
                   let className = item.className;
                   if(className){
                        titleArray.push({'title':className});
                        tempData.push(item);
                    } 
                })
                that.tabTitles = titleArray;
                that.data = tempData;
            }, function(err) { 
                console.log('err:'+err);
            })
        },
        //下拉点击事件
        pullDownClick:function(){
            console.log('事件点击')
            this.showPopover = !this.showPopover
            let el = this.$refs.arrowImg
            Reftrans.transformRotateX(el,this.showPopover?180:0)
        },
        //下拉选择分类
        didSelectPopoverItem:function(index){
            console.log('index:',index)
            this.$refs['wxc-tab-page'].setPage(index)
            this.showPopover = false
            let el = this.$refs.arrowImg
            Reftrans.transformRotateX(el,0)
        },
        //关闭下拉选择框
        closePopover:function(){
            this.showPopover = false
            let el = this.$refs.arrowImg
            Reftrans.transformRotateX(el,0)
        },
        wxcTabPageCurrentTabSelected (e) {
            const self = this;
            const index = e.page;
            this.$refs['popover'].setIndex(index)
            console.log(self.tabTitles[index]);
            /* Unloaded tab analog data request */
            if (!Utils.isNonEmptyArray(self.tabTitles[index])) {
                if(self.data[index].id){
                    const tabSelectedChannel = new BroadcastChannel("home_TabSelected");
                    tabSelectedChannel.postMessage(self.data[index].id);
                }
                setTimeout(() => {
                    Vue.set(self.tabTitles, index, self.tabTitles[index]);
                }, 100);
            }
        },
        //滑动手势
        classListPan(e){
            if (BindEnv.supportsEBForAndroid()) {
                this.$refs['wxc-tab-page'].bindExp(e.element);
            }
        },
        wxcMinibarMiddleButtonClicked () {
            console.log('点击中间了')
            // 热门搜索传值
            if (this.hotList.length) {
                storage.setItem('hotSearchList', JSON.stringify(this.hotList), event =>{})
            }
            navigationSearch.push({url:'homepage_search.html', title:''}, event =>{});
        },
        // 热搜关键字接口网络请求
        loadHotSearchKeywordsData:function () {
            const self = this;
            // var index = 0;
            // self.navTitle = self.defList.length > 0 ? self.defList[index] : '搜索商品'
            // self.timer = setInterval(() => {
            //     // console.log(index)
            //     index += 1;
            //     self.navTitle = self.defList[index % self.defList.length]
            //     if (index > self.defList.length - 1) {
            //         index = 0
            //     }
            //     // clearInterval(self.timer);
            // }, 10000);
            // return
            var param = {};
            Fetch.post(
                "superiorGoodsHotSearch.json",
                param,
                function(jsonString) {
                    var result = JSON.parse(jsonString);
                    if (result.op_flag === "success") {
                        self.hotList = result.hotList
                        self.defList = result.defList
                        // 每10秒 刷新一次
                        var index = 0;
                        self.navTitle = self.defList.length > 0 ? self.defList[index] : '搜索商品'
                        self.timer = setInterval(() => {
                            // console.log(index)
                            index += 1;
                            self.navTitle = self.defList[index % self.defList.length]
                            if (index > self.defList.length - 1) {
                                index = 0
                            }
                            // clearInterval(self.timer);
                        }, 10000);
                    } else {
                        modal.toast({
                            message: result.info,
                            duration: 1.0
                        });
                    }
                }, function(err) {
                    modal.toast({
                        message:err,
                        duration:1.0
                    })
                }
            );
        },
        // 查看通知消息
        checkNotification: function(){
            if (this.login) {
                navigationSearch.push({url:'notification_index.html', title:'消息'}, event =>{});
            } else {
                navigationSearch.push({url:'login_login.html',
                        title:'登录'}, event =>{
                    });
            }
        },
        // 更新消息数量
        updateMessage: function(){
            if (!this.login) {
                return
            }
            var param = { currentPage: '1' };
            var self = this
            Fetch.post(
                "superior/unreadUserMessageCount.json",
                param,
                function(respone) {
                    var result = JSON.parse(respone);
                    if (result.op_flag == "success") {
                        self.msgCount = result.count
                        if (self.msgCount > 9){
                            self.msgCount = '9+'
                        } else if (self.msgCount < 1) {
                            self.msgCount = null
                        }
                    } else if(result.op_flag === "noLogin" ) {
                        AutoLogin.loginOut(event=>{
                        })
                    }
                },
                function(err) {
                }
            );
        },
        // 检测用户登录状态
        checkUserStatus() {
            var self = this
            storage.getItem('JESSIONID', event=>{
                console.log('some' + event);
                if (event.result == 'success') {
                    console.log('JESSIONID:', event)
                    self.login = true
                    self.updateMessage()
                } else {
                    self.login = false
                    self.msgCount = null
                }
            })
        },
    }
}
</script>

<style scoped>
.classlist {
    width: 750px;
    flex: 1;
}
.fixed{
    position: fixed;
    height: 70px;
    width: 80px;
    right: 0;
    top: 130px;
    flex-direction: row;
    justify-content: center;
    align-items: center;
}
.arrow{
    height: 70px;
    flex: 1;
    justify-content: center;
    align-items: center;
    background-color: #ffffff;
}
.arrowImg{
    width: 27px;
    height: 27px;
}
.gradient{
    height: 70px;
    width:20px;
    background-image: linear-gradient(to right,rgba(255,255,255, 0.1),rgba(255,255,255,1.0));
}
.message-box{
    position: absolute;
    bottom: 0px;
    right: 10px;
    width: 90px;
    height: 88px;
    align-items: center;
    justify-content: center;
}
.massage-icon{
    width: 50px;
    height: 50px;
}
.message-badge{
    position: absolute;
    left: 48px;
    top: 0px;
    width: 36px;
    height: 36px;
    border-radius: 36px;
    background-color: #d0104c;
    align-items: center;
    justify-content: center;
}
.message-unread{
    font-size: 20px;
    color: #ffffff;
}
</style>
