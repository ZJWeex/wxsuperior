import Define from "@/base-superior/Define.js";
import DB from "../base-superior/shopping_cartdb.js"
import Fetch from "@/base-superior/Fetch.js";

const storage = weex.requireModule("storage");
const modal = weex.requireModule("modal");

export default {
    //自动登录
    autoLogin() {
        const self = this;
        storage.getItem(Define.kWechat, wechat => {
            var wechat = wechat.data;
            storage.getItem(Define.kToken, event => {
                storage.getItem(Define.kPhone, ret => {
                    if (event.data != 'undefined' && ret.data != 'undefined') {
                        var token = event.data;
                        var phoneNumber = ret.data;
                        var url = 'appLongin.json'
                        var drivice = ''
                        if (weex.config.env.appName === Define.APP_NAME) {
                            drivice = drivice + '_' + WXEnvironment.platform
                        } else {
                            drivice = WXEnvironment.platform.toLowerCase()
                        }

                        var param = { token: token, username: phoneNumber, drivice: drivice, };
                        if (wechat != 'undefined') {
                            param.isWechat = wechat
                            console.log(param)
                        }

                        Fetch.post(url, param, function(respone) {
                            var result = JSON.parse(respone)
                                // modal.alert({ message: "走到这里了:" + respone })

                            if (result.op_flag == 'success') {
                                self.loginSuccess(result, phoneNumber, callback => {});
                            } else {
                                if (result.info.indexOf('没有登录') != -1) {

                                }
                                self.loginOut(callback => {});
                            }
                            console.log(url)
                            console.log(respone)
                        }, function(err) {
                            modal.toast({ message: err });
                            console.log(url)
                            console.log(err);
                        })
                    }
                })
            });
        });

    },
    //登录成功后的处理
    loginSuccess(result, phoneNumber, callback) {
        //保存用户信息
        storage.setItem(Define.kToken, result.token, event => {});
        //保存手机号
        storage.setItem(Define.kPhone, phoneNumber)

        storage.setItem('JESSIONID', result.sessionid)
        const loginChannel = new BroadcastChannel("login");
        loginChannel.postMessage("login");

        callback();
    },

    //退出登录的处理
    loginOut(callback) {
        //删除用户信息token
        storage.removeItem(Define.kToken, event => {})
        //置空sessionid
        storage.removeItem('JESSIONID', event => {
                if (event.result == 'success') {
                    const logoutChannel = new BroadcastChannel("login");
                    logoutChannel.postMessage("logout");
                }
            })
        //清空本地购物车数据库
        storage.removeItem(Define.kLocal_Cart, event => {
            DB.postBadgeNotification();
        })

        callback();
    },
}