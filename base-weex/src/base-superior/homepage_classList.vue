<!-- 优选分类数据  -->
<template>
    <div class="wrapper">
        <list class="in-scroller" alwaysScrollableVertical='true' 
            scroll-direction="vertical" loadmoreoffset="10" 
            @loadmore="loadmore" @scroll="onScroll">
            <refresh class="refresh" @refresh="onrefresh" :display="refreshing ? 'show' : 'hide'" @pullingdown="onpullingdown">
                <text class="indicator-text">{{refreshText}}</text>
                <loading-indicator class="indicator"></loading-indicator>
            </refresh>
            <!-- 热销商品滚动Banner -->
            <cell>
                <slider v-if="topSellers.length>0" class="banner-zone" interval="3000" auto-play="true">
                    <div v-for="item in limitTopSellers" :key="item.goodsId">
                        <image class="banner-image" resize="stretch" :src="item.goodsAdvertisingImg" @click="topSellersAction(item)" />
                    </div>
                    <indicator class="layout1Indicator"></indicator>
                </slider>
            </cell>

            <!-- 二级分类Button -->
            <cell class="button-zone" v-if="topCategory.length>0">
                <div v-for="(item,index) in topCategory" :key='index'>
                    <wxc-pan-item @wxcPanItemPan="wxcPanItemPan" @wxcPanItemClicked="topCategoryAction(item)">
                        <div :class="['button-item', topCategoryStyle]">
                            <image style="width: 100px; height: 85px;" :src='item.categoryBtnImage' />
                            <text class="button-title">{{item.categoryName}}</text>
                        </div>
                    </wxc-pan-item>
                </div>
            </cell>
            <!-- 商品列表 -->
            <cell class="cell" v-for="(item,index) in lists" :key="index" :style="{'background-color': item.class_color&&item.class_color.length>0?item.class_color:'#fffff'}" :ref="'section'+index">
                <!-- 显示头图-->
                <wxc-pan-item @wxcPanItemPan="wxcPanItemPan">
                    <div v-if="item.header_disable=='false'&&item.head_icon.length>0" class="header" @appear="onsectionAppear(index)" @disappear="onsectionDisappear($event,index)">
                        <image style="height:80px;width:750px;" resize="contain" :src="item.head_icon" />
                    </div>
                    <!-- 显示分栏名称 -->
                    <div v-else class="header" @appear="onsectionAppear(index)" @disappear="onsectionDisappear($event,index)">
                        <!-- 商品单列显示时 -->
                        <text style="color:#666666;font-size:40px;font-weight:bold;">{{item.className}}</text>
                    </div>
                </wxc-pan-item>
                <!-- Android的布局方式 -->
                <div v-if="isAndroid" class="content-and">
                    <div v-for="(model,i) in item.goodsList" :key="i">
                        <div v-if="Array.isArray(model)" class="smallcell-group">
                            <div v-for="(submodel,key) in model" :key="key" class="smallcell">
                                <wxc-pan-item @wxcPanItemPan="wxcPanItemPan" @wxcPanItemClicked="cellClick(submodel)">
                                    <image class="smallImg" resize="contain" :src="submodel.goodsImage" />
                                    <div>
                                        <text class="textName">{{submodel.supGoodsName}}</text>
                                        <text class="textDes textDes-height">{{submodel.supGoodsDescribe}}</text>
                                        <div class="text-price">
                                            <text style="font-size: 30px;color: #ff093c">¥</text>
                                            <text style="font-size: 44px;color: #ff093c">{{submodel.storePrice}}</text>
                                        </div>
                                    </div>
                                </wxc-pan-item>
                            </div>
                        </div>
                        <wxc-pan-item v-else @wxcPanItemPan="wxcPanItemPan" @wxcPanItemClicked="cellClick(model)">
                            <div class="bigcell">
                                <image class="bigImg" resize="contain" :src="model.goodsImage" />
                                <div class="textcontent">
                                    <text class="textName" style="width: 370px;lines: 2;text-overflow: ellipsis;margin-top: 20px; ">{{model.supGoodsName}}</text>
                                    <text class="textDes" style="width: 370px;lines: 2;text-overflow: ellipsis;">{{model.supGoodsDescribe}}</text>
                                    <div class="text-price">
                                        <text style="font-size: 30px;color: #ff093c">¥</text>
                                        <text style="font-size: 44px;color: #ff093c">{{model.storePrice}}</text>
                                    </div>
                                </div>
                            </div>
                        </wxc-pan-item>
                    </div>
                </div>
                <!-- iOS、web的布局方式 -->
                <div v-else class="content">
                    <div v-for="(model,i) in item.goodsList" :key="i">
                        <div v-if="(item.layoutType && item.layoutType == 1) || (i == 0 && item.goodsList.length%2 == 1)">
                            <wxc-pan-item @wxcPanItemPan="wxcPanItemPan" @wxcPanItemClicked="cellClick(model)">
                                <div class="bigcell">
                                    <image class="bigImg" resize="contain" :src="model.goodsImage" />
                                    <div class="textcontent">
                                        <text class="textName" style="width: 370px;lines: 2;text-overflow: ellipsis;margin-top: 20px;">{{model.supGoodsName}}</text>
                                        <text class="textDes" style="width: 370px;lines: 2;text-overflow: ellipsis;">{{model.supGoodsDescribe}}</text>
                                        <div class="text-price">
                                            <text style="font-size: 30px;color: #ff093c;">¥</text>
                                            <text style="font-size: 44px;color: #ff093c;">{{model.storePrice}}</text>
                                        </div>
                                    </div>
                                </div>
                            </wxc-pan-item>
                        </div>
                        <div v-else>
                            <div class="smallcell">
                                <wxc-pan-item @wxcPanItemPan="wxcPanItemPan" @wxcPanItemClicked="cellClick(model)">
                                    <image class="smallImg" resize="contain" :src="model.goodsImage" />
                                    <div>
                                        <text class="textName">{{model.supGoodsName}}</text>
                                        <text class="textDes textDes-height">{{model.supGoodsDescribe}}</text>
                                        <div class="text-price">
                                            <text style="font-size: 30px;color: #ff093c">¥</text>
                                            <text style="font-size: 44px;color: #ff093c">{{model.storePrice}}</text>
                                        </div>
                                    </div>
                                </wxc-pan-item>
                            </div>
                        </div>
                    </div>
                </div>
            </cell>
            <cell v-if="lists.length>0" :style="{'background-color':lists[lists.length-1].class_color}">
                <div style="width: 750px;align-items: center;">
                    <text style="padding:30px;color:#666666;font-size:28px;">-- 食品安全和膳食营养是我们的底线 --</text>
                </div>
                <div v-if="topCategory.length==0&&topSellers.length==0&&lists.length<3" style="height:480px"></div>
                <!-- 目的：android全面屏物理键可隐藏和显示 -->
                <div v-if="isAndroid" style="height:100px;"></div>
            </cell>
            <!-- 加载更多 -->
            <!-- <loading v-if="!isBottom" class="loading" @loading="onloading" :display="loadinging ? 'show' : 'hide'">
                <text class="indicator-text">{{loadingText}}</text>
                <loading-indicator class="indicator"></loading-indicator>
            </loading> -->
        </list>
        <!-- 二级分类tab -->
        <tabpage v-if="showTabPage" :floors="sectionTitles" :selectIndex="sectionIndex" @changeSegment="onchangeSegment"></tabpage>
    </div>
</template>

<script>
import Fetch from "@/base-superior/Fetch.js";
import Define from "@/base-superior/Define.js";
import navigation from "@/base-superior/components/NavigationBar.vue";
import tabpage from "../base-superior/homepage_tabpage2.vue";
import { WxcPanItem } from "weex-ui";
const modal = weex.requireModule("modal");
const dom = weex.requireModule("dom");
const storage = weex.requireModule("storage");

export default {
    components: { WxcPanItem, tabpage },
    //定义属性
    props: {
        classId: {
            default: 2
        },
        subPage: {
            type: Boolean,
            //是否作为次级界面显示，即不采用通道交互方式
            default: false
        }
    },
    data() {
        return {
            isAndroid: WXEnvironment.platform === "android",
            refreshing: false,
            refreshText: "下拉刷新",
            isBottom: false,
            loadinging: false,
            loadingText: "",
            topH: navigation.navigationHeight() + 70 + 64, //导航高+一级分类tab高+二级分类高
            showTabPage: false,
            isScoll: false,
            sectionIndex: 0,
            appearSectionIndex: 0,
            sectionTitles: [
                { title: "推荐" },
                { title: "网红青团" },
                { title: "南北干货" }
            ],
            page: 1,
            lists: [],
            topSellers: [],
            topCategory: [],
            topCategoryStyle: "button-item4"
        };
    },
    created() {
        const self = this;
        if (WXEnvironment.platform.toLowerCase() === "web" || self.subPage) {
            this.loadData();
        } else {
            const tabSelectedChannel = new BroadcastChannel("home_TabSelected");
            tabSelectedChannel.onmessage = function(event) {
                // modal.alert({message:'data='+event.data+"id="+self.classId})
                if (event.data == self.classId) {
                    if (self.lists.length == 0) {
                        self.loadData();
                    }
                }
            };
        }
    },
    computed: {
        //计算属性
        limitTopSellers: function() {
            if (this.topSellers.length > 9) {
                return this.topSellers.slice(0, 9);
            } else {
                return this.topSellers;
            }
        }
    },
    methods: {
        //热销商品
        topSellersAction: function(model) {
            console.log("热销：", model);
            if (model.isGiftCard == "true") {
                storage.setItem(
                    "goods_giftVoucher",
                    JSON.stringify({
                        goodsId: model.goodsId,
                        goodsName: model.supGoodsName
                    }),
                    event => {}
                );
                let url = "goods_giftVoucher.html";
                navigation.push(
                    { url: url, title: model.supGoodsName },
                    event => {}
                );
            } else {
                storage.setItem(
                    Define.kSuperior_goods_id,
                    model.goodsId,
                    event => {}
                );
                let url = "goods_goodsDetail.html";
                navigation.push({ url: url, title: "商品详情" }, event => {});
            }
        },
        topCategoryAction: function(item) {
            console.log(item);
            storage.setItem(
                "secondClassItem",
                JSON.stringify(item),
                event => {}
            );
            let url = "homepage_secondClass.html";
            navigation.push(
                { url: url, title: item.categoryName },
                event => {}
            );
        },
        //点击事件
        cellClick: function(model) {
            console.log("商品：" + model.supGoodsName);
            if (model.isGiftCard == "true") {
                storage.setItem(
                    "goods_giftVoucher",
                    JSON.stringify({
                        goodsId: model.goodsId,
                        goodsName: model.supGoodsName
                    }),
                    event => {}
                );
                let url = "goods_giftVoucher.html";
                navigation.push(
                    { url: url, title: model.supGoodsName },
                    event => {}
                );
            } else {
                storage.setItem(
                    Define.kSuperior_goods_id,
                    model.goodsId,
                    event => {}
                );
                let url = "goods_goodsDetail.html";
                navigation.push({ url: url, title: "商品详情" }, event => {});
            }
        },
        //下拉刷新事件
        onrefresh(event) {
            this.refreshing = true;
            this.page = 1;
            this.loadData();
        },
        onpullingdown(event) {},
        //上啦加载
        onloading(event) {
            if (!this.isBottom) {
                this.loadingText = "Loading ...";
                this.loadinging = true;
                setTimeout(() => {
                    this.page = this.page + 1;
                    this.loadData();
                }, 300);
            }
        },
        //section显示和隐藏的事件
        onsectionAppear: function(index) {
            if (this.isScoll) {
                console.log("appearindex:", index);
                this.appearSectionIndex = index;
            }
        },
        onsectionDisappear: function(event, index) {
            if (this.isScoll) {
                let direction = event.direction;
                if (direction == "up") {
                } else {
                    if (index > 0) {
                        this.appearSectionIndex = index - 1;
                    }
                }
            }
        },
        onScroll: function(e) {
            this.isScoll = true;
            const self = this;
            let el = this.$refs.section0 ? this.$refs.section0[0] : null;
            if (!el) return;
            // console.log('element:', el)
            let height = 0;
            if (self.topSellers.length == 0 && self.topCategory.length == 0) {
                height = 64;
            }
            dom.getComponentRect(el, option => {
                // console.log('getComponentRect:', option)
                if (option.size.top <= self.topH - height) {
                    self.showTabPage = true;
                } else {
                    self.showTabPage = false;
                }
            });
            //控制二级分类选中状态
            if (Math.abs(self.sectionIndex - self.appearSectionIndex) <= 1) {
                let seletEl = this.$refs[
                    "section" + this.appearSectionIndex
                ][0];
                dom.getComponentRect(seletEl, option => {
                    if (option.size.top <= self.topH + 20) {
                        self.sectionIndex = self.appearSectionIndex;
                    } else {
                        self.sectionIndex = self.appearSectionIndex - 1;
                    }
                });
            }
        },
        onchangeSegment: function(index) {
            this.sectionIndex = index;
            let el = this.$refs["section" + index][0];
            let offset = this.isAndroid ? -60 - 140 : -60;
            dom.scrollToElement(el, { offset: offset, animated: false });
        },
        //scroll滚动到底部时触发该事件
        loadmore: function(e) {
            const self = this;
            if (WXEnvironment.platform == "android") {
                //取消上拉加载
                // self.onloading(e);
                //loadmore重置函数
                e.target.resetLoadmore();
            }
        },
        wxcPanItemPan(e) {
            const self = this;
            var element = e;
            self.$emit("classListPan", element);
        },
        formatClassButtonData: function(classArray) {
            if (!Array.isArray(classArray)) {
                return [];
            }
            // 750 => 3   4   5
            var list = new Array();
            if (classArray.length < 3) {
                return list;
            }
            var endNode = classArray.length;
            if (classArray.length >= 10) {
                endNode = 10;
            } else if (classArray.length >= 8) {
                endNode = 8;
            } else if (classArray.length >= 6) {
                endNode = 6;
            }
            list = classArray.slice(0, endNode);
            this.topCategoryStyle =
                "button-item" +
                Number(
                    list.length > 5 ? list.length / 2 : list.length
                ).toString();

            return list;
        },
        //加载数据
        loadData: function() {
            var that = this;
            /*
            //之前的接口
            var param = { id: that.classId, currentPage: that.page };
            let uri = "superiorGoods/byClass.json";
            */
            var param = { class_id: that.classId };
            let uri = "superiorGoods/byClass_v2.json";
            console.log("一级分类参数：", JSON.stringify(param));
            Fetch.post(
                uri,
                param,
                function(jsonStr) {
                    setTimeout(() => {
                        that.refreshing = false;
                        that.loadinging = false;
                        that.loadingText = "";
                    }, 1000);
                    var result = JSON.parse(jsonStr);
                    console.log("byClass:" + jsonStr);
                    if (result.op_flag == "success") {
                        that.topCategory = that.formatClassButtonData(
                            result.topCategory
                        );
                        that.topSellers = result.topSellers;
                        if (that.page > 1) {
                            let arrayList = that.androidDataHandle(
                                result.categoryList
                            );
                            if (arrayList.length == 0) {
                                that.isBottom = true;
                            } else {
                                //拼接一个数组
                                that.lists = that.lists.concat(arrayList);
                            }
                        } else {
                            that.isBottom = false;
                            that.lists = that.androidDataHandle(result.categoryList);
                        }
                    } else {
                        let arrayList = result.categoryList;
                        if (arrayList.length == 0) {
                            that.isBottom = true;
                        }
                    }

                    that.sectionTitles = that.lists.map(function(item) {
                        return { title: item.className };
                    });
                },
                function(err) {
                    console.log("err:" + err);
                    modal.toast({ message: err });
                    that.refreshing = false;
                    that.loadinging = false;
                    that.loadingText = "";
                }
            );
        },
        //安卓数据处理
        androidDataHandle: function(array) {
            if (this.isAndroid) {
                if (array.length > 0) {
                    array.forEach(element => {
                        if (
                            element.goodsList &&
                            element.goodsList.length > 0 &&
                            (!element.layoutType || element.layoutType != 1)
                        ) {
                            var tempArray = [];
                            let beginIndex = 0;
                            var model = element.goodsList[0];
                            if (element.goodsList.length % 2 == 1) {
                                tempArray.push(model);
                                beginIndex = 1;
                            }
                            var subArray = [];
                            var group = 0;
                            tempArray.push(subArray);
                            for (
                                let j = beginIndex;
                                j < element.goodsList.length;
                                j++
                            ) {
                                model = element.goodsList[j];
                                //每两个一组
                                if (parseInt((j - beginIndex) / 2) == group) {
                                    subArray.push(model);
                                } else {
                                    group = parseInt((j - beginIndex) / 2);
                                    subArray = [];
                                    tempArray.push(subArray);
                                    subArray.push(model);
                                }
                            }

                            element.goodsList = tempArray;
                        }
                    });
                }
                return array;
            } else {
                /*
                //测试用
                array.forEach(element => {
                    element.layoutType = '0';
                    element.class_color = "#" + Math.floor(Math.random() * 0xffffff).toString(16);
                });
                */
                return array;
            }
        }
    }
};
</script>

<style scoped>
.wrapper {
    width: 750px;
    align-items: center;
    background-color: #ffffff;
}
.in-scroller {
    flex: 1;
    width: 750px;
    flex-direction: column;
}
.content {
    flex-direction: row;
    flex-wrap: wrap;
    padding-top: 10px;
    padding-left: 10px;
    padding-right: 10px;
    justify-content: space-between;
    width: 750px;
}
.content-and {
    padding-top: 10px;
    padding-left: 10px;
    padding-right: 10px;
    width: 750px;
}
.header {
    height: 90px;
    padding-top: 10px;
    flex: 1;
    justify-content: center;
    align-items: center;
}
.bigcell {
    margin-bottom: 5px;
    width: 730px;
    align-items: center;
    flex-direction: row;
    background-color: white;
    border-radius: 10px;
}
.bigImg {
    width: 340px;
    height: 260px;
}
.smallcell-group {
    flex-direction: row;
    justify-content: space-between;
}
.smallcell {
    margin-bottom: 5px;
    background-color: white;
    border-radius: 10px;
}
.smallImg {
    width: 364px;
    height: 240px;
}
.textcontent {
    justify-content: center;
    flex-direction: column;
    margin-left: 10px;
    margin-right: 10px;
}
.text-price {
    flex-direction: row;
    align-items: center;
    margin-left: 20px;
    margin-bottom: 40px;
}
.textName {
    lines: 1;
    margin-bottom: 10px;
    text-overflow: ellipsis;
    font-size: 30px;
    width: 325px;
    margin-left: 20px;
    margin-right: 10px;
    color: #333;
}
.textDes {
    lines: 1;
    text-overflow: ellipsis;
    font-size: 28px;
    width: 325px;
    margin-left: 20px;
    margin-right: 10px;
    color: #999999;
}
.textDes-height{
    height: 40px;
}
.refresh {
    width: 750px;
    height: 140px;
    display: -ms-flex;
    display: -webkit-flex;
    display: flex;
    /* flex-direction: row; */
    /* justify-content: center; */
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
.loading {
    width: 750px;
    height: 180px;
    display: -ms-flex;
    display: -webkit-flex;
    display: flex;
    -ms-flex-align: center;
    -webkit-align-items: center;
    -webkit-box-align: center;
    align-items: center;
}
.banner-zone {
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
.banner-image {
    width: 750px;
    height: 450px;
}
.button-zone {
    flex-direction: row;
    flex-wrap: wrap;
    justify-content: space-between;
    padding-left: 15px;
    padding-right: 15px;
    padding-top: 24px;
    padding-bottom: 24px;
}
.button-item {
    justify-content: center;
    align-items: center;
    margin-top: 5px;
    margin-bottom: 5px;
}
.button-item3 {
    width: 235px;
    height: 120px;
}
.button-item4 {
    width: 175px;
    height: 120px;
}
.button-item5 {
    width: 135px;
    height: 120px;
}
.button-title {
    color: #666666;
    font-size: 26px;
    margin-top: 10px;
    lines: 1;
    text-overflow: ellipsis;
}
</style>