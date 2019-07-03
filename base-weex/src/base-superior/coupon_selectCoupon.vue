<template>
    <div class='wrapper'>
        <navigation title="选择优惠券"/>
        <div style="width:750px;flex:1;">
            <!-- 不使用优惠券按钮 -->
            <div class="noneuse-coupon" @click="nonUseCouponClick">
                <text style="font-size: 36px;color:#333333;">不使用优惠券</text>
            </div>
            <!-- 优惠券列表 -->
            <list class="list">
                <cell v-for="(model,i) in updateList" :key="i" @click="selectCouponClick(i,model)">
                    <couponCell :itemType="100" :item="model" v-bind="model"></couponCell>
                </cell>
            </list>
            <wxc-result type="noGoods"
                :show="showResultPage"
                :custom-set="customSet"
                :wrap-style="{top:120}"
                padding-top="232">
            </wxc-result>
            <!-- 确定使用优惠券 -->
            <div v-if="selectCouponList.length>0" class='use-coupon' @click="useCouponClick">
                <text style="font-size: 36px;color:#ffffff;">确定</text>
            </div>
            <div v-else class="use-couponeable">
                <text style="font-size: 36px;color:#ffffff;">确定</text>
            </div>
        </div>
    </div>
</template>

<script>
import { WxcResult } from 'weex-ui';
import couponCell from '../base-superior/coupon_coupon_cell.vue';
import Fetch from "@/base-superior/Fetch.js";
import navigation from "@/base-superior/components/NavigationBar.vue";

const modal = weex.requireModule("modal");
const storage = weex.requireModule("storage");

export default {
    components: { couponCell, WxcResult, navigation },
    data() {
        return {
            showResultPage:false,
            customSet:{noGoods: { button: null, content: '您没有可使用的优惠券', desc: '' }},
            list:[{
                "code": "onlyFirstOrder",
		        "mergeAble": "1",//是否可合并使用
		        "validity_date": "2018-10-29",
		        "begin_date": "2018-10-23",
		        "useTypeInfo": "蔬菜",
		        "description": "仅首单；本券为品类专用优惠券，不得与淘菜猫其他优惠同享",
		        "useType": "1003",//1全场通用券；2普通优惠券；3专区优惠券；4店铺优惠券；5假日优惠券；6优选专用；7配送费优惠券；8优选兑换券；9品类优惠券；10优选商品券；1000普通折扣券；1001闪惠折扣券；1003专区折扣券；1004闪惠折扣
		        "type": "品类券",
		        "onlyFirstOrder": "1",
		        "enable": "false",//false不可用或未激活
		        "origin_price": "100.00",
		        "id": "821822930317852670",
		        "favorable_money": "10.00",
		        "timeFlag": "invalid"//invalid可使用；valid已失效；future未生效；already已使用
                },{
                  begin_date: "2018-11-08 00:00:00",
                description: "满足本劵使用金额即可使用 ，不得与淘菜猫其他优惠同享（促销、满赠、换购、首单）",
                favorable_money: "50.00",
                goodsId: "",
                goodsName: "",
                id: "827673850871824384",
                minusActivity: "0",
                origin_price: "0.00",
                supplierName: "淘菜猫优选旗舰店",
                useType: "2",
                validity_date: "2019-05-06 23:59:59"  
                }],
                
            selectCouponList:[],
        };
    },
    computed: {
      updateList () {
        const { list, selectCouponList } = this;
        const updateList = [];
        list && list.forEach((item, i) => {
          item.checked = false;
          selectCouponList.forEach((selectItem, j) => {
              if(item.id === selectItem.id){
                   item.checked = true;
              }
          })
          updateList.push(item);
        });
        return updateList;
      }
    },
    
    created () {
        console.log('开始')
        storage.getItem('oderSubmit_selectCoupon', event => {
          console.log('oderSubmit_selectCoupon:', event.data)
          if(event.data && event.data != 'undefined'){
              console.log('订单提交界面商品数据：'+event.data);
             this.loadCouponData(JSON.parse(event.data))
              storage.removeItem('oderSubmit_selectCoupon',event => {})
          }
        });
       
    },
    methods: {
        //加载可用优惠券数据
        loadCouponData: function(goodsCartlist){
            const self = this;
            /*
            var goodsCartlist = [{count:'1',
                                  supGoodsId:'784921804782215169',
                                  bgcId:'827704076099686400',
                                  supCartId:''}];*/
            var param = {currentPage:'1',
                        supGoodsIds:JSON.stringify(goodsCartlist),
                        offLineStoreZiTi:'0'};
            Fetch.post('superior/wechat/discountList.json', param, function(response){
                var result = JSON.parse(response)
                if(result.op_flag == 'success'){
                    self.list = result.objs;
                    if(self.list.length == 0){
                        self.showResultPage = true;
                    }else{
                        self.showResultPage = false;
                    }
                }else{
                     modal.toast({message:reslut.info})
                }
            },function(err){
                modal.alert({message:'err:'+err})
            })
        },
        //不使用优惠券
        nonUseCouponClick: function() {
            //回调数据
            const selectCouponChannel = new BroadcastChannel("selectCoupon");
             selectCouponChannel.postMessage(JSON.stringify([]));
            navigation.pop({animated:"true"},function(value){})
        },
        //选择优惠券
        selectCouponClick: function(i,obj) {
            if(this.array_contain(this.selectCouponList, obj)){
                let index = this.selectCouponList.indexOf(obj)
                //删除一个对象
                this.selectCouponList.splice(index,1)
            }else{
                if(this.selectCouponList.length==0){
                    this.selectCouponList.push(obj);
                }else{
                    var merge = false;
                    for (let index = 0; index < this.selectCouponList.length; index++) {
                        const item = this.selectCouponList[index];
                        if(item.mergeAble == 1){
                            merge = true;
                        }else{
                            break;
                        }
                    }
                    //都为可合并优惠券才可使用
                    if(merge && obj.mergeAble == 1){
                        this.selectCouponList.push(obj);
                    }else{
                        this.selectCouponList = [obj]
                    }
                }
            }
            
        },
        //数组是否包含一个元素
        array_contain:function(array, obj){
            for (var i = 0; i < array.length; i++){
                if (array[i] == obj)
                    return true;
            }
            return false;
        },
        //确定使用优惠券
        useCouponClick: function() {
            if(this.selectCouponList.length == 0)return;
            //回调数据
            const selectCouponChannel = new BroadcastChannel("selectCoupon");
             selectCouponChannel.postMessage(JSON.stringify(this.selectCouponList));

            navigation.pop({
               animated:"true" 
            },function(value){})
        },
        wxcPanItemPan(e) {
            console.log('手势事件交互')
        }
    }
};
</script>

<style scoped>
.wrapper {
    align-items: center;
    background-color: #f5f5f9;
}
.noneuse-coupon {
    align-items: center;
    justify-content: center;
    margin-top: 20px;
    margin-left: 24px;
    margin-right: 24px;
    height: 80px;
    margin-bottom: 10px;
    border-radius: 10px;
    background-color: #ffffff;
}
.list {
    flex-direction: column;
    position: absolute;
    top: 110px;
    width: 750px;
    bottom: 160px;
    background-color: #f5f5f9;
}
.use-coupon {
    align-items: center;
    justify-content: center;
    position: absolute;
    height: 80px;
    left: 24px;
    right: 24px;
    bottom: 40px;
    margin-top: 40px;
    border-radius: 10px;
    background-color: #ea333d;
}
.use-couponeable {
    align-items: center;
    justify-content: center;
    position: absolute;
    height: 80px;
    left: 24px;
    right: 24px;
    bottom: 40px;
    margin-top: 40px;
    border-radius: 10px;
    background-color: #c9c9c9;
}
</style>
