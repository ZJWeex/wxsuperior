<template>
  <div class="wrapper">
    <navigation title="设置支付密码"/>
    <div class="row">
        <text class="text-title">{{titleStr}}</text>
        <div style="padding-right:20px">
            <switch :checked="switchCheck" @change="onchange"></switch>
        </div>  
    </div>
     <text class="text-desc">{{descStr}}</text>
     <text class="forget-pwd" @click="forgetPwdClick">忘记密码?</text>
     <wxc-loading :show="loading" need-mask=false type="default"></wxc-loading>
     <!-- 密码输入弹框 -->
     <PasswordInput :show="isBottomShow"
                    @cancalClick="cancalPasswordInputClick"
                    @passwordFinish="passwordFinish">    
     </PasswordInput>
  </div>
</template>

<script>
import { WxcLoading } from "weex-ui";
import Define from "@/base-superior/Define.js";
import Fetch from "@/base-superior/Fetch.js";
import navigation from "@/base-superior/components/NavigationBar.vue";
import PasswordInput from  "../components/PasswordInput.vue";


const modal = weex.requireModule("modal");
const storage = weex.requireModule('storage')

export default {
  components: { navigation, WxcLoading, PasswordInput },
  data() {
    return {
        loading: false,
        openStatus: '',
        titleStr: '',
        descStr: '',
        switchCheck: false,
        isBottomShow: false,//密码弹框
    };
  },
  created: function() {
      var self = this
      storage.getItem('isOpenPwd', event => {
          console.log('isOpenPwd:', event.data)
          if(event.data && event.data != 'undefined'){
              self.openStatus = event.data;
              self.initOpenStatus();
              storage.removeItem('isOpenPwd',event => {})
          }
      });
  },
  methods: {
    
    // switch是否开启状态
    initOpenStatus: function () {
        var self = this
        if (self.openStatus == 'open') {
            self.titleStr = '余额支付密码已开启'
            self.descStr = '为了您的账户安全，提交订单时需输入该支付密码!'
            self.switchCheck = true
        } else if (self.openStatus == 'close') {
            self.titleStr = '余额支付密码已关闭'
            self.descStr = '余额充足时无密码支付，可能存在一定的风险。'
            self.switchCheck = false
        }
    },
    //switch切换
    onchange: function(e) {
        this.switchCheck = e.value
        if (e.value) {
            // 通知开启
            this.openOrClosePwd('open')
        } else {
            // 通知关闭
            // this.isBottomShow = true;
            // 点击关闭：调用的接口有：先判断密码错误次数，小于等于5次：弹出输入密码；大于5次直接toast弹出框提示
            this.pwdErrorCount()
        }
    },
    // 判断密码输入错误次数
    pwdErrorCount: function () {
        const self = this
        var param = {}
        Fetch.post('buyer/getUserCardPayPasswordErrorCount.json', param, function(respone){
            var result = JSON.parse(respone);
            /**
             * {"op_flag":"success","info":"操作成功","code":"0","errorCount":"0","userId":"748736657603915776","userName":"15801974371","currDate":"2018-11-30 13:46:23"}
             */
            if (result.op_flag == 'success') {
                
                if (parseInt(result.errorCount) < 5) {
                    self.isBottomShow = true
                } else {
                    modal.toast({
                        message:'密码错误次数超过5次，请过5分钟后再试或重置密码',
                        duration: 0.5
                    })
                    setTimeout(() => {
                        self.openStatus = 'open'
                        self.initOpenStatus()
                        console.log('延时执行')
                    }, 501)
                }
            } else {
                modal.toast({message:reslut.info})
            }
        }, function(err){
            modal.toast({message:'错误信息:'+err})
        })
    },
    //隐藏密码弹框
    cancalPasswordInputClick:function() {
        this.isBottomShow = false;
        this.openStatus = 'open'
        this.initOpenStatus()
    },
    //密码输入完成
    passwordFinish:function(value){
        console.log('密码：'+value)
        // modal.toast({message:'密码：'+value})
        const self = this;
        var param = {password: value}
        Fetch.post('buyer/checkUserCardPayPassword.json', param, function(respone){
            var result = JSON.parse(respone);
            /*
            { "op_flag": "success",
            "info":'',
            "userId":'',
            "isPasswordCorrect":"true"}
            */
           if(result.op_flag == 'success'){
               if(result.isPasswordCorrect == 'true'){
                   self.openOrClosePwd('close')
                   self.isBottomShow = false;
               } else {
                   self.isBottomShow = false;
                   modal.alert({
                       message:result.info == '操作成功'?"密码错误":result.info,
                       okTitle: "确认"
                   },evnet=>{
                       self.isBottomShow = false
                       self.openStatus = 'open'
                       self.initOpenStatus()
                   })
               }
           } else {
               modal.toast({
                   message:result.info,
                   duration: 0.5
               })
           }
        }, function(err){
            modal.toast({
                message:'错误信息:'+err,
                duration: 0.5
            })
        });
    },
    forgetPwdClick: function () {
        // 跳转至设置密码(真的设置)
        navigation.push({url:'balance_setPayPwd.html', title:'设置支付密码'}, event =>{

        });
    },
    openOrClosePwd: function (openType) {
        const self = this;
        if (openType == 'open') {
            self.openStatus = 'close'
        } else if (openType == 'close') {
            self.openStatus = 'open'
        }
        var params = {opType: openType}
        Fetch.post('buyer/openOrCloseUserCardPayPassword.json', params, function(respone) {
            var result = JSON.parse(respone);
            if (result.op_flag == 'success') {
                /*
                {"op_flag":"success","info":"操作成功","code":"0","userId":"748736657603915776","payPasswordOpened":"true"/"false"}
                */
                if (result.payPasswordOpened == 'true') {
                    self.openStatus = 'open'
                } else if (result.payPasswordOpened == 'false') {
                    self.openStatus = 'close'
                }
                // 支付密码开启与关闭-发全局通知
                const openedChannel = new BroadcastChannel("openOrCloseSuccess");
                openedChannel.postMessage(self.openStatus);
            } else {
                modal.toast({message:result.info})
            }
            self.initOpenStatus()
        }, function(err) {
            modal.toast({message:'错误信息:'+err})
        })
    }
  }
};
</script>

<style scoped>
.wrapper {
    width: 750px;
    background-color: #F5F5F5;
}
.row {
  height: 100px;
  margin-top: 30px;
  background-color: #FFFFFF;
  flex-direction: row;
  justify-content: space-between;
  align-items: center;
  border-bottom-width: 1px;
  border-bottom-color: #dddddd;
  border-top-width: 1px;
  border-top-color: #dddddd;
}
.text-title {
  margin-left: 20px;
  color: #333333;
}
.text-desc {
  padding: 20px;
  font-size: 28px;
  color: #666666;
}
.forget-pwd {
  padding-right: 20px;
  text-align: right;
  color: #ff0033;
  font-size: 28px;
}
</style>
