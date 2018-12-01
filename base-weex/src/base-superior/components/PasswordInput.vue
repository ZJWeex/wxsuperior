<template>
    <wxc-popup popup-color="#f2f2f2" 
               :show="show" 
               @wxcPopupOverlayClicked="popupOverlayBottomClick" 
               pos="bottom" 
               height="360">
        <input autofocus='true'
               ref="pwdinput" 
               type="number" 
               :maxlength='maxlength'
               :max-length='maxlength'
               @input="onInput"
               @change="onChange"
               style="width:0;height:0"/>
        <div class="title">
            <wxc-icon name="close" 
            :icon-style="{color:'#666666',fontWeight: 'bolder',padding:'20px'}"
            @wxcIconClicked="popupOverlayBottomClick"></wxc-icon>
            <text class="title-text">{{ title }}</text>
            <span style="padding:20px;" />
        </div>
        <div class="password-content">
            <div v-for="(item,i) in maxArray" :key="i" class="password-item">
                <div v-if="i<passwordText.length" class="point"></div>
            </div>
        </div>
        <text v-if="forgetpwd.length>0" class="forget-pwd" @click="forgetpwdClick">{{ forgetpwd }}</text>
    </wxc-popup>
</template>

<script>
import { WxcPopup, WxcIcon } from "weex-ui";

const modal = weex.requireModule("modal");
const navigator = weex.requireModule("navigator");

export default {
    components: { WxcPopup, WxcIcon },
    props:{
        show:{
            type: Boolean,
            default:false
        },
        title:{
            type:String,
            default:'请输入余额支付密码'
        },
        maxlength:{
            type: Number,
            default:6
        },
        forgetpwd:{
            type:String,
            default:'忘记密码？'
        }
    },
    data() {
        return {
            maxArray:[],
            passwordText:'',
        };
    },
    created() {
        for (let index = 0; index < this.maxlength; index++) {
            this.maxArray.push(index);
        }
    },
    methods: {
        popupOverlayBottomClick:function(event){
            //重置
            this.passwordText = ''; 
            this.$emit('cancalClick', event);
        },
        //输入改变时
        onInput:function(event){
            const self = this;
            self.passwordText = event.value;
            if(self.passwordText.length == self.maxlength){
                setTimeout(()=>{
                    self.$emit('passwordFinish', event.value);
                    // this.$refs['pwdinput'].blur();
                    //重置
                    self.passwordText = ''; 
                },300)
            }
        },
        //输入失去焦点时
        onChange:function(event){
            this.passwordText = '';
        },
        //忘记密码点击事件
        forgetpwdClick:function(){
            navigator.push({url:'balance_setPayPwd.html',title:'重置密码'},event =>{});
        },
    }
};
</script>

<style scoped>
.wrapper {
    justify-content: center;
    align-items: center;
}
.title {
    flex-direction:row;
    align-items:center;
    justify-content:space-between;
    border-bottom-color:#c8c8c8;
    border-bottom-width:2px;
}
.title-text {
    font-size: 36px;
    color: #333333;
}
.password-content {
    flex-direction:row;
    align-items:center;
    margin:34px;
    background-color:#ffffff;
    border-color:#f2f2f2;
    border-width:2px;
    border-radius:10px;
}
.password-item{
    flex:1;
    height:90px;
    border-right-color:#f2f2f2;
    border-right-width:2px;
    justify-content:center;
    align-items:center;
}
.point {
    width:20px;
    height:20px;
    background-color:#333333;
    border-radius:10px;
}
.forget-pwd {
    align-self: flex-end;
    margin-right:20px;
    font-size: 28px;
    color: #333333;
}

</style>
