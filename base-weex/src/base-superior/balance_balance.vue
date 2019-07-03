<template>
    <div class='wrapper'>
        <navigation title = '我的账户' />
        <!-- top info -->
        <div>
            <!-- 账户余额 -->
            <div class="account-info">
                <image class="shadowImg" :src='shadowImg' />
                <text style="font-size: 30px;margin-top: 60px;color: #333333;">账户余额(元)</text>
                <text class="balance">{{spCardBalance}}</text>
                <div class="pay-div">
                    <text class="pay-text" @click="payClick(1)">充值</text>
                    <text class="setPwd-text" @click="payClick(2)">{{payPwdString}}</text>
                </div>
            </div>
            <!-- 交易明细(-年-月) -->
            <div class="trade-info">
                <div>
                    <text class="title-text">交易明细</text>
                </div>
                <div style="margin-right:20px;align-items: center;" @click="dateClick">
                    <text class="year-text-style">{{yearStr}}年</text>
                    <div class="month-bgDiv-style">
                        <div class="month-div-style">
                            <text class="month-text-style">{{monthStr}}</text>
                            <text style="color:#333333;font-size:18px;margin-bottom:2px;">月</text>
                        </div>
                        <image style="width: 18px;height: 9px;margin-left:5px;" :src=downArrow />
                    </div>
                </div>
            </div>
        </div>
        <!-- 交易明细list -->
        <list class="list">
            <cell v-for="(item, index) in dataList" :key="index" :index="index">
                <div class="cell-bg-div">
                    <div style="margin-right:5px;">
                        <text style="color: #333333;font-size: 30px;margin-bottom:25px;">{{item.opAction}}</text>
                        <div v-if="item.linkedDataId.length > 0 && item.linkedDataType != 'spCard'">
                            <text style="color: #666666;font-size: 24px;" v-if="item.linkedDataType == 'spOrder'">订单号：{{item.linkedDataId}}</text>
                            <text style="color: #666666;font-size: 24px;" v-else-if="item.linkedDataType == 'spAfSale'">售后编号：{{item.linkedDataId}}</text>
                        </div>
                        <text style="color: #666666;font-size: 24px;">{{item.opTime}}</text>
                    </div>
                    <div style="margin-right:30px;">
                        <div v-if="item.opType === 'add'">
                            <text class="income-text-style">+¥{{item.opAmount}}</text>
                        </div>
                        <div v-else-if="item.opType === 'sub'">
                            <text class="spend-text-style">-¥{{item.opAmount}}</text>
                        </div>
                        <div v-else>
                            <text style="font-size: 36px;color: #666666;">{{item.opAmount}}</text>
                        </div>
                    </div>
                </div>
            </cell>
        </list>
    </div>
</template>

<script>
import Fetch from '@/base-superior/Fetch.js'
import navigation from "@/base-superior/components/NavigationBar.vue";

const modal = weex.requireModule("modal");
const storage = weex.requireModule("storage");
const picker = weex.requireModule('picker')

export default {
    components: {navigation},
    data() {
        return {
            redeemCodeChannel: {},
            shadowImg: "/web/assets/sup/sup_accountBalance_balanceTopShadow.png",
            downArrow: "/web/assets/sup/sup_accountBalance_balanceDownArrow.png",
            spCardBalance: "0.00",
            yearStr: "",
            monthStr: "",
            dateValue: '',
            currentDate: '',
            defaultDate: '',
            dataList: [
                // {desc:'订单号：4858238409523455234'+'\n'+'2018-09-23 09:58:23', title:'优选订单支出', custome:'-100.00'},
                // {desc:'2018-09-23 09:58:23', title:'企业福利', custome:'100.00'},
                // {desc:'2019-01-01 09:58:23', title:'部门福利', custome:'0.00'}
            ],
            payPwdString: "设置支付密码",
            hasPassword:'false',
            opened:'false'
        };
    },
    created() {
        // 获取当前年月
        var that = this;
        var myDate = new Date()
        var year = myDate.getFullYear()
        var month = myDate.getMonth()
        var day = myDate.getDate()

        that.yearStr = year.toString()
        that.monthStr = (month+1).toString()

        that.dateValue = that.yearStr + '-' + that.monthStr
        that.currentDate = that.yearStr + '-' + that.monthStr + '-' + day.toString()
        that.defaultDate = that.yearStr + '-' + that.monthStr + '-' + day.toString()
        console.log('当前年月：'+that.dateValue)
        console.log('当前年月日：'+that.currentDate)
        
        // 收到设置支付密码的通知
        var pwdChannel = new BroadcastChannel('submitPayPwdSuccess');
        pwdChannel.onmessage = function (event) {
            that.payPwdString = '支付密码已开启'
            that.hasPassword = 'true'
            that.opened = 'true'
        }
        // 收到支付密码开启与关闭通知
        var opendChannel = new BroadcastChannel('openOrCloseSuccess')
        opendChannel.onmessage = function (event) {
            console.log('收到支付密码开启与关闭通知',event.data)
            if (event.data == 'open') {
                that.hasPassword = 'true'
                that.opened = 'true'
                that.payPwdString = '支付密码已开启'
            } else if (event.data == 'close') {
                that.hasPassword = 'true'
                that.opened = 'false'
                that.payPwdString = '支付密码已关闭'
            }
        }

        // 收到充值成功的通知
        that.redeemCodeChannel =  new BroadcastChannel('redeemCodeSuccess');
        console.log(new Date().toString()+ that.redeemCodeChannel.name);
        that.redeemCodeChannel.onmessage = function (event) {
            if (event.data == 'redeemCodeSuccess') {
                //更新账户余额信息
                that.loadAccountInfoData();
            }
        }
        //加载账户余额信息
        that.loadAccountInfoData();
    },
    methods: {
        //加载账户余额信息
        loadAccountInfoData: function () {
            var self = this;
            var param = {};
            Fetch.post(
                "buyer/getUserCardInfo.json",
                param,
                function(jsonString) {
                    var result = JSON.parse(jsonString);
                    if (result.op_flag === "success") {
                        self.spCardBalance = result.spCardBalance;
                        self.hasPassword = result.hasPassword;
                        self.opened = result.opened;
                        if (self.hasPassword == 'true' && self.opened == 'true') {
                            self.payPwdString = '支付密码已开启'
                        } else if (self.hasPassword == 'true' && self.opened == 'false') {
                            self.payPwdString = '支付密码已关闭'
                        } else {
                            self.payPwdString = '设置支付密码'
                        }
                    } else {
                        modal.toast({
                            message: result.info,
                            duration: 1.0
                        });
                    }
                },
                function(err) {
                    console.log('err:'+err);
                }
            );

            self.getTradeDataList()
        },
        getTradeDataList: function () {
            var that = this;
            var param = {cardType:'1', currentPage:'1', yearMonthType:"month", yearMonth:that.dateValue};
            Fetch.post(
                "buyer/getUserCardChLogList.json",
                param,
                function(jsonString) {
                    var result = JSON.parse(jsonString);
                    if (result.op_flag === "success") {
                        let arrayList = result.objs;
                        if(arrayList.length == 0){
                          modal.toast({message:"暂无交易明细数据",
                                       duration: 1.0});
                        }
                        //接收返回的一个数组
                        that.dataList = arrayList;
                    } else {
                        modal.toast({
                            message: result.info,
                            duration: 1.0
                        });
                    }
                }, function(err) {
                    modal.toast({
                        message: err,
                        duration: 1.0
                    })
                }
            );
        },
        // 跳转：充值 1，设置支付密码 2
        payClick: function(params) {
            var title = "";
            var url = '';
            switch (params) {
                case 1:
                {
                    title = "充值";
                    url = 'balance_redeemCode.html'
                }
                    break;
                case 2:
                {
                    if (this.hasPassword == 'true' && this.opened == 'true') {
                        //this.payPwdString = '支付密码已开启'
                        url = 'balance_pwdOpen.html'
                        storage.setItem('isOpenPwd', 'open', event =>{

                        })
                    } else if (this.hasPassword == 'true' && this.opened == 'false') {
                        //this.payPwdString = '支付密码已关闭'
                        url = 'balance_pwdOpen.html'
                        storage.setItem('isOpenPwd', 'close', event =>{

                        })
                    } else {
                        //this.payPwdString = '设置支付密码'
                        url = 'balance_setPayPwd.html'
                    }
                    title = "设置支付密码";
                }
                    break;
            }
            navigation.push({url:url, title:title}, event =>{

            });
        },
        // 日期点击
        dateClick: function() {
            console.log("选择日期")
            var that = this
            picker.pickDate({
                value: that.currentDate,
                max: that.defaultDate
            }, event => {
                if (event.result === 'success') {
                    that.currentDate = event.data
                    console.log('选择的日期为：'+that.currentDate)

                    // 字符串分割
                    var dateStrs = new Array();
                    dateStrs = that.currentDate.split("-"); //字符分割 
                    console.log(dateStrs);
                    that.dateValue = dateStrs[0]+'-'+dateStrs[1]
                    that.yearStr = dateStrs[0]
                    that.monthStr = dateStrs[1]
                    that.getTradeDataList()
                }
            })
        }
    }
};
</script>

<style scoped>
.wrapper {
    width: 750px;
    align-items: center;
    background-color: white;
}
.account-info {
    width: 750px;
    height: 440px;
    padding-top: 23px;
    /* padding-left: 20px;
    padding-right: 20px; */
    padding-bottom: 7px;
    align-items: center;
}
.shadowImg {
    position: absolute;
    width: 750px;
    height: 410px;
    background-color: white;
}
.balance {
    font-size: 60px;
    font-weight: bold;
    margin-top: 15px;
    color: #333333;
}
.pay-div {
    flex-direction: row;
    margin-top: 55px;
}
.pay-text {
    width: 210px;
    height: 60px;
    text-align: center;
    line-height: 56px;
    border-radius: 10px;
    font-size: 26px;
    color: #ffffff;
    border-width: 2px;
    border-color: #ea333d;
    background-color: #ea333d;
}
.setPwd-text {
    width: 210px;
    height: 60px;
    text-align: center;
    margin-left: 40px;
    line-height: 56px;
    border-radius: 10px;
    font-size: 26px;
    color: #ea333d;
    border-width: 2px;
    border-color: #ea333d;
}
.trade-info {
    flex-direction: row;
    align-items: center;
    justify-content: space-between;
    width: 750px;
    height: 78px;
    background-color: #f8f8f8;
}
.title-text {
    margin-left: 20px;
    padding-left: 10px;
    line-height: 40px;
    height: 40px;
    border-left-width: 6px;
    border-style: solid;
    border-color: #ff0033;
    font-size: 26px;
    color: #333333;
}
.year-text-style {
    font-size: 18px;
    color: #999999;
}
.month-bgDiv-style {
    flex-direction: row;
    align-items: center;
}
.month-div-style {
    flex-direction: row;
    align-items: flex-end;
}
.month-text-style {
    font-size: 30px;
    color: #333333;
    margin-right: 2px;
}
.list {
    width: 750px;
    flex: 1;
}
.cell-bg-div {
    flex-direction: row;
    justify-content: space-between;
    align-items: center;
    padding-left:30px;
    padding-top: 25px;
    padding-bottom: 30px;
    border-bottom-width: 1px;
    border-bottom-color: #e8e8e8;
}
.income-text-style {
    font-size: 36px;
    color: #67cc23;
}
.spend-text-style {
    font-size: 36px;
    color: #ea333d;
}
</style>
