<template>
    <div @viewappear="viewappear" @viewdisappear="viewdisappear">
        <navigation title='登录'/>
        <div class='wrapper'>
            <div style="width: 580px;justify-content:flex-start">
                <!-- 输入手机号 -->
                <div class="phone-div">
                    <image class="phoneIcon" src="/web/assets/sup/sup_login_loginPhoneIcon.png" />
                    <input type="tel" class="input-number" autofocus=true placeholder="输入手机号码" max-length=11 maxlength=11 ref="phone" return-key-type="done" @change="numberchange" @input="numberinput" />
                </div>
                <!-- 输入验证码 -->
                <div class="code-div">
                    <div class="div-code">
                        <input type="number" class="input-code" placeholder="输入验证码" max-length=6 maxlength=6 ref="code" return-key-type="done" @change="codechange" @input="codeinput" />
                    </div>
                    <text v-if="countDowningEnable" class="get-code" :style="{'background-color': '#ea333d' }" @click="getVerCode">{{ countDown }}</text>
                    <text v-else class="get-code" :style="{'background-color': '#c9c9c9' }">{{ countDown }}</text>
                </div>
            </div>
            <div class="prcol-info">
                <div class="selectIcon-div" @click="onSelectProtocol">
                    <image class="selectIcon" :src="selectAgree ? Agree : unAgree" @click="onSelectProtocol" />
                </div>
                <text class="prcol">我同意</text>
                <text class="prcol" :style="{color:'red'}" @click="onProtocol(1)">《淘菜猫服务协议》</text>
                <text class="prcol">和</text>
                <text class="prcol" :style="{color:'red'}" @click="onProtocol(2)">《淘菜猫隐私权政策》</text>
            </div>
            <div v-if="selectAgree&&isPhone&&codeText.length>=4" class="login loginbgcolor" @click="onLoginClick">
                <text class="login-text">登录</text>
            </div>
            <div v-else class="login loginenable-bgcolor">
                <text class="login-text">登录</text>
            </div>
            <text class="des-info">未注册的手机号，自动注册为淘菜猫用户</text>
        </div>
        <wxc-loading :show="loading" need-mask=false type="default"></wxc-loading>
    </div>
</template>

<script>
import { WxcLoading } from "weex-ui";
import Fetch from "@/base-superior/Fetch.js";
import Define from "@/base-superior/Define.js";
import DB from "../base-superior/shopping_cartdb.js"
import navigation from "@/base-superior/components/NavigationBar.vue";

const modal = weex.requireModule("modal");
const storage = weex.requireModule("storage");

var crypt = require("crypt");
var CryptoJS = require("crypto-js");

export default {
    components: {navigation, WxcLoading },
    data() {
        return {
            timer: null,
            isStopTimer:true,
            loading: false,
            countDown: "发送验证码",
            countDowningEnable: false,
            isPhone: false,
            phoneNumber: "",
            codeText: "",
            unAgree:"/web/assets/sup/sup_login_unagreeicon.png",
            Agree:"/web/assets/sup/sup_login_agreeicon.png",
            selectAgree: true,
            //登录返回的用户信息
            userInfo: {
                sessionid: "",
                userId: "",
                token: "",
                newUserFlag: "", //是否新注册用户（第一次登陆）
                newUser:
                    "" /* ture表示新用户(未下过单)，此字段不一定有，没有或者是false都代表老用户 */,
                addrInfo: {
                    areaInfo: "",
                    trueName: "",
                    hasAddress: "", //true有地址，false没地址
                    lng: "",
                    lat: "",
                    gender: "", //1男，0女
                    telephone: "",
                    addr_id: "",
                    addrType: "",
                    areas: [
                        {
                            areaId: "",
                            areaName: "",
                            level: ""
                        }
                    ]
                }
            }
        };
    },
    created() {
       
    },
    methods: {
        viewappear(){
           //加载页面完成
           this.isStopTimer = true;
        },
        //输入手机号
        numberchange: function(event) {
            this.phoneNumber = event.value;
            console.log("phoneNumber:", this.phoneNumber);
        },
        numberinput: function(event) {
            this.phoneNumber = event.value;
            if (this.isPhoneAvailable(this.phoneNumber)) {
                if(this.countDown.indexOf('验证码') != -1){
                    this.countDowningEnable = true;
                }
                this.isPhone = true;
            } else {
                this.countDowningEnable = false;
                this.isPhone = false;
                if (this.phoneNumber.length >= 11) {
                    modal.toast({
                        message: "请输入有效的手机号",
                        duration: 1.0
                    });
                }
            }
            console.log("phoneNumber:", event.value);
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
            if (this.phoneNumber.length == 0) {
                modal.toast({ message: "请输入手机号", duration: 1.0 });
                return;
            } else if (!this.isPhoneAvailable(this.phoneNumber)) {
                modal.toast({ message: "请输入有效的手机号", duration: 1.0 });
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
        //AES加密方法
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
        //协议事件
        onProtocol: function(number) {
            this.isStopTimer = false;
            //number：1-服务协议；2-隐私权政策
            if (number == 1) {
                console.log("服务协议");
                var objc = {url:'https://s3.cn-north-1.amazonaws.com.cn/h5.taocai.mobi/app/uesr_agree.html',
                            title:'服务协议'}
                storage.setItem('web_url',JSON.stringify(objc),event =>{})
                navigation.push(
                    {
                        url: "setting_agreementWeb.html",
                        title:'服务协议',
                        animated: "true"
                    },
                    event => {
                        console.log("结果回调");
                    }
                );
            } else if (number == 2) {
                console.log("隐私权政策");
                var objc = {url:'https://s3.cn-north-1.amazonaws.com.cn/www.taocaimall.com/webResources/tcmApp_page/lawInfo.html',
                            title:'隐私权政策'}
                storage.setItem('web_url',JSON.stringify(objc),event =>{})
                navigation.push(
                    {
                        url: "setting_agreementWeb.html",
                        title:'隐私权政策',
                        animated: "true"
                    },
                    event => {
                        console.log("结果回调");
                    }
                );
            }
        },
        //选中协议事件
        onSelectProtocol: function() {
            this.selectAgree = !this.selectAgree;
        },
        //登录操作
        onLoginClick: function() {
            const self = this;
            //让输入框失去焦点
            self.$refs['phone'].blur()
            self.$refs['code'].blur()
            let enable =
                !this.selectAgree || !this.isPhone || this.codeText.length < 4;
            if (enable) return;
            self.loading = true;
            
            var drivice = ''
            if (weex.config.env.appName === Define.APP_NAME) {
                drivice = drivice + '_' + WXEnvironment.platform
            } else {
                drivice = WXEnvironment.platform.toLowerCase()
            }              
                     
            var param = { username: this.phoneNumber, code: this.codeText, drivice: drivice, };  
            Fetch.post(
                "app_sms_login.json",
                param,
                function(jsonString) {
                    self.loading = false;
                    //   modal.alert({message:jsonString})
                    var result = JSON.parse(jsonString);
                    if (result.op_flag === "success") {
                        //保存用户信息
                        storage.setItem(Define.kToken, result.token,event => {});
                        //保存手机号
                        storage.setItem(Define.kPhone, self.phoneNumber)
                        
                        self.userInfo = result;
                        weex.config.userInfo = self.userInfo;
                        weex.config.sessionid = self.userInfo.sessionid;
                        storage.setItem('JESSIONID', self.userInfo.sessionid)
                        //游客同步购物车数据
                        DB.touristsSynchCartData();
                        setTimeout(()=>{
                            //消费者app同步登录
                           DB.appSynchLoginNotification();
                        },300)

                        modal.toast({
                            message: weex.config.userInfo.info,
                            duration: 1.0
                        });

                        const loginChannel = new BroadcastChannel("login");
                        loginChannel.postMessage("login");

                        setTimeout(() => {
                            navigation.pop(
                                {
                                    animated: "true"
                                },
                                event => {
                                    console.log("结果回调");
                                }
                            );
                        }, 1000);
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
        //手机号验证
        isPhoneAvailable: function(str) {
            var reg = /^[1][3-9][0-9]{9}$/;
            if (!reg.test(str)) {
                return false;
            } else {
                return true;
            }
        },
        viewdisappear: function(event) {
            if(this.timer && this.isStopTimer){
                clearInterval(this.timer);
            }
        }
    },
    beforeDestroy(){
        console.log('该方法也不执行')
    },
    //释放时，调用该函数
    destroyed(){
        console.log('该方法不执行')
    }
};
</script>

<style scoped>
.wrapper {
    /* justify-content: center; */
    position: relative;
    top: 200px;
    align-items: center;
}
.phone-div {
    flex-direction: row;
    align-items: center;
    border-bottom-color: #dddddd;
    border-bottom-width: 2px;
    margin-bottom: 40px;
}
.phoneIcon {
    width: 34px;
    height: 46px;
}
.input-number {
    margin-left: 20px;
    font-size: 30px;
    height: 80px;
    flex: 1;
    /* placeholder-color:#999; */
    color: #333;
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
.input-code {
    font-size: 30px;
    color: #333;
    flex: 1;
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
    margin-bottom: 60px;
    margin-top: 20px;
}
.selectIcon-div {
    width: 80px;
    align-items: center;
}
.selectIcon {
    height: 40px;
    width: 40px;
}
.prcol {
    font-size: 24px;
    color: #666666;
}
.login {
    justify-content: center;
    align-items: center;
    width: 580px;
    height: 80px;
    border-radius: 10px;
    
}
.loginbgcolor {
    background-color: #ea333d;
}
.loginbgcolor:active {
    background-color: rgb(112, 0, 16);
}
.loginenable-bgcolor {
    background-color: #c9c9c9;
}
.login-text {
    color: white;
    font-size: 36px;
}
.des-info {
    margin-top: 70px;
    font-size: 24px;
    color: #999;
}
</style>
