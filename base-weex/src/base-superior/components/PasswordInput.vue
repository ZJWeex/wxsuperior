<template>
    <wxc-popup ref="wxcPopup"
               popup-color="#f2f2f2" 
               :show="show" 
               @wxcPopupOverlayClicked="popupOverlayBottomClick" 
               pos="bottom" 
               :height="popupHeight">
        <input autofocus='true'
               ref="pwdinput" 
               type="number" 
               :maxlength='maxlength'
               :max-length='maxlength'
               @input="onInput"
               @change="onChange"
               @keyboard="keyboard"
               style="width:1;height:0"/>
        <div class="title">
            <wxc-icon name="close" 
            :icon-style="{color:'#666666',fontWeight: 'bolder',padding:'20px'}"
            @wxcIconClicked="popupOverlayBottomClick"></wxc-icon>
            <text class="title-text">{{ title }}</text>
            <span style="padding:20px;" />
        </div>
        <div :class="[isAndroid?'android-password-content':'password-content']">
            <div v-for="(item,i) in maxArray" :key="i" class="password-item">
                <div v-if="i<passwordText.length" class="point"></div>
            </div>
        </div>
        <div v-if="isAndroid" style="flex-direction:row;width:750px;position: absolute;top: 240px;">
            <div style="flex:1"></div>
            <text v-if="forgetpwd.length>0" class="android-forget-pwd" @click="forgetpwdClick">{{ forgetpwd }}</text>
        </div>
        <div v-else>
            <text v-if="forgetpwd.length>0" class="forget-pwd" @click="forgetpwdClick">{{ forgetpwd }}</text>
        </div>
    </wxc-popup>
</template>

<script>
import { WxcPopup, WxcIcon } from "weex-ui";
import navigation from "@/base-superior/components/NavigationBar.vue";

const modal = weex.requireModule("modal");

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
            isAndroid:WXEnvironment.platform === 'android',
            popupHeight:360,
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
        //andriod键盘弹出隐藏事件,ios调用modal组件会死循环
        keyboard:function(e){
            const self = this;
            if(self.isAndroid){
                // modal.alert({message:"keyboard："+JSON.stringify(e)})
                if(e.isShow){
                    //android的weexsdk0.19以下没有keyboardSize参数
                    if(e.keyboardSize){
                        self.popupHeight = 300 //+ Number(e.keyboardSize);
                    }else{
                        self.popupHeight = 300+616
                    }
                    
                }else{
                    self.$refs.wxcPopup.hide();
                }
            }else{
                console.log("keyboard："+JSON.stringify(e))
            }
        },
        //忘记密码点击事件
        forgetpwdClick:function(){
            navigation.push({url:'balance_setPayPwd.html',title:'重置密码'},event =>{});
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
.android-password-content {
    position: absolute;
    top: 80px;
    flex-direction:row;
    align-items:center;
    margin:34px;
    width: 682px;
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
.android-forget-pwd{
    padding: 10px;
    margin-right:20px;
    font-size: 28px;
    color: #333333; 
}
.forget-pwd {
    align-self: flex-end;
    margin-right:20px;
    padding: 10px;
    font-size: 28px;
    color: #333333;
}

</style>
