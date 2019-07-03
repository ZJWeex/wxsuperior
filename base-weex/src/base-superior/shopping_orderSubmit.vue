<template>
    <div style="background-color:#f2f3f4;">
        <navigation title="提交订单"/>
        <scroller class='scroller' v-if="!showResult">
            <!-- 地址 -->
            <div class="address" @click="changeAddressClick" v-if="!addressModel || addressModel.telephone.length">
                <div v-if="!addressModel" style="flex:1;">
                    <div style="height:100px;flex:1;justify-content:center;align-items:center;">
                        <text style="color:#333333;">+添加地址</text>
                    </div>
                </div>
                <div v-else style="flex: 1;">
                    <div class="name-div">
                        <image class="address-icon" src="/web/assets/sup/sup_cart_me.png"/>
                        <text class="name-text">{{addressModel.trueName}}  {{addressModel.telephone}}</text>
                    </div>
                    <div class="address-info">
                        <image class="address-icon" src="/web/assets/sup/sup_cart_location.png"/>
                        <text class="address-text">{{addressModel.areaInfo}}</text>
                    </div>
                </div>
                <wxc-icon name="more" :icon-style="{color:'#999999',fontWeight: 'bolder','margin-right':'10px'}" @wxcIconClicked="changeAddressClick"></wxc-icon>
            </div>
            <!-- 订单详情 -->
            <submit-cell :preOrderData="preOrderData"
                        :hasAddress="addressModel" 
                        @gatherTogether="goGatherTogether"></submit-cell>
            
            <!-- 优惠 -->
            <div style="padding-top:22px;padding-bottom:22px;border-bottom-width:10px;border-bottom-color:#f0f0f0;">
                <div class="spacebetween-div">
                    <div style="flex-direction: row;align-items: center;">
                        <image style="width:34px;height:34px;margin-right: 22px;" src="/web/assets/sup/sup_cart_redpacket.png"/>
                        <text style="font-size:30px;color:#333333">优惠券</text>
                    </div>
                    <div style="flex-direction: row;align-items: center;" @click="seletCouponClick">
                        <text v-if="couponPrice>0&&preOrderData.listWithinArea.length>0" style="color:#ff0033;">-¥{{ couponPrice.toFixed(2) }}</text>
                        <div v-else-if="preOrderData.listWithinArea.length==0&&preOrderData.listWithoutArea.length>0" style="flex-direction: row;align-items: center;">
                            <text style="font-size:26px;color:#333333;">有</text>
                            <text style="font-size:26px;color:#ff0033;">0张</text>
                            <text style="font-size:26px;color:#333333;">可使用</text>
                        </div>
                        <div v-else style="flex-direction: row;align-items: center;">
                            <text style="font-size:26px;color:#333333;">有</text>
                            <text style="font-size:26px;color:#ff0033;">{{couponCount}}张</text>
                            <text style="font-size:26px;color:#333333;">可使用</text>
                        </div>
                        <wxc-icon name="more" :icon-style="{color:'#999999',fontWeight: 'bolder'}" @wxcIconClicked="seletCouponClick"></wxc-icon>
                    </div>
                </div>
            </div>
            <div style="padding-top:22px;padding-bottom:22px;border-bottom-width:10px;border-bottom-color:#f0f0f0;">
                <div class="spacebetween-div">
                    <div style="flex-direction: row;align-items: center;">
                        <image style="width:34px;height:34px;margin-right: 22px;" src="/web/assets/sup/sup_cart_gift.png"/>
                        <text style="font-size:30px;color:#333333;">满减优惠</text>
                    </div>
                    <text style="font-size:36px;color:#ff0033;">-¥{{preOrderData.minusPrice}}</text> 
                </div>
            </div>
            <!-- 订单结算 -->
            <div style="padding-bottom:20px">
                <text style="font-size: 36px;color:#333333;padding:22px;width:750px;border-bottom-width:2px;border-bottom-color:#f0f0f0;">订单结算</text>
                <div class="spacebetween-div">
                    <text style="font-size: 30px;color:#333333;">订单金额:</text>
                    <text style="font-size: 30px;color:#333333;">¥{{preOrderData.totalPrice}}</text>
                </div>
                <div class="spacebetween-div">
                    <text style="font-size: 30px;color:#333333;">优惠金额:</text>
                    <text style="font-size: 30px;color:#333333;">¥{{ freeTotalPrice }}</text>
                </div>
                <div class="spacebetween-div">
                    <text style="font-size: 30px;color:#333333;">配送金额:</text>
                    <text style="font-size: 30px;color:#333333;">{{ shippingFee }}</text>
                </div>
                <div class="spacebetween-div">
                    <text style="font-size: 30px;color:#333333;">应付金额:</text>
                    <text style="font-size: 30px;color:#333333;">¥{{ shouldPayPrice.toFixed(2) }}</text>
                </div>
            </div>

            <div style="padding-top:22px;padding-bottom:22px;border-bottom-width:10px;border-bottom-color:#f0f0f0;border-top-width:10px;border-top-color:#f0f0f0;">
                <!-- 优选余额支付 -->
                <div class="spacebetween-div">
                    <div style="flex-direction: row; align-item: center">
                        <image style="width:48px;height:48px;margin-right: 22px; " src="/web/assets/sup/sup_cart_wallet.png"/>
                        <text style="font-size:36px;color:#333333;">余额支付</text>
                    </div>
                </div>

                <div class="spacebetween-div">
                    <div style="flex-direction: row; align-item: center">
                        <text style="font-size:28px;color:#333333;margin-left: 2w0px">优选</text>
                        <text style="font-size:28px;color:#333333;">(</text>
                        <text style="font-size:28px;color:#ff0033;">可用¥{{localWallet.spCardBalance}}</text>
                        <text style="font-size:28px;color:#333333;">)</text>
                    </div>
                    <div style="align-items：flex-start">
                        <switch :checked ='checkSPCard' @change="onSwitchChangeSP"></switch>
                    </div>
                </div>

                <!-- 菜市余额支付 -->
                <div v-if="localWallet.mkCardBalance > 0 && localWallet.isSuperiorOrderCanUseMkCard == 1" class="spacebetween-div">
                    <div style="flex-direction: row; align-item: center">
                        <text style="font-size:28px;color:#333333; margin-left: 0px">菜市</text>
                        <text style="font-size:28px;color:#333333;">(</text>
                        <text style="font-size:28px;color:#ff0033;">可用¥{{localWallet.mkCardBalance}}</text>
                        <text style="font-size:28px;color:#333333;">)</text>
                    </div>
                    <div style="align-items：flex-start">
                        <switch :checked ='checkMKCard' @change="onSwitchChangeMK"></switch>
                    </div>
                </div>
            </div>
            <!-- 支付方式 -->
            <text v-if="preOrderData.listWithinArea.length==0&&preOrderData.listWithoutArea.length>0" class="confirm-unpay">确认支付</text>
            <text v-else-if="realPayPrice<=0 && preOrderData.listWithinArea.length>0" class="confirm-pay" @click="confirmPayClick(100)">确认支付</text>
            <div v-else class="bottom-pay">
                <div class="spacebetween-div">
                    <text style="font-size: 26px;color:#333333;padding:32px;">支付方式</text>
                    <text style="font-size: 30px;color:#ff0033;padding:10px;background-color:#fff1fb;border-color:#ff0033;border-width:2px;">还需支付{{ realPayPrice }}</text>
                </div>
                <div>
                    <div class="spacebetween-div" @click="confirmPayClick(1)">
                        <div style="flex-direction: row;align-items: center;">
                            <image style="width:68px;height:68px;margin-right: 22px;" src="/web/assets/sup/sup_cart_wechat.png"/>
                            <text style="color:#333333;font-size:28px;">微信支付</text>
                        </div>
                        <div>
                            <wxc-icon name="more" :icon-style="{color:'#999999',fontWeight: 'bolder'}" @wxcIconClicked="confirmPayClick(1)"></wxc-icon>
                        </div>
                    </div>
                    <div style="height:2px;flex:1;background-color:#f0f0f0;"></div>
                    <div class="spacebetween-div" @click="confirmPayClick(2)">
                        <div style="flex-direction: row;align-items: center;">
                            <image style="width:68px;height:68px;margin-right: 22px;" src="/web/assets/sup/sup_cart_alipay.png"/>
                            <text style="color:#333333;font-size:28px;">支付宝支付</text>
                        </div>
                        <div>
                            <wxc-icon name="more" :icon-style="{color:'#999999',fontWeight: 'bolder'}" @wxcIconClicked="confirmPayClick(2)"></wxc-icon>
                        </div>
                    </div>
                </div>
            </div>
        </scroller>
        <wxc-loading :show="showLoading" need-mask=false type="default"></wxc-loading>
        <!-- 网络接口出错的结果页 -->
        <wxc-result :show="showResult"
              :wrap-style="{top:176}"
              padding-top="232"
              @wxcResultButtonClicked="wxcResultButtonClicked"></wxc-result>
        <!-- 密码输入弹框 -->
        <PasswordInput :show="isBottomShow"
                       @cancalClick="cancalPasswordInputClick"
                       @passwordFinish="passwordFinish">    
        </PasswordInput>
    </div>
</template>

<script>
import { WxcIcon, WxcPopup, WxcLoading, WxcResult } from 'weex-ui';
import Fetch from "@/base-superior/Fetch.js";
import navigation from "@/base-superior/components/NavigationBar.vue";
import PasswordInput from  "./components/PasswordInput.vue";
import SubmitCell from "@/base-superior/shopping_orderSubmit_cell.vue";

const modal = weex.requireModule('modal');
const storage = weex.requireModule("storage");
var globalEvent = weex.requireModule('globalEvent');

export default {
    components: { WxcIcon, WxcPopup, WxcLoading, WxcResult, PasswordInput, navigation, SubmitCell },
    data() {
        return {
            topBecomeActive:false,//ios支付是否点击顶部返回
            password_error_count: "",
            showLoading:false,
            showResult:false,
            addressModel: { 
                   "trueName": "淘菜猫",
                    "areaInfo": "",
                    "areaId": "",
                    "gender": "0",//1男，2女
                    "lng": "",
                    "acquiescent_addr": "0",//1为默认地址
                    "deliveryDistance": "",
                    "telephone": "",
                    "id": "",
                    "area_info": "上海市 上海市 普陀区 天地软件园",
                    "lat": "",
                    "addrType": "0",//1公司，2家，3父母家
                },
            preOrderData:{
                    "listWithinArea": [/*{
                        "supGoodsId": "784921804782215169",
                        "price": "98.00",
                        "count": "1",
                        "supCartId": "",
                        "goodsName": "辽宁蟹田香米2.5kg*1袋"
                    }*/],
                    "listWithoutArea": [],
                    "bgcListWithinArea": [/*{
                        "supGoodsId": "784921804782215169",
                        "count": "1",
                        "supCartId": "",
                        "bgcId": "827704076099686400"
                    }*/],
                    resultMap:{
                        allGoodsMap:{
                            allGoodsList:[],
                            otherPrice:0,//全场包邮商品总价
                            otherFee:0,//邮费
                            condtionPrice:0 //包邮限制
                            },
                        singleList:[],//单品包邮商品
                        groups:[
                            //组合包邮
                            /*
                            {
                                templateName:'模版名称',
                                templateId:'模版ID',
                                condtionPrice:0,//包邮限制
                                groupingFee:0,//邮费
                                goodsList:[],

                            }*/
                        ],
                    },
                    "bgcListWithoutArea": [],
                    "totalPrice": "0.00",//商品总价
                    "payalbePrice": "0.00",//实际支付金额
                    "shipPrice": "0.00",//订单需支付的配送费
                    "newShipPrice": "0.00",//包邮的配送费
                    "isPostFree": "0",//0:1是否包邮
                    "minusPrice": "0.00"//满减优惠价格
            },
            supGoodsIds:[{count:'1',
                            supGoodsId:'',
                            subjectId:'1',
                            supCartId:'',
                            bgcId:''}],
            tempSupGoodsIds:[],
            isBottomShow:false,//密码弹框
            couponCount:0,//可用优惠券数量
            shippingFee:'¥0.00',//配送费
            couponPrice:0.00,//优惠券额度
            couponList:[],//选择的优惠券对象数组
            localWallet:{mkCardBalance: "0.00"},//账户余额,默认0
            payType:0,//支付类型
            checkSPCard: true, //是否使用账户余额--优选
            checkMKCard: false, //是否使用账户余额--菜市
        }
    },
    created() {
        const self = this;
        //获取余额信息
        this.getUserCardInfo();
        //获取提交订单数据
        storage.getItem('submitOrderData', event => {
          console.log('submitOrderData:', event.data)
          if(event.data && event.data != 'undefined'){
              console.log('订单商品数据：'+event.data);
            //   modal.alert({message:event.data});
            self.supGoodsIds = JSON.parse(event.data);
             //获取优惠券数量
                this.getCouponCount();
                //获取地址信息
                this.loadAddressInfo(callback => {
                    //获取商品信息
                    self.loadGoodsReadyData();
                });
                if (WXEnvironment.platform.toLowerCase() !== 'web'){
                    storage.removeItem('submitOrderData',event => {})
                }
          }
        });

        //选择地址的回调数据
        const selectAddressChannel = new BroadcastChannel("selectAddressChannel");
        selectAddressChannel.onmessage = function (event){
            console.log("selectAddressChannel："+event.data);
            //保存本地
            storage.setItem('history_select_address',event.data,ret =>{})
            self.addressModel = JSON.parse(event.data);
            //切换地址后刷新商品数据信息
            self.loadGoodsReadyData();
        };
        //添加/编辑地址回调
        const addressChannel = new BroadcastChannel("addressChange");
        addressChannel.onmessage = function (event){
            console.log('通道名称：',event.data)
             //重新获取地址信息
            self.loadAddressInfo(callback => {
                //获取商品信息
                self.loadGoodsReadyData();
            });  
        }
        //选择优惠券的回调数据
        const selectCouponChannel = new BroadcastChannel("selectCoupon");
        selectCouponChannel.onmessage = function (event){
            console.log("selectCoupon："+event.data);
            self.couponPrice = 0.00;
            self.couponList = JSON.parse(event.data);
            self.couponList.forEach(function(el,i){
                self.couponPrice = self.couponPrice + Number(el.favorable_money);
            })
        };
        //凑单返回刷新界面
        const gatherChannel = new BroadcastChannel("GatherTogetherChannel");
        gatherChannel.onmessage = function (event){
             self.supGoodsIds = JSON.parse(event.data);
             //获取商品信息
             self.loadGoodsReadyData();
        }
    },
    computed: {
        freeTotalPrice(){
            //总优惠价 = 满减优惠+优惠券优惠
            var freePrice = Number(this.preOrderData.minusPrice)+Number(this.couponPrice);
            if(freePrice>this.preOrderData.totalPrice){
                return this.preOrderData.totalPrice;
            }
            return freePrice.toFixed(2);
        },
        shouldPayPrice(){
            var payalbePrice = 0.00;
            var peisongFee = 0.00;
            if(this.preOrderData.isPostFree == '1'){
                payalbePrice = this.preOrderData.totalPrice - this.freeTotalPrice;
            }else{
                peisongFee = parseFloat(this.preOrderData.shipPrice);
                var after_discount_price = this.preOrderData.totalPrice - this.freeTotalPrice;
                if(after_discount_price<0){
                   after_discount_price = 0.00; 
                }
                payalbePrice = after_discount_price + peisongFee;
            }
            //应付金额
            return payalbePrice<0?0.00:payalbePrice;
        },
        realPayPrice(){
            var realPay = this.shouldPayPrice;
            if(this.checkSPCard){
                if(this.localWallet.spCardBalance >= this.shouldPayPrice){
                    realPay = 0.00;
                }else{
                    realPay = this.shouldPayPrice - this.localWallet.spCardBalance;
                }
            } else if(this.checkMKCard){
                if(this.localWallet.mkCardBalance >= this.shouldPayPrice){
                    realPay = 0.00;
                }else{
                    realPay = this.shouldPayPrice - this.localWallet.mkCardBalance;
                }
            }
            //实际支付金额
            return realPay.toFixed(2);
        },
    },
    methods: {
        //切换地址
        changeAddressClick:function(){
            //地址不存在需要传一个空对象
            storage.setItem('oderSubmit_selectAddress',JSON.stringify(this.addressModel?this.addressModel:{}),event =>{})
            navigation.push({url:'address_list.html', title:'选择地址'}, event =>{
             });
        },
        //选择优惠券
        seletCouponClick:function(){
            if(this.preOrderData.listWithinArea.length==0&&this.preOrderData.listWithoutArea.length>0){
                modal.toast({message:'无可选择优惠券'})
                return;
            }
            storage.setItem('oderSubmit_selectCoupon',JSON.stringify(this.supGoodsIds),event =>{})
            navigation.push({url:'coupon_selectCoupon.html', title:'选择优惠券'}, event =>{
             });
        },
        //切换余额支付
        onSwitchChangeMK:function(event){
            this.checkMKCard = event.value;
            this.checkSPCard = false;
        },
        onSwitchChangeSP:function(event){
            console.log(`onchage, value: ${event.value}`)
            this.checkSPCard = event.value;
            this.checkMKCard = false;
        },
        //点击确认支付按钮或第三方支付
        confirmPayClick:function(payType){
            const self = this;
            self.payType = payType;
            if(!this.addressModel){
                modal.toast({message:"当前无可配送地址"})
                return;
            }
            if(this.preOrderData.listWithinArea.length == 0){
                //若商品全部不在配送范围内
                modal.alert({message:"当前无可结算商品"})
                return;
            }
            if(this.preOrderData.bgcListWithoutArea && this.preOrderData.bgcListWithoutArea.length > 0){
                var message = '\n超出配送范围，是否继续交易';
                if(this.preOrderData.listWithoutArea.length == 1){
                    var goodsName = this.preOrderData.listWithoutArea[0].goodsName;
                    message = goodsName + message;
                }else {
                    message = '有部分商品超出配送范围\n是否继续交易'
                }
                //bgcListWithinArea数组中没有主题活动ID，故在此做如下处理
                //排除supGoodsIds中包含在bgcListWithoutArea中的商品对象
                var outAreaGoodsIds = ''
                this.preOrderData.bgcListWithoutArea.forEach(element => {
                    outAreaGoodsIds = outAreaGoodsIds + element.supGoodsId+','
                });
                if(outAreaGoodsIds.length > 0){
                    var goodsIds = [];
                    this.supGoodsIds.forEach(element => {
                        if(outAreaGoodsIds.indexOf(element.supGoodsId) == -1){
                            goodsIds.push(element);
                        }
                    });
                    this.tempSupGoodsIds = goodsIds;
                }
                modal.confirm({message:message,okTitle:'继续',cancelTitle:'取消'},function(result){
                    if(result == '继续'){
                        //全部使用余额支付且设置过支付密码且开启密码支付
                        if(payType == 100 && self.realPayPrice<=0 &&self.localWallet.hasPassword =="true"&&self.localWallet.opened == 'true'){
                            // this.isBottomShow = true;
                            self.pwdErrorCount()
                        }else{
                            //余额支付金额
                            var localpay = '0.00';
                            if(self.checkSPCard){
                                if(self.localWallet.spCardBalance >= self.shouldPayPrice){
                                    localpay = self.shouldPayPrice.toFixed(2);
                                }else{
                                    localpay = self.localWallet.spCardBalance;
                                }
                            } else if (self.checkMKCard) {
                                if(self.localWallet.mkCardBalance >= self.shouldPayPrice){
                                    localpay = self.shouldPayPrice.toFixed(2);
                                }else{
                                    localpay = self.localWallet.mkCardBalance;
                                }
                            }
                            //第三方和余额混合支付，使用余额不够且设置过支付密码且开启密码支付
                            if(Number(localpay)>0 && self.localWallet.hasPassword =="true" && self.localWallet.opened == 'true'){
                                self.pwdErrorCount()
                            }else {
                                self.submitActivitySuperiorOrder('',payType);
                            }
                        }
                    }
                });

            }else{
                this.tempSupGoodsIds = this.supGoodsIds;
                //全部使用余额支付且设置过支付密码且开启密码支付
                if(payType == 100 && this.realPayPrice<=0&&this.localWallet.hasPassword =="true"&&this.localWallet.opened == 'true'){
                    // this.isBottomShow = true;
                    this.pwdErrorCount()
                }else{
                    //余额支付金额
                    var localpay = '0.00';
                    if(this.checkSPCard){
                        if(this.localWallet.spCardBalance >= this.shouldPayPrice){
                            localpay = this.shouldPayPrice.toFixed(2);
                        }else{
                            localpay = this.localWallet.spCardBalance;
                        }
                    } else if (this.checkMKCard) {
                        if(this.localWallet.mkCardBalance >= this.shouldPayPrice){
                            localpay = this.shouldPayPrice.toFixed(2);
                        }else{
                            localpay = this.localWallet.mkCardBalance;
                        }
                    }
                    //第三方和余额混合支付，使用余额不够且设置过支付密码且开启密码支付
                    if(Number(localpay)>0 && this.localWallet.hasPassword =="true" && this.localWallet.opened == 'true'){
                        this.pwdErrorCount()
                    }else {
                        this.submitActivitySuperiorOrder('',payType);
                    }
                }
            }
            
        },
        // 判断密码输入错误次数
        pwdErrorCount: function () {
            const self = this
            var param = {}
            Fetch.post('buyer/getUserCardPayPasswordErrorCount.json', param, function(respone){
                var result = JSON.parse(respone);
                /**
                 * {"op_flag":"success","info":"操作成功","code":"0","errorCount":"0","userId":"748736657603915776","userName":"15801974371","currDate":"2018-11-30 13:46:23"}
                 */
                if (result.op_flag == 'success') {
                    if (parseInt(result.errorCount) < 5) {
                        self.isBottomShow = true
                    } else {
                        self.isBottomShow = false
                        modal.toast({
                            message:'密码错误次数超过5次，请过5分钟后再试或重置密码',
                            duration: 0.5
                        })
                    }
                } else {
                    modal.toast({message:reslut.info})
                }
            }, function(err){
                modal.toast({message:err})
            })
        },
        //网络出错点击
        wxcResultButtonClicked:function(){
            const self = this;
            self.showResult = false;
            //获取优惠券数量
            this.getCouponCount();
            //获取地址信息
            this.loadAddressInfo(callback => {
                //获取商品信息
                self.loadGoodsReadyData();
            });
        },
        //隐藏密码弹框
        cancalPasswordInputClick:function() {
             this.isBottomShow = false;
        },
        //密码输入完成
        passwordFinish:function(value){
             console.log('密码：'+value)
            //  modal.toast({message:'密码：'+value})
            const self = this;
            var param = {password:value}
             Fetch.post('buyer/checkUserCardPayPassword.json', param, function(respone){
                 var reslut = JSON.parse(respone);
                  /*
                    { "op_flag": "success",
                    "code": "0",
                    "info":'',
                    "userId":'',
                    "errorCount": "5",
                    "isPasswordCorrect":"true"}
                 */
                 if(reslut.op_flag == 'success'){
                     self.password_error_count = reslut.errorCount
                     if(reslut.isPasswordCorrect == 'true'){
                         self.isBottomShow = false;
                         self.submitActivitySuperiorOrder(value,self.payType);
                     }else{
                         self.isBottomShow = false;
                         modal.alert({
                             message:reslut.info == '操作成功'?"密码错误":reslut.info,
                             okTitle: "确认"
                         },evnet=>{
                             if (self.password_error_count < '5') {
                                 self.isBottomShow = true;
                             } else {
                                 self.isBottomShow = false;
                             }
                         })
                     }
                     
                 }else{
                     modal.toast({
                         message:reslut.info,
                         duration: 0.5
                     })
                 }
             }, function(err){
                 modal.toast({
                     message:err,
                     duration: 0.5
                 })
             });
             
        },
        //获取地址信息
        loadAddressInfo:function(callback){
            const self = this;
            var param = {queryFrom:'wechatShop'}
            Fetch.request('buyer/address.json',param, function(respone){
                // console.log('地址：'+respone);
                // modal.alert({message:'地址：'+respone})
                var reslut = JSON.parse(respone);
                if(reslut.op_flag == 'success'){
                    storage.getItem('history_select_address',event =>{
                        var found = false;
                        if (event.data != 'undefined' && event.data.length > 0 && reslut.list.length > 0){
                            var history_address = JSON.parse(event.data);
                            reslut.list.forEach(function(addr){
                                if(addr.id == history_address.id){
                                    self.addressModel = addr;
                                    found = true;
                                }
                            });
                            
                        } 
                        if(reslut.list.length > 0){
                            if(!found){
                                self.addressModel = reslut.list[0];
                            }
                            reslut.list.forEach(function(e){
                                if(e.acquiescent_addr == 1){
                                    self.addressModel = e;
                                }
                            }); 
                        } else {
                            self.addressModel = null;
                        }
                        callback();
                    })

                } else {
                    modal.toast({message:reslut.info})
                }
            }, function(err){
                self.showResult = true;
                modal.toast({message:err})
            })
        },
        //获取商品信息
        loadGoodsReadyData:function() {
            const self = this;
             var addrId = 'none';
            if(self.addressModel && self.addressModel.id && self.addressModel.id.length > 0){
                addrId = self.addressModel.id;
            }
            var param = {supGoodsIds:JSON.stringify(self.supGoodsIds),addrId:addrId}
            console.log('提交订单入参：',param)
            self.showLoading = true
            Fetch.post('buyer/countSuperiorBuyerGoodsCart.json',param, function(respone){
                self.showLoading = false
                console.log('商品信息：'+respone);
                var reslut = JSON.parse(respone);
                /*
                reslut = {
                    "op_flag": "success",
                    "listWithinArea": [{
                        "supGoodsId": "784921804782215169",
                        "price": "98.00",
                        "count": "1",
                        "supCartId": "",
                        "goodsName": "辽宁蟹田香米2.5kg*1袋"
                    }],
                    "listWithoutArea": [],
                    "bgcListWithinArea": [{
                        "supGoodsId": "784921804782215169",
                        "count": "1",
                        "supCartId": "",
                        "bgcId": "827704076099686400"
                    }],
                    "bgcListWithoutArea": [],
                    "totalPrice": "98.00",//商品总价
                    "payalbePrice": "0.00",//实际支付金额
                    "shipPrice": "3.00",//订单需支付的配送费
                    "newShipPrice": "5.00",//包邮的配送费
                    "isPostFree": "0",//0:1是否包邮
                    "minusPrice": "20.00"//满减优惠价格
                    "condtionPrice":"199" //满额包邮条件
                }*/
                if(reslut.op_flag == 'success'){
                    self.preOrderData = reslut;
                    
                    var peisongFee = 0.00;
                    if(reslut.isPostFree != '1'){
                        //  peisongFee = parseFloat(reslut.shipPrice);
                        //满额包邮2期优化修改
                        peisongFee = parseFloat(reslut.resultMap.expressFee)
                    }
                    self.shippingFee = `¥${peisongFee.toFixed(2)}`
                }else{
                    self.showResult = true;
                    modal.toast({message:reslut.info})
                }
            }, function(err){
                self.showLoading = false
                self.showResult = true;
                modal.toast({message:err,duration: 0.3})
            })
        },
        //切换地址刷新接口
        changeAddressRefresh:function(addrId){

            var param = {supGoodsIds:JSON.stringify(this.supGoodsIds),addr_id:addrId,weChat:"2"}

            Fetch.post('buyer/address_by_id_1.json',param, function(respone){
                var reslut = JSON.parse(respone);
                modal.alert({message:'切换地址：'+respone})
                if(reslut.op_flag == 'success'){

                }else{
                    console.log(reslut.info)
                }
            }, function(err){
                console.log('错误信息:'+err)
                // modal.toast({message:err,duration: 0.3})
            })
        },
        //获取余额信息
        getUserCardInfo:function() {
            const self = this;
            Fetch.post('buyer/getUserCardInfo.json',{}, function(respone){
                console.log('余额信息：'+respone);
              var sm_respone ={
                 "op_flag":"success",
                "userId": "725166171291836416",
                "userName": "13564528094",
                "mkCardBalance": "10.00",//菜市帐号余额
                "spCardBalance": "200.10",//优选帐号余额
                "totalCardBalance": "0.00",//账户总的余额
                "exchangedAmount": "0",//已兑换金额总数
                "superiorExchangedAmount": "0",//优选已兑换金额
                "hasPassword": "true",//是否设置过密码，若设置过则余额支付需要输入密码
                "opened": "true",//支付密码是否开启（true 和 false）
                "isSuperiorOrderCanUseMkCard": "0",//优选订单是否可以使用菜市卡（1--可使用，0--不可使用）
                "exchangeDescription":"",//兑换规则说明
                
               } 
                var reslut = JSON.parse(respone);
                if(reslut.op_flag == 'success'){
                    var spCardBalance = parseFloat(reslut.spCardBalance);
                    if(reslut.isSuperiorOrderCanUseMkCard == 1){
                        // spCardBalance = spCardBalance + parseFloat(reslut.mkCardBalance);
                    }
                    reslut.spCardBalance = spCardBalance.toFixed(2);
                    self.localWallet = reslut;
                }else{
                    modal.toast({message:reslut.info})
                }
            }, function(err){
                modal.toast({message:err,duration: 0.3})
            })
        },
        //获取优惠券信息
        getCouponCount:function(){
             const self = this;
            var param = {currentPage:'1',
                        supGoodsIds:JSON.stringify(self.supGoodsIds),
                        offLineStoreZiTi:'0'};
            Fetch.post('superior/wechat/discountList.json', param, function(response){
                var result = JSON.parse(response)
                if(result.op_flag == 'success'){
                    self.couponCount = result.objs.length;   
                }else{
                     modal.toast({message:reslut.info})
                     self.showResult = true;
                }
            },function(err){
                self.showResult = true;
                modal.toast({message:err,duration: 0.3})
            })
        },
        
        //提交订单,payType支付类型1微信支付；2支付宝；100本地余额支付
        submitActivitySuperiorOrder:function(password, payType){
            const self = this;
            //优惠券ID
            var couponId='';
            self.couponList.forEach(function(e,i){
                couponId += ','+e.id;
            })
            if(couponId.length>0){
                couponId = couponId.substring(1);
            }
            //余额支付金额
            var localpay = '0.00';
            if(this.checkSPCard){
                if(this.localWallet.spCardBalance >= this.shouldPayPrice){
                    localpay = this.shouldPayPrice.toFixed(2);
                }else{
                    localpay = this.localWallet.spCardBalance;
                }
            } else if(this.checkMKCard){
                if(this.localWallet.mkCardBalance >= this.shouldPayPrice){
                    localpay = this.shouldPayPrice.toFixed(2);
                }else{
                    localpay = this.localWallet.mkCardBalance;
                }
            }

            var cardType = 'YP'
            if (this.checkMKCard) {
                cardType = 'CS'
            }

            
            var param = {addrId:self.addressModel.id,//地址ID
                        supGoodsIds:JSON.stringify(self.tempSupGoodsIds),
                        discountCouponId:couponId,//优惠券ID
                        cardType: cardType,//优选标示:YP, 菜市标识:CS
                        minusPrice:self.preOrderData.minusPrice,//满减优惠金额
                        cardAmount:localpay,//余额支付金额
                        cardPw:password&&password!='undefined'?password:'',//支付密码
                        addFrom:'weChatShop'};
            self.showLoading = true;
            Fetch.post('buyer/submitActivitySuperiorOrderForm.json', param, function(response){
                var result = JSON.parse(response)
                // modal.alert({message:'支付完成：'+response})
                
                if(result.op_flag == 'success'){
                    const refreshChannel = new BroadcastChannel("refreshChannel");
                    refreshChannel.postMessage('refreshChannel')
                    if(payType == 100){
                        self.showLoading = false;
                        navigation.push({url:'order_index.html', title:'订单列表', replace:'true'}, event =>{ });
                    } else {
                        console.log('订单ids:'+JSON.stringify(result.supOfList))
                        self.thirdPartyPay(result.supOfList, payType);
                    }
                } else {
                    self.showLoading = false;
                    modal.toast({message:result.info, duration: 0.5})
                }
            }, function(err){
                self.showLoading = false;
                modal.toast({
                    message: err,
                    duration: 0.3
                })
            })
        },
        //使用第三方支付
        thirdPartyPay:function(orderIds,payType){
            var payTypeStr = '';
            if(payType == 1){
                payTypeStr = 'weChatpay'
            }else if(payType == 2){
                payTypeStr = 'alipay'
            }
            const self = this;
            var clientType = "youxuan"
            if(weex.config.env.appName == 'superior'){
                //优选
                clientType = "youxuan"
            }else if(weex.config.env.appName == 'buyer' || weex.config.env.appName == 'IOS-buyer'){
                //消费者普通版
                clientType = "release"
            }else if(weex.config.env.appName == 'IOS-buyer-preview'){
                //消费者抢先版
                clientType = "test"
            }else if(weex.config.env.appName == 'IOS-buyer-pro'){
                //消费者专业版
                clientType = "professional"
            }
            
            var param = {
                payType:payTypeStr,
                orderIdJSON:JSON.stringify(orderIds),
                clientType:clientType,
                orderType:'Superoir'
            };
            Fetch.request('order_pay_for_superior.json', param, function(response){
                self.showLoading = false;
                var result = JSON.parse(response)
                if(result.op_flag == 'success'){
                    result.payType = payTypeStr
                    //已拉起第三方支付sdk
                    self.topBecomeActive = true;
                    self.addEventListener()
                    if (WXEnvironment.platform === 'android' || WXEnvironment.platform === 'iOS') {
                        weex.requireModule('Payment').Pay(result, function(event){})
                    }
                }else{
                    navigation.push({url:'order_index.html', title:'我的订单', replace:'true'}, event =>{ });  
                    modal.toast({message:result.info})
                }
            },function(err){
                self.showLoading = false;
                navigation.push({url:'order_index.html', title:'我的订单', replace:'true'}, event =>{ });
                modal.toast({message:err,duration: 0.3})
            })
        },
        addEventListener(){
            //iOS支付是否点击顶部返回监听
            var self = this
            globalEvent.addEventListener("WXApplicationDidBecomeActiveEvent", function (e) {
                console.log("WXApplicationDidBecomeActiveEvent");
                //支付回调和应用激活，先后无序；故延时处理
                setTimeout(()=>{
                    if(self.topBecomeActive){
                        self.topBecomeActive = false;
                        navigation.push({url:'order_index.html', title:'我的订单', replace:'true'}, event =>{ }); 
                    }
                },1000);
                self.removeEventListener()
            });
            globalEvent.addEventListener("PayBack", function (event) {
                console.log(event)
                self.topBecomeActive = false;
                //code:0支付成功；1支付失败
                var paystr = '支付成功'
                if (event.code != '0') {
                    paystr = event.msg
                }
                modal.toast({message:paystr})
                navigation.push({url:'order_index.html', title:'我的订单', replace:'true'}, event =>{ });
                self.removeEventListener()
            })
        },
        removeEventListener(){
            globalEvent.removeEventListener('WXApplicationDidBecomeActiveEvent')
            globalEvent.removeEventListener('PayBack')
        },
        goGatherTogether(template){
            
            let gatherData = {
                                templateId:template.templateId,
                                addrId:this.addressModel.id,
                                totalPrice:template.totalPrice,
                                postagePrice:template.postagePrice
                                }
            storage.setItem('GatherDataKey',JSON.stringify(gatherData),event =>{})
            navigation.push({url:'shopping_gather.html','pop':true, title:'凑单'}, event =>{});
            /*
            //跳转到首页
            navigation.push({switchTab: '0'}, evnet=>{})
            if (navigation.isIOS() && WXEnvironment.appVersion == '1.0') {
                navigation.pop({popToRoot: true}, event=>{})
            }else if(navigation.isAndroid()){
                navigation.pop({popToRoot: true}, event=>{})
            }else if(WXEnvironment.platform.toLowerCase() === 'web'){
                navigation.pop({animated:'true'},event=>{})
            }
            */
        }
    }
}
</script>

<style scoped>
.scroller { 
    width: 750px;
    flex: 1;
    background-color: white;
}
.address{
    flex-direction:row; 
    align-items: center;
    border-bottom-width: 10px;
    border-bottom-color: #f0f0f0; 
}
.name-div {
    flex-direction: row;
    align-items: center;
    margin: 22px;
}
.name-text {
    margin-right: 10px;
    flex: 1;
    color: #333333;
    font-size: 28px;
}
.address-info {
    flex-direction: row;
    margin-left: 22px;
    margin-right: 10px;
    margin-bottom: 22px;
}
.address-icon {
    width:32px;
    height:38px;
    margin-right: 22px;
}
.address-text {
    flex: 1;
    color: #000000;
    font-size: 28px;
}
.spacebetween-div {
    flex-direction: row;
    align-items: center;
    justify-content: space-between;
    margin-left: 22px;
    margin-right: 22px;
    padding-top: 10px;
    padding-bottom: 10px;
}
.bottom-pay {
    margin-bottom:40px;
    padding-bottom:20px;
    border-bottom-width:2px;
    border-bottom-color:#f0f0f0;
}
.confirm-pay {
  font-size: 40px;
  text-align: center;
  margin-top: 20px;
  margin-bottom: 20px;
  margin-left: 75px;
  margin-right: 75px;
  padding-top: 20px;
  padding-bottom: 20px;
  border-width: 1px;
  border-style: solid;
  color: #ffffff;
  border-color: #dddddd;
  background-color: rgb(226, 35, 35);
  border-radius: 10px;
}
.confirm-unpay {
  font-size: 40px;
  text-align: center;
  margin-top: 20px;
  margin-bottom: 20px;
  margin-left: 75px;
  margin-right: 75px;
  padding-top: 20px;
  padding-bottom: 20px;
  border-width: 1px;
  border-style: solid;
  color: #ffffff;
  border-color: #dddddd;
  background-color: #d0d0d0;
  border-radius: 10px;
}

</style>
