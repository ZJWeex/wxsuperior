let Define = {
    APP_NAME: 'superior', //优选APP
    /**
     * 全局key
     */
    TCM_AESKEY: "taocaimall201609", // AES加密key
    TCM_APPID: "93d8dd933973ee892b505f076d5896e5",
    /**
     * 保存全局Token、手机号、是否微信登录（消费者中用到）
     */
    kToken: 'tcm_token',
    kPhone: 'tcm_phone',
    kWechat: 'tcm_Wechat',
    /**
     * 保存登录后首次进入weex（消费者中用到）
     */
    kNormalLogin: 'tcm_normalLogin',
    kNative: 'native', //从消费者进入主题、商品详情
    /**
     * 频道名称定义
     */

    /**
     * 购物车数据缓存字段
     */
    kLocal_Cart: 'LocalStorage_CartData', //本地购物车存储字段
    /**
     * 用于跨界面传参，定义统一键值
     * 全局常量命名以k开头
     */
    kSuperior_goods_id: 'superior_goods_id', //优选商品id
    kSubjectId: 'superior_subjectId', //优选主题id
    kGoodsDetail_Cart: 'Goods_Detail_Cart', //商品详情到购物车
    kPayment_Listener: 'Taocaimall_APP_Payment_Notification', //支付结果通知
    kHomePage_Activity_ReceiveRedEnvelope: 'kHomePage_Activity_ReceiveRedEnvelope', //领取红包活动

    kGatherData: 'GatherDataKey', //凑单数据key


    /*
    Promise封装storage
    用法：
        Define.getItem('key')
        .then(ret =>{
            
        })
    */
    getItem: function(key) {
        const storage = weex.requireModule("storage");
        return new Promise(function(resolve, reject) {
            try {
                storage.getItem(key, e => {
                    if (e.result === 'success' && e.data != 'undefined') {
                        resolve(e);
                    } else {
                        console.log('Promise获取本地数据失败')
                        reject(e);
                    }
                });
            } catch (e) {
                console.log('获取本地数据异常')
                let event = {
                    result: 'fail',
                }
                reject(event);
            }
        });
    },
    setItem: function(key, value) {
        const storage = weex.requireModule("storage");
        return new Promise(function(resolve, reject) {
            try {
                storage.setItem(key, value, e => {
                    if (e.result === 'success') {
                        resolve(e);
                    } else {
                        reject(e);
                    }
                });
            } catch (e) {
                let event = {
                    result: 'fail',
                }
                reject(event);
            }
        });
    },
    removeItem: function(key) {
        const storage = weex.requireModule("storage");
        return new Promise(function(resolve, reject) {
            try {
                storage.removeItem(key, e => {
                    if (e.result === 'success') {
                        resolve(e);
                    } else {
                        reject(e);
                    }
                });
            } catch (e) {
                let event = {
                    result: 'fail',
                }
                reject(event);
            }
        });
    },
}


export default Define;