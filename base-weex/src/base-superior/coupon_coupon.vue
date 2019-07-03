<template>
    <div class='wrapper'>
        <list class="list">
            <cell class="border-cell"></cell>
            <cell v-for="(item,i) in couponList" :key="i">
                <wxc-pan-item @wxcPanItemPan="wxcPanItemPan">
                    <couponCell :itemType="typeIndex" :item="item"></couponCell>
                </wxc-pan-item>
            </cell>
            <cell v-if="couponList.length < 3" v-for="i in noneList" :key="'none-'+i">
                <wxc-pan-item @wxcPanItemPan="wxcPanItemPan">
                    <div style="width:750px; height:400px;"></div>
                </wxc-pan-item>
            </cell>
            <cell v-if="isAndroid">
                <!-- 目的：android全面屏物理键可隐藏和显示 -->
                <div style="height:100px; width:750px;"></div>
            </cell>
        </list>
        <div v-if="showResultPage" style="position: absolute; top: 0; left: 0; right: 0; bottom: 0; background-color:#f2f3f4;">
            <wxc-pan-item @wxcPanItemPan="wxcPanItemPan">
                <wxc-result type="noGoods"
                            :show="showResultPage"
                            :custom-set="customSet"
                            padding-top="232">
                </wxc-result>
            </wxc-pan-item> 
        </div>
             
    </div>
</template>

<script>
import { WxcPanItem, WxcResult } from 'weex-ui';
import couponCell from '../base-superior/coupon_coupon_cell.vue';

const modal = weex.requireModule('modal');

export default {
    components: {WxcPanItem ,WxcResult, couponCell },
    props:{
        typeIndex: {
            type:Number,
            default:0,//1未使用，2已失效，3已使用
        },
        couponList:{
            type:Array,
            default:function (){
                return [/*{
                "code": "onlyFirstOrder",
		        "mergeAble": "0",//是否可合并使用
		        "validity_date": "2018-10-29",
		        "begin_date": "2018-10-23",
		        "useTypeInfo": "蔬菜",
		        "description": "仅首单；本券为品类专用优惠券，不得与淘菜猫其他优惠同享",
		        "useType": "1003",//1全场通用券；2普通优惠券；3专区优惠券；4店铺优惠券；5假日优惠券；6优选专用；7配送费优惠券；8优选兑换券；9品类优惠券；10优选商品券；1000普通折扣券；1001闪惠折扣券；1003专区折扣券；1004闪惠折扣
		        "type": "品类券",
		        "onlyFirstOrder": "1",
		        "enable": "false",//false不可用或未激活
		        "origin_price": "100.00",
		        "id": "821822930317852672",
		        "favorable_money": "10.00",
		        "timeFlag": "invalid"//invalid可使用；valid已失效；future未生效；already已使用
                }*/]
            },
        }
    },
    data() {
        return {
            isAndroid:WXEnvironment.platform === 'android',
            showResultPage:false,
            customSet:{},
            noneList:[],
        }
    },
    created() {
        console.log('周期创建开始')
    },
    mounted() {
      //周期函数
    },
    watch:{
        //属性监听
        couponList(newValue, oldValue){
            if(newValue.length == 0){
                this.showResultPage = true;
                var content = '没有红包~'
                if(this.typeIndex == 1){
                    content = '没有未使用的红包~'
                }else if(this.typeIndex == 2){
                    content = '没有已失效的红包～'
                }else if(this.typeIndex == 3){
                    content = '没有已使用的红包～'
                }
                this.customSet={noGoods: { button: null, content: content, desc: '' }}
            }else{
                this.showResultPage = false;
                this.customSet={}
                if(newValue.length<3){
                    for (let index = 0; index < 3 - newValue.length; index++) {
                        this.noneList.push(index);
                    }
                }
                
            }
        }
    },
    methods: {
        wxcPanItemPan (e){
            const self = this
            var element = e;
            self.$emit('couponItemPan', element);
        },
    }
}
</script>

<style scoped>
.wrapper { 
    align-items: center;
}
.list {
    flex-direction: column;
    width: 750px;
    flex:1;
    background-color: #f5f5f9;
}
.border-cell {
    background-color: #f5f5f9;
    width: 750px;
    height: 24px;
    align-items: center;
    justify-content: center;
  }

</style>
