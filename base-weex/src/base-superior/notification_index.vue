<template>
    <div class="wrapper">
        <navigation title="消息"/>
        <list class="message-list">
            <refresh
                class="refreshAndLoading"
                :display="refresh ? 'show' : 'hide'"
                @refresh="updateMessage"
            >
                <text class="indicator-text" v-if="!refresh">刷新消息列表</text>
                <loading-indicator class="indicator" style="margin-top: 20px;"></loading-indicator>
            </refresh>
            <cell>
                <div class="list-header"></div>
            </cell>
            <cell
                class="message-container"
                v-for="(msg,index) in msgs"
                :key="index"
                @click="clickEvent(msg)"
            >
                <div class="message-box">
                    <text class="message-title">{{msg.title}}</text>
                    <text class="message-content" style="lines: 1;">{{msg.content}}</text>
                    <text class="message-time">{{msg.data}}</text>
                    <div class="message-no-read" v-if="msg.status == 'false'"></div>
                </div>
            </cell>
            <loading
                class="refreshAndLoading"
                :display="loadingMore ? 'show' : 'hide'"
                @loading="loadMessage"
            >
                <text class="indicator-text" v-if="!loadingMore">{{loadingPrompt}}</text>
                <loading-indicator class="indicator" style="margin-bottom: 20px;"></loading-indicator>
            </loading>
        </list>
        <wxc-loading :show="loading" need-mask="false" type="default"></wxc-loading>
    </div>
</template>
<script>
import navigation from "@/base-superior/components/NavigationBar.vue";
import Fetch from "@/base-superior/Fetch.js";
import Define from "@/base-superior/Define.js";
import { WxcResult, WxcLoading, WxcMask } from "weex-ui";
const storage = weex.requireModule("storage");
const modal = weex.requireModule("modal");
export default {
    components: { navigation, WxcResult, WxcLoading },
    data() {
        return {
            loadingMore: false,
            refresh: false,
            loadingPrompt: "加载更多消息",
            loading: false,
            MSG_TYPE: {
                MSG_TYPE_NOTHING: 0 /** 文本消息 */,
                MSG_TYPE_GOOD: 1 /** 商品 */,
                MSG_TYPE_ACTIV_COUPON: 2 /** 领劵运营 */,
                MSG_TYPE_ACTIV_FULL: 3 /** 满减 */,
                MSG_TYPE_ACTIV_LIMIT: 4 /** 限时购 */,
                MSG_TYPE_ACTIV_RED: 5 /** 红包运营 */,
                MSG_TYPE_LOGIST_SIGN: 6 /** 物流签收 */,
                MSG_TYPE_LOGIST_SEND: 7 /** 物流发货 */,
                MSG_TYPE_PAY: 8 /** 支付提醒 */,
                MSG_TYPE_COUPON_SEND: 9 /** 优惠券发放提醒 */,
                MSG_TYPE_COUPON_END: 10 /** 优惠券到期提醒 */,
                MSG_TYPE_REFOUND: 11 /** 退款提醒 */,
                MSG_TYPE_LIMIT_SHOPPING: 12 /** 限时购抢购提醒 */
            },
            msgs: [],
            totalMsg: 5,
            pageIndex: 1
        };
    },
    created() {
        this.updateMessage();
    },
    methods: {
        loadMessage: function() {
            var self = this;
            self.loadingMore = true;
            if (this.msgs.length >= this.totalMsg) {
                this.loadingPrompt = "已加载全部消息";
                setTimeout(function() {
                    self.loadingMore = false;
                }, 1000);
                return 
            }
            this.message(this.pageIndex + 1, data => {
                data.forEach(element => {
                    self.msgs.push(element);
                });
                self.pageIndex++;
            });
        },
        updateMessage: function() {
            var self = this;
            self.refresh = true;
            this.message(1, data => {
                self.pageIndex = 1;
                self.msgs = data;
                if (self.msgs.length < 16) {
                    self.loadingPrompt = "已加载全部消息";
                }
            });
        },
        message: function(page, callback) {
            var param = { currentPage: String(page) };
            var self = this;
            Fetch.post(
                "superior/userMessageList.json",
                param,
                function(respone) {
                    var result = JSON.parse(respone);
                    self.totalMsg = result.allCount;
                    if (result.op_flag == "success") {
                        callback(result.messageList);
                    } else {
                        modal.toast({ message: result.info });
                    }
                    if (page === 1) {
                        self.refresh = false;
                    } else {
                        self.loadingMore = false;                        
                    }
                },
                function(err) {
                    modal.toast({ message: err });
                    self.loadingMore = false;
                    self.refresh = false;
                }
            );
        },
        clickEvent: function(msg) {
            this.markedRead(msg);
            this.gotoPage(msg);
        },
        gotoPage: function(msg) {
            var data = {
                key: null,
                value: null,
                url: null,
                title: null
            };
            switch (Number(msg.type)) {
                case this.MSG_TYPE.MSG_TYPE_NOTHING:
                    /** 文本消息 */
                    return;
                    break;
                case this.MSG_TYPE.MSG_TYPE_GOOD:
                    /** 商品 */
                    data.key = Define.kSuperior_goods_id;
                    data.value = msg.linkedId;
                    data.url = "goods_goodsDetail.html";
                    data.title = "商品详情";
                    break;
                case this.MSG_TYPE.MSG_TYPE_ACTIV_COUPON:
                    /** 领劵运营 */
                    data.key = Define.kHomePage_Activity_ReceiveRedEnvelope;
                    data.value = msg.linkedId;
                    data.url = "activity_receiveRedEnvelope.html";
                    data.title = "领取红包";
                    break;
                case this.MSG_TYPE.MSG_TYPE_ACTIV_FULL:
                    /** 满减 */
                    data.key = Define.kSubjectId;
                    data.value = msg.linkedId;
                    data.url = "active_subject.html";
                    data.title = "活动主题";
                    break;
                case this.MSG_TYPE.MSG_TYPE_ACTIV_RED:
                    /** 红包运营 */
                    this.activeRedOperation(msg.linkedId);
                    return;
                    break;
                case this.MSG_TYPE.MSG_TYPE_LOGIST_SIGN:
                /** 物流签收 */
                case this.MSG_TYPE.MSG_TYPE_LOGIST_SEND:
                    /** 物流发货 */
                    data.key = "Order_logisticCode";
                    data.value = msg.linkedId;
                    data.url = "order_logistic_detail.html";
                    data.title = "物流轨迹";
                    break;
                case this.MSG_TYPE.MSG_TYPE_PAY:
                /** 支付提醒 */
                case this.MSG_TYPE.MSG_TYPE_REFOUND:
                    /** 退款提醒 */
                    data.key = "OrderDetail_OrderId";
                    data.value = msg.linkedId;
                    data.url = "order_orderDetail.html";
                    data.title = "订单详情";
                    break;
                case this.MSG_TYPE.MSG_TYPE_COUPON_SEND:
                /** 优惠券发放提醒 */
                case this.MSG_TYPE.MSG_TYPE_COUPON_END:
                    /** 优惠券到期提醒 */
                    data.key = "OrderDetail_OrderId";
                    data.value = msg.linkedId;
                    data.url = "coupon_couponTab.html";
                    data.title = "我的红包";
                    break;
                case this.MSG_TYPE.MSG_TYPE_ACTIV_LIMIT:
                /** 限时购 */
                case this.MSG_TYPE.MSG_TYPE_LIMIT_SHOPPING:
                    /** 限时购抢购提醒 */
                    break;
            }
            if (!data.url) {
                return;
            }
            storage.setItem(data.key, data.value, event => {});
            navigation.push(
                {
                    url: data.url,
                    title: data.title
                },
                event => {}
            );
        },
        markedRead: function(msg) {
            if (msg.status == "true") {
                return;
            }
            var param = { messageId: msg.messageId };
            Fetch.post(
                "superior/changMessageRead.json",
                param,
                function(respone) {
                    var result = JSON.parse(respone);
                    msg.status = "true";
                },
                function(err) {
                    modal.toast({ message: err });
                }
            );
        },
        //红包运营跳转
        activeRedOperation: function(linkedId) {
            console.log("superiorRedPacketActivity");
            const self = this;
            this.loading = true;
            var param = { activityId: linkedId };
            let url = "superior/superiorRedPacketActivity.json";
            Fetch.post(
                url,
                param,
                function(respone) {
                    self.loading = false;
                    var result = JSON.parse(respone);
                    if (result.op_flag == "success") {
                        let goodsList = result.goodsList;
                        if (goodsList && goodsList.length == 1) {
                            let goodsId = goodsList[0].supGoodsId;

                            storage.setItem(
                                Define.kSuperior_goods_id,
                                goodsId,
                                event => {}
                            );
                            navigation.push(
                                {
                                    url: "goods_goodsDetail.html",
                                    title: "商品详情"
                                },
                                event => {}
                            );
                        } else {
                            //红包主题
                            if (Array.isArray(goodsList)) {
                                storage.setItem(
                                    "RedActiveGoodsList",
                                    JSON.stringify(goodsList),
                                    event => {}
                                );
                                navigation.push(
                                    {
                                        url: "active_subject.html",
                                        title: "活动主题"
                                    },
                                    event => {}
                                );
                            }
                        }
                    } else {
                        modal.toast({ message: result.info });
                    }
                },
                function(err) {
                    self.loading = false;
                    modal.toast({ message: err });
                }
            );
        }
    }
};
</script>
<style scoped>
.wrapper {
    align-items: center;
    background-color: #f5f5f5;
}
.message-list {
    width: 750px;
    flex: 1;
    flex-direction: column;
    border-style: solid;
}
.message-container {
    padding-left: 15px;
    padding-right: 16px;
    padding-bottom: 20px;
}
.message-box {
    background-color: #ffffff;
    padding-left: 28px;
    padding-right: 28px;
    padding-top: 20px;
    padding-bottom: 20px;
    border-radius: 10px;
}
.message-title {
    color: #333333;
    font-size: 30px;
}
.message-content {
    font-size: 28px;
    color: #999999;
    text-overflow: ellipsis; /*超出部分以点号代替*/
}
.message-time {
    font-size: 24px;
    color: #999999;
    margin-top: 4px;
}
.message-no-read {
    width: 16px;
    height: 16px;
    border-radius: 16px;
    background-color: #d0104c;
    position: absolute;
    left: 9px;
    top: 15px;
}
/* 加载刷新 */
.refreshAndLoading {
    width: 750;
    /* display: -ms-flex;
    display: -webkit-flex;
    display: flex; */
    -ms-flex-align: center;
    -webkit-align-items: center;
    -webkit-box-align: center;
    align-items: center;
}
.refresh {
    width: 750;
    height: 140px;
    display: -ms-flex;
    display: -webkit-flex;
    display: flex;
    -ms-flex-align: center;
    -webkit-align-items: center;
    -webkit-box-align: center;
    align-items: center;
}
.indicator-text {
    color: #888888;
    font-size: 30px;
    text-align: center;
}
.indicator {
    height: 40px;
    width: 40px;
    color: #888888;
}
.list-header {
    height: 20px;
}
</style>