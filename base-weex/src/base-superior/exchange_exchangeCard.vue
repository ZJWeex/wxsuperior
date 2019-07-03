<template>
    <div class='wrapper'>
        <navigation title="商品兑换" 
                    right-button="/web/assets/sup/sup_personal_helper.png" 
                    :use-default-return='show == false && dialogShow == false' 
                    @wxcMinibarRightButtonClicked='wxcMinibarRightButtonClicked'
                    @wxcMinibarLeftButtonClicked="wxcMaskSetHidden"/>
        <wxc-tab-page ref="wxc-tab-page"
            :tab-titles="tabTitles"
            :tab-styles="tabStyles"
            :tab-page-height="tabPageHeight"
            :needSlider='true'
            @wxcTabPageCurrentTabSelected="wxcTabPageCurrentTabSelected">
            <list v-for="(item, index) in cardList" :key="index+'cell1'" :style="{height:((tabPageHeight - tabStyles.height)+'px'), width:(750+'px')}">
                <cell v-if="index == 0">
                    <wxc-pan-item @wxcPanItemPan="wxcPanItemPan">
                        <div v-if="item.type == '未使用'">
                            <div class="inputZone">
                                    <input type="number" ref="input1" placeholder="请输入兑换码" @input="inputListener" style="font-size: 30px; height: 80px; width: 400px;" :value="theExchangeCardCode"/>
                                    <div style="flex-direction: row; align-items: center;">
                                        <image v-if="theExchangeCardCode != '' && !isAndroid" style="width: 30px; height: 30px;" src='/web/assets/sup/sup_personal_cancle_input.png' @click="cancelInput"/>
                                        <text style="font-size: 30px;color: #d0104c;margin-left:10px;" @click="confirmExchange">兑换</text>
                                    </div>
                            </div>
                        </div>
                        <div v-if="index != 0" style="width: 750px;height: 20px;"></div>
                    </wxc-pan-item>
                </cell>

                <cell v-for="(card, idx) in item.giftCardList" :key="idx+'cell2'">
                    <wxc-pan-item @wxcPanItemPan="wxcPanItemPan">
                        <div class="card" >
                            <image class="goodsImg" :src='card.card_img' resize='contain'/>
                            <div class="goodsInfo goodsInfo-height">
                                <div>
                                    <text style="font-size:30px; color: #222222;">¥{{card.cardAmount}}</text>
                                    <text style="font-size:18px; color: #999999; lines:1;">卡号:{{card.serialNo}}</text>
                                </div>
                                <text v-if="index == 1" class="orderStatus">{{card.notice ? card.notice : '已被'+PrivacyPhone(card.telephone)+'用户充值'}}</text>  
                                <text v-else :style="{'font-size': 18+'px', color:(index == 0) ? '#333333': '#d0104c'}">有效期至{{card.expiryDate}}</text>  
                            </div>
                            <div class="goodsInfo-height gift-button" >
                                <!-- 已过期 -->
                                <div v-if="index == 2" class="expire">
                                    <image style="width: 75px; height: 60px; " src='/web/assets/sup/sup_personal_expire.png' resize='contain'/>
                                </div>

                                <!-- 未使用 -->
                                <div v-else-if="index == 0" style="align-items: flex-end; flex-direction: row; ">
                                    <div class="logistics" style="background-color: #d0104c; margin-right: 15px; " @click="deposit(card)">
                                        <text class="gift-operator" >充值</text>
                                    </div>
                                    <div class="logistics" style="background-color: #2e9987;"  @click="shareToFriends(card)">
                                        <text class="gift-operator">赠送</text>
                                    </div>
                                </div>
                                <div v-if="index == 0" style="justify-content: flex-start; flex-direction: row; ">
                                    <text style="font-size: 24px; margin-left: 15px" >x</text>
                                    <text style="font-size: 26px;" >1</text>
                                </div>

                            </div>
                        </div>
                    </wxc-pan-item>
                </cell>
                <cell v-for="(card, idx) in item.exchangeCardList" :key="idx+'cell3'">
                    <wxc-pan-item @wxcPanItemPan="wxcPanItemPan">
                        <div class="card" >
                            <image class="goodsImg" :src='card.goodsImageUrl' resize='contain'/>
                            <div class="goodsInfo goodsInfo-height">
                                <div>
                                    <text style="font-size:30px; color: #222222;">{{card.goodsName}}</text>
                                    <text style="font-size:18px; color: #999999; lines:1;">{{card.aliasName}}</text>
                                </div>
                                <div v-if="index == 1">
                                        <text v-if="card.orderStatus == '20'" class="orderStatus">待准备</text>
                                        <text v-if="card.orderStatus == '30'" class="orderStatus">准备中</text>
                                        <text v-if="card.orderStatus == '35'" class="orderStatus">配送中</text>
                                        <text v-if="card.orderStatus == '40'" class="orderStatus">待收货</text>
                                        <text v-if="card.orderStatus == '8'" class="orderStatus">已关闭</text>
                                        <text v-if="card.orderStatus == '50' || card.orderStatus == '108'" class="orderStatus">已完成</text>
                                </div>
                                <text v-else style="font-size:18px; color: #d0104c;">有效期至{{card.expiryDate}}</text>
                            </div>
                            
                            <div class="goodsInfo-height" style="margin-top: 5px">
                                <!-- 已过期 -->
                                <div v-if="index == 2" class="expire">
                                    <image style="width: 75px; height: 60px;" src='/web/assets/sup/sup_personal_expire.png' resize='contain'/>
                                </div>
                                <!-- 已使用 -->
                                <div v-if="index == 1 && card.waybillNumber != '' && (card.orderStatus == '40' || card.orderStatus == '35' || card.orderStatus == '50' || card.orderStatus == '108')" class="logistics" style="background-color: #d0104c; margin-top: 30px; margin-right: 20px;" @click="logisticsAction(card)">
                                    <text class="gift-operator">查看物流</text>
                                </div>
                            </div>
                        </div>
                    </wxc-pan-item>
                </cell>

                <cell v-if ="item.exchangeCardList.length == 0 && item.giftCardList.length == 0" >
                    <wxc-pan-item>
                      <div :style="{height:((tabPageHeight - tabStyles.height)+'px'), width:(750+'px')}">
                            <wxc-result
                                :type="item.prompt"
                                :show="true"
                                :custom-set="customSet"
                                :wrap-style="{top:0}"
                                padding-top="32"
                                v-if="index != 0">
                            </wxc-result>
                        </div>
                    </wxc-pan-item>
                </cell>
                <cell v-if="isAndroid">
                    <!-- 目的：android全面屏物理键可隐藏和显示 -->
                    <div style="height:100px;width:750px;"></div>
                </cell>
            </list>
        </wxc-tab-page>
        <helper :show='show' @wxcMaskSetHidden='wxcMaskSetHidden'/>
        <wxc-loading :show="showLoading" 
                    :need-mask='needMask'>
        </wxc-loading>
            <Dialog
                        :title=bindTitle
                        :title-color='contentColor'
                        :content=bindTelephone
                        :content-color='contentColor'
                        :show="dialogShow"
                        :main-btn-color='mainBtnColor'
                        :show-no-prompt="false"
                        :single="bindTitle?false:true"
                        @wxcDialogCancelBtnClicked="wxcDialogCancelBtnClicked"
                        @wxcDialogConfirmBtnClicked="wxcDialogConfirmBtnClicked">

            </Dialog>
    </div>
</template>

<script>
import navigation from "@/base-superior/components/NavigationBar.vue";
import {WxcTabPage, WxcResult, BindEnv, WxcPanItem, WxcLoading} from 'weex-ui';

import Fetch from "@/base-superior/Fetch.js";
import helper from "@/base-superior/exchange_exchangeCard_helper.vue";
import check from './check.js';
import Define from "@/base-superior/Define.js";
import Dialog from '@/base-superior/components/Dialog.vue';

const storage = weex.requireModule("storage");
const modal = weex.requireModule('modal')


export default {
    components: {navigation, WxcTabPage, helper, WxcResult, WxcPanItem, Dialog, WxcLoading},
    data() {
        return {
            needMask: (navigation.isAndroid() || navigation.isIOS())?'true':true,
            tabPageHeight: navigation.pageHeight(false),
            show: false,
            isCanClick: true,
            dialogShow: false,
            showLoading: false,
            isAndroid:WXEnvironment.platform === 'android',
            customSet:{
                noues: { button: null, content: '没有未使用的兑换', desc: '' },
                used: { button: null, content: '没有已使用的兑换', desc: '' },
                expire: { button: null, content: '没有已过期的兑换', desc: '' },
            },
            tabTitles:[{'title':'未使用', },{'title':'已使用', },{'title':'已过期', }],
            tabStyles:{
                bgColor: '#FFFFFF',
                titleColor: '#999999',
                activeTitleColor: '#d0104c',
                activeBgColor: '#FFFFFF',
                isActiveTitleBold: false,
                iconWidth: 0,
                iconHeight: 0,
                width: 250,
                height: 90,
                fontSize: 34,
                hasActiveBottom: true,
                activeBottomColor: '#d0104c',
                activeBottomHeight: 3,
                activeBottomWidth: 120,
                textPaddingLeft: 10,
                textPaddingRight: 10
            },
            cardList:[
                {
                    type: '未使用',
                    prompt: 'noues',
                    exchangeCardList:[],
                    giftCardList:[],
                },
                {
                    type: '已使用',
                    prompt: 'used',
                    exchangeCardList:[],
                    giftCardList:[],
                },
                {
                    type: '已过期',
                    prompt: 'expire',
                    exchangeCardList:[
                        /*{"goodsName":"臻萃百福",
                                        "sku_id":"6175085937110302257",
                                        "aliasName":"1盒",
                                        "goodId":"849486491931213825",
                                        "expiryStatus":"false",
                                        "deleteStatus":"false",
                                        "goodsStatus":"0",
                                        "order_id":"5439135817603018445",//订单ID
                                        "superiorOrderId":"862094145520738304",
                                        "orderStatus":"50",
                                        "goodsImageUrl":"http://tcmdefaultbucket-1253294191.cossh.myqcloud.com/img/upload/img/upload/advert/a5e11f6c-f4bb-4b34-9f31-e8cc39a126c9.jpg_middle.jpg",
                                        "addCart":"false",
                                        "waybillNumber":"253550565148" //物流单号
                                        }*/
                                        ],
                    giftCardList:[],
                },
            ],
            theExchangeCardCode:'',
            bindTitle: null,
            bindTelephone: null,
            card: null,
            mainBtnColor: '',
            contentColor: '',
            titleColor: '',
        }
    },
    created() {
        this.getCardList(1)
        this.getCardList(2)
        this.getCardList(3)

        var self = this
        const commodidyCardChannel = new BroadcastChannel("exchange_exchangeCard_event");
        
        commodidyCardChannel.onmessage = function (event){
            if (event.data == 'goods_giftVoucher') {
                self.$refs['wxc-tab-page'].setPage(0)
            } else {
                modal.toast({
                    message: '兑换成功',
                    duration: 0.5
                })
                self.$refs['wxc-tab-page'].setPage(1)
            }

        } 
    },
    methods: {
        confirmExchange (event) {
            // 过滤emoji表情
            if (check.isEmojiCharacter(this.theExchangeCardCode)) {
                modal.toast({
                    message:"兑换码不能包含特殊字符\n请输入正确的兑换码",
                    duration: 1.0
                })
                return;
            }
            if (this.isCanClick) {
                this.isCanClick = false;
                this.showLoading = true
                this.$refs.input1[0].blur()
                if (this.theExchangeCardCode.length) {
                    var self = this
                    Fetch.post('useCommodityCard.json', {exchangeCode:self.theExchangeCardCode},
                    function(jsonString) {
                        var result = JSON.parse(jsonString);
                        if (result['op_flag'] == "success") {
                            storage.setItem('oderSubmit_selectAddress',JSON.stringify({}),event =>{})
                            storage.setItem('Exchange_Card_Info', self.theExchangeCardCode,event =>{})
                            navigation.push({url:'address_list.html', title:'选择收货地址', pop: 'true'}, event =>{});
                        } else {
                            modal.toast({
                                message: result.info
                                })
                        }
                        self.showLoading = false
                    }, function(err) {
                        modal.toast({
                            message: err,
                        })
                        self.showLoading = false
                    })
                } else {
                    modal.toast({
                        message: '请输入正确的兑换码',
                    })
                    this.showLoading = false
                }
                //定时器
                setTimeout(() =>{
                    this.isCanClick = true;
                }, 850);
            }
        },
        getCardList (index) {
            var self = this
            Fetch.post('superiorGoods/exchangeCardV2.json', {type:String(index)}, event=>{
                var result = JSON.parse(event);
                console.log('礼品卡：',event);
                if (result['op_flag'] == "success") {
                    self.cardList[(index - 1)].giftCardList = result.giftCardList
                    if (index != 0) {
                        self.cardList[(index - 1)].exchangeCardList = result.exchangeCardList
                    }
                }
                self.showLoading = false
            }, event=>{
                self.showLoading = false
            })
        },
        inputListener (event) {
            this.theExchangeCardCode = event.value
        },
        logisticsAction (event) {
            var photoArr = []
            if (event.goodsImageUrl.length) {
                photoArr.push(event.goodsImageUrl)
            }
            //物流轨迹
            storage.setItem('Order_logisticCode', event.waybillNumber, event=>{
            });
            navigation.push({url:'order_logistic_detail.html', title:'物流轨迹'}, event =>{});
        },
        wxcTabPageCurrentTabSelected (e) {
            this.getCardList(parseInt(e.page)+1)
            this.$refs.input1[0].blur()
        },
        wxcMinibarRightButtonClicked (event) {
            this.show = true
            this.$refs.input1[0].blur()
        },
        wxcMaskSetHidden (event) {
            this.show = false
            this.dialogShow = false
        },
        cancelInput: function (){
            this.theExchangeCardCode = ''
        },
        wxcPanItemPan (e) {
            if (BindEnv.supportsEBForAndroid()) {
                this.$refs['wxc-tab-page'].bindExp(e.element);
            }
        },
        deposit(card){
            this.dialogShow = true
            this.card = card
            this.showBindAlert(true)
        },
        shareToFriends(card){
            storage.setItem('goods_giftVoucher_my', JSON.stringify(card))
            navigation.push({url:'goods_giftVoucher_my.html', title:'查看礼品卡'}, event =>{ });
        },
        wxcDialogConfirmBtnClicked(){
            this.dialogShow = false
            if (!this.bindTitle) {
                return
            }

            this.showLoading = true
            var param = {
                "tab":"1",
                "giftCardId":this.card.giftCardId,}

            var self = this
            Fetch.post('bindsGiftCard.json', param, response=>{
                self.showLoading = false
                self.card = null
                var result = JSON.parse(response)
                self.getCardList(1)
                if (result.op_flag == 'fail'){
                    modal.toast({
                        message: result.info,
                    })
                } else {
                    self.showBindAlert(false)
                    self.dialogShow = true
                }
            }, fail=>{
                self.showLoading = false
                modal.toast({
                    message: fail,
                })
            })
        },
        wxcDialogCancelBtnClicked(){
            this.dialogShow = false
        },
        PrivacyPhone(telephone){
            var len= telephone.length;
            var xx= telephone.substring(3,len-4);
            var values = telephone.replace(xx,"****");
            return values;
        },
        showBindAlert(binding){
            var self = this
            if (binding) {
                storage.getItem(Define.kPhone, event=>{
                    if (event.result == 'success') {
                        self.bindTelephone = event.data
                    }
                    self.titleColor = '#333333'
                    self.contentColor = '#333333'
                    self.mainBtnColor = '#d0104c'
                }) 
                self.bindTitle = '绑定当前账户'
            } else {
                self.bindTitle = null
                self.titleColor = '#d0104c'
                self.contentColor = '#d0104c'
                self.mainBtnColor = '#333333'
                self.bindTelephone = '已充值至"' + self.bindTelephone + '"的账户余额中'
            }
        }
    }
}
</script>

<style scoped>
.wrapper { 
    align-items: center;
}
.inputZone{
    margin-top: 20px;
    height: 80px; 
    width: 750px;
    background-color:#ffffff;
    flex-direction: row;
    padding-left: 30px;
    padding-right: 30px;
    align-items: center;
    justify-content: space-between;
}
.card{
    margin-left: 30px;
    margin-right: 30px;
    margin-top: 20px;
    height: 160px;
    flex-direction: row;
    background-color: #ffffff;
    align-items: center;
    justify-content: space-between;
}
.goodsImg{
    width: 140px;
    height: 110px;
}
.goodsInfo{
    padding-left: 5px;
    width: 360px; 
    flex: 1.5;
    justify-content: space-between;
}
.goodsInfo-height{
    height: 120px;
}
.logistics{
    height: 44px;
    padding-left: 20px;
    padding-right: 20px;
    border-radius: 22px;
    justify-content: center;
    align-items: center;
    opacity: 1.0;
}
.logistics:active {
    opacity: 0.8;
}
.expire{
    align-items: flex-end;
    justify-content: flex-start;
    margin-top: -30px;
}
.orderStatus{
    font-size:24px; 
    color: #d0104c;
}
.gift-operator{
    font-size: 26px; 
    color: #ffffff; 
}
.gift-button{
    padding-top:5px; 
    padding-bottom: 5px; 
    flex: 1; 
    justify-content: space-between;
    align-content: space-around;
}
</style>
