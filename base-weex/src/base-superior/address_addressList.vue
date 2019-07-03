<template>
    <div class='wrapper'>
        <navigation title="收货地址管理"
                    :use-default-return='showAlert == false' 
                    @wxcMinibarLeftButtonClicked="wxcDialogCancelBtnClicked"/>
        <list class="list">
            <!-- 刷新 -->
            <refresh class="refresh" @refresh="onrefresh" 
                :display="refreshing ? 'show' : 'hide'" 
                @pullingdown="onpullingdown">
                <text class="indicator-text">{{refreshText}}</text>
                <loading-indicator class="indicator"></loading-indicator>
            </refresh>
            
            <cell v-for="(address,i) in addresslist" :index="i" :key="i">
                <div class="cell" @click="callbackCell(address)">
                    <div class="cell-content">
                        <div class="address-info">
                            <div class="name-tel">
                                <text class="name">{{address.trueName}}</text>
                                <text class="phone">{{address.telephone}}</text>
                            </div>
                            <text class="address">{{address.area_info}}</text>
                        </div>
                        <div class="item-content">
                            <div class="editItem" @click="editAddressAction(address)">
                                <image class="image" src="/web/assets/sup/sup_address_editaddress.png"/>
                                <text class="edit-del">编辑</text>
                            </div>
                            <div class="editItem" @click="deleteAddressAction(address)">
                                <image class="image" src="/web/assets/sup/sup_address_deladdress.png"/>
                                <text class="edit-del">删除</text>
                            </div>
                        </div>
                    </div>
                </div>
            </cell>
            <!-- 加载更多 -->
            <loading v-if="addressCount > 0" class="loading" @loading="onloading" :display="loadinging ? 'show' : 'hide'">
                <text class="indicator-text">{{loadingText}}</text>
                <loading-indicator class="indicator"></loading-indicator>
            </loading>
        </list>
        <wxc-result type="noGoods"
              :show="showResultPage"
              :custom-set="customSet"
              :wrap-style="{top:300}"
              padding-top="232">
        </wxc-result>
        <div class="add-address-color" @click="addAddressAction">
            <div class="add-address-text">
                <text style="color: #fff;font-size: 36px;font-weight: bold;">+ 新增地址</text>
            </div>
            <div v-if="isIPhoneX" style="width: 750px;height:48px;">
            </div>
        </div>
        <wxc-dialog title="确定要删除地址吗？"
                :show="showAlert"
                main-btn-color='#ff0033'
                :show-no-prompt="false"
                @wxcDialogCancelBtnClicked="wxcDialogCancelBtnClicked"
                @wxcDialogConfirmBtnClicked="wxcDialogConfirmBtnClicked">
        </wxc-dialog>

        <!-- 优选商品兑换卡兑换地址选择 -->
        <div v-if="selectAddressInfo" style="position: fixed; width: 750px;"> 
            <wxc-overlay  :show="true" :hasAnimation="false"></wxc-overlay>
            <div style="left:20px; width:710px; top: 400px; background-color: white; position: fixed; ">
                <div>
                    <div class="name-tel" style="padding: 20px;">
                        <text class="name">{{selectAddressInfo.trueName}}</text>
                        <text class="phone">{{selectAddressInfo.telephone}}</text>
                    </div>
                    <text class="address"  style="padding-bottom: 20px; padding-left: 20px; padding-right: 20px;">{{selectAddressInfo.area_info}}</text>
                </div>
                <!-- button -->
                <div style="padding-top: 10px; flex-direction: row; ">
                    <div style="background-color: #ff0033; flex: 1; align-items: center; justify-content: center; height: 90px;" @click="confirmSubmit">
                        <text style="color: white">确认</text>
                    </div>
                    <div style="background-color: #f6f6f6; flex: 1; align-items: center; justify-content: center; height: 90px;" @click="cancelSubmit">
                        <text>取消</text>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import Fetch from "@/base-superior/Fetch.js";
import { WxcDialog, WxcResult, Utils, WxcOverlay, } from 'weex-ui';
import navigation from "@/base-superior/components/NavigationBar.vue";
const storage = weex.requireModule("storage");
const modal = weex.requireModule('modal')

export default {
    components: {navigation, WxcDialog, WxcResult, WxcOverlay, },
    name:'地址管理',
    data() {
        return {
            isIPhoneX: Utils.env.isIPhoneX(),
            refreshing: false,
            refreshText:'下拉刷新',
            loadinging: false,
            loadingText: '',
            customSet:{noGoods: { button: null, content: '您还没收货地址，快去新增地址吧', desc: '' }},
            showResultPage:false,
            page:1,
            addressCount:0,
            addresslist:[
               /*{ 
                   "trueName": "淘菜猫",
                    "areaInfo": "25栋一楼",
                    "areaId": "816492183481184256",
                    "gender": "0",//1男，2女
                    "lng": "",
                    "acquiescent_addr": "0",//1为默认地址
                    "deliveryDistance": "",
                    "telephone": "18934728901",
                    "id": "816492183611207680",
                    "area_info": "上海市 上海市 普陀区 天地软件园",
                    "lat": "",
                    "addrType": "0",//1公司，2家，3父母家
                }*/
            ],
            showAlert:false,
            deleAddress:null,
            oderSubmit_selectAddress:null,
            exchangeCardInfo: null,
            selectAddressInfo: null,
        }
    },
    created() {
        var self = this;
        //添加/编辑地址回调
        const addressChannel = new BroadcastChannel("addressChange");
        addressChannel.onmessage = function (event){
            console.log('通道名称：',event.data)
             self.loadAdresslist();  
        }
        //选择地址
        storage.getItem('oderSubmit_selectAddress', event => {
          console.log('oderSubmit_selectAddress:', event.data)
          if(event.data && event.data != 'undefined'){
            //   modal.alert({message:"传递的数据："+event.data})
              self.oderSubmit_selectAddress = JSON.parse(event.data);
              storage.removeItem('oderSubmit_selectAddress',event => {})
          }
        });

        storage.getItem('Exchange_Card_Info', event => {
            console.log(event)
            if(event.result == 'success' && event.data != 'undefined'){
                self.exchangeCardInfo = event.data;
                storage.removeItem('Exchange_Card_Info',event => {})
            }
        });
        
        this.loadAdresslist();
        
    },
    methods: {
        //下拉刷新事件
          onrefresh(event) {
              this.refreshing = true
              this.page = 1;
              this.loadAdresslist();  
          },
          onpullingdown (event) {

          },
          //上啦加载
          onloading (event) {
            this.loadingText = 'Loading ...'
            this.loadinging = true
            this.page = this.page + 1;
            this.loadAdresslist();
        },
        //加载地址列表
        loadAdresslist: function(){
            const self = this;
            var param = {currentPage:this.page,queryFrom: 'wechatShop'}
            var params = { requestmodel: JSON.stringify(param), queryFrom: 'wechatShop' }
            Fetch.request('buyer/address.json',params,function(respone){
                setTimeout(() => {
                      self.refreshing = false;
                      self.loadinging = false;
                      self.loadingText ='';
                    }, 1000)

                console.log(respone);
                var result = JSON.parse(respone);
                if(result.op_flag == 'success'){
                    if(self.page > 1){
                        //拼接一个数组
                        self.addresslist = self.addresslist.concat(result.list);
                    }else{
                        self.addresslist = result.list;
                        if(self.addresslist.length == 0){
                            self.showResultPage = true;
                        }else{
                            self.showResultPage = false;
                        }
                    }
                    
                    if(result.list.length >= 30){
                        //后台设置的一页30条数据
                        self.addressCount = 1;
                    }else{
                        self.addressCount = 0;
                    }
                }else{
                    modal.toast({message:result.info})
                }
            },function(err){
                setTimeout(() => {
                      self.refreshing = false;
                      self.loadinging = false;
                      self.loadingText ='';
                    }, 1000)
                console.log(err);
                modal.toast({message:err})
            });
        },
        //编辑地址事件
        editAddressAction: function(address) {
            storage.setItem('addressEdit',address.id,event =>{})
            let url = 'address_addressEdit.html'
             navigation.push({url:url, title:'编辑地址'}, event =>{
             });
        },
        //删除地址事件
        deleteAddressAction: function(address){
            if(this.oderSubmit_selectAddress&&this.oderSubmit_selectAddress.id==address.id){
                modal.alert({message:'当前地址不可删除',okTitle:'确定'})
            }else{
                this.showAlert = true;
                this.deleAddress = address;
            }
            
        },
        //添加地址事件
        addAddressAction: function(){
            let url = 'address_addressEdit.html'
             navigation.push({url:url, title:'添加地址'}, event =>{});
        },
        //弹框事件
        wxcDialogCancelBtnClicked () {
        //此处必须设置，组件为无状态组件，自己管理
            this.showAlert = false;
            this.deleAddress = null;
        },
        wxcDialogConfirmBtnClicked () {
        //此处必须设置，组件为无状态组件，自己管理
            const self = this;
            this.showAlert = false;
            var param = {mulitId:this.deleAddress.id}
             Fetch.get('buyer/address_del.json', param, function(respone){
                 var result = JSON.parse(respone)
                 if(result.op_flag == 'success'){
                     var index = -1;
                     for(var i = 0; i < self.addresslist.length; i++){
                         if(self.addresslist[i] == self.deleAddress){
                             index = i;
                         }
                     }
                     if(index>-1){
                         //删除元素
                         self.addresslist.splice(index,1);
                         if(self.addresslist.length == 0){
                              self.showResultPage = true;
                         }
                     }
                     
                 }else{
                      modal.toast({message:result.info})
                 }
             }, function(err){
                 modal.toast({message:err})
             })
        },

        //选择地址事件
        callbackCell: function(addressModel){
            if(!this.oderSubmit_selectAddress)return;

            if (this.exchangeCardInfo) {
                this.submitCommodidyCardOrder(addressModel);
                return;
            }
            var addressStr = JSON.stringify(addressModel)
            console.log('地址'+addressStr)
            
            const selectAddressChannel = new BroadcastChannel("selectAddressChannel");
            selectAddressChannel.postMessage(addressStr);
            //返回
            navigation.pop({},function(value){});
        },

        submitCommodidyCardOrder: function (addressModel){
            this.selectAddressInfo = addressModel
        },
        cancelSubmit (event){
            this.selectAddressInfo = null
        },
        confirmSubmit (event){
            var params = {
                addrId: this.selectAddressInfo.id,
                exchangeCode: this.exchangeCardInfo,
                addFrom: 'APP'
            }

            Fetch.post('submitCommodidyCardOrder.json',params,function(respone){
                var result = JSON.parse(respone);
                if (result.op_flag == 'success') {
                    const commodidyCardChannel = new BroadcastChannel("exchange_exchangeCard_event");
                    commodidyCardChannel.postMessage('exchange_exchangeCard');
                    navigation.pop({animated: 'true'},function(value){});
                } else {
                    modal.toast({
                        message: result.info,
                        duration:1.0
                    })
                }
            },function(err){
                modal.toast({message:err})
            });
        }
    }
}
</script>

<style scoped>
.wrapper { 
    /* justify-content: center; */
    align-items: center;
}
.list {
    width: 750px;
    background-color: #F5F5F5;
    flex: 1;
    /* margin-bottom: 80px; */
}
.cell {
    background-color: #ffffff;
    border-bottom-color: #F5F5F5;
    border-bottom-width: 20px;
}
.cell-content {
    padding: 20px;
}
.address-info {
    border-bottom-color: #dddddd;
    border-bottom-width: 2px;
}
.name-tel {
    flex-direction: row;
    justify-content: space-between;
}
.name {
    font-size:30px;
    color: #333333;
}
.phone {
    font-size:26px;
    color: #666666;
    margin-right: 10px;
    /* margin-right: 40px; */
}
.address {
    font-size:26px;
    color: #333333;
    padding-top: 20px;
    padding-bottom: 20px;
}
.item-content {
    padding-top: 10px;
    flex-direction: row;
    justify-content: flex-end;
}
.editItem {
    flex-direction: row;
    align-items: center;
    margin-left: 40px;
}
.image {
    width: 26px;
    height: 26px;
    background-color: #f9f9f9;
}
.edit-del {
    font-size:26px;
    color: #333333;
    padding: 10px;
}
.add-address-text {
    height: 90px;
    width: 750px;
    /* position: absolute;
    height: 80px; */
    justify-content: center;
    align-items: center;
    /* left: 0;
    right: 0;
    bottom: 0; */
}
.add-address-color {
    background-color: #ff0033;
}
.add-address-color:active {
    background-color: rgb(112, 0, 16);
}
.refresh {
    width: 750px;
    height: 140px;
    -ms-flex-align: center;
    -webkit-align-items: center;
    -webkit-box-align: center;
    align-items: center;
  }
.indicator-text {
    color: #888888;
    font-size: 30px;
    text-align: center;
  }
  .indicator {
    margin-top: 16px;
    height: 40px;
    width: 40px;
    color: #999999;
  }
  .loading {
    width: 750px;
    height: 180px;
    display: -ms-flex;
    display: -webkit-flex;
    display: flex;
    -ms-flex-align: center;
    -webkit-align-items: center;
    -webkit-box-align: center;
    align-items: center;
  }
</style>
