<template>
    <div class='wrapper'>
        <div class="content-left">
            <div style="flex-direction: row;align-items: flex-end;">
                <text class="money-front" :style="{color:getCouponCong(item).color}">¥</text>
                <text class="money-back" :style="{color:getCouponCong(item).color}">{{ item.favorable_money }}</text>
            </div>
            <text style="font-size: 24px;color:#666666;">满{{ item.origin_price }}元使用</text>
            <div v-if="getCouponCong(item).stateTitle.length > 0" class="state-tag" :style="{'background-color':getCouponCong(item).tagColor, height:getCouponCong(item).stateTitle.length>0 ? '114px':0}">
                <text class="state-text">{{ getCouponCong(item).stateTitle }}</text>
            </div>
        </div>
        <div class="content-center">
            <div class="top-round"></div>
            <div class="dashed-line"></div>
            <div class="bottom-round"></div>
        </div>
        <div class="content-right">
            <image class="type-tag" :src='getCouponCong(item).img' />
            <div style="flex-direction: row;">
                <text style="font-size: 22px;color:#383434;">有效期：</text>
                <text class="date-text" :style="{color:getCouponCong(item).color}">{{ item.begin_date.substr(0, 10) }}至{{ item.validity_date.substr(0, 10) }}</text>
            </div>
            <text style="font-size: 22px;color:#2c2a29;padding-top:10px;padding-right:40px;">说明：{{ checkDescription(item.description) }}</text>
            <text v-if="getCouponCong(item).useInfo.length>0" style="font-size: 22px;color:#333333;padding-top:10px;padding-right:40px;">{{ getCouponCong(item).useInfo }}</text>
            <div v-if="itemType == 100" :class="[isAndriod?'select-imgandriod':'select-img']">
                <image v-if="checked==true" style="width: 36px; height: 36px;" src='/web/assets/sup/sup_coupon_selectcoupon.png'/>
                <div v-else style="width: 36px; height: 36px;border-radius: 18px; border-width: 2px;border-color: #c9c9c9"></div>
            </div>
        </div>
    </div>
</template>

<script>
const modal = weex.requireModule("modal");

export default {
    components: {},
    props: {
        itemType: {
            type: Number,
            default: 0 //1未使用，2已失效，3已使用,100选择优惠券
        },
        item: {
            type: Object,
            default: function() {
                return {
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
                };
            }
        },
        checked: {
            type: Boolean,
            default: false
      },
    },
    data() {
        return {
            isAndriod:WXEnvironment.platform === 'android',
        };
    },
    created() {
        
    },
    methods: {
        //选择优惠券点击事件
        didSelectClick:function(e){
            var item = this.item;
            this.$emit('didSelectClick', item);
        },
        //获取优惠券配置
        getCouponCong:function(item){
            //useType优惠券类型：1全场通用券；2普通优惠券；3专区优惠券；4店铺优惠券；5假日优惠券；6优选专用；7配送费优惠券；8优选兑换券；9品类优惠券；10优选商品券；1000普通折扣券；1001闪惠折扣券；1003专区折扣券；1004闪惠折扣
            let useType = item.useType;
            //只有普通优惠券有合并使用功能
            let mergeAble = item.mergeAble;

            var color = '#ff0033';//文字颜色
            var img = '';
            var tagColor = '#ff0033';//标签颜色
            var useInfo ='';
            //使用信息说明
            switch (item.useType) {
                case '4':
                if(item.couponStoreName){
                    useInfo = '店 铺：'+item.couponStoreName;
                }
                case '6':
                if(item.supplierName){
                    useInfo = '供应商：'+item.supplierName;
                }
                    break;
                case '10':
                if(item.goodsName){
                    useInfo = '适用商品：'+item.goodsName;
                }
                    break;
            
                default:
                if(item.type&&item.useTypeInfo){
                    useInfo = item.type+':'+item.useTypeInfo;
                }
                    break;
            }
            
            if(useType == 1){
                color = '#eacf3a';
                tagColor = '#eacf3a';
                img = '/web/assets/sup/sup_coupon_common_discount.png';
                useInfo = item.type;
            }else if(useType == 2){
                color = '#ff0033';
                tagColor = '#ff0033';
                if(mergeAble == 1){
                    img = '/web/assets/sup/sup_coupon_coupon_mergeable.png';
                }else{
                    img = '/web/assets/sup/sup_coupon_nomal_coupon.png';
                }
            }else if(useType == 3){
                color = '#ffa800';
                tagColor = '#ffa800';
                img = '/web/assets/sup/sup_coupon_zone_coupon.png';
            }else if(useType == 4){
                color = '#58b2cc';
                tagColor = '#58b2cc';
                img = '/web/assets/sup/sup_coupon_store_coupon.png';
            }else if(useType == 5){
                
            }else if(useType == 6){
                color = '#48a23f';
                tagColor = '#48a23f';
                img = '/web/assets/sup/sup_coupon_youpin_coupn.png';
            }else if(useType == 7){
                color = '#ff0033';
                tagColor = '#ff0033';
                img = '';
            }else if(useType == 8){
                color = '#8fcd47';
                tagColor = '#8fcd47';
                img = '';
            }else if(useType == 9){
                color = '#f9670f';
                tagColor = '#f9670f';
                img = '/web/assets/sup/sup_coupon_coupon_category.png';
            }else if(useType == 10){
                color = '#b71c47';
                tagColor = '#b71c47';
                img = '/web/assets/sup/sup_coupon_goods_coupon.png';
            }else if(useType == 1000){
                color = '#f9670f';
                tagColor = '#f9670f';
                img = '/web/assets/sup/sup_coupon_nomal_discount.png';
            }else if(useType == 1001 || useType == 1004){
                color = '#7c7dde';
                tagColor = '#7c7dde';
                img = '/web/assets/sup/sup_coupon_fast_discount.png';
            }else if(useType == 1002){
                
            }else if(useType == 1003){
                color = '#cc79bf';
                tagColor = '#cc79bf';
                img = '/web/assets/sup/sup_coupon_zone_discount.png';
            }
            var stateTitle = '';
            if(this.itemType == 1){
                //未使用
                if(item.timeFlag == 'future'){
                    stateTitle = '未生效';
                    if(item.enable == 'false'&&(useType == 8 || useType == 10)){
                        stateTitle = '未激活';
                    }
                }
            }else if(this.itemType == 2){
                //已失效
                stateTitle = '已失效';
                color = '#999999';
                tagColor = '#ebeaea';
                if(useType == 1){
                    img = '/web/assets/sup/sup_coupon_common_discount_invalid.png';
                }else if(useType == 2){
                    if(mergeAble == 1){
                        img = '/web/assets/sup/sup_coupon_coupon_mergeable_invalid.png';
                    }else{
                        img = '/web/assets/sup/sup_coupon_nomal_coupon_invalid.png';
                    }
                }else if(useType == 3){
                    img = '/web/assets/sup/sup_coupon_nomal_coupon_invalid.png';
                }else if(useType == 4){
                    img = '/web/assets/sup/sup_coupon_store_coupon_invalid.png';
                }else if(useType == 5){
                    img = '';
                }else if(useType == 6){
                    img = '/web/assets/sup/sup_coupon_youpin_coupn_invalid.png';
                }else if(useType == 7){
                    img = '';
                }else if(useType == 8){
                    img = '';
                }else if(useType == 9){
                    img = '';
                }else if(useType == 10){
                    img = '/web/assets/sup/sup_coupon_goods_coupon_invalid.png';
                }else if(useType == 1000){
                    img = '/web/assets/sup/sup_coupon_nomal_discount_invalid.png';
                }else if(useType == 1001 || useType == 1004){
                    img = '/web/assets/sup/sup_coupon_fast_discount_invalid.png';
                }
                
            }else if(this.itemType == 3){
                //已使用
                stateTitle = '已使用';
            }
            
            return {color:color,
                    tagColor:tagColor,
                    img:img,
                    stateTitle:stateTitle,
                    useInfo:useInfo}
        },
        //适配字符中有</br>问题
        checkDescription:function(description){
            if(WXEnvironment.platform.toLowerCase() === 'web'){
                return description;
            }else{
                
                if(description.indexOf("</br>")!= -1){
                   description = description.replace('</br>','\r\n');
                }else if(description.indexOf("<br>")!= -1){
                   description = description.replace("<br>",'\n');
                }else if(description.indexOf("<br/>")!= -1){
                    description = description.replace("<br/>",'\n');
                }

                return description;
            }
        },
        
    }
};
</script>

<style scoped>
.wrapper {
    align-items: center;
    flex-direction: row;
    margin: 24px;
    width: 702px;
    height: 272px;
    border-radius: 20px;
    background-color: #ffffff;
}
.content-left {
    align-items: center;
    justify-content: center;
    width: 210px;
    height: 272px;
}
.money-front {
    font-size: 32px;
}
.money-back {
    font-size: 58px;
}
.content-center {
    justify-content: space-between;
    align-items: center;
    background-color: #ffffff;
    width: 30px;
    height: 272px;
}
.content-right {
    align-items: flex-start;
    justify-content: center;
    flex: 1;
    height: 272px;
}
.date-text {
    font-size: 22px;
}
.dashed-line {
    width:4px;
    height:184px;
    border-left-style: dashed;
    border-left-width: 2px;
    border-left-color: #bbbaba;
}
.top-round {
    width:30px;
    height:15px;
    background-color:#f5f5f9;
    border-bottom-left-radius: 15px;
    border-bottom-right-radius: 15px;
}
.bottom-round {
    width:30px;
    height:15px;
    background-color:#f5f5f9;
    border-top-left-radius: 15px;
    border-top-right-radius: 15px;
}
.state-tag {
    align-items: center;
    justify-content: flex-start;
    position: absolute;
    width: 46px;
    height: 114px;
    top: 0;
    left: 0;
    background-color: #d60053;
    border-top-left-radius: 20px;
    border-bottom-right-radius: 46px;
}
.state-text {
    color: #ffffff;
    font-size: 22px;
    width: 24px;
    padding-top: 14px;
    line-height: 24px;
}
.type-tag {
    position: absolute;
    /* background-color: #999999; */
    width: 152px;
    height: 127px;
    top: 0;
    right: 0;
}
.select-img {
    width: 36px;
    height: 6px;
    /* background-color: orange; */
    align-self: flex-end;
    margin-right: 46px;
}
.select-imgandriod {
    width: 36px;
    height: 36px;
    /* background-color: orange; */
    align-self: flex-end;
    margin-right: 46px;
}

</style>
