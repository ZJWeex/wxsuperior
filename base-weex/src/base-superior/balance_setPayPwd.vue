<template>
    <div>
        <navigation title="设置支付密码"/>
        <div class='wrapper' @viewappear="viewappear" @viewdisappear="viewdisappear">
            <div style="width: 580px; justify-content:flex-start">
                <!-- 输入6位数支付密码 -->
                <div class="password-div">
                    <input type="password" class="input-number" autofocus=true placeholder="请输入6位数字支付密码" max-length=6 maxlength=6 ref="pwd" return-key-type="done" @change="pwdchange" @input="pwdinput" />
                </div>
                <!-- 再次输入6位数支付密码 -->
                <div class="password-div">
                    <input type="password" class="input-number" placeholder="请再次输入支付密码" max-length=6 maxlength=6 ref="pwd" return-key-type="done" @change="confirmchange" @input="confirminput" />
                </div>
                <!-- 输入验证码 -->
                <div class="code-div">
                    <div class="div-code">
                        <input type="number" class="input-number" placeholder="请输入验证码" max-length=6 maxlength=6 ref="code" @change="codechange" @input="codeinput" />
                    </div>
                    <text class="get-code" :style="{'background-color': countDowningEnable ? '#ea333d':'#c9c9c9'}" @click="getVerCode">{{countDown}}</text>
                </div>
            </div>
            <!-- 提交修改 -->
            <div v-if="isPassword && isConfirmPwd && codeText.length>=4" class="submit submitbgcolor" @click="submitClick">
                <text class="login-text">提交</text>
            </div>
            <div v-else class="submit submitenable-bgcolor">
                <text class="login-text">提交</text>
            </div>
            <wxc-loading :show="loading" need-mask=false type="default"></wxc-loading>
        </div>
    </div>

</template>

<script>

import { WxcLoading, WxcPartLoading } from "weex-ui";
import Fetch from "@/base-superior/Fetch.js";
import Define from "@/base-superior/Define.js";
import navigation from "@/base-superior/components/NavigationBar.vue";

const modal = weex.requireModule("modal");
const storage = weex.requireModule("storage");

// 加密文件
var crypt = require("crypt");
var CryptoJS = require("crypto-js");

export default {
    components: {navigation, WxcLoading, WxcPartLoading },
    data() {
        return {
            timer: null,
            loading: false,
            countDown: "发送验证码",
            countDowningEnable: false,
            passwordText: "",
            confirmPwdText: "",
            codeText: "",
            isPassword: false,
            isConfirmPwd: false,
            phoneNumber: "",
            userInfo:{}
        };
    },
    created() {
        // 获取用户信息-获取手机号
        storage.getItem("customer_userInfo", event => {
            if (event.result == "success") {
                this.userInfo = JSON.parse(event.data);
                console.log(this.userInfo);
                this.phoneNumber = this.userInfo.telephone
                console.log("修改支付密码的手机号：", this.phoneNumber)
            }
        });
    },
    methods: {
        viewappear(){
           //加载页面完成
        },
        //输入支付密码
        pwdchange: function(event) {
            this.passwordText = event.value;
            console.log("passwordText:", this.passwordText);
        },
        pwdinput: function(event) {
            this.passwordText = event.value;
            if (this.isNumAvailable(this.passwordText)) {
                if (this.passwordText === this.confirmPwdText) {
                    this.countDowningEnable = true;
                    this.isPassword = true;
                    this.isConfirmPwd = true;
                } else {
                    this.countDowningEnable = false;
                    this.isPassword = false;
                }
            } else {
                this.countDowningEnable = false;
                this.isPassword = false;
                if (this.passwordText.length >= 6) {
                    modal.toast({
                        message: "请输入有效的6位数字支付密码",
                        duration: 1.0
                    });
                }
            }
            console.log("passwordText:", event.value);
        },
        //确认支付密码
        confirmchange: function(event) {
            this.confirmPwdText = event.value;
            console.log("confirmPwdText:", this.confirmPwdText);
        },
        confirminput: function(event) {
            this.confirmPwdText = event.value;
            if (this.isNumAvailable(this.confirmPwdText)) {
                if (this.passwordText === this.confirmPwdText) {
                    this.countDowningEnable = true;
                    this.isPassword = true;
                    this.isConfirmPwd = true;
                } else {
                    this.countDowningEnable = false;
                    this.isConfirmPwd = false;
                }
            } else {
                this.countDowningEnable = false;
                this.isConfirmPwd = false;
                if (this.confirmPwdText.length >= 6) {
                    modal.toast({
                        message: "请输入有效的6位数字支付密码",
                        duration: 1.0
                    });
                }
            }
            console.log("passwordText:", event.value);
        },
        //验证码输入
        codechange: function(event) {
            this.codeText = event.value;
            console.log("codeNumber:", event.value);
        },
        codeinput: function(event) {
            this.codeText = event.value;
            console.log("codeNumber:", event.value);
        },
        //输入失去焦点
        resignBlur: function(e) {
            //   this.$refs['input'].blur();
        },
        //获取验证码点击事件
        getVerCode: function() {
            const self = this;
            if (this.passwordText.length == 0) {
                // modal.toast({ message: "请输入6位数字密码", duration: 1.0 });
                return;
            } else if (!this.isNumAvailable(this.passwordText)) {
                // modal.toast({ message: "请输入有效的6位数字密码", duration: 1.0 });
                return;
            } else if (this.confirmPwdText.length == 0) {
                // modal.toast({ message: "请输入6位数字密码", duration: 1.0 });
                return;
            } else if (!this.isNumAvailable(this.confirmPwdText)) {
                // modal.toast({ message: "请输入有效的6位数字密码", duration: 1.0 });
                return;
            } else if (self.passwordText != self.confirmPwdText) {
                // modal.toast({message: "两次密码输入不一致！", duration: 1.0 });
                return;
            }

            this.onCountDown();
            this.requestSignKey(function(sigin_key) {
                self.requestVerificationCode(sigin_key);
            });
        },
        //获取动态密钥key
        requestSignKey(callBack) {
            let appid = Define.TCM_APPID;
            let AESKEY = Define.TCM_AESKEY;
            //获得当前毫秒时间戳
            var timestamp = new Date().getTime();
            let query_string = "appid=" + appid + "&posttime=" + timestamp;

            //md5需转大写
            let md5str = CryptoJS.MD5(query_string)
                .toString()
                .toLocaleUpperCase();
            //aes加密
            let aesSign = this.Encrypt(query_string, AESKEY);

            var param = { postdata: aesSign, siganature: md5str };
            //   console.log(param);
            console.log(JSON.stringify(param));
            let url = "hellotcm.json";

            Fetch.post(
                url,
                param,
                function(respone) {
                    console.log(respone);
                    var result = JSON.parse(respone);
                    if (result.key.length > 0) {
                        callBack(result.key);
                    } else {
                        modal.toast({
                            message: result.info,
                            duration: 1.0
                        });
                    }
                },
                function(err) {
                    console.log(err);
                    modal.toast({
                        message: err,
                        duration: 1.0
                    });
                }
            );
        },
        //ASE加密方法
        Encrypt: function(word, key) {
            var key = CryptoJS.enc.Utf8.parse(key);
            var srcs = CryptoJS.enc.Utf8.parse(word);
            var encrypted = CryptoJS.AES.encrypt(srcs, key, {
                mode: CryptoJS.mode.ECB,
                padding: CryptoJS.pad.Pkcs7
            });
            let base64AES = CryptoJS.enc.Base64.stringify(
                CryptoJS.enc.Utf8.parse(encrypted.toString())
            );
            return encrypted.toString();
        },
        //获取验证码接口
        requestVerificationCode: function(sign_key) {
            let appid = Define.TCM_APPID;
            var timestamp = new Date().getTime();

            // //获取手机号(直接获取userInfo)
            // this.phoneNumber = storage.getItem(Define.kPhone)
            console.log("打印手机号：", this.phoneNumber)
            let queryString =
                "telephone=" +
                this.phoneNumber +
                "&appid=" +
                appid +
                "&posttime=" +
                timestamp;

            let md5str = CryptoJS.MD5(queryString)
                .toString()
                .toLocaleUpperCase();
            let key = this.Encrypt(queryString, sign_key);
            var param = { postdata: key, siganature: md5str };

            //获取验证码
            Fetch.post(
                "phone_verify_code_app.json",
                param,
                function(jsonString) {
                    //result:info、time、countdownSeconds
                    var result = JSON.parse(jsonString);
                    if (result.op_flag === "success") {
                        modal.toast({
                            message: "验证码已发送",
                            duration: 1.0
                        });
                    } else if (result.info.length > 0) {
                        modal.toast({
                            message: result.info,
                            duration: 1.0
                        });
                    }
                },
                function(err) {
                    modal.toast({
                        message: err,
                        duration: 1.0
                    });
                }
            );
        },
        //倒计时
        onCountDown: function() {
            const that = this;
            if (!that.countDowningEnable) return;

            var second = 59;
            that.countDown = second + "秒";
            that.countDowningEnable = false;

            that.timer = setInterval(() => {
                second = second - 1;
                if (second <= 0) {
                    clearInterval(that.timer);
                    that.countDown = "重获验证码";
                    that.countDowningEnable = true;
                } else {
                    that.countDown = second + "秒";
                }
            }, 1000);
        },
        //提交操作
        submitClick: function() {
            let enable = !this.isPassword || !this.isConfirmPwd || this.codeText.length < 4;
            if (enable) return;
            
            this.loading = true;
            var param = {telephone: this.phoneNumber, codeValue: this.codeText,
            password: this.passwordText, password2: this.confirmPwdText};
            const self = this;
            Fetch.post(
                "buyer/setUserCardPayPassword.json",
                param,
                function(jsonString) {
                    self.loading = false;
                    //   modal.alert({message:jsonString})
                    var result = JSON.parse(jsonString);
                    if (result.op_flag === "success") {

                        const submitChannel = new BroadcastChannel("submitPayPwdSuccess");
                        submitChannel.postMessage("submitSuccess");

                        // 修改密码成功，toast弹出框
                        modal.toast({
                            message: '支付密码设置成功',
                            duration: 1.0
                        });

                        setTimeout(() => {
                            navigation.pop(
                                {
                                    animated: "true"
                                },
                                event => {
                                    console.log("结果回调");
                                }
                            );
                        }, 500);
                    } else {
                        modal.toast({
                            message: result.info,
                            duration: 1.0
                        });
                    }
                },
                function(err) {
                    self.loading = false;
                    modal.toast({
                        message: err,
                        duration: 0.5
                    })
                }
            );
        },
        //6位数-纯数字验证
        isNumAvailable: function(str) {
            var reg = /^[0-9]{6}$/;
            if (!reg.test(str)) {
                return false;
            } else {
                return true;
            }
        },
        viewdisappear: function(event) {
            if(this.timer){
                clearInterval(this.timer);
            }
        }
    }
};
</script>

<style scoped>
.wrapper {
    /* justify-content: center; */
    position: relative;
    top: 110px;
    align-items: center;
}
.password-div {
    flex-direction: row;
    align-items: center;
    border-bottom-color: #dddddd;
    border-bottom-width: 2px;
    margin-bottom: 40px;
}
.input-number {
    font-size: 24px;
    height: 80px;
    flex: 1;
    /* placeholder-color:#999; */
    color: #333333;
    /* background-color: orange; */
}
.code-div {
    flex-direction: row;
    justify-content: flex-start;
    align-items: center;
}
.div-code {
    border-bottom-color: #dddddd;
    border-bottom-width: 2px;
    margin-right: 10px;
    height: 80px;
    width: 200px;
}
.get-code {
    color: white;
    font-size: 26px;
    font-weight: bold;
    padding-top: 12px;
    padding-bottom: 12px;
    padding-left: 20px;
    padding-right: 20px;
    background-color: #ea333d;
    border-radius: 10px;
}

.prcol-info {
    flex-direction: row;
    align-items: center;
    margin-top: 0px;
}
.selectIcon {
    height: 40px;
    width: 80px;
}
.prcol {
    font-size: 24px;
    color: #666666;
}
.submit {
    justify-content: center;
    align-items: center;
    width: 580px;
    height: 80px;
    margin-top: 60px;
    border-radius: 10px;
}
.submitbgcolor {
    background-color: #ea333d;
}
.submitbgcolor:active {
    background-color: rgb(112, 0, 16);
}
.submitenable-bgcolor {
    background-color: #c9c9c9;
}
.login-text {
    color: white;
    font-size: 36px;
}
</style>
