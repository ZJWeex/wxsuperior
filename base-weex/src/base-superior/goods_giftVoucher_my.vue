<template>
    <div class="wrapper">
        <navigation title="查看礼品卡"
                    right-button="/web/assets/platform/tcm_share.png" 
                    :use-default-return='isBottomShow == false' 
                    @wxcMinibarRightButtonClicked='wxcMinibarRightButtonClicked'
                    @wxcMinibarLeftButtonClicked="wxcMaskSetHidden"/>

        <list v-if="card" class="info-list" :style="{height: listHeight}">
            <cell class="image-cell">
                    <image class="image-goods" :src='card.card_img' />
            </cell>
            <cell class="item-cell">
                <text style="color: #333333; font-size: 32px;">{{card.goodsName}}{{card.cardAmount}}元面值</text>
                <div class="item-info">
                    <text style="color: #666666; font-size: 30px; flex: 1; ">有效期至{{card.expiryDate}}</text>
                    <div class="item-operator">
                        <text class="item-button" style="background-color: #efc004; " @click="deposit(card)">自己用</text>
                        <text class="item-button" style="background-color: #cb1b45; " @click="shareToFriends(card)">赠送</text>
                    </div>      
                </div>
            </cell>
        </list>
        <tcmShare :show="isBottomShow"
                  :shareInfo="shareInfo"
                  @cancelShare="wxcMaskSetHidden" 
                  @afterShare="afterShare"></tcmShare>
        <wxc-loading :show="showLoading" :need-mask='needMask' type="default"></wxc-loading>

        <Dialog :title=bindTitle
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
import Fetch from "@/base-superior/Fetch.js";
import Define from "@/base-superior/Define.js";
import tcmShare from "./components/components_share.vue";
import { WxcLoading} from 'weex-ui';
import Dialog from '@/base-superior/components/Dialog.vue';

const modal = weex.requireModule("modal");
const storage = weex.requireModule("storage");

export default {
    components: {navigation, tcmShare, Dialog, WxcLoading},
    data() {
        return {
            needMask: (navigation.isAndroid() || navigation.isIOS())?'true':true,
            supGoodsId: "",
            listHeight: navigation.pageHeight(false),
            card: null,
            isBottomShow: false,
            dialogShow: false,
            showLoading: false,
            shareInfo:{},
            bindTitle: null,
            bindTelephone: null,
            mainBtnColor: '',
            contentColor: '',
            titleColor: '',
        }
    },
    created() {
         //加载商品数据
        var self = this;
        storage.getItem('goods_giftVoucher_my', event=>{
            if (event.result == "success") {
                var card = JSON.parse(event.data)
                console.log(card)
                var shareInfo = {}
                shareInfo.shareIcon = 'http://h5.taocai.mobi/down/thybrid/assets/platform/tcm_sup.png'
                shareInfo.subtitle = '为食品安全和膳食营养专家型精选'
                shareInfo.title = '淘菜猫优选'
                shareInfo.shareUrl = WXEnvironment.netEnv + '/superior/wechat/page.htm?pageName=eleGetgiftCard&supGoodsId='+ card.giftCardId
                self.shareInfo = shareInfo
                self.card = card
            }
        })
        storage.getItem(Define.kPhone, event=>{
            if (event.result == 'success') {
                self.telephone = event.data
            }
        })
    },
    methods: {
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
                var result = JSON.parse(response)
                
                if (result.op_flag == 'fail'){
                    modal.toast({
                        message: result.info,
                    })
                } else {
                    self.showBindAlert(false)
                    self.dialogShow = true
                }
                const commodidyCardChannel = new BroadcastChannel("exchange_exchangeCard_event");
                commodidyCardChannel.postMessage('goods_giftVoucher');
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
        shareToFriends(card){
            this.isBottomShow = true;
        },
        deposit(card){
            this.dialogShow = true
            this.showBindAlert(true)
        },
        wxcMinibarRightButtonClicked(event){
            this.isBottomShow = true;
        },
        wxcMaskSetHidden(event){
            this.isBottomShow = false;
            this.dialogShow = false
        },
        afterShare(event){

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
    },
}
</script>

<style scoped>
.wrapper{
    align-items: center;
    width: 750px;
    background-color: white;
}
.info-list{
    height: 120px; 
    width: 750px; 
    align-items: center;
}
.image-cell{
    width: 750px; 
    height:480px; 
    justify-content: center;
    align-items: center;
}
.image-goods{
    width: 716px;
    height: 438px;
}
.item-cell{
    margin-left: 17px;
    width: 716px;
    height: 116px;
    margin-top: 12px;
    margin-bottom: 12px;
    justify-content: center;
}
.item-info{
    flex-direction: row;
    justify-content: space-between;
    align-items: flex-end;
}
.item-operator{
    flex-direction: row;
    justify-content: flex-end;
    flex: 1;
    padding-right: 10px;
}
.item-button{
    padding-left: 25px;
    padding-right: 25px;
    padding-top: 5px;
    padding-bottom: 5px;
    margin-left: 10px;
    margin-right: 10px;
    border-radius: 10px;
    color: white;
    font-size: 32px;
}
</style>
