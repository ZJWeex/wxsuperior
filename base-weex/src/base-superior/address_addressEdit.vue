<template>
    <div class='wrapper'>
        <navigation title="添加收货地址"/>
        <div class="box">
            <text class="text">联系人：</text>
            <input type="text" class="input"
                    placeholder="请输入联系人"
                    :value="addressmodel.true_name" 
                    @change="onchange(1,$event)" 
                    @input="oninput(1,$event)"/>
        </div>
        <div class="box">
            <text class="text">电话：</text>
            <input type="tel" class="input" 
                    placeholder="输入手机号码" 
                    max-length=11
                    maxlength=11
                    :value="addressmodel.telephone" 
                    @change="onchange(2,$event)" 
                    @input="oninput(2,$event)"/>
        </div>
        <div style="background-color: white">
            <text class="text">所在城市：</text>
            <div class="box">
                <input type="text" class="input-city" style="margin-left: 20px;" disabled='false'
                    placeholder="省" 
                    :value="province"
                    @change="onchange(3,$event)" 
                    @input="oninput(3,$event)"/>
                <input type="text" class="input-city" disabled='false'
                        placeholder="市" 
                        :value="bindAreaName(cityName)"
                        @change="onchange(4,$event)" 
                        @input="oninput(4,$event)"/>
                <input type="text" class="input-city" disabled='false'
                        placeholder="区" 
                        :value="bindAreaName(areaName)"
                        @change="onchange(5,$event)" 
                        @input="oninput(5,$event)"/>
            </div>
            <div class="mask | mask1" @click="citypicker(1)"></div>
            <div class="mask | mask2" @click="citypicker(2)"></div>
            <div class="mask | mask3" @click="citypicker(3)"></div>
        </div>
        <div>
            <textarea class="textarea" placeholder="请填写详细地址" 
                        :value="addressmodel.area_info" 
                        @change="onchange(10,$event)" 
                        @input="oninput(10,$event)"></textarea>
        </div>
        <div class="dele-box" v-if="addressmodel.addr_id.length>0">
                <text class="delete-Address" @click="deleteAddressClick">删除收货地址</text>
            </div>
        <div class="save-address | save-button"
            @click="saveAddressClick">
            <text class="save-text">保存收货地址</text>
        </div>
        <wxc-loading :show="loading" need-mask=false type="default"></wxc-loading>
    </div>
</template>

<script>
import { WxcLoading, WxcPartLoading } from "weex-ui";
import Fetch from "@/base-superior/Fetch.js";
import Define from "@/base-superior/Define.js";
import citys from "@/base-superior/citys.js";
import check from '@/base-superior/check.js';
import navigation from "@/base-superior/components/NavigationBar.vue";

const modal = weex.requireModule('modal');
const storage = weex.requireModule("storage");
const picker = weex.requireModule('picker')

export default {
    components: {navigation, WxcLoading, WxcPartLoading },
    data() {
        return {
            loading: false,
            province:'',
            cityName:'',
            areaName:'',
            addressmodel:{
                    "telephone": "",
                    "true_name": "",
                    "areaId":'',////行政区Id 如 普陀区Id
		            "areas": [ {
			            "areaId": "",
			            "areaName": "",
			            "level": ""//0省、1市、2区、3详细地址
		            }],
                    "area_info": "",//详细地址
                    "area_name": "",
                    "addr_id": "",
                    "lng": "",
		            "lat": ""
            },
        }
    },
    created() {
        const self = this;
        storage.getItem('addressEdit', event => {
          console.log('get value:', event.data)
          
          if(event.data &&event.data != 'undefined'){
              var addrId = event.data;
              self.getEditAddressInfo(addrId);

              storage.removeItem('addressEdit',event => {})
          }else{
              storage.getItem(Define.kPhone, event => {
                  if(event.data != 'undefined'){
                      //$set可触发视图变化，self.addressmodel.telephone=value无效
                      self.$set(self.addressmodel,'telephone',event.data)
                  }
              })
          }
          
        })
    },
    methods: {
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
            }
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
                            self.cityName = '';
                            self.areaName = '';
                        }
                        self.province = province;
                    }else if(tag == 2){
                        let cityName = citys.getCityName(self.province,ret.data);
                        if(self.cityName != cityName){
                            self.areaName = ''
                            self.addressmodel.areaId = ''
                        }
                        self.cityName = cityName;
                    }else if(tag == 3){
                        self.areaName = citys.getAreaName(self.province,self.cityName,ret.data);
                        self.addressmodel.areaId = citys.getArea_id(self.province,self.cityName,self.areaName);
                    }
                }
                
            })

        },
        //长度限制
        bindAreaName:function(areaName){
            if(areaName.length<=7){
                return areaName;
            }else{
                //第一个参数是开始位置；第二个是长度
                var tempArea = areaName.substr(0,6);
                tempArea = tempArea + '...';
                return tempArea;
            }
        },
        //编辑时获取地址信息
        getEditAddressInfo:function(addrId) {
            const self = this
            var param = {addr_id:addrId}
            Fetch.post('buyer/address_by_id_1.json',param ,function(respone){
                console.log('地址数据：',JSON.stringify(respone))
                var reslut = JSON.parse(respone)
                if(reslut.op_flag ==  "success"){
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
                }else{
                    modal.toast({message:reslut.info})
                }
            }, function(err){

            })
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
        //保存地址
        saveAddressClick:function(){
            //数据校验
            var msg = '';
            if(this.Trim(this.addressmodel.area_info).length == 0){
                msg = '请填写详细地址';
            }else if(check.isEmojiCharacter(this.addressmodel.area_info)){
                msg = '详细地址不能包含特殊字符';
            }
            if(this.Trim(this.areaName).length == 0){
                msg = '请选择区域';
            }
            if(this.Trim(this.cityName).length == 0){
                msg = '请选择城市';
            }
            if(this.Trim(this.province).length == 0){
                msg = '请选择省市';
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
            this.addressmodel.area_name = this.province+' '+this.cityName+' '+this.areaName;
            // 数据整理
            let url = 'buyer/address_save_v2.json';//保存地址接口
            var param = {
                lng:'',
                lat:'',
                district_id:this.addressmodel.areaId,//行政区areaId
                area_name:this.addressmodel.area_info,//和area_info相同
                area_info:this.addressmodel.area_info,
                telephone:this.addressmodel.telephone,
                trueName:this.addressmodel.true_name,
                addFrom:'wechatShop',
                code:'',
            };
            
            if(this.addressmodel.addr_id && this.addressmodel.addr_id.length > 0){
                //编辑地址使用
                param.addr_id = this.addressmodel.addr_id;
            }
            console.log("发送前参数："+JSON.stringify(param));
            const self = this;
            this.loading = true;
            Fetch.post(url, param, function(respone){
                self.loading = false;
                var reslut = JSON.parse(respone);
                if(reslut.op_flag === "success") {
                    modal.toast({
                        message: reslut.info,
                        duration: 1.0
                    });

                    const addressChannel = new BroadcastChannel("addressChange");
                    addressChannel.postMessage("addressChange");
                    if(weex.config.userInfo){
                        weex.config.userInfo.addrInfo.hasAddress = 'true';
                    }
                     navigation.pop({

                        },event => {
                            console.log("结果回调");
                        });
                }else{
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
    align-items: center;
    flex: 1;
    background-color: #f5f5f9;
}
.box {
    position: relative;
    flex-direction: row;
    align-items: center;
    border-bottom-color: #dddddd;
    border-bottom-width: 2px;
    background-color: white;
    width: 750px;
    height: 90px;
}
.text {
  font-size: 36px;
  color: #333333; 
  padding-left: 20px;
  padding-top: 10px;
  padding-bottom: 10px;
  height: 70px;
}
.input {
    margin-right: 40px;
    height: 70px;
    width: 500px;
}
.input-city {
    margin-right: 10px;
    height: 70px;
    flex: 1;
    text-overflow:ellipsis;
    /* background-color: #ea333d; */
}
.mask {
    position:absolute;
    bottom: 10px;
    top: 80px;
    height: 70px;
    /* background-color: aqua; */
    /* opacity: 0.5; */
}
.mask1 {
    left: 20px;
    width: 230px; 
}
.mask2 {
    width: 210px;
    left: 260px;
}
.mask3 {
    width: 270px;
    left: 480px;
}
.textarea {
    width: 750px;
    height: 200px;
    padding: 20px;
    font-size: 30px;
    color: #333333;
    background-color: white;
}
.dele-box {
    flex-direction: row;
    align-items: center;
    height: 90px;
    border-bottom-width: 2px;
    border-bottom-color: #f5f5f9;
    background-color: #ffffff;
    margin-top: 40px;
    width: 750px;
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
    width: 600px;
    height: 100px;
    margin-top: 60px;
    border-radius: 10px;
}
.save-button {
    background-color: #ea333d;
}
.save-button:active {
    background-color: rgb(112, 0, 16);
}
.save-text {
    color: white;
    font-size: 36px;
}

</style>
