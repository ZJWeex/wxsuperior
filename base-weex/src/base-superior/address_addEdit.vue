<template>
    <div class='wrapper'>
        <navigation title="添加/编辑地址"/>
        <scroller style="width:750px;flex:1;" alwaysScrollableVertical='true'>
            <div class="box">
                <input type="text" class="input"
                        placeholder="收货人"
                        max-length=10
                        maxlength=10
                        :value="addressmodel.true_name" 
                        @change="onchange(1,$event)" 
                        @input="oninput(1,$event)"/>
                <div style="padding-right:20px;padding-left:40px;" @click="cancelInput">
                    <image v-if="addressmodel.true_name != ''" style="width: 30px; height: 30px; margin: 10px;" resize="contain" src='/web/assets/sup/sup_personal_cancle_input.png' @click="cancelInput"/>
                </div>
            </div>
            <div class="box">
                <input type="tel" class="input" 
                        placeholder="输入手机号码" 
                        max-length=11
                        maxlength=11
                        :value="addressmodel.telephone" 
                        @change="onchange(2,$event)" 
                        @input="oninput(2,$event)"/>
            </div>
            <div class="box" @click="citypicker(1)">
                <div class="address-marker">
                    <text v-if="cityName.length>0" class="city-div">{{cityName}}</text>
                    <text v-else class="city-des">所在城市</text>
                    <wxc-icon name="more" :icon-style="{color:'#999999',fontSize:'40px'}"></wxc-icon>
                </div>
            </div>
            <div class="box" @click="goToMap">
                <div class="address-marker">
                    <div style="flex-direction: row;align-items: center;">
                        <image style="width:28px;height:34px;" src="/web/assets/sup/sup_address_loction.png"/>
                        <text v-if="addressmodel.area_name.length>0" class="area-text">{{addressmodel.area_name}}</text>
                        <text v-else class="area-des">小区／写字楼</text>
                    </div>
                    <wxc-icon name="more" :icon-style="{color:'#999999',fontSize:'40px'}"></wxc-icon>
                </div>
            </div>
            <div style="margin-bottom:40px;">
                <textarea class="textarea" placeholder="楼号门牌" 
                        :value="addressmodel.area_info" 
                        @change="onchange(10,$event)" 
                        @input="oninput(10,$event)"></textarea>
            </div>
            <div class="box">
                <div class="address-marker" @click="selectMarkerClick">
                    <text style="color:#333333;font-size:30px;">地址标签</text>
                    <div style="flex-direction: row;align-items: center;">
                        <text v-if="addressMarker.addrType==10" style="color:#999999;font-size:28px;">{{addressMarker.name}}</text>
                        <image v-else-if="addressMarker.addrType>0" style="width:50px;height:50px;" :src="addressMarker.img"/>
                        <text v-else style="color:#999999;font-size:28px;">请选择</text>
                        <wxc-icon name="more" :icon-style="{color:'#999999',fontSize:'40px'}" @wxcIconClicked="selectMarkerClick"></wxc-icon>
                    </div>
                </div>
            </div>
            <div v-if="!isDefaultAddress" class="box">
                <div class="address-marker">
                    <text style="color:#333333;font-size:30px;">设为默认地址</text>
                    <image v-if="defaultAddress" style="width:80px;height:50px;margin-right:40px;" src="/web/assets/sup/sup_address_swtchselect.png" @click="setDefaultAddressClick"/>
                    <image v-else style="width:80px;height:50px;margin-right:40px;" src="/web/assets/sup/sup_address_swtch.png" @click="setDefaultAddressClick"/>
                </div>
            </div>
            <div class="box box-top" v-if="addressmodel.addr_id.length>0">
                <text class="delete-Address" @click="deleteAddressClick">删除收货地址</text>
            </div>
            <div class="save-address | save-button" @click="saveAddressClick">
                <text class="save-text">保存收货地址</text>
            </div>
            <wxc-loading :show="loading" need-mask=false type="default"></wxc-loading>
        </scroller>
        <wxc-popup ref="wxcPopup" popup-color="rgba(255,255,255,0.0)" 
                   :show="showPopup" pos="bottom" :height="popupHeight"
                   @wxcPopupOverlayClicked="popupOverlayBottomClick">
            <div class="popup-content">
                <div style="flex-direction: row;align-items: center;justify-content: space-around;height:80px;padding:10px;">
                    <div style="width:40px;"></div>
                    <text style="color:#333333;font-size:30px;flex:1;text-align: center;">选择地址标签</text>
                    <wxc-icon name="close" :icon-style="{color:'#999999'}" @wxcIconClicked="onHideOverlayClick"></wxc-icon>
                </div>
                <div style="flex:1;padding-left:50px;">
                    <div v-for="(item,index) in markerList" :key='index' style="flex-direction: row;align-items: center;justify-content: space-between;" @click="didSelectAddressMarker(index)">
                        <div v-if="index==0" style="flex-direction: row;align-items: center;">
                            <image style="width:64px;height:64px;margin:15px;" :src="item.img"/>
                            <div style="width:410px;height:90px;border-bottom-color:#f5f4f4;border-bottom-width:1px;justify-content:center;">
                                <input ref='inputMarker' style="font-size:26px;height:70px;"
                                    type="text" placeholder="默认显示姓名，可输入自定义标签"
                                    :value="markerList[0].name"
                                    max-length=10 maxlength=10
                                    @input="oninput(11,$event)"
                                    @change="onchange(11,$event)"
                                    @keyboard="keyboardAction"
                                    @focus="inputGetFocus"/>
                            </div>
                        </div>
                        <div v-else style="flex-direction: row;align-items: center;height:90px;">
                            <image style="width:64px;height:64px;margin:15px;" :src="item.img"/>
                            <text style="color:#333333;font-size:30px;">{{item.name}}</text>
                        </div>
                        <image v-if="selectAddressIndex==index" class="select-marker" src="/web/assets/sup/sup_address_markerSelect.png"/>
                        <div v-else class="select-marker"></div>
                    </div>
                </div>
                <div style="align-items: center;margin-top:50px;margin-bottom:50px;">
                    <div class="complete-btn" @click="confirmAddressMarker">
                        <text style="color:#ffffff;font-size:32px;">完成</text>
                    </div>
                </div>
            </div>
        </wxc-popup>
        <wxc-loading :show="loading" need-mask=false type="default"></wxc-loading>
    </div>
</template>

<script>
import { WxcLoading, WxcPartLoading, WxcIcon, WxcPopup } from "weex-ui";
import Fetch from "@/base-superior/Fetch.js";
import Define from "@/base-superior/Define.js";
import citys from "@/base-superior/citys.js";
import check from '@/base-superior/check.js';
import navigation from "@/base-superior/components/NavigationBar.vue";

const storage = weex.requireModule("storage");
const picker = weex.requireModule('picker')
const modal = weex.requireModule('modal');

export default {
    components: { navigation ,WxcLoading, WxcPartLoading,WxcIcon,WxcPopup },
    data() {
        return {
            isAndroid: WXEnvironment.platform === "android",
            loading: false,
            isDefaultAddress:false,
            defaultAddress:false,
            showPopup:false,
            popupHeight:680,
            addressMarker:{img:'',name:'',addrType:'0'},//地址标签
            selectAddressIndex:0,
            province:'',//省
            cityName:'',//市
            areaName:'',
            addressmodel:{
                    telephone: "",
                    true_name: "",
                    areaId:'',////行政区Id 如 普陀区Id
		            areas: [ {
			            areaId: "",
			            areaName: "",
			            level: ""//0省、1市、2区、3详细地址
		            }],
                    area_info: "",//详细地址
                    area_name: "",
                    addr_id: "",
                    lng: "",
                    lat: "",
                    addrType:'0',
                    custom_label:'',
            },
            markerList:[{img:'/web/assets/sup/sup_address_zidingyi.png',name:'',addrType:'10'},
                        {img:'/web/assets/sup/sup_address_jia.png',name:'家',addrType:'2'},
                        {img:'/web/assets/sup/sup_address_gongsi.png',name:'公司',addrType:'1'},
                        {img:'/web/assets/sup/sup_address_xuexiao.png',name:'学校',addrType:'4'},],
        }
    },
    created() {
        var self = this;
        //选择定位地址回调
        const loctionChannel = new BroadcastChannel("loctionAddressChannel");
        loctionChannel.onmessage = function (event){
            console.log('通道名称：',event.data) 
            let model = JSON.parse(event.data)
            if(model.province&&self.province != model.province){
                self.province = model.province;
            }
            if(model.city&&self.cityName != model.city){
                self.cityName = model.city;
            }
            self.areaName = model.area;
            self.addressmodel.areaId = citys.getArea_id(self.province,self.cityName,self.areaName);
            self.addressmodel.lng = model.longitude;
            self.addressmodel.lat = model.latitude;
            self.addressmodel.area_name = model.name;
            self.addressmodel.area_info = model.address;
            console.log('areaId:',self.addressmodel.areaId)
            modal.toast({message:'请补全门牌号'})
        }
        //地址编辑传值
        storage.getItem('addressEdit', event => {
          console.log('get value:', event.data)
          
          if(event.data &&event.data != 'undefined'){
              let param = JSON.parse(event.data)
              var addrId = param.addressId;
              let acquiescent_addr = param.acquiescent_addr;
              if(acquiescent_addr == 1){
                  self.defaultAddress = true;
                  self.isDefaultAddress = true
              }else{
                  self.defaultAddress = false;
                  self.isDefaultAddress = false
              }
              self.addressmodel.addrType = param.addrType
              self.getEditAddressInfo(addrId);

              storage.removeItem('addressEdit',event => {})
          }else{
              storage.getItem(Define.kPhone, event => {
                  if(event.data != 'undefined'){
                    //   console.log('kPhone:', event.data)
                      //$set可触发视图变化，self.addressmodel.telephone=value无效
                      self.$set(self.addressmodel,'telephone',event.data)
                  }
              })
          }
          
        })
    },
    methods: {
        goToMap:function(street){
            let mapSearchParam = {cityName:this.cityName}
            if((typeof street) == 'string'){
                //老地址搜索内容
                mapSearchParam.address = street
            } 
            //用于排序
            mapSearchParam.area_name = this.addressmodel.area_name
            //用于地址编辑，给当前地址添加标注
            mapSearchParam.longitude = this.addressmodel.lng
            mapSearchParam.latitude = this.addressmodel.lat

            storage.setItem('city_POI',JSON.stringify(mapSearchParam),event =>{})
            let url = 'address_address_map.html'
             navigation.push({url:url, title:'地址选择'}, event =>{});
        },
        //输入事件
        onchange:function(index,event){
            console.log("index:"+index+"\nchange:", event.value);
            if(index==1){
                this.addressmodel.true_name = event.value;
            }else if(index == 2){
                 this.addressmodel.telephone = event.value;
            }else if(index == 3){
                 
            }else if(index == 10){
                 this.addressmodel.area_info = event.value;
            }
        },
        oninput:function(index,event) {
            console.log("index:"+index+"\ninput:", event.value);
            if(index==1){
                this.addressmodel.true_name = event.value;
            }else if(index == 2){
                 this.addressmodel.telephone = event.value;
            }else if(index == 3){
                
            }else if(index == 10){
                 this.addressmodel.area_info = event.value;
            }else if(index == 11){
                 let value = event.value;
                 let item = this.markerList[0]
                 item.name = value 
            }
        },
        inputGetFocus:function(e){
            this.selectAddressIndex = 0
        },
        cancelInput:function(){
            this.$set(this.addressmodel,'true_name','')
        },
        //选择地址
        citypicker:function(tag) {
            const self = this;
            var items = []
            var title = '请选择'
            if(tag == 1){
                items = citys.province_list();
                title = '请选择省市'
            }else if(tag == 2){
                if(self.province.length<=0)return;
                items = citys.city_list(self.province);
                title = '请选择城市'
            }else if(tag == 3){
                if(self.cityName.length<=0)return;
                items = citys.areaorcounty_list(self.province,self.cityName);
                title = '请选择区域'
            }
            var options = {
                index:0,
                items:items,
                confirmTitle:'确认',
                cancelTitle:'取消',
                confirmTitleColor:'#ff0033',
                cancelTitleColor:'#999999',
                title:title
            }
            picker.pick(options,function(ret){
                if(ret.result === 'success'){
                    let index = ret.data;
                    if(tag == 1){
                        let province = citys.getProvinceName(ret.data);
                        if(self.province != province){
                            // self.cityName = '';
                            self.areaName = '';
                        }
                        self.province = province;
                        console.log('province:',province)
                        setTimeout(() => {
                             self.citypicker(2)
                        }, 300)
                    }else if(tag == 2){
                        let cityName = citys.getCityName(self.province,ret.data);
                        if(self.cityName != cityName){
                            self.cityName = ''
                            self.areaName = ''
                            self.addressmodel.areaId = ''
                            self.addressmodel.area_info = ''
                            self.addressmodel.area_name = ''
                            self.addressmodel.lng = ''
                            self.addressmodel.lat = ''
                        }
                        self.cityName = cityName;
                    }else if(tag == 3){
                        self.areaName = citys.getAreaName(self.province,self.cityName,ret.data);
                        self.addressmodel.areaId = citys.getArea_id(self.province,self.cityName,self.areaName);
                    }
                }
                
            })

        },
        //选择标签
        selectMarkerClick:function(){
            this.showPopup = true
        },
        //设置默认地址
        setDefaultAddressClick:function(){
            this.defaultAddress = !this.defaultAddress;
        },

        //删除地址
        deleteAddressClick:function(){
            const self = this
            modal.confirm({message:'确定删除该地址吗？',okTitle:'确定',cancelTitle:'取消'},result=>{
                if(result == '确定'){
                    console.log('删除该地址')
                    self.deleteAddressHandle(self.addressmodel.addr_id)
                }
            })
        },
        //弹框隐藏
        popupOverlayBottomClick () {
            if(this.isAndroid){
                this.popupHeight = 680;
                this.$refs.inputMarker[0].blur()
            }
             this.showPopup = false;
        },
        onHideOverlayClick () {
            this.$refs.wxcPopup.hide();
        },
        confirmAddressMarker:function(){
            //添加地址标签
            this.onHideOverlayClick();
             let markerObjc = this.markerList[this.selectAddressIndex];
            if(this.Trim(markerObjc.name).length>0){
                this.addressMarker = markerObjc;
                this.addressmodel.addrType = markerObjc.addrType;
                if(markerObjc.addrType != "10"){
                    setTimeout(()=>{
                        this.markerList[0].name = ''
                    },500) 
                }
            }else{
                this.addressMarker={img:'',name:'',addrType:'0'}
                this.addressmodel.addrType = 0
            }

        },
        //选择地址标签
        didSelectAddressMarker:function(index){
            this.selectAddressIndex = index;   
        },
        //andriod键盘弹出隐藏事件
        keyboardAction:function(e){
            const self = this;
            if(self.isAndroid){
                if(e.isShow){
                    self.popupHeight = 680+200
                }else{
                    self.popupHeight = 680
                }
            }

        },
        //地址标签描述处理
        handleAddressMarkerWords:function(addrModel){
            let addressType = addrModel.addrType
            this.markerList.forEach((element,index) => {
                if(element.addrType == addressType){
                    this.addressMarker = element
                    this.selectAddressIndex = index
                }
            });
            if(Number(addressType) == 10){
                this.addressMarker.name = addrModel.custom_label
            }else if(Number(addressType) == 3){
                //将地址类型3转换成自定义类型10
                this.addressMarker = this.markerList[0]
                this.addressMarker.name = '父母家'
                this.selectAddressIndex = 0
            }
            
        },
        //编辑时获取地址信息
        getEditAddressInfo:function(addrId) {
            const self = this
            this.loading = true;
            var param = {addr_id:addrId}
            Fetch.post('buyer/address_by_id_1.json',param ,function(respone){
                self.loading = false;
                console.log('地址数据：',JSON.stringify(respone))
                var reslut = JSON.parse(respone)
                if(reslut.op_flag ==  "success"){
                    reslut.obj.addrType = self.addressmodel.addrType
                    self.addressmodel = reslut.obj;
                    reslut.obj.areas.forEach(function(e){
                        if(e.level == 0){
                            self.province = e.areaName;
                        }else if(e.level == 1){
                            self.cityName = e.areaName;
                        }else if(e.level == 2){
                            self.areaName = e.areaName;
                            self.addressmodel.areaId = e.areaId;
                        }
                    })

                    self.handleAddressMarkerWords(self.addressmodel)
                    if(self.addressmodel.lng.length == 0){
                        self.goToMap(self.addressmodel.area_name)
                    }
                }else{
                    modal.toast({message:reslut.info})
                }
            }, function(err){
                self.loading = false;
                 modal.toast({message:err})
            })
        },
        //删除地址
        deleteAddressHandle:function(addressId) {
            const self = this;
            var param = {mulitId:addressId}
            this.loading = true;
             Fetch.get('buyer/address_del.json', param, function(respone){
                 self.loading = false;
                 var result = JSON.parse(respone)
                 if(result.op_flag == 'success'){
                     //发送消息，刷新地址列表
                     const addressChannel = new BroadcastChannel("addressChange");
                     addressChannel.postMessage("addressChange");
                     navigation.pop({ },event => { });
                 }else{
                      modal.toast({message:result.info})
                 }
             }, function(err){
                 self.loading = false;
                 modal.toast({message:err})
             })
        },
        //保存收货地址
        saveAddressClick:function(){
            //数据校验
            var msg = '';
            if(this.Trim(this.addressmodel.lng.toString()).length == 0){
                msg = '无定位坐标，无法保存';
            }
            if(check.isEmojiCharacter(this.addressMarker.name)){
                msg = "自定义标签不能包含特殊字符"
            }
            if(this.Trim(this.addressmodel.area_info).length == 0){
                msg = '请填写详细地址';
            }else if(check.isEmojiCharacter(this.addressmodel.area_info)){
                msg = '详细地址不能包含特殊字符';
            }
            if(this.addressmodel.area_name.length == 0){
                msg = '请选择小区／写字楼';
            }
            if(this.Trim(this.cityName).length == 0){
                msg = '请选择城市';
            }
            
            if(this.Trim(this.addressmodel.telephone).length == 0){
                msg = '请输入手机号';
            }
            if(this.Trim(this.addressmodel.true_name).length == 0){
                msg = '请输入联系人';
            }
            if(msg.length > 0){
                modal.toast({message:msg,duration: 1.0})
                return;
            }
            // 数据整理
            let url = 'buyer/address_save_v2.json';//保存地址接口
            var param = {
                lng:Number(this.addressmodel.lng).toFixed(6).toString(),
                lat:Number(this.addressmodel.lat).toFixed(6).toString(),
                district_id:this.addressmodel.areaId,//行政区areaId
                area_name:this.addressmodel.area_name,
                area_info:this.addressmodel.area_info,
                telephone:this.addressmodel.telephone,
                trueName:this.addressmodel.true_name,
                addrType:this.addressmodel.addrType.toString(),
                custom_label:this.addressMarker.name,
                code:'',
            }
            if(this.addressmodel.addr_id && this.addressmodel.addr_id.length > 0){
                //编辑地址使用
                param.addr_id = this.addressmodel.addr_id;
            }
            console.log("发送前参数："+JSON.stringify(param));
            const self = this;
            this.loading = true;
            Fetch.post(url, param, function(respone){  
                var reslut = JSON.parse(respone);
                if(reslut.op_flag === "success") {
                    let addressId = reslut.addr_id
                    self.setDefaultAddress(addressId,function(isSuccess){
                        self.loading = false;
                        modal.toast({
                            message: reslut.info,
                            duration: 1.0
                        });

                        const addressChannel = new BroadcastChannel("addressChange");
                        addressChannel.postMessage("addressChange");
                        if(weex.config.userInfo){
                            weex.config.userInfo.addrInfo.hasAddress = 'true';
                        }
                        navigation.pop({ },event => { });
                    })

                }else{
                    self.loading = false;
                    modal.toast({
                        message: reslut.info,
                        duration: 1.0
                    });
                }
                
            },function(err){
                self.loading = false;
                modal.toast({message: err,duration: 1.0});
            });
        },
        //设置默认地址
        setDefaultAddress:function(addressId,callBlock){
            console.log('地址类型：',typeof addressId)
            if(!this.defaultAddress|| !addressId){
                console.log('设置默认地址')
                callBlock(true);
                return;
            }
            let url = 'buyer/address_acquiescent.json'
            let param = {id:addressId}
             Fetch.get(url, param, function(respone){
                 var reslut = JSON.parse(respone);
                 console.log('设置默认地址：',respone)
                if(reslut.op_flag === "success"){
                    if(weex.config.env.appName.indexOf('buyer') != -1){
                        //消费者发送通知
                        if (WXEnvironment.platform.toLowerCase() === 'android') {
                            weex.requireModule('myGlobalEvent').postNotificationName('defaultAddressChange', { addressId:addressId })
                        } else {
                            weex.requireModule('globalEvent').postNotificationName('defaultAddressChange', { addressId:addressId })
                        }
                    }
                    callBlock(true)
                }else{
                    callBlock(false)
                }
             },function(err){
                 callBlock(false)
             })

        },
        //去除首尾空格
         Trim:function(str){ 
            return str.replace(/(^\s*)|(\s*$)/g, ""); 
        },
    }
}
</script>

<style scoped>
.wrapper { 
    width: 750px;
    flex: 1;
    background-color: #f5f5f9;
}
.box {
    flex-direction: row;
    align-items: center;
    height: 90px;
    border-bottom-width: 2px;
    border-bottom-color: #f5f5f9;
    background-color: #ffffff;
}
.input {
    margin-right: 40px;
    margin-left: 40px;
    height: 70px;
    width: 500px;
}
.city-div {
    color:#333333;
    font-size:30px;
    padding:10px;
}
.city-des {
    color:#999999;
    font-size:30px;
    padding:10px;
}
.area-text {
    color:#333333;
    font-size:30px;
    padding:10px;
    width: 620px;
}
.area-des {
    color:#999999;
    font-size:30px;
    padding:10px;
}
.textarea {
    width: 750px;
    height: 120px;
    padding: 20px;
    font-size: 30px;
    color: #333333;
    background-color: white;
}
.address-marker{
    flex-direction: row;
    align-items: center;
    justify-content: space-between;
    flex: 1;
    margin-left:40px;
    margin-right:20px;
}
.box-top {
    margin-top: 40px;
}
.delete-Address {
    margin-left: 40px;
    font-size:30px;
    color: #d0104c;
}
.delete-Address:active {
    color: rgb(112, 0, 16);
}

.save-address {
    justify-content: center;
    align-items: center;
    height: 80px;
    margin-top: 60px;
    margin-right: 20px;
    margin-left: 20px;
    border-radius: 40px;
}
.save-button {
    background-color: #d0104c;
}
.save-button:active {
    background-color: rgb(112, 0, 16);
}
.save-text {
    color: white;
    font-size: 30px;
}

.popup-content{
    margin: 40px;
    flex: 1;
    border-radius: 20px;
    background-color: #ffffff;
    /* align-items: center; */
}
.select-marker{
    width:30px;
    height:30px;
    margin-right:30px;
}

.complete-btn {
    height:60px;
    width:350px;
    border-radius: 30px;
    align-items: center;
    justify-content:center;
    background-image: linear-gradient(to right,#e42a8b,#ff565a);
}

</style>
