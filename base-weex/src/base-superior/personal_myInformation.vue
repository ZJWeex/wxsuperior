<template>
    <div>
        <navigation title = "个人信息" />
        <scroller class="scroller">
            <div v-for="(item, index) in rows" :key="index" :class="[index === 0?'otherRow':'row']">
                <text :class="[(item.type == 0||item.type == 1)?'title-disable-text':'title-text']">{{item.name}}</text>
                <!-- <div > -->
                <div v-if="item.type == 0" class="avatarsContent" style="margin-right:25px;" @click="changeAvatars">
                    <image class="avatarsImg" :src='userInfo.photoPath' resize="cover" />
                    <!-- // 暂时取消头像修改功能 -->
                    <!-- <image class="arrowImg" :src='arrow' resize="contain" /> -->
                </div>
                <!-- </div> -->
                <div v-else-if="item.type == 1">
                    <text style="padding-right:25px;font-size: 26px;color: #666666;">{{userInfo.userName}}</text>
                </div>
                <div v-else-if="item.type == 2">
                    <input type="text" placeholder="输入昵称" class="input" :autofocus=false :value="userInfo.trueName" @change="onchange" @input="oninput" maxlength=11/>
                </div>
                <div v-else-if="item.type == 3" class="avatarsContent" style="margin-right:25px;">
                    <image class="genderImg" :src='femaleIconImg' resize="contain" style="margin-right:60px;" @click="genderClick(0)" />
                    <image class="genderImg" :src='maleIconImg' resize="contain" @click="genderClick(1)" />
                </div>
                <div v-else>
                    <!-- item.type == 4 -->
                    <text class="birthday-text" @click="birthdayClick">{{userInfo.birthday}}</text>
                </div>
            </div>
        </scroller>
        <text class="saveInfo" @click="saveInfo">保存</text>
        <wxc-loading :show="loading" need-mask=true type="default"></wxc-loading>
    </div>
</template>

<script>
import { WxcLoading } from "weex-ui";
import Fetch from "@/base-superior/Fetch.js";
import navigation from "@/base-superior/components/NavigationBar.vue";

const modal = weex.requireModule("modal");
const storage = weex.requireModule("storage");
const picker = weex.requireModule("picker");

export default {
    components: {navigation, WxcLoading },
    data() {
        return {
            loading: false,
            userInfo: {
                photoPath: "",
                userName: "",
                trueName: "",
                sex: "", // 0女， 1男
                birthday: ""
            },
            femaleIconImg: "/web/assets/sup/sup_myInfo_femaleNormal.png",
            maleIconImg: "/web/assets/sup/sup_myInfo_maleNormal.png",
            arrow: "/web/assets/sup/sup_personal_next.png",
            currentDate: "",
            defaultDate: "",
            rows: [
                {name: "头像",type: 0}, 
                {name: "用户名",type: 1}, 
                {name: "昵称",type: 2}, 
                {name: "性别",type: 3}, 
                {name: "出生日期",type: 4}
            ]
        };
    },
    created: function() {
        var that = this;
        var myDate = new Date();
        var year = myDate.getFullYear();
        var month = myDate.getMonth();
        var day = myDate.getDate();

        that.currentDate = year.toString() + "-" + (month + 1).toString() + "-" + day.toString();
        that.defaultDate = year.toString() + "-" + (month + 1).toString() + "-" + day.toString();
        console.log("当前日期：" + that.currentDate);

        // 获取用户信息
        storage.getItem("customer_userInfo", event => {
            if (event.result == "success") {
                that.userInfo = JSON.parse(event.data),
                console.log(that.userInfo);
                if (that.userInfo.sex === "0") {
                    that.femaleIconImg = "/web/assets/sup/sup_myInfo_femaleSelected.png";
                    that.maleIconImg = "/web/assets/sup/sup_myInfo_maleNormal.png";
                } else if (that.userInfo.sex === "1") {
                    that.maleIconImg = "/web/assets/sup/sup_myInfo_maleSelected.png";
                    that.femaleIconImg = "/web/assets/sup/sup_myInfo_femaleNormal.png";
                } else {
                    that.femaleIconImg = "/web/assets/sup/sup_myInfo_femaleNormal.png";
                    that.maleIconImg = "/web/assets/sup/sup_myInfo_maleNormal.png";
                }
                // 判断生日是否存在
                if (that.userInfo.birthday.length <= 0) {
                    that.userInfo.birthday = that.defaultDate;
                }
            }
        });
    },
    methods: {
        // 更换头像
        changeAvatars: function() {
            return;
            modal.toast({
                message: "更换头像",
                duration: 0.5
            });
        },
        // 修改昵称
        onchange: function(event) {
            this.userInfo.trueName = event.value;
            console.log('nickName:', this.userInfo.trueName)
        },
        oninput: function(event) {
            this.userInfo.trueName = event.value;
            console.log("nickName:", this.userInfo.trueName);
            if (event.value.length <= 0) {
                modal.toast({
                    message: "昵称不能为空哟！",
                    duration: 0.5
                });
            }
        },
        genderClick: function(tag) {
            var message;
            if (tag == 0) {
                message = "女";
                this.femaleIconImg = "/web/assets/sup/sup_myInfo_femaleSelected.png";
                this.maleIconImg = "/web/assets/sup/sup_myInfo_maleNormal.png";
                this.userInfo.sex = '0'
            } else {
                message = "男";
                this.maleIconImg = "/web/assets/sup/sup_myInfo_maleSelected.png";
                this.femaleIconImg = "/web/assets/sup/sup_myInfo_femaleNormal.png";
                this.userInfo.sex = '1'
            }
            modal.toast({
                message: message,
                duration: 0.5
            });
        },
        // 修改生日
        birthdayClick: function() {
            console.log("选择生日");
            var that = this;
            picker.pickDate(
                {
                    value: that.currentDate,
                    max: that.defaultDate
                },
                event => {
                    if (event.result === "success") {
                        that.currentDate = event.data;
                        console.log("选择的日期为：" + that.currentDate);
                        that.userInfo.birthday = that.currentDate;
                    }
                }
            );
        },
        //保存
        saveInfo: function() {
            const self = this;
            console.log("保存用户信息");
            let enable = self.userInfo.trueName.length > 0 && self.userInfo.sex.length > 0 && self.userInfo.birthday.length > 0;
            let emojiStr = self.isEmojiCharacter(self.userInfo.trueName)
            console.log(enable, "是否包含emoji表情",emojiStr)
            console.log('昵称长度：'+self.userInfo.trueName.length, '性别长度：'+self.userInfo.sex.length, '生日长度：'+self.userInfo.birthday.length)
            var msg = ''
            if (self.userInfo.trueName.length <= 0) {
                msg = "请输入昵称";
                modal.toast({
                    message: msg,
                    duration: 0.5
                });
            } else if (self.userInfo.sex.length <= 0) {
                msg = "请选择性别";
                modal.toast({
                    message: msg,
                    duration: 0.5 
                });
            } else if (self.userInfo.birthday.length <= 0) {
                msg = "请选择生日";
                modal.toast({
                    message: msg,
                    duration: 0.5
                });
            }
            if (!enable) return;
            if (emojiStr) {
                modal.toast({
                    message:"不能包含特殊字符及表情!",
                    duration:0.5            
                })
                return
            }

            self.loading = true;
            var param = {
                trueName: self.userInfo.trueName,
                sex: self.userInfo.sex,
                telephone: self.userInfo.telephone,
                birthday: self.userInfo.birthday
            };
            Fetch.get(
                "buyer/account_save.json",
                {userInfoJSON: JSON.stringify(param)},
                function(jsonString) {
                    self.loading = false;
                    var result = JSON.parse(jsonString);
                    if (result.op_flag === "success") {
                        // 保存成功 - 发全局通知;
                        const saveInfoChannel = new BroadcastChannel("login");
                        saveInfoChannel.postMessage("saveInfoSuccess");
                        setTimeout(() => {
                            navigation.pop({
                                animated: "true"
                            }, event => {
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
                }, function(err) {
                    self.loading = false;
                    modal.toast({
                        message:err,
                        duration:0.5
                    })
                }
            );
            // navigation.pop({
            //     animated:'true'
            // }, event =>{
            //     console.log('结果回调')
            // })
            // modal.confirm({
            //     message: '保存个人信息',
            //     okTitle: '确定',
            //     cancelTitle: '取消'
            // }, function (value){
            //     if (value === '确定') {

            //     }
            // })
        },
        // 判断输入的字符串是否带有特殊字符和emoji表情
        isEmojiCharacter: function(substring) {
            if (substring) { 
                var reg = new RegExp("[~#^$@%&!?%*]", 'g'); 
                if (substring.match(reg)) {
                     return true;
                }
                for ( var i = 0; i < substring.length; i++) { 
                    var hs = substring.charCodeAt(i); 
                    if (0xd800 <= hs && hs <= 0xdbff) { 
                        if (substring.length > 1) { 
                            var ls = substring.charCodeAt(i + 1); var uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000; 
                            if (0x1d000 <= uc && uc <= 0x1f77f) { 
                                return true; 
                            } 
                        } 
                    } else if (substring.length > 1) { 
                        var ls = substring.charCodeAt(i + 1); 
                        if (ls == 0x20e3) { 
                            return true; 
                        } 
                    } else { 
                        if (0x2100 <= hs && hs <= 0x27ff) { 
                            return true; 
                        } else if (0x2B05 <= hs && hs <= 0x2b07) { 
                            return true; 
                        } else if (0x2934 <= hs && hs <= 0x2935) { 
                            return true;
                        } else if (0x3297 <= hs && hs <= 0x3299) { 
                            return true;
                        } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) { 
                            return true; 
                        } 
                    }
                } 
            }
        }
    }
};
</script>

<style scoped>
.scroller {
    width: 750px;
    height: 550px;
}
.row {
    height: 100px;
    flex-direction: row;
    justify-content: space-between;
    align-items: center;
    border-bottom-width: 1px;
    border-bottom-style: solid;
    border-bottom-color: #dddddd;
}
.otherRow {
    height: 150px;
    flex-direction: row;
    justify-content: space-between;
    align-items: center;
    border-bottom-width: 1px;
    border-bottom-style: solid;
    border-bottom-color: #dddddd;
}
.content {
    height: 100px;
    flex-direction: row;
    justify-content: flex-start;
    align-items: center;
    padding-left: 20px;
}
.iconImg {
    width: 36px;
    height: 36px;
}
.title-text {
    margin-left: 25px;
    font-size: 26px;
    color: #333333;
}
.title-disable-text {
    margin-left: 25px;
    font-size: 26px;
    color: #666666;
}
.avatarsContent {
    flex-direction: row;
    align-items: center;
}
.avatarsImg {
    width: 88px;
    height: 88px;
    border-radius: 44px;
}
.arrowImg {
    width: 16px;
    height: 27px;
    margin-left: 15px;
}
.input {
    font-size: 26px;
    text-align: right;
    margin-right: 25px;
    height: 80px;
    width: 300px;
}
.genderImg {
    width: 38px;
    height: 38px;
}
.birthday-text {
    margin-right: 25px;
    font-size: 26px;
    height: 80px;
    width: 160px;
    line-height: 80px;
    text-align: right;
}
.saveInfo {
    font-size: 36px;
    text-align: center;
    margin-top: 60px;
    margin-bottom: 60px;
    margin-left: 75px;
    margin-right: 75px;
    padding-top: 20px;
    padding-bottom: 20px;
    border-width: 1px;
    border-style: solid;
    color: #ffffff;
    border-color: #dddddd;
    background-color: rgb(226, 35, 35);
    border-radius: 10px;
}
.saveInfo:active {
    background-color: rgb(112, 0, 16);
}
</style>
