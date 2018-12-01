<template>
    <div>
        <navigation title="我的红包"/>
        <wxc-tab-page ref="wxc-tab-page"
                    :tab-titles="tabTitles"
                    :tab-styles="tabStyles"
                    :needSlider='true'
                    @wxcTabPageCurrentTabSelected="wxcTabPageCurrentTabSelected">
                    <div v-for="(item, index) in tabTitles" :key="index">
                        <Coupon class="coupon"
                                :typeIndex='index+1'
                                :couponList='dataList[index]' 
                                :style="{ height: (tabPageHeight - tabStyles.height) + 'px' }"></Coupon>
                    </div>
        </wxc-tab-page>        
    </div>

</template>

<script>
import { WxcTabPage, Utils, BindEnv } from 'weex-ui';
import Fetch from "@/base-superior/Fetch.js";
import Coupon from "../base-superior/coupon_coupon.vue";
import navigation from "@/base-superior/components/NavigationBar.vue";

const modal = weex.requireModule('modal');

function getPageHeight () {
            const { env } = weex.config;
            var navHeight =  0;
            if(Utils.env.isIOS()){
                navHeight = 128;
                if(Utils.env.isIPhoneX()){
                   navHeight = 176; 
                }
            }else if(Utils.env.isAndroid()){
                navHeight = 168;
            }
            return env.deviceHeight / env.deviceWidth * 750 - navHeight;
        }

export default {
    components: {navigation, WxcTabPage, Coupon },
    data() {
        return {
            tabTitles:[{'title':'未使用'},{'title':'已失效'},{'title':'已使用'}],
            tabStyles: {
                        bgColor: '#FFFFFF',
                        titleColor: '#666666',
                        activeTitleColor: '#FF0033',
                        activeBgColor: '#FFFFFF',
                        isActiveTitleBold: false,
                        iconWidth: 0,
                        iconHeight: 0,
                        width: 250,
                        height: 90,
                        fontSize: 34,
                        hasActiveBottom: true,
                        activeBottomColor: '#FF0033',
                        activeBottomHeight: 4,
                        activeBottomWidth: 250,
                        textPaddingLeft: 10,
                        textPaddingRight: 10
                    },
            tabPageHeight: getPageHeight(),
            dataList:[],
        }
    },
    created() {
        this.loadCouponData();
    },
    methods: {
        wxcTabPageCurrentTabSelected:function(e){
            console.log(e.page);
             
        },
        //加载优惠券数据
        loadCouponData:function(){
            const self = this;
            var param = {"voucherType":"all",
                        "couponType":"all",
                        "superior":"1",
                        "isFromWechat":"1"}
            console.log('红包参数：',JSON.stringify(param))
            Fetch.post('buyer/discountList_2.json', param, function(respone){
                console.log('红包:',JSON.stringify(respone))
                var reslut = JSON.parse(respone);
                if(reslut.op_flag == 'success'){
                    //未使用
                    var unusedCouponArray = reslut.unused;
                    self.dataList.push(unusedCouponArray)
                    //已失效
                    var invalidCouponArray = reslut.invalid;
                    var invalidArray = [];
                    invalidCouponArray.forEach(element => {
                        //去除品类券
                        if(element.useType != '9'){
                            invalidArray.push(element);
                        }
                    });
                    self.dataList.push(invalidArray)
                    //已使用
                    var usedCouponArray = reslut.used;
                    self.dataList.push(usedCouponArray)
                    
                }else{
                    modal.toast({message:reslut.info})
                }

            }, function(err){
                 modal.alert({message:'err:'+err})
            });
        },
        
    }
}
</script>

<style scoped>
.wrapper { 
    justify-content: center;
    align-items: center;
}
</style>
