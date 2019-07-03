<template>
     <scroller class="wrapper" alwaysScrollableVertical='true' 
                @scroll="scrollHandler"
                @viewappear="viewappear"  @viewdisappear="viewdisappear"> 
         <!-- 用户信息区 -->
        <div class="topZone">
            <image class="bgImage" ref="bgImage" src="/web/assets/sup/sup_personal_bg.png" />
            <div class="topZoneContent" @click="MineInformation">
                <div v-if="!miniProgram" class="setting" @click="setting()">
                    <text style="font-size:30px;color:#ffffff;">设置</text>
                    <!-- <image resize="contain" style="width: 40px; height: 40px;" src="/web/assets/sup/sup_personal_settingIcon.png" /> -->
                </div>
                <div class="protraitZone">
                    <image class="protrait"  :src='userInfo.photoPath' />
                    <div style="left: 20px;">
                        <text style="font-size: 44px; color: white; width:300px; lines: 1">{{userInfo.trueName}}</text>
                    </div>
                </div>
            </div>
            <div class="card">
                <!-- src="/web/assets/sup/sup_setting_aboutUsTopImg.png" -->
                <image class="card-bgimg" src="/web/assets/sup/sup_personal_cardbg.png"/>
                <div style="flex:1;flex-direction: row;align-items: center;justify-content:space-around;">
                    <div style="align-items: center;" @click="customeClick(4)">
                        <text style="color:#f52d5b">{{userInfo.redPackCount}}</text>
                        <text style="padding-top:5px;font-size:30px;color:#333;">红包卡券</text>
                    </div>
                    <div style="align-items: center;" @click="customeClick(8)">
                        <text v-if="userInfo.login != false" style="color:#f52d5b">¥{{userInfo.balance}}</text>
                        <text v-else style="color:#f52d5b">¥0.00</text>
                        <text style="padding-top:5px;font-size:30px;color:#333;">余额</text>
                    </div>
                </div>
            </div>
        </div>

        <!-- 用户订单区 -->
        <div class="order-card"> 
            <div class="orderTagZone" @click="customeClick(0)">
                <text style="margin-left:30px;font-size: 30px; color: #333333;">我的订单</text>
                <div style="flex-direction: row;align-items: center;margin-right:10px;">
                    <text style="font-size: 26px; color: #666666; ">查看全部订单 </text>
                    <image class="arrowImg" src="/web/assets/sup/sup_personal_next.png"/>
                </div>
            </div>
            <div class="orderItemZone" style="flex-direction: row;">
                <div class="orderItem" v-for="custome in orderList" :key="custome.custome" @click="customeClick(custome.custome)">
                    <image class="orderItemIcon" :src="custome.icon" />
                    <text style="font-size: 22px; color: #666666; ">{{custome.title}}</text>
                    <div :class="[custome.orderCount>9?'orderBadage':'orderBubble']" v-if="custome.orderCount>0">
                        <text v-if="custome.orderCount>999" style="font-size: 26px; text-align: center; color:#f52e66; line-height: 34px;" >999+</text>
                        <text v-else style="font-size: 26px; text-align: center; color:#f52e66; line-height: 34px;" >{{custome.orderCount}}</text>
                    </div>
                </div>
            </div>
            <!-- 物流展示 -->
            <LogCard ref="logCard" v-if="trackSlid.trackObj.length>0" 
                    :logisticsList="trackSlid.trackObj" 
                    @onClick="customeClick(3)"></LogCard>
            <!-- <LogCard></LogCard> -->
        </div>
        <!-- 轮播图区 -->
        <div class="slider-card" v-if="trackSlid.imgObj.length>0">
            <slider class="banner-zone" interval="3000" auto-play="true">
                <div v-for="(item,index) in trackSlid.imgObj" :key="index">
                    <image class="banner-image" resize="stretch" :src="item.imageUrl" @click="activeDetailAction(item)"/>
                </div>
                <indicator class="indicator"></indicator>
            </slider>
        </div>
        <!-- 常用功能区 -->
        <div class="common-card"> 
            <div class="common-title">
                <text>常用功能</text>
            </div>
            <div class="common-content">
                <div class="customeItem" v-for="custome in customeList" :key="custome.custome" @click="customeClick(custome.custome)">
                    <image class="menuIcon" :src="custome.icon" />
                    <text style="font-size: 22px; color: #666666;">{{custome.title}}</text>
                </div>
            </div>
        </div>

        <!-- <div class="bottomLine"></div> -->
        <web ref="webview" style="width: 0px; height: 0px" :src='weburl'></web>
     </scroller>
</template>

<script>
import Fetch from '@/base-superior/Fetch.js'
import Define from "@/base-superior/Define.js"
import navigation from "@/base-superior/components/NavigationBar.vue";
import LogCard from "@/base-superior/components/CenterLogCard.vue";

const modal = weex.requireModule('modal')
const dom = weex.requireModule('dom')
const animation = weex.requireModule('animation')
const storage = weex.requireModule("storage");

if(typeof Custome == "undefined"){
    var Custome = {};
    Custome.Order = 0;          //全部订单
    Custome.Obligations = 1;    //待付款
    Custome.Consignment = 2;    //待发货
    Custome.Unreceipted = 3;    //待收货
    Custome.Coupon = 4;         //优惠券|红包
    Custome.CustomerService = 5;//客服
    Custome.Address = 6;        //收货地址
    Custome.ExchangeCard = 7;   //商品兑换卡
    Custome.Balance = 8;        //账户余额
    Custome.TopUp = 9;          //充值
    Custome.Welfare = 10;        //企业福利
    Custome.refund = 11;        //售后/退款
}

export default {
    components: { LogCard },
    data () {
        return {
            weburl: '',
            loginChannel: {},
            CustomerServiceHotline: '4001885757',
            userInfo: {
                trueName: '登录/注册',
                photoPath: '/web/assets/sup/sup_personal_mrtx.png',
                login: false,
                balance: '0.00',
                redPackCount:'0',
            },
            orderList: [
                {icon:'/web/assets/sup/sup_personal_obligations.png' , title: '待付款', custome: Custome.Obligations, orderCount: 0},
                {icon:'/web/assets/sup/sup_personal_consigment.png' , title: '待发货', custome: Custome.Consignment, orderCount: 0},
                {icon:'/web/assets/sup/sup_personal_unreceiptd.png' , title: '待收货', custome: Custome.Unreceipted, orderCount: 0},
                {icon:'/web/assets/sup/sup_personal_afterSales.png' , title: '售后/退款', custome: Custome.refund, orderCount: 0},
            ],
            customeList: [
                {icon:'/web/assets/sup/sup_personal_exchangeCard.jpg' , title: '兑换', custome: Custome.ExchangeCard},
                {icon:'/web/assets/sup/sup_personal_balance.jpg' , title: '充值', custome: Custome.TopUp},
                {icon:'/web/assets/sup/sup_personal_address.jpg' , title: '地址', custome: Custome.Address},
                {icon:'/web/assets/sup/sup_personal_customerService.jpg' , title: '客服', custome: Custome.CustomerService},
                {icon:'/web/assets/sup/sup_personal_welfare.jpg' , title: '企业福利', custome: Custome.Welfare},
                // {icon:'/web/assets/sup/sup_personal_coupon.png' , title: '优惠券', custome: Custome.Coupon},
            ],
            trackSlid:{trackObj:[],imgObj:[]},
            miniProgram: navigation.miniProgram(),// 判断平台是不是优选商城
        }
    }, 
    created: function () {
        this.loginChannel =  new BroadcastChannel('login');
        var self = this
        self.loginChannel.onmessage = function (event) {
            console.log("退出登录通知", event.data)
            self.updatedInfo()
        }
        console.log(weex.config)
        var channel = new BroadcastChannel('redeemCodeSuccess');
        channel.onmessage = function (event) {
            self.getUserCardInfo()
        }
        this.updatedInfo()
        this.addEventListener()
    },
    methods: {
        viewappear:function(){
            this.updatedInfo()
        },
        viewdisappear:function(){
            let elment = this.$refs.logCard;
            if(elment){
                elment.overlayMaskHide();
            } 
        },
        updatedInfo() {
            var self = this
            storage.getItem('JESSIONID', event=>{
                if (event.result == 'success') {
                    console.log('JESSIONID:', event)
                    self.userInfo.login = true
                    self.getUserInfo()
                } else {
                    self.userInfo.login = false
                    self.getUserInfo()
                }
            })
        },
        setting: function() {
            if (this.miniProgram) {
                return;
            }
            //相对路径
            navigation.push({url:'setting_index.html',
            title:'设置'}, event =>{

            });
        },
        MineInformation: function () {
            if (this.userInfo.login == false) {
                return this.toLogin()
            }
            if (this.miniProgram) {
                return;
            }
            navigation.push({url:'personal_myInformation.html', title:'个人信息'}, event =>{

            });
        },
        getUserInfo: function () {
            if (this.userInfo.login == false) {
                this.userInfo = {
                    trueName: '登录/注册',
                    photoPath: '/web/assets/sup/sup_personal_mrtx.png',
                    login: false,
                    balance: '0.00',
                    redPackCount: '0'
                }
                this.orderList[0].orderCount = 0
                this.orderList[1].orderCount = 0
                this.orderList[2].orderCount = 0
                this.orderList[3].orderCount = 0
               this.trackSlid = {trackObj:[],imgObj:this.trackSlid.imgObj};
               this.getTrackAndSlid()
                return
            }
            //获取用户信息
            var self = this
            storage.getItem(Define.kWechat, wechat => {
                 var wechat = wechat.data;
                 var param = {}
                 if(wechat != 'undefined' && wechat.length>0){
                      param = {isWechat:wechat}
                 }
                 Fetch.post('buyer/account.json', param,function(jsonString){
                    var result = JSON.parse(jsonString)
                    if (result.op_flag == 'success') {
                        var userInfo = result.userInfo
                        if (userInfo.photoPath.length) {
                            self.userInfo.photoPath = userInfo.photoPath
                        } else {
                            self.userInfo.photoPath = '/web/assets/sup/sup_personal_mrtx.png'
                        }
                        
                        self.userInfo.userName = userInfo.userName
                        self.userInfo.telephone = userInfo.telephone
                        self.userInfo.birthday = userInfo.birthday
                        if (userInfo.trueName.length > 0) {
                            self.userInfo.trueName = userInfo.trueName
                        } else {
                            self.userInfo.trueName = userInfo.userName
                        }
                        self.userInfo.sex = userInfo.sex
                    } else {
                        self.userInfo.login = false
                    }
                    // 只能存储字符串类型
                    storage.setItem('customer_userInfo', JSON.stringify(self.userInfo), event=>{
                        console.log('customer_userInfo:', event)
                    }) 
                },function(err){
                    console.log(err)
                    if(err.indexOf('网络不可用') == -1){
                        self.userInfo.login = false
                    }
                    
                })

            });
            
            this.getOrderInfo()
            this.getUserCardInfo()
            this.getTrackAndSlid()
        },
        getOrderInfo: function (){
            var self = this
            //clientType:"H5";H5 调用必传参数，不屏蔽电子卡订单，其他可不传，会屏蔽电子礼品卡订单。后期优选app 若传“superior” 也不屏蔽电子卡订单。
            Fetch.post('query_order_statistics.json', {clientType:"H5"}, function(jsonString){
                var result = JSON.parse(jsonString)
                if (result.op_flag == 'success') {
                    self.orderList[0].orderCount = result.superiorPaymentOrders
                    self.orderList[1].orderCount = result.superiorNeedDeliveryOrder
                    self.orderList[2].orderCount = result.superiorWechatShopDeliveryOrder
                    self.orderList[3].orderCount = result.afterOrderCount
                }
            }, function(err) {

            })
        },
        getUserCardInfo: function () {
            var self = this
            Fetch.get('buyer/getUserCardInfo.json', {}, function(jsonString){
                var result = JSON.parse(jsonString)
                if (result.op_flag == 'success') {
                    self.userInfo.balance = result.spCardBalance
                    self.userInfo.redPackCount = result.redPackCount?result.redPackCount:"0"
                }
            }, function(err) {

            })
        },
        //获取物流轨迹列表及轮播图
        getTrackAndSlid:function(){
            var self = this
            Fetch.get('superior/superior_user_trick.json', {}, function(jsonString){
                var result = JSON.parse(jsonString)
                if (result.op_flag == 'success') {
                    if(Array.isArray(result.trackObj)){
                        self.trackSlid.trackObj = result.trackObj
                    }
                   if(Array.isArray(result.imgObj)){
                       self.trackSlid.imgObj = result.imgObj
                   }
                }
            }, function(err) {

            })
        },
        toLogin: function () {
            if (this.userInfo.login == true) {
                return;
            } 
            navigation.push({url:'login_login.html',
                title:'登录'}, event =>{
            });
        },
        activeDetailAction:function(ob){
            //actyType:1:满减；2：红包；3：领劵
            //linkDataType跳转类型，1跳至指定对应商品详情，2跳转列表，0根据活动类型调至指定活动
            var url = '';
            var title = ''
            if(ob.actyType == 3){
                //领劵
                url = 'activity_receiveRedEnvelope.html'
                title = '领取红包'
                storage.setItem(Define.kHomePage_Activity_ReceiveRedEnvelope,ob.linkDataId,event => {});
                /*
                storage.setItem("goods_giftVoucher",JSON.stringify({goodsId: ob.linkDataId,goodsName: ob.actyName}),event => {});
                url = "goods_giftVoucher.html";
                title = ob.actyName */
                
            }else{
                if(ob.linkDataType==0){

                }else if(ob.linkDataType==1){
                    url = 'goods_goodsDetail.html'
                    title = '商品详情'
                    storage.setItem(Define.kSuperior_goods_id,ob.goodsId,event => {});
                }else if(ob.linkDataType==2){
                    url = 'active_subject.html'
                    title = '主题活动' 
                    storage.setItem(Define.kSubjectId,ob.linkDataId,event => {});
                }
            }
            
            if(url.length>0){
                navigation.push({url:url, title:title}, event =>{});
            }
        },
        customeClick: function (params) {
         
            var url = '';
            var title = ''
            var needLogin = true
            switch (params) {
                case Custome.Order:
                //绝对路径 以/开始
                    url = 'order_index.html'
                    title = '我的订单'
                    storage.setItem('OrderType', '0', event=>{})
                    break;
                case Custome.Obligations:
                    url = 'order_index.html'
                    title = '待付款'
                    storage.setItem('OrderType', '1', event=>{})
                    break;
                case Custome.Consignment:
                    url = 'order_index.html'
                    title = '待发货'
                    //待发货
                    storage.setItem('OrderType', '2', event=>{})
                    break;
                case Custome.Unreceipted:
                    url = 'order_index.html'
                    title = '待收货'
                    //待收货
                    storage.setItem('OrderType', '3', event=>{})
                    break;
                case Custome.Coupon:
                    url = 'coupon_couponTab.html'
                    title = '我的红包'
                    break;
                case Custome.CustomerService:{
                    this.CustomerService()
                    return
                }
                    break;
                case Custome.Address:
                    url = 'address_list.html'//'address_addressList.html'
                    title = '地址管理'
                    break;
                case Custome.ExchangeCard:
                    url = 'exchange_exchangeCard.html'
                    title = '商品兑换'
                    break;
                case Custome.Balance:
                    url = 'balance_balance.html'
                    title = '我的账户'
                    break;
                case Custome.TopUp:
                    url = 'balance_redeemCode.html'
                    title = '充值'
                    break;
                case Custome.Welfare:
                    url = 'personal_welfare.html'
                    title = '企业福利'
                    needLogin = false
                    break;
                case Custome.refund:
                    url = 'order_refundGoods_list.html'
                    title = '售后/退款'
                    break;
                default:
                    break;
            }

            if (needLogin == true && this.userInfo.login != true) {
                return this.toLogin()
            } 
            if (url.length) {
                navigation.push({url:url, title:title}, event =>{});
            } 
        },
        CustomerService: function () {
            var self = this;
            if(WXEnvironment.platform === 'iOS'){                    
                self.weburl = "tel:"+self.CustomerServiceHotline
                weex.requireModule('webview').reload( self.$refs['webview'].$el);
                setTimeout(function(){
                    //重置，否则滑动iOS还会弹出拨打电话弹框
                    self.weburl = ''
                },500);
            } else {
                modal.confirm({
                    message: '联系客服:' + self.CustomerServiceHotline,
                    okTitle: '确定',
                    cancelTitle: '取消'
                }, function(value){
                    if(value === '确定') {
                        if (WXEnvironment.platform === 'Web'){
                            self.weburl = "tel:"+self.CustomerServiceHotline
                            weex.requireModule('webview').reload( self.$refs['webview'].$el);
                            setTimeout(function(){
                            //重置，否则滑动iOS还会弹出拨打电话弹框
                                self.weburl = ''
                            },500);
                        }else if(WXEnvironment.platform === 'android'){
                            //android使用上述方法无效
                            //采用原生交互
                            weex.requireModule('myGlobalEvent').telCall(self.CustomerServiceHotline)
                        }
                    }
                })
            }
        },
        //滑动回调
        scrollHandler:function(event){     
            var offsetY = event.contentOffset.y;
            if(offsetY >= 0){
                var image = this.$refs.bgImage
                var imgH = 346;//图片指定的高度
                var scale = 1+offsetY/imgH;
                animation.transition(image,{
                    styles:{
                        transform:'scale('+scale+') '+'translateY(-'+offsetY/2+')',
                    },
                },function (){});
            }  
        },
        addEventListener(){
            var self = this
            if (weex.config.tag) {
                weex.requireModule('globalEvent').addEventListener('android_keyboard_back_'+weex.config.tag, event=>{
                    self.leftButtonClicked()
                })
            }
        },
        /**
         *  移除Android物理键监听
         */
        removeEventListener(){
            if (WXEnvironment.platform.toLowerCase() === 'android') {
                weex.requireModule('globalEvent').removeEventListener('android_keyboard_back_'+weex.config.tag)
            }
        },
        /**
         * 导航栏左侧按钮点击事件
         */
        leftButtonClicked () {
            if (WXEnvironment.platform.toLowerCase() === 'android') {
                let elment = this.$refs.logCard;
                if(this.trackSlid.trackObj.length == 0 || (elment && elment.leftButtonClicked())){
                    if (WXEnvironment.appName !== "superior") {
                        this.removeEventListener()
                    }
                    weex.requireModule('MyNavigatorModule').pop({tag: weex.config.tag }, event=>{})
                }
            }
        },
    }
}
</script>


<style scoped>
    .wrapper {
        width: 750px;
        align-items: center;
        background-color: whitesmoke;
    }
    .topZone {
        width: 750px;
        height: 380px;
    }
    .bgImage {
        position:absolute;
        top: 0;
        left: 0;
        right: 0;
        height: 346px;
    }
    .topZoneContent {
        margin-top: 40px;
        width: 750px;
        height: 240px;
        padding-left: 20px;
        padding-right: 20px;
        flex-direction: row;
        justify-content: space-between;
        align-items: center;
    }
    .card {
        position:absolute;
        bottom: 0;
        left: 6px;
        right: 6px;
        height: 154px;
        border-radius: 20px;
        /* background-color: #ffffff; */
    }
    .card-bgimg {
        position:absolute;
        top: 0;
        bottom: 0;
        left: 0;
        right: 0;
        border-radius: 20px;
    }
    .protraitZone {
        align-items: center;
        justify-content: flex-start;
        flex-direction: row;
    }
    .protrait {
        width: 100px;
        height: 100px;
        border-radius: 100px;
        opacity: 1.0;
    }
    .protrait:active {
        opacity: 0.8;
    }
    .setting {
        padding: 30px;
        /* width: 50px;
        height: 50px; */
        opacity: 1.0;
        position: absolute;
        top: 0px;
        right: 0px;
    }
    .setting:active {
        opacity: 0.8;
    }
    .order-card {
        background-color: white; 
        border-radius: 20px;
        margin: 20px;
        width: 710px; 
    }
    .arrowImg {
        width: 16px;
        height: 27px;
        /* margin-left: 15px; */
    }
    .orderTagZone {
        flex-direction: row;
        justify-content: space-between;
        margin-left: 10px;
        margin-right: 10px;
        padding-top: 20px;
        padding-bottom: 20px;
        border-bottom-width: 1px;
        border-bottom-color: #f5f2f2;
    }
    .orderItemZone {
        width: 710px;
        justify-content: space-between;
        padding-left: 30px;
        padding-right: 30px;
    }
    .orderItem{
        flex: 1;
        align-items: center;
        padding-top: 40px;
        padding-bottom: 26px;
    }
    .orderItemIcon{
        width: 70px;
        height: 52px;
        margin-bottom: 20px;
    }
    .orderBubble {
        width: 34px;
        height: 34px;
        justify-content: center;
        border-radius: 34px;
        background-color: #ffffff;
        border-width: 1px;
        border-color: #ff3366;
        position: absolute;
        top: 22px;
        right: 40px;
    }
    .orderBadage {
        padding-right: 6px;
        padding-left: 6px;
        height: 34px;
        justify-content: center;
        border-radius: 34px;
        background-color: #ffffff;
        border-width: 1px;
        border-color: #ff3366;
        position: absolute;
        top: 22px;
        right: 30px;
    }
    .log-card {
        flex: 1;
        background-color: #f6f6f6;
        padding: 20px;
        border-radius: 20px;
        margin-left: 30px;
        margin-right: 30px;
        margin-bottom: 30px;
    }
    .slider-card {
        margin-left: 20px;
        margin-right: 20px;
        height: 280px;
        width: 710px;
        background-color: #fedbe3;
    }
    .banner-zone {
        flex: 1;
    }
    .banner-image{
        height: 280px;
        width: 710px;
    }
    .indicator {
        width: 710px;
        height: 30px;
        item-color: #808080;
        item-selected-color: #ffffff;
        item-size: 15px;
        position: absolute;
        bottom: 30px;
    }
    .common-card {
        width: 710px;
        background-color: white;
        border-radius: 20px;
        margin: 20px;
        padding: 10px; 
    }
    .common-title {
        justify-content: center;
        height: 80px;
        flex: 1;
        padding: 20px;
        border-bottom-color: #f5f2f2;
        border-bottom-width: 1px;
    }
    .common-content{
        flex-direction:row;
        justify-content:center; 
        margin: 10px;
        flex-wrap: wrap;
    }
    .customeItem {
        width: 110px;
        align-items: center;
        background-color: white;
        margin: 10px;
    }
    .menuIcon {
        width: 71px;
        height: 53px;
        margin-bottom: 10px; 
    }
</style>

