<template>
    <div class="wrapper">
        <list class="scroller">
            <refresh class="refresh" @refresh="onrefresh" @pullingdown="onpullingdown" :display="refreshing ? 'show' : 'hide'">
                <text class="indicator-text">{{ refreshingPrompt }}</text>
                <loading-indicator class="indicator"></loading-indicator>
            </refresh>

            <cell v-for="(ele,index) in requestdata" v-bind:key="index">

                <!-- 单列商品活动区-->
                <div v-if="ele.layOutType == LayouType.SingleRow">
                    <div class="layout5" v-for="(group,index) in  ele.groups" :key="index" style="background-color: #ffffff;">
                        <!-- 单列商品区头部分 显示头图-->
                        <wxc-pan-item v-if="group.groupInfo.image_disable=='false'" @wxcPanItemPan="wxcPanItemPan">
                            <image class="layout5Banner" resize="contain" :src="group.groupInfo.titleImageUrl" />
                        </wxc-pan-item>
                        <!-- 显示分栏名称 -->
                        <wxc-pan-item v-else-if="group.groupInfo.columns_disable=='false'" @wxcPanItemPan="wxcPanItemPan">
                            <text class="layout5Text">{{group.groupInfo.title}}</text>
                        </wxc-pan-item>
                        <!-- 商品列表-->
                        <div v-for="(goods,index) in group.goods" :key="index">
                            <wxc-pan-item @wxcPanItemPan="wxcPanItemPan" @wxcPanItemClicked="click(goods)">
                                <div class="layout5item" style="background-color: white">
                                    <image class="layout5LeftImage" resize="contain" :src="goods.goodsImage" />
                                    <div class="layout5Right">
                                        <!-- 商品名称 -->
                                        <text class="layout5GoodsName" style="font-size:34; marge-top:10px;">{{goods.supGoodsName}}</text>
                                        <text class="layout5GoodsName" style="color:#808080; font-size:28;">{{goods.supGoodsDescribe}}</text>
                                        <div style="flex-direction: row; align-items:center;">
                                            <text class="layout5GoodsName" style="color:#FF0000; font-size:30;  padding-right: 0px;">¥</text>
                                            <text class="layout5GoodsName" style="color:#FF0000; font-size:44;">{{goods.storePrice}}</text>
                                            <!-- 活动信息 -->
                                            <text v-if="goods.subjectActivityPower && goods.subjectActivityPower.length>0" class="layout5ActivityDes">满{{Number(goods.subjectActivityPower[0].fullPrice).toFixed(0)}}减{{Number(goods.subjectActivityPower[0].minusPrice).toFixed(0)}}</text>
                                        </div>
                                    </div>
                                </div>
                            </wxc-pan-item>
                        </div>
                        <!-- 是否启用分栏 -->
                        <div v-if="group.groupInfo.enable_column=='true'" class="goodsBottomZone" @click="entryPage(group.groupInfo)">
                            <text style="color:#666666;font-size:28px;">更多淘菜猫优选{{group.groupInfo.className}}商品 ></text>
                        </div>
                    </div>
                </div>

                <!--左一右二-->
                <div class="layout2" v-if="ele.layOutType == LayouType.OnePlusTwo">
                    <!-- 图片 -->
                    <wxc-pan-item @wxcPanItemPan="wxcPanItemPan" @wxcPanItemClicked="click(ele.images[0])">
                        <image class="layout2LeftImage" resize="stretch" :src="ele.images[0].imageUrl" />
                    </wxc-pan-item>
                    <div class="layout2RightDiv">
                        <wxc-pan-item @wxcPanItemPan="wxcPanItemPan" @wxcPanItemClicked="click(ele.images[1])">
                            <image class="layout2RightImage" resize="stretch" :src="ele.images[1].imageUrl" />
                        </wxc-pan-item>
                        <wxc-pan-item @wxcPanItemPan="wxcPanItemPan" @wxcPanItemClicked="click(ele.images[2])">
                            <image class="layout2RightImage" resize="stretch" :src="ele.images[2].imageUrl" />
                        </wxc-pan-item>
                    </div>
                </div>
                <!-- 活动海报 -->
                <div v-else-if="ele.layOutType == LayouType.Poster" v-for="img in ele.images" v-bind:key="img.id">
                    <wxc-pan-item @wxcPanItemPan="wxcPanItemPan" @wxcPanItemClicked="click(img)">
                        <image class="layout3Item" resize="stretch" :src="img.imageUrl" />
                    </wxc-pan-item>
                </div>
                <!-- 二分海报 -->
                <div class="layout4" v-else-if="ele.layOutType == LayouType.TwoPoster">
                    <div v-for="img in ele.images" v-bind:key="img.id">
                        <wxc-pan-item @wxcPanItemPan="wxcPanItemPan" @wxcPanItemClicked="click(img)">
                            <image class="layout4Image" resize="stretch" :src="img.imageUrl" />
                        </wxc-pan-item>
                    </div>
                </div>

                <!-- 双排商品活动区 -->
                <div class="layout6" v-else-if="ele.layOutType == LayouType.Biserial" v-for="group in ele.groups" v-bind:key="group.groupInfo.title" style="background-color: #ffffff;">
                    <!-- 双排商品区头部分 显示头图-->
                    <wxc-pan-item v-if="group.groupInfo.image_disable=='false'" @wxcPanItemPan="wxcPanItemPan">
                        <image class="layout5Banner" resize="contain" :src="group.groupInfo.titleImageUrl" />
                    </wxc-pan-item>
                    <!-- 显示分栏名称 -->
                    <wxc-pan-item v-else-if="group.groupInfo.columns_disable=='false'&&group.groupInfo.title.length>0" @wxcPanItemPan="wxcPanItemPan">
                        <text class="layout5Text">{{group.groupInfo.title}}</text>
                    </wxc-pan-item>

                    <div class="layout6Item">
                        <div v-for="(goods, i) in group.goods" v-bind:key="goods.goodsId">
                            <wxc-pan-item @wxcPanItemPan="wxcPanItemPan" @wxcPanItemClicked="click(goods)">
                                <div v-if="i == 0 && group.goods.length%2 == 1">
                                    <div class="layout5item" style="background-color: white">
                                        <image class="layout5LeftImage" resize="contain" :src="goods.goodsImage" />
                                        <div class="layout5Right">
                                            <!-- 商品名称 -->
                                            <text class="layout5GoodsName" style="font-size:34; marge-top:10px;">{{goods.supGoodsName}}</text>
                                            <text class="layout5GoodsName" style="color:#808080; font-size:28;">{{goods.supGoodsDescribe}}</text>
                                            <div style="flex-direction: row; align-items:center;">
                                                <text class="layout5GoodsName" style="color:#FF0000; font-size:30;  padding-right: 0px;">¥</text>
                                                <text class="layout5GoodsName" style="color:#FF0000; font-size:44;">{{goods.storePrice}}</text>
                                                <!-- 活动信息 -->
                                                <text v-if="goods.subjectActivityPower && goods.subjectActivityPower.length>0" class="layout5ActivityDes">满{{Number(goods.subjectActivityPower[0].fullPrice).toFixed(0)}}减{{Number(goods.subjectActivityPower[0].minusPrice).toFixed(0)}}</text>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div  v-else class="layout6GoodsItem">
                                    <image class="layout5LeftImage" resize="contain" :src="goods.goodsImage" />
                                    <div style="margin-left:15px;margin-top:20px; ">
                                        <!-- 商品名称 -->
                                        <text class="layout5GoodsName" style="font-size:34;">{{goods.supGoodsName}}</text>
                                        <text class="layout5GoodsName" style="color: #808080; font-size:28;">{{goods.supGoodsDescribe}}</text>
                                        <div style="flex-direction: row; align-items: flex-end;">
                                            <text class="layout5GoodsName" style="color:#FF0000; font-size:30;  padding-right: 0px;">¥</text>
                                            <text class="layout5GoodsName" style="color:#FF0000; font-size:44;">{{goods.storePrice}}</text>
                                            <!-- 活动信息 -->
                                            <text v-if="goods.subjectActivityPower.length>0" class="layout5ActivityDes">满{{Number(goods.subjectActivityPower[0].fullPrice).toFixed(0)}}减{{Number(goods.subjectActivityPower[0].minusPrice).toFixed(0)}}</text>
                                        </div>
                                    </div>
                                </div>
                            </wxc-pan-item>
                        </div>
                    </div>
                    <!-- 是否启用分栏 -->
                    <div v-if="group.groupInfo.enable_column=='true'" class="goodsBottomZone" @click="entryPage(group.groupInfo)">
                        <text style="color:#666666;font-size:28px;">更多淘菜猫优选{{group.groupInfo.className}}商品 ></text>
                    </div>
                </div>
                <!--页面顶部Banner[使用率最低]-->
                <div v-else-if="ele.layOutType == LayouType.Slider">
                    <slider class="layout1" interval="3000" auto-play="true">
                        <div v-for="img in ele.images" v-bind:key="img.id">
                            <image class="image" resize="stretch" :src="img.imageUrl" @click="click(img)" />
                        </div>
                        <indicator class="layout1Indicator"></indicator>
                    </slider>
                </div>
            </cell>
            <cell v-if="requestdata.length>0" class="wrapper">
                <text style="padding:30px;color:#d9d9d9;font-size:28px;">-- 食品安全和膳食营养是我们的底线 --</text>
                <!-- 目的：android全面屏物理键可隐藏和显示 -->
                <div v-if="isAndroid" style="height:100px;width:750px;"></div>
            </cell>
        </list>
        <wxc-loading :show="loading" need-mask=false type="default"></wxc-loading>
    </div>
</template>

<script>
import Fetch from "@/base-superior/Fetch.js";
import Define from "@/base-superior/Define.js";
import navigation from "@/base-superior/components/NavigationBar.vue";
import { WxcPanItem, WxcLoading } from "weex-ui";
const modal = weex.requireModule("modal");
const storage = weex.requireModule("storage");

export default {
    components: { WxcPanItem, WxcLoading },
    data() {
        return {
            loading:false,
            LayouType: {
                Slider: 1, // 轮播图
                OnePlusTwo: 2, // 1+2展示
                Poster: 3, // 单列海报
                TwoPoster: 4, // 二分海报
                SingleRow: 5, // 单列活动区
                Biserial: 6 // 双排活动区
            },
            isAndroid: WXEnvironment.platform === "android",
            requestdata: [],
            response: "",
            refreshing: false,
            refreshingPrompt: ""
        };
    },
    created: function() {
        //加载数据
        var self = this;
        storage.getItem("superior/wechat/layoutConfig.json", event => {
            if (event.result == "success") {
                self.parsePageData(event.data);
            } else {
                self.loadData();
            }
        });
    },
    methods: {
        //加载数据
        loadData: function() {
            var that = this;
            Fetch.get(
                "superior/wechat/layoutConfig.json",
                {},
                function(jsonString) {
                    that.refreshing = false;
                    that.refreshingPrompt = "下拉刷新";
                    that.parsePageData(jsonString);
                },
                function(err) {
                    that.refreshing = false;
                    modal.toast({
                        message: err
                    });
                }
            );
        },
        //点击事件
        click: function(e) {
            switch (e.linkType) {
                case "receiveCouponOpt":
                    {
                        //新加的类型
                        // modal.toast({message:'关注淘菜猫优选公众号进入微信商城即可领取',duration:1.0});
                        console.log(e);
                        storage.setItem(
                            Define.kHomePage_Activity_ReceiveRedEnvelope,
                            e.linkDataId,
                            event => {}
                        );
                        let url = "activity_receiveRedEnvelope.html";
                        navigation.push(
                            { url: url, title: "领取红包" },
                            event => {}
                        );
                    }
                    break;
                case "subjectActivity":
                    {
                        //活动主题Superior.springToActiveView(e)
                        storage.setItem(
                            Define.kSubjectId,
                            e.linkDataId,
                            event => {}
                        );
                        let url = "active_subject.html";
                        navigation.push(
                            { url: url, title: "活动主题" },
                            event => {}
                        );
                    }
                    break;
                case "goodsActivity":
                    {
                        //商品详情Superior.springToGoodsView(e)
                        storage.setItem(
                            Define.kSuperior_goods_id,
                            e.linkDataId,
                            event => {}
                        );
                        let url = "goods_goodsDetail.html";
                        navigation.push(
                            { url: url, title: "商品详情" },
                            event => {}
                        );
                    }
                    break;
                case "imageUrl":
                    {
                        //web界面Superior.springToWebView(e)
                        let title = e.title.length > 0 ? e.title : "商品详情";
                        storage.setItem(
                            "web_url",
                            JSON.stringify({ url: e.linkUrl, title: title }),
                            event => {}
                        );
                        let url = "setting_agreementWeb.html";
                        navigation.push(
                            { url: url, title: title },
                            event => {}
                        );
                    }
                    break;
                case "redRulePacket":
                    /** 红包运营 */
                    var self = this
                    storage.getItem('JESSIONID', event=>{
                        console.log('some' + event);
                        if (event.result == 'success') {
                            self.activeRedOperation(e.linkDataId);
                        } else {
                            navigation.push({url:'login_login.html',title:'登录'}, event =>{});
                        }
                    })
                    return;
                    break;
                default:
                    {
                        if (e.isGiftCard == "true") {
                            storage.setItem(
                                "goods_giftVoucher",
                                JSON.stringify({
                                    goodsId: e.linkDataId,
                                    goodsName: e.supGoodsName
                                }),
                                event => {}
                            );
                            let url = "goods_giftVoucher.html";
                            navigation.push(
                                { url: url, title: e.supGoodsName },
                                event => {}
                            );
                        } else if (e.goodsId.length > 0) {
                            //商品详情
                            storage.setItem(
                                Define.kSuperior_goods_id,
                                e.linkDataId,
                                event => {}
                            );
                            let url = "goods_goodsDetail.html";
                            navigation.push(
                                { url: url, title: "商品详情" },
                                event => {}
                            );
                        }
                    }
                    break;
            }
        },
        onrefresh(event) {
            this.refreshing = true;
            this.refreshingPrompt = "";
            this.loadData();
        },
        onpullingdown(event) {},
        wxcPanItemPan(e) {
            const self = this;
            var element = e;
            self.$emit("classListPan", element);
        },
        entryPage(groupInfo) {
            if (groupInfo.linkUrlType == 2) {
                storage.setItem(
                    "secondClassItem",
                    JSON.stringify({ classId: groupInfo.second_class_id })
                );
                let url = "homepage_secondClass.html";
                navigation.push(
                    { url: url, title: groupInfo.className },
                    event => {}
                );
            } else {
                storage.setItem(
                    "homepage_subPage",
                    JSON.stringify({ classId: groupInfo.linkClassId })
                );
                let url = "homepage_subPage.html";
                navigation.push(
                    { url: url, title: groupInfo.className },
                    event => {}
                );
            }
        },
        parsePageData: function(jsonString) {
            /*
            网络数据模型{
                classList:[{一级分类列表}],
                //数据对象
                objs:[{
                        layOutType: '单列、多列商品布局',
                        groups:[//商品模块
                            {
                                groupInfo:{商品模块信息
                                    color: '#FF0033',//颜色
                                    linkClassId: '4',
                                    second_class_id:'二级分类ID',
                                    linkUrlType: '1->一级分类；2->二级分类',
                                    className: '品类名称',
                                    title:'',
                                    "columns_disable": "是否禁用分栏名称",
                                    "enable_column": "是否启用分栏",
		                            "image_disable": "是否禁用图片标识",
                                },
                                goods:[//商品列表
                                ]
                            },
                        ]
                    },
                ],
            }
            */
            var formatData = this.formatData(jsonString);
            var objs = formatData.objs;
            /*
            var classData = formatData.classList
            objs.forEach(element => {
                if (element.layOutType == this.LayouType.SingleRow || element.layOutType == this.LayouType.Biserial) {
                    element.groups.forEach(group=>{
                        group.groupInfo.color = '#' + Math.floor(Math.random() * 0xFFFFFF).toString(16)
                        let index = Math.ceil(Math.random() *(classData.length - 2)) + 1
                        var theClass = classData[index]
                        group.groupInfo.className = theClass.className
                        group.groupInfo.linkClassId = theClass.id
                    })
                }
            });*/
            this.requestdata = objs;
        },
        formatData: function(jsonString) {
            if (typeof jsonString == "string") {
                // modal.toast({message: 'String'})
                try {
                    var data = JSON.parse(jsonString);
                    return data;
                } catch (e) {
                    return jsonString;
                }
            } else {
                return jsonString;
            }
        },
        //红包运营跳转
        activeRedOperation:function(linkedId){
            console.log('superiorRedPacketActivity')
            const self = this;
            this.loading = true;
            var param = { activityId: linkedId };
            let url = "superior/superiorRedPacketActivity.json";
            Fetch.post(url,param,function(respone) {
                self.loading = false;
                var result = JSON.parse(respone);
                if(result.op_flag == "success"){
                    let goodsList = result.goodsList
                    if(goodsList&&goodsList.length==1){
                        let goodsId = goodsList[0].supGoodsId

                        storage.setItem(Define.kSuperior_goods_id, goodsId, event => {});
                        navigation.push({url: "goods_goodsDetail.html",title: "商品详情"},event => {});

                    }else{
                        //红包主题
                        if(Array.isArray(goodsList)){
                            storage.setItem("RedActiveGoodsList", JSON.stringify(goodsList), event => {});
                            navigation.push({url: "active_subject.html",title: "活动主题"},event => {});
                        }
                        
                    }
                }else{
                     modal.toast({ message: result.info })
                }
            },function(err) {
                 self.loading = false;
                modal.toast({ message: err });
            });
        },
    }
};
</script>

<style scoped>
.wrapper {
    align-items: center;
    background-color: #ffffff;
}
.scroller {
    width: 750px;
    flex: 1;
    flex-direction: column;

    border-style: solid;
}
.layout1 {
    margin-top: 2px;
    height: 450px;
}
.layout1Indicator {
    width: 730px;
    height: 30px;
    item-color: #808080;
    item-selected-color: #ffffff;
    item-size: 15px;
    position: absolute;
    bottom: 30px;
}
.image {
    width: 750px;
    height: 450px;
}
.layout2 {
    flex-direction: row;
    margin-top: 12px;
    margin-left: 10px;
    height: 400px;
}
.layout2LeftImage {
    width: 360px;
    height: 400px;
}
.layout2RightDiv {
    justify-content: space-between;
    left: 10;
    width: 360px;
}
.layout2RightImage {
    width: 360px;
    height: 195px;
}

.layout3Item {
    margin-left: 10px;
    margin-top: 12px;
    width: 730px;
    height: 280px;
}
.layout4 {
    margin-left: 10px;
    width: 730;
    flex: 1;
    flex-direction: row;
    flex-wrap: wrap;
    justify-content: space-between;
}
.layout4Image {
    margin-top: 12px;
    width: 360px;
    height: 398px;
}
.layout5 {
    padding-left: 10px;
    padding-top: 12px;
    padding-right: 10px;
    padding-bottom: 12px;
}
.layout5-Banner {
    padding-top: 12px;
    padding-bottom: 12px;
    align-items: center;
}
.layout5Banner {
    width: 730px;
    height: 140px;
}
.layout5Text {
    width: 730px;
    height: 140px;
    font-size: 46px;
    color: #333333;
    text-align: center;
    line-height: 140px;
}
.layout5item {
    flex-direction: row;
    margin-top: 10px;
    width: 730px;
    height: 240px;
}
.layout5LeftImage {
    width: 354px;
    height: 240px;
}
.layout5Right {
    width: 376px;
    margin-right: 20px;
    background-color: #ffffff;
    justify-content: center;
}

.layout5GoodsName1 {
    padding-right: 10px;
    lines: 100;
}
.layout5ActivityDes {
    margin-left: 10px;
    border-radius: 6px;
    border-width: 1px;
    border-color: #ea3323;
    color: #ea3323;
    background-color: #ffe3e1;
    padding-left: 5px;
    padding-right: 5px;
    font-size: 18px;
}
.layout6 {
    padding-left: 10px;
    padding-top: 12px;
    padding-right: 10px;
    padding-bottom: 12px;
}
.layout6Item {
    width: 730px;
    flex: 1;
    flex-direction: row;
    flex-wrap: wrap;
    justify-content: space-between;
    /* border-width: 1px; */
}
.layout6GoodsItem {
    background-color: #ffffff;
    margin-top: 10px;
    height: 480px;
    width: 360px;
    border-width: 1px;
    border-style: solid;
    border-color: whitesmoke;
}
.goodsBottomZone {
    height: 50px;
    margin-top: 10px;
    /* background-color: white; */
    /* width: 730px; */
    align-items: center;
    justify-content: center;
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
    margin-top: 16px;
    height: 40px;
    width: 40px;
    color: #888888;
}
</style>
