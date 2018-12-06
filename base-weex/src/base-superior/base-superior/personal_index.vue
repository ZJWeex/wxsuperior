<template>
     <scroller class="wrapper" 
               alwaysScrollableVertical='true'
               offset-accuracy="2" 
               @viewappear="viewappear"
               @scroll="scrollHandler"> 
         <!-- 用户信息区 -->
        <div class="topZone">
            <image class="topZone" ref="bgImage" :src="backgroundImage" />
            <div class="topZone | topZoneContent" @click="MineInformation">
                <div class="protraitZone">
                    <image class="protrait"  :src='userInfo.photoPath' />
                    <div style="left: 20px; bottom: -10px; ">
                        <text style="font-size: 30px; color: white; width:300px; lines: 1">{{userInfo.trueName}}</text>
                        <!-- <text style="width: 500px; lines: 1; text-overflow: ellipsis; "></text> -->
                    </div>
                </div>
                <div class="setting" @click="setting()">
                    <image resize="contain" style="width: 40px; height: 40px;" :src=settingIcon />
                </div>
            </div>
        </div>

        <!-- 用户订单区 -->
        <div style="background-color: white; margin-top: 22px; margin-bottom: 22px;"> 
            <div class="orderTagZone" @click="customeClick(0)">
                <text style="font-size: 28px; color: #000000; ">我的订单</text>
                <text style="font-size: 26px; color: #666666; ">查看全部订单 ></text>
            </div>
            <div class="orderItemZone" style="flex-direction: row;">
                <div class="orderItem" v-for="custome in orderList" :key="custome.custome" @click="customeClick(custome.custome)">
                    <image class="orderItemIcon"  :src=custome.icon />
                    <text style="font-size: 26px; color: #333333; ">{{custome.title}}</text>
                    <div class="orderBubble" v-if="custome.orderCount != '0'">
                        <text style="font-size: 24px;p: white; text-align: center; color:white; " >{{custome.orderCount}}</text>
                    </div>
                </div>
            </div>

        </div>

        <!-- 功能列表区 -->
        <div style="background-color: white;"> 
            <div class="customeItem" v-for="custome in customeList" :key="custome.custome" @click="customeClick(custome.custome)">
                <div class="customeMenu">
                    <image class="menuIcon"  :src=custome.icon />
                    <text style="font-size: 28px; color: #333333; ">{{custome.title}}</text>
                </div>
                <div class="customeMenu">
                    <text style="font-size: 28px; color: #ff0033; margin-right: 20px;" v-if="custome.custome == 8">￥{{userInfo.balance}}</text>
                    <text style="font-size: 28px; color: #b3b3b3; ">></text>
                </div>
            </div>
        </div>

        <!-- <div class="bottomLine"></div> -->
        <web ref="webview" style="width: 0px; height: 0px" :src='weburl'></web>
     </scroller>
</template>

<script>
import Fetch from '@/base-superior/Fetch.js'

const modal = weex.requireModule('modal')
const dom = weex.requireModule('dom')
const animation = weex.requireModule('animation')

const storage = weex.requireModule("storage");
import navigation from "@/base-superior/components/NavigationBar.vue";

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
    Custome.Welfare = 9;        //企业福利
}

export default {
    data () {
        return {
            weburl: '',
            loginChannel: {},
            CustomerServiceHotline: '4001885757',
            userInfo: {
                trueName: '登录/注册',
                photoPath: '/web/assets/icon.png',
                login: false,
                balance: '0.00'
            },
            backgroundImage:'https://goss.veer.com/creative/vcg/veer/800water/veer-309873970.jpg',
            settingIcon: '/web/assets/personal/settingIcon.png',
            orderList: [
                {icon:'/web/assets/personal/obligations.png' , title: '待付款', custome: Custome.Obligations, orderCount: 0},
                {icon:'/web/assets/personal/consigment.png' , title: '待发货', custome: Custome.Consignment, orderCount: 0},
                {icon:'/web/assets/personal/unreceiptd.png' , title: '待收货', custome: Custome.Unreceipted, orderCount: 0},
            ],
            customeList: [
                {icon:'/web/assets/personal/coupon.png' , title: '优惠券', custome: Custome.Coupon},
                {icon:'/web/assets/personal/customerService.png' , title: '联系客服', custome: Custome.CustomerService},
                {icon:'/web/assets/personal/address.png' , title: '我的地址', custome: Custome.Address},
                {icon:'/web/assets/personal/exchangeCard.png' , title: '兑换', custome: Custome.ExchangeCard},
                {icon:'/web/assets/personal/balance.png' , title: '账户余额', custome: Custome.Balance},
                {icon:'/web/assets/personal/welfare.png' , title: '企业福利', custome: Custome.Welfare},
            ],
        }
    }, 
    created: function () {
        this.loginChannel =  new BroadcastChannel('login');
        var self = this
        self.loginChannel.onmessage = function (event) {
            console.log("退出登录通知", event.data)
            self.updatedInfo()
        }
        var channel = new BroadcastChannel('redeemCodeSuccess');
        channel.onmessage = function (event) {
            self.getUserCardInfo()
        }
        this.updatedInfo()
        
    },
    methods: {
        viewappear(){
            this.getUserInfo()
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
            //相对路径
            navigation.push({url:'setting_index.html',
            title:'设置'}, event =>{
            });
        },
        MineInformation: function () {
            if (this.userInfo.login == false) {
                return this.toLogin()
            }
            navigation.push({url:'personal_myInformation.html', title:'我的账户'}, event =>{
            });
        },
        getUserInfo: function () {
            if (this.userInfo.login == false) {
                this.userInfo = {
                    trueName: '登录/注册',
                    photoPath: '/web/assets/icon.png',
                    login: false,
                    balance: '0.00'
                }
                this.orderList[0].orderCount = 0
                this.orderList[1].orderCount = 0
                this.orderList[2].orderCount = 0
                return
            }



            //获取用户信息
            var self = this
            Fetch.get('buyer/account.json', {},function(jsonString){
                var result = JSON.parse(jsonString)
                if (result.op_flag == 'success') {
                    var userInfo = result.userInfo
                    if (userInfo.photoPath.length) {
                        self.userInfo.photoPath = userInfo.photoPath
                    } else {
                        self.userInfo.photoPath = '/web/assets/icon.png'
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
                }
                // 只能存储字符串类型
                storage.setItem('customer_userInfo', JSON.stringify(self.userInfo), event=>{
                    console.log('customer_userInfo:', event)
                }) 
            },function(err){
                modal.alert({
                message: err,
                okTitle:'确定'
                },function(vaule){})
            })
            this.getOrderInfo()
            this.getUserCardInfo()
        },
        getOrderInfo: function (){
            var self = this
            Fetch.get('query_order_statistics.json', {}, function(jsonString){
                var result = JSON.parse(jsonString)
                if (result.op_flag == 'success') {
                    self.orderList[0].orderCount = result.superiorPaymentOrders
                    self.orderList[1].orderCount = result.superiorNeedDeliveryOrder
                    self.orderList[2].orderCount = result.superiorWechatShopDeliveryOrder
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
        customeClick: function (params) {
         
            var url = '';
            var title = ''
            var needLogin = true
            switch (params) {
                case Custome.Order:
                //绝对路径 以/开始
                    url = 'order_orderList.html'
                    title = '我的订单'
                    break;
                case Custome.Obligations:
                    url = 'order_orderList.html'
                    title = '待付款'
                    storage.setItem('OrderType', '10', event=>{})
                    break;
                case Custome.Consignment:
                    url = 'order_orderList.html'
                    title = '待发货'
                    //待准备、准备中、配送中
                    storage.setItem('OrderType', '20,30', event=>{})
                    break;
                case Custome.Unreceipted:
                    url = 'order_orderList.html'
                    title = '待收货'
                    //配送中、待收货
                    storage.setItem('OrderType', '35,108', event=>{})
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
                    url = 'address_addressList.html'
                    title = '收货地址管理'
                    break;
                case Custome.ExchangeCard:
                    url = 'exchange_exchangeCard.html'
                    title = '商品兑换'
                    break;
                case Custome.Balance:
                    url = 'balance_balance.html'
                    title = '我的账户'
                    break;
                case Custome.Welfare:
                    url = 'personal_welfare.html'
                    title = '企业福利'
                    needLogin = false
                    break;
                default:
                    break;
            }

            console.log(needLogin)
            console.log(this.userInfo.login)
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
            }else if(WXEnvironment.platform === 'android'){
                //android使用上述方法无效
                //采用原生交互
                Superior.telCall(self.dataModel.servicePhone)
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
                var imgH = 300;//图片指定的高度
                var scale = 1+offsetY/imgH;
                animation.transition(image,{
                    styles:{
                        transform:'scale('+scale+') '+'translateY(-'+offsetY/2+')',
                    },
                    duration: 0,
                    needLayout:false,
                    delay: 0
                },function (){});
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
        height: 300px;
    }
    .topZoneContent {
        padding-left: 20px;
        padding-right: 20px;
        flex-direction: row;
        justify-content: space-between;
        align-items: center;
        position: absolute;
        left: 0px;
        top: 40px;
    }
    .protraitZone {
        align-items: center;
        justify-content: flex-start;
        flex-direction: row;
    }
    .protrait {
        width: 114px;
        height: 114px;
        border-radius: 114px;
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
    .customeItem {
        width: 750px;
        padding: 30px;
        padding-left: 40px;
        padding-right: 40px;
        /* height: 150px;; */
        flex-direction: row;
        justify-content: space-between;
        align-items: center;
        background-color: white;
        border-bottom-width: 1px;
        border-bottom-color: #d9d9d9;
    }
    .customeMenu{
        flex-direction: row;
        align-items: center;
    }
    .menuIcon {
        width: 34px;
        height: 35px;
        margin-right: 30px; 
    }
    .orderTagZone {
        width: 750px;
        flex-direction: row;
        justify-content: space-between;
        padding: 30px;
        border-bottom-width: 1px;
        border-bottom-color: #d9d9d9;
    }
    .orderItemZone {
        width: 750px;
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
        width: 46px;
        height: 43px;
        margin-bottom: 27px;
    }
    .orderBubble {
        width: 36px;
        height: 36px;
        justify-content: center;
        border-radius: 36px;
        background-color: red;
        position: absolute;
        top: 22px;
        right: 75px;
    }
</style>

