let Define = {
    /**
     * 全局key
     */
    TCM_AESKEY: "taocaimall201609", // AES加密key
    TCM_APPID: "93d8dd933973ee892b505f076d5896e5",
    /**
     * 保存全局Token、手机号
     */
    kToken: 'tcm_token',
    kPhone: 'tcm_phone',
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
    kPayment_Listener: 'Taocaimall_APP_Payment_Notification',//支付结果通知
}

export default Define;