<template>
    <div class='wrapper'>
        <navigation title="地址管理"/>
        <list class="list">
            <!-- 刷新 -->
            <refresh class="refresh" @refresh="onrefresh" 
                :display="refreshing ? 'show' : 'hide'" 
                @pullingdown="onpullingdown">
                <text class="indicator-text">{{refreshText}}</text>
                <loading-indicator class="indicator"></loading-indicator>
            </refresh>
            <cell v-for="(address,i) in addresslist" :index="i" :key="i">
                <div class="cell-content" @click="callbackCell(address)">
                    <div style="margin:24px;">
                        <image v-if="setAddressMarker(address).showImg" style="height:64px;width:64px;" :src="setAddressMarker(address).img"/>
                        <div v-else  style="height:64px;width:64px;background-color:#cccccc;border-radius: 32px;align-items: center;justify-content: center;">
                            <text v-if="setAddressMarker(address).text.length>1" :style="{color:'#f5f5f9','font-size':'24'}">{{setAddressMarker(address).text}}</text>
                            <text v-else :style="{color:'#f5f5f9','font-size':'30'}">{{setAddressMarker(address).text}}</text>
                        </div>   
                    </div>
                    <div style="flex:1;justify-content: center;">
                        <div class="user-info">
                            <text class="name">{{address.trueName}}</text>
                            <text class="phone">{{address.telephone}}</text>
                        </div>
                        <div class="address-info">
                            <text v-if="address.acquiescent_addr==1&&setAddressMarker(address).mark.length>0" class="address-text">&nbsp; 默认 &nbsp; &nbsp;{{setAddressMarker(address).mark}} &nbsp; {{address.area_info}} {{address.areaInfo}}</text>
                            <text v-else-if="address.acquiescent_addr==1&&setAddressMarker(address).mark.length==0" class="address-text">&nbsp; 默认 &nbsp; {{address.area_info}} {{address.areaInfo}}</text>
                            <text v-else-if="address.acquiescent_addr==0&&setAddressMarker(address).mark.length>0" class="address-text"> {{setAddressMarker(address).mark}} &nbsp; {{address.area_info}} {{address.areaInfo}}</text>
                            <text v-else class="address-text">{{address.area_info}} {{address.areaInfo}}</text>
                            <div class="marker-div">
                                <div v-if="address.acquiescent_addr==1" class="default-marker">
                                    <text style="color:#f89e33;font-size:24px;">&nbsp; 默认 &nbsp;</text>
                                </div>
                                <div v-if="setAddressMarker(address).mark.length>0" class="custom-marker">
                                    <text style="color:#666666;font-size:24px;">&nbsp; {{setAddressMarker(address).mark}} &nbsp;</text>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="editItem" @click="editAddressAction(address)">
                        <text class="edit-text">编辑</text>
                    </div>
                </div>
            </cell>
            <cell v-if="addresslist.length>0">
                <div style="height:20px;background-color:#ffffff;flex:1;"></div>
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
              :wrap-style="{top:130 + (isIPhoneX?48:0)}"
              padding-top="232">
        </wxc-result>
        <div class="add-address">
            <div class="add-address-text" @click="addAddressAction">
                <text style="color: #fff;font-size: 30px;font-weight: bold;">添加新地址</text>
            </div>
            <div v-if="isIPhoneX" style="width: 750px;height:48px;"></div>
        </div>

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
import { WxcDialog, WxcResult, Utils } from 'weex-ui';
import navigation from "@/base-superior/components/NavigationBar.vue";
const storage = weex.requireModule("storage");
const modal = weex.requireModule('modal')

export default {
    components: {navigation, WxcDialog, WxcResult },
    name:'地址管理',
    data() {
        return {
            isAndroid: WXEnvironment.platform === "android",
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
                    "addrType": "0",//0未设置，1公司，2家，3父母家，4学校，10自定义标签
                    "custom_label":'自定义标签',
                    "addFrom":"app" //地址添加来源，app来自消费者和小程序；wechatShop来自老版微信商城
                }*/
            ],
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
        setAddressMarker:function(address){
            var mark = {showImg:true,
                        img:'',
                        mark:'',
                        text:''}
            if(address.addrType==1){
                mark.mark = '公司'
                mark.showImg = true
                mark.img = '/web/assets/sup/sup_address_gongsi.png'
            }else if(address.addrType==2){
                mark.mark = '家'
                mark.showImg = true
                mark.img = '/web/assets/sup/sup_address_jia.png'
            }else if(address.addrType==3){
                 let markTypeStr = '父母家'
                 mark.showImg = false
                 mark.text = markTypeStr.slice(0,2)
            }else if(address.addrType==4){
                 mark.mark = '学校'
                 mark.showImg = true
                 mark.img = '/web/assets/sup/sup_address_xuexiao.png'
            }else if(address.addrType==10){
                 mark.showImg = false
                 mark.mark = address.custom_label
                 if(address.custom_label.length>2){
                    mark.text = address.custom_label.slice(0,1)
                }else{
                    mark.text = address.custom_label
                }
            }else{
                mark.showImg = false
                if(address.trueName.length>2){
                    mark.text = address.trueName.slice(0,1)
                }else{
                    mark.text = address.trueName
                }
                
            }
            return mark;
        },
        //加载地址列表
        loadAdresslist: function(){
            const self = this;
            var params = { currentPage:this.page, queryFrom: 'wechatShop'}
            Fetch.request('buyer/address.json',params,function(respone){
                setTimeout(() => {
                      self.refreshing = false;
                      self.loadinging = false;
                      self.loadingText ='';
                    }, 1000)

                console.log('address:',respone);
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
            //新版
            if(weex.supports('@module/location')){
                let param = { addressId:address.id,
                              acquiescent_addr:address.acquiescent_addr,
                              addrType:address.addrType
                            }
                storage.setItem('addressEdit',JSON.stringify(param),event =>{})
                let url = 'address_addEdit.html'
                navigation.push({url:url, title:'编辑地址'}, event =>{});
            }else{
                //老版
                if(address.addFrom == 'app'){
                    //同步的含经纬度地址
                    modal.toast({
                        message: '编辑修改地址，请升级至最新版本',
                        duration: 1.0
                    });
                }else{
                    //老地址
                   storage.setItem('addressEdit',address.id,event =>{})
                    let url = 'address_addressEdit.html'
                    navigation.push({url:url, title:'编辑地址'}, event =>{}); 
                }
            }
            
        },
        //添加地址事件
        addAddressAction: function(){
            if(weex.supports('@module/location')){
                let url = 'address_addEdit.html'
                navigation.push({url:url, title:'添加/编辑地址'}, event =>{});
            }else{
                modal.toast({
                        message: '添加新地址，请升级至最新版本',
                        duration: 1.0
                    });
            }
            
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
    align-items: center;
    background-color: #f5f5f9;
}
.list {
    width: 750px;
    background-color: #f5f5f9;
    flex: 1;
}

.cell-content {
    height: 180px;
    flex-direction: row;
    align-items: center;
    background-color: #ffffff;
}
.user-info {
    flex-direction: row;
    align-items: center;
    margin-bottom: 10px;
}
.name {
    font-size:32px;
    color: #333333;
}
.phone {
    font-size:26px;
    color: #999999;
    margin-left: 40px;
}
.address-info {
    flex-direction: row;
    /* height: 80px; */
    flex: 1;
}
.marker-div {
    position: absolute;
    left: 0;
    height: 32px;
    flex-direction: row;
}
.default-marker {
    height: 32px;
    border-radius: 6px;
    background-color: #fff1e8;
    justify-content: center;
    align-items: center;
    margin-right:10px;
}
.custom-marker {
    /* width: 0.2px; */
    height: 32px;
    border-radius: 6px;
    background-color: #f0f0f0;
    justify-content: center;
    align-items: center;
    margin-right:10px;
}
.address-text {
    font-size:26px;
    color: #333333;
    flex: 1;
    lines:3;
    text-overflow:ellipsis;
}
.editItem {
    flex-direction: row;
    align-items: center;
    height: 50px;
    padding-left:20px;
    padding-right:20px;
    margin-left: 8px;
    border-left-width: 2px;
    border-left-color: #f0f0f0;

}
.edit-text {
    font-size:26px;
    color: #999999;
}

.add-address-text {
    height: 80px;
    /* width: 730px; */
    flex: 1;
    justify-content: center;
    align-items: center;
    margin-left:10px;
    margin-right: 10px;
    background-color: #d0104c;
    border-radius: 40px;
}
.add-address {
    margin-top: 40px;
    margin-bottom: 56px;
    width: 750px;
}
.add-address-text:active {
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
