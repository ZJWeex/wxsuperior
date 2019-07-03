<template>
    <div class='wrapper' @viewappear="viewappear">
        <navigationSearch title=""
                        :showInput='true'
                        right-text='搜索'
                        :theInputValue='inputString'
                        @wxcMinibarRightButtonClicked='wxcMinibarRightButtonClicked'
                        @wxcMinibarMiddleInputChanged='wxcMinibarMiddleInputChanged'
                        @wxcMinibarCancelInputClick='wxcMinibarCancelInputClick'
                        @wxcMinibarMiddleKeyboardShowOrHide='wxcMinibarMiddleKeyboardShowOrHide'
                        @wxcMinibarMiddleInputReturnKeyClick='wxcMinibarMiddleInputReturnKeyClick'>
        </navigationSearch>
        <list class="list" @scroll='scrollTheList' @scrollstart='scrollstart'>
            <cell class="border-cell" :ref="'floor-'+'border-cell'"></cell>
            <cell v-if="hotSearchList.length > 0 && searchClick == false && isKeywordsThinking == false">
                <div class="search-record-bg">
                    <div class="record-top">
                        <div style="flex-direction: row; align-items: center;">
                            <image style="width: 27px; height: 34px;" src="/web/assets/sup/sup_homeSearch_hot.png"/>
                            <text style="color:#333333; font-size:32px; padding-left:10px; font-weight: bold;">热门搜索</text>
                        </div>
                    </div>
                    <div class="record-label">
                        <text v-for="(label, index) in hotSearchList" :key="index" class="label-text" @click='hotLabelClick(label, index)'>{{label}}</text>
                    </div>
                </div>
            </cell>
            <cell v-if="searchClick == false && isKeywordsThinking == false">
                <div class="search-record-bg">
                    <div class="record-top">
                        <div style="flex-direction: row; align-items: center;">
                            <image style="width: 32px; height: 32px;" src="/web/assets/sup/sup_homeSearch_history.png"/>
                            <text style="color:#333333; font-size:32px; padding-left:10px; font-weight: bold;">历史搜索</text>
                        </div>
                        <image style="width: 36px; height: 36px;" src="/web/assets/sup/sup_homeSearch_deleteHistory.png" @click="clearHistoryRecord"/>
                    </div>
                    <div v-if="record_lables.length > 0" class="record-label">
                        <text v-for="(label, index) in record_lables" :key="index" class="label-text" @click='labelClick(label, index)'>{{label}}</text>
                    </div>
                    <div v-else-if="record_lables.length <= 0" class="record-label-no">
                        <text style="color:#999999; font-size:28px; padding-left:10px; padding-right:10px; text-align: center; flex:1;">暂无搜索记录</text>
                    </div>
                </div>
            </cell>
            <cell v-else-if="searchResultList.length <= 0 && searchClick == true && isKeywordsThinking == false">
                <div class="no-result">
                    <image style="width: 267px; height: 296px;" src="/web/assets/sup/sup_homeSearch_noData_cry.png"/>
                    <text style="color:#999999; font-size:28px; padding-top:45px;">哎呀，这里没有你需要商品哦~</text>
                </div>
            </cell>
            <cell v-else-if="searchResultList.length > 0 && searchClick == true && isKeywordsThinking == false">
                <div v-for="(item, i) in searchResultList" :key="i" @click="didSelectGoodsClick(item, i)" class="cell-content">
                    <image style="width:198px; height:134px; background-color:#f0f0f0; margin-left:26px;" :src='item.goodsImgURLs'/>
                    <div style="flex:1; margin-left:10px; margin-right:26px;">
                        <text class="goods-name">{{item.supGoodsName}}</text>
                        <div style="flex-direction: row; justify-content: space-between; align-items: center;">
                            <text class="goods-desc">{{item.supGoodsSpecs}}</text>
                            <div v-if="item.count > 0" style="flex-direction: row;align-items: center;">
                                <div style="width:72px;height:46px;" @click="reduceGoodsCountClick(item)">
                                    <image style="width:46px; height:46px;" src="/web/assets/sup/sup_cart_reduce.png" @click="reduceGoodsCountClick(item)" />
                                </div>
                                <text style="font-size:30px;">{{item.count}}</text>
                                <div style="width:72px;height:46px;" @click="addGoodsCountClick(item)">
                                    <image style="width:46px; height:46px;" src="/web/assets/sup/sup_cart_add.png" @click="addGoodsCountClick(item)" />
                                </div>
                            </div>
                            <div v-else style="flex-direction: row; align-items: center;">
                                <div style="width:72px;height:46px;"></div>
                                <text></text>
                                <div style="width:72px;height:46px;align-items: center;" @click="addActionClick(item)">
                                    <image style="width:46px; height:46px;" resize="contain" src="/web/assets/sup/sup_homeSearch_cartIcon.png" @click="addActionClick(item)"/>
                                </div>
                            </div>
                        </div>
                        <text class="goods-price">¥{{item.supStorePrice}}</text>
                    </div>
                </div>
            </cell>
            <cell v-else>
                <div v-for="(keyword, j) in keywordsThinkingList" :key='j' :index="j" @click="didSelectThinkGoodsClick(keyword, j)" class="search-think">
                    <text style="color:#333333; font-size:32px;">{{keyword.superiorName}}</text>
                </div>
            </cell>
            <cell v-if="commendGoodsList.length > 0 && isKeywordsThinking == false">
                <text style="color:#333333; font-size:32px; font-weight: bold; padding-left:30px; padding-top:26px; padding-right:30px;">推荐商品</text>
            </cell>
            <cell v-if="commendGoodsList.length > 0 && isKeywordsThinking == false">
                <div v-for="(item, i) in commendGoodsList" :key="i" @click="didSelectGoodsClick(item, i)" class="cell-content">
                    <image style="width:198px; height:134px; background-color:#f0f0f0; margin-left:26px;" :src="item.goodsImgURLs"/>
                    <div style="flex:1; margin-left:10px; margin-right:26px;">
                        <text class="goods-name">{{item.supGoodsName}}</text>
                        <div style="flex-direction: row; justify-content: space-between; align-items: center;">
                            <text class="goods-desc">{{item.supGoodsSpecs}}</text>
                            <div v-if="item.count > 0" style="flex-direction: row;align-items: center;">
                                <div style="width:72px;height:46px;align-items: center;" @click="reduceGoodsCountClick(item)">
                                    <image style="width:46px; height:46px;" resize="contain" src="/web/assets/sup/sup_cart_reduce.png" @click="reduceGoodsCountClick(item)" />
                                </div>
                                <text style="font-size:30px;">{{item.count}}</text>
                                <div style="width:72px;height:46px;align-items: center;" @click="addGoodsCountClick(item)">
                                    <image style="width:46px; height:46px;" resize="contain" src="/web/assets/sup/sup_cart_add.png" @click="addGoodsCountClick(item)" />
                                </div>
                            </div>
                            <div v-else style="flex-direction: row; align-items: center;">
                                <div style="width:72px;height:46px;"></div>
                                <text></text>
                                <div style="width:72px;height:46px;align-items: center;" @click="addActionClick(item)">
                                    <image style="width:46px; height:46px;" resize="contain" src="/web/assets/sup/sup_homeSearch_cartIcon.png" @click="addActionClick(item)"/>
                                </div>    
                            </div>
                        </div>
                        <text class="goods-price">¥{{item.supStorePrice}}</text>
                    </div>
                </div>
            </cell>
            <div ref="fixed" class="fixedItem" :style="{bottom:popupHeight+'px'}">
                <ButtonItem title="" :imgSize = {width:50,height:50}
                  img="https://s3.cn-north-1.amazonaws.com.cn/h5.taocai.mobi/down/debug.IPA/weexIcon/goodsIcon/shopping_cart2x.png" 
                  :badge='cartGoodsCount' 
                  :textCong="{font:22, color:'#999999', dotTop:-10, dotRight:-10}" 
                  @onclick="goToShoppingCart"></ButtonItem>
            </div>
        </list>
        <wxc-loading :show="loading" need-mask=false type="default" loading-text='加载中'></wxc-loading>
    </div>
</template>

<script>
import { WxcLoading, WxcPartLoading } from "weex-ui";
import navigationSearch from "@/base-superior/components/NavigationBarSearch.vue";
import Fetch from "@/base-superior/Fetch.js";
import Define from "@/base-superior/Define.js";
import navigation from "@/base-superior/components/NavigationBar.vue";
import ButtonItem from "@/base-superior/components/ButtonItem.vue";
import DB from "@/base-superior/shopping_cartdb.js";
const modal = weex.requireModule('modal');
const storage = weex.requireModule("storage");
const dom = weex.requireModule('dom') || {};

export default {
    components: {navigationSearch, WxcLoading, WxcPartLoading, navigation, ButtonItem},
    data() {
        return {
            // record_lables:["小番茄","网红青团","砂糖桔","苹果","梨","茄子","小番茄","网红青团","砂糖桔","苹果","梨","茄子"],
            record_lables:[], //历史搜索记录
            searchClick:false, //点击搜索按钮
            searchResultList:[], //搜索结果数组
            inputString:'',
            loading: false,
            isKeywordsThinking:false,
            keywordsThinkingList:[],
            cartGoodsCount: 0,
            supSubjectId: "", //活动主题ID
            isKeyboardShow:false,
            isAndroid:WXEnvironment.platform === 'android',
            popupHeight:150,// 500 默认键盘高度
            hotSearchList:[],// 热门搜索数组
            userId:'',
            commendGoodsList:[],// 推荐商品数组
        }
    },
    created(){
        const self = this;
        storage.getItem('historySearchList', event => {
            console.log('historySearchList:', event.data)
            if (event.data && event.data != 'undefined') {
                self.record_lables = JSON.parse(event.data);
            }
        })
        storage.getItem('hotSearchList', event => {
            console.log('hotSearchList:', event.data)
            if (event.data && event.data != 'undefined') {
                self.hotSearchList = JSON.parse(event.data);
            }
        })
        //
        storage.getItem(Define.kNative, event=>{
            //判断是否从消费者端跳转过来
            if(event.result == "success"){
                storage.removeItem(Define.kNative, function(e){})
                if(weex.config.env.appName.indexOf('buyer') != -1) {
                    //是否登录后首次进入weex
                    storage.getItem(Define.kNormalLogin, function(e) {
                        if (e.result == "success") {
                            storage.removeItem(Define.kNormalLogin, call=>{})
                            //同步游客购物车数据
                            DB.touristsSynchCartData(function(ret){
                                DB.getCounts(function(count){
                                    self.cartGoodsCount = count;
                                })
                            });
                        } else {
                            DB.loadCartData(function(e){
                                DB.getCounts(function(count){
                                    self.cartGoodsCount = count;
                                })
                            })
                        }
                    })
                }
            } else {
                DB.getCounts(function(count){
                    self.cartGoodsCount = count;
                })
            }
        })
        
        if (WXEnvironment.platform === 'Web') {
            storage.getItem('JESSIONID', function (event) {
                if (event.result == 'success') {
                    self.userId = event.data;   
                }
                var sessionid = event.data;
                weex.config.sessionid = sessionid;
            });
        }

        //加载推荐商品
        this.loadCommendGoodsData();
    },
    methods: {
        viewappear(){
            var self = this;
            DB.getCounts(function(count){
                self.cartGoodsCount = count;
            });
            // 重新获取jession
            storage.getItem('JESSIONID', function (event) {
                if (event.result == 'success') {
                    self.userId = event.data;   
                }
                var sessionid = event.data;
                weex.config.sessionid = sessionid;
            });

            // 搜索列表操作后，返回刷新
            if (self.searchClick == true) {
                self.loadSearchResultData()
            };
            //加载推荐商品
            setTimeout(()=>{
                self.loadCommendGoodsData();
            },10)

        },
        wxcMinibarRightButtonClicked (event) {
            console.log('搜索按钮,输入值:'+this.inputString)
            if (this.inputString == '') {
                modal.toast({
                    message:'请输入商品名称',
                    duration:1.0
                }); 
                return
            }
            if (this.record_lables.length == 20) {
                this.record_lables.pop()
            }
            if (this.record_lables.indexOf(this.inputString) != -1) {
                this.record_lables.splice(this.record_lables.indexOf(this.inputString), 1);
            }
            this.record_lables.unshift(this.inputString)

            this.loadSearchResultData ()
            // 存储历史搜索记录
            storage.setItem('historySearchList', JSON.stringify(this.record_lables), event =>{})
            // 滑动到某一条cell（最顶部top）
            this.go2floor(event)
        },
        wxcMinibarMiddleInputChanged (event) {
            console.log(event.inputChanged)
            this.inputString = event.inputChanged
            if (event.inputChanged == '') {
                this.searchClick = false
                this.isKeywordsThinking = false
            } else {
                this.loadKeywordsThinkData()
                this.isKeywordsThinking = true
            }
        },
        wxcMinibarCancelInputClick () {
            console.log('清空输入框')
            this.inputString = ''
            this.searchClick = false
            this.isKeywordsThinking = false
        },
        wxcMinibarMiddleInputReturnKeyClick: function (event) {
            // modal.alert({message:"return："+JSON.stringify(event)})
            this.wxcMinibarRightButtonClicked(event)
            this.noticeListenMethod()
        },
        // 清空历史记录
        clearHistoryRecord:function () {
            if (this.record_lables && this.record_lables.length > 0) {
                const self = this
                modal.confirm({
                    message: '确定清空历史搜索记录吗?',
                    okTitle: '确定',
                    cancelTitle: '取消'
                }, function(value){
                    if(value === '确定') {
                        storage.removeItem('historySearchList', event => {
                            if (event.result == 'success') {
                                self.record_lables = []
                            }
                        })
                    }
                })
            } else {
                modal.toast({
                    message:'暂无历史搜索记录',
                    duration:1.0
                }); 
            }
        },
        labelClick:function (labelText, labelIndex) {
            console.log(labelText, labelIndex)
            this.inputString = labelText
            this.record_lables.splice(labelIndex, 1);
            this.record_lables.unshift(labelText)

            this.loadSearchResultData()
            // 存储历史搜索记录
            storage.setItem('historySearchList', JSON.stringify(this.record_lables), event =>{})
            this.noticeListenMethod()
        },
        hotLabelClick:function (hotLabelText, hotLabelIndex) {
            this.inputString = hotLabelText
            if (this.record_lables.length == 20) {
                this.record_lables.pop()
            }
            if (this.record_lables.indexOf(this.inputString) != -1) {
                this.record_lables.splice(this.record_lables.indexOf(this.inputString), 1);
            }
            this.record_lables.unshift(this.inputString)

            this.loadSearchResultData ()
            // 存储历史搜索记录
            storage.setItem('historySearchList', JSON.stringify(this.record_lables), event =>{})
            this.noticeListenMethod()
        },
        didSelectGoodsClick:function (item, i) {
            
            if (item.isGiftCard == "1") {
                // 礼品卡 商品详情
                storage.setItem('goods_giftVoucher', JSON.stringify({goodsId:item.supGoodsId,goodsName:item.supGoodsName}),event =>{})
                let url = 'goods_giftVoucher.html'
                navigation.push({url:url, title:item.supGoodsName}, event =>{})
            } else {
                // 普通商品 商品详情
                storage.setItem(Define.kSuperior_goods_id, item.supGoodsId, event =>{})
                let url = 'goods_goodsDetail.html'
                navigation.push({url:url, title:'商品详情'}, event =>{});
            }

            if (this.record_lables.length == 20) {
                this.record_lables.pop()
            }
            if (this.record_lables.indexOf(item.supGoodsName) != -1) {
                this.record_lables.splice(this.record_lables.indexOf(item.supGoodsName), 1);
            }
            this.record_lables.unshift(item.supGoodsName)
            
            // 存储历史搜索记录
            storage.setItem('historySearchList', JSON.stringify(this.record_lables), event =>{})
            this.noticeListenMethod()
        },
        didSelectThinkGoodsClick:function (item, j) {

            if (item.isGiftCard == "1"){
                // 礼品卡 商品详情
                storage.setItem('goods_giftVoucher', JSON.stringify({goodsId:item.id,goodsName:item.superiorName}),event =>{})
                let url = 'goods_giftVoucher.html'
                navigation.push({url:url, title:item.superiorName}, event =>{})
            } else {
                // 普通商品 商品详情
                storage.setItem(Define.kSuperior_goods_id, item.id, event =>{})
                let url = 'goods_goodsDetail.html'
                navigation.push({url:url, title:'商品详情'}, event =>{});
            }

            if (this.record_lables.length == 20) {
                this.record_lables.pop()
            }
            if (this.record_lables.indexOf(item.superiorName) != -1) {
                this.record_lables.splice(this.record_lables.indexOf(item.superiorName), 1);
            }
            this.record_lables.unshift(item.superiorName)
            
            // 存储历史搜索记录
            storage.setItem('historySearchList', JSON.stringify(this.record_lables), event =>{})
            this.noticeListenMethod()
        },
        //商品添加操作
        addGoodsCountClick:function(goodsModel) {
            // goodsModel.supGoodsInventory = 20;
            if (Number(goodsModel.count) < Number(goodsModel.inventory)) {
                goodsModel.count = parseInt(goodsModel.count) + 1;
                this.changeGoodsCountEvent(goodsModel, true);
            } else {
                modal.toast({message:"没那么多库存了～"})
            }
        },
        //商品减少操作
        reduceGoodsCountClick:function(goodsModel) {
            if(goodsModel.count > 1){
                this.changeGoodsCountEvent(goodsModel, false);
                goodsModel.count = parseInt(goodsModel.count) - 1;
            } else {
                this.changeGoodsCountEvent(goodsModel, false);
                goodsModel.count = 0
            }
        },
        // 搜索网络请求
        loadSearchResultData:function () {
            const self = this;
            self.loading = true;
            // var param = {marketId:'', queryText:self.inputString, orderBy:"0", orderType:"0", plotarea_lng:'116.358536', plotarea_lat:'39.984329', weChat:"2"};// 'goods_SPU.json'
            var param = {queryText:self.inputString, userId:self.userId}
            Fetch.post(
                "superiorGoodsSearch.json",
                param,
                function(jsonString) {
                    self.loading = false;
                    var result = JSON.parse(jsonString);
                    if (result.op_flag === "success") {
                        self.searchResultList = result.superiorList.filter(function(item){
                            if(item.supplierName == "淘菜猫优选旗舰店"){
                                return item
                            }else{}
                        })
                        self.searchResultList.forEach(item => {
                            DB.getItem(item.supGoodsId, function(ret) {
                                if (ret.data != 'undefined' && ret.data.length > 0){
                                    var goodsModel = JSON.parse(ret.data)
                                    if (item.supGoodsId == goodsModel.supGoodsId) {
                                        item.count = goodsModel.count;
                                    }
                                }
                            });
                        });
                    } else {
                        modal.toast({
                            message: result.info,
                            duration: 1.0
                        });
                        self.searchResultList = []
                    }
                    self.searchClick = true
                    self.isKeywordsThinking = false
                },
                function(err) {
                    self.loading = false;
                    self.searchClick = true
                    self.isKeywordsThinking = false
                    self.searchResultList = []
                    modal.toast({
                        message:err,
                        duration:1.0
                    })
                }
            );
        },
        // 关键词联想网络请求
        loadKeywordsThinkData:function () {
            const self = this;
            // var param = {goods_name:self.inputString, plotarea_lng:'116.358536', plotarea_lat:'39.984329'};// "goods_search_fuzzy_matching.json" 旧的菜市接口
            var param = {superior_name:self.inputString};
            Fetch.post(
                "superior_search_fuzzy.json",
                param,
                function(jsonString) {
                    var result = JSON.parse(jsonString);
                    if (result.op_flag === "success") {
                        self.keywordsThinkingList = result.objs.filter(function(item){
                            if(item.supplier == "淘菜猫优选旗舰店"){
                                return item
                            }else{}
                        })
                    } else {
                        modal.toast({
                            message: result.info,
                            duration: 1.0
                        });
                        self.keywordsThinkingList = []
                    }
                },
                function(err) {
                    self.keywordsThinkingList = []
                    modal.toast({
                        message:err,
                        duration:1.0
                    })
                }
            );
        },
        noticeListenMethod:function () {
            // 发出通知(目的为了点击历史记录，软键盘隐藏)
            const inputKeyboardChannel = new BroadcastChannel("inputKeyboardDisappear");
            inputKeyboardChannel.postMessage("inputKeyboardDisappear");
        },
        scrollTheList:function () {
            // console.log('滑动啦')
            if (this.isKeyboardShow) {
                this.noticeListenMethod()
                console.log('键盘隐藏啦')
            }
        },
        // 版本 0.17.0+ 支持
        scrollstart: function () {
            // console.log('开始滑动')
            // if (this.isKeyboardShow) {
            //     this.noticeListenMethod()
            //     console.log('键盘隐藏啦')
            // }
        },
        //跳转购物车
        goToShoppingCart: function() {
            this.noticeListenMethod()
            storage.getItem('fromCart',function(ret){
                storage.removeItem('fromCart', event => {});
                if (ret.data != 'undefined') {
                    navigation.pop({}, event=>{});
                } else {
                    storage.setItem(Define.kGoodsDetail_Cart, 'active_suject', event=>{})
                    navigation.push({url:'shopping_index.html', title:'购物车'}, event =>{});
                }
            })
        },
        //添加购物车事件
        addActionClick:function (item) {
            if (item.isGiftCard == "1"){
                // 礼品卡 商品详情
                storage.setItem('goods_giftVoucher', JSON.stringify({goodsId:item.supGoodsId,goodsName:item.supGoodsName}),event =>{})
                let url = 'goods_giftVoucher.html'
                navigation.push({url:url, title:item.supGoodsName}, event =>{})
                return
            }
            var self = this;
            storage.getItem('JESSIONID', event=>{
                var sessionid = event.data;
                if (sessionid &&sessionid != 'undefined') {
                    DB.getItem (item.supGoodsId, function(ret){
                        if (ret.data != 'undefined' && ret.data.length > 0){
                            var goodsModel = JSON.parse(ret.data)
                            if(goodsModel.count >= item.inventory){
                                 modal.toast({message:'库存不足', duration:0.5})
                            } else {
                                self.addCartToServer(item);
                            }
                        } else {
                            if(item.inventory > 0){
                                self.addCartToServer(item);
                            } else {
                                modal.toast({message:'库存不足', duration:0.5})
                            }
                        }
                    });
                    
                } else {
                    self.saveDataLocal(item, function(ent){
                        var message = '加入购物车失败'
                        if (ent.result == 'success') {
                            message = '加入购物车成功'
                            self.cartGoodsCount += 1;
                            item.count = 1
                        } else if (ent.data == '库存不足') {
                            message = '库存不足'
                        }
                        modal.toast({
                            message:message,
                            duration:0.5
                        }); 
                    })
                }
            });
        },
        //加入购物车
        addCartToServer: function(item) {
            const self = this;
            //加入购物车所需参数
            var param = {num: "1",//商品数量
                        type: "add",//操作类型添加
                        supSubjectId:self.supSubjectId,//主题id
                        supGoodsId:item.supGoodsId};//商品ID
            Fetch.post("buyer/addSuperiorGoodsCart.json", param, function(jsonString) {
                console.log('get:'+jsonString);
                let responeObjc = JSON.parse(jsonString);
                if (responeObjc.op_flag === 'success') {
                    //存入本地
                    self.saveDataLocal(item, event=>{})
                    self.cartGoodsCount += 1;
                    item.count = 1
                    responeObjc = {op_flag:"success",
                    info:'加入购物车成功',
                    goodsCart_id:'xx',
                    count:'1',}
                    modal.toast({message:responeObjc.info,
                                duration:0.3});
                } else {
                    modal.toast({
                        message: responeObjc.info,
                        duration: 0.3
                    }, function (value) {
                        console.log('alert callback', value)
                    })
               }
            },function(err) {
                console.log("err:" + err);
                modal.toast({message:err}); 
           });
        },
        //数据保存本地
        saveDataLocal:function (item, callback){
            const self = this;
            var goodsData = {
                        "expiryStatus": "false",//失效状态
                        "supplierId": item.supplier_id,//供货商id
                        "checkScope": "1",
                        "useNormalFlag": "true",//能否使用普通优惠券
                        "count": "1",
                        "goodsImgURLs": item.goodsImgURLs,
                        "supSubjectId": self.supSubjectId,//主题id
                        "orderStartPrice": "",//满免邮费金额
                        "supGoodsSpecs": item.supGoodsSpecs,//规格如200g/盒
                        "activityPower": [],
                        "supCartId": "",
                        "bgcId": '',//菜篮子id
                        "shipPrice": "",//配送费
                        "supGoodsName": item.supGoodsName,
                        "supGoodsInventory": item.inventory,//库存量
                        "supGoodsId": item.supGoodsId,//优品商品id
                        "mainImgURL": item.goodsImgURLs,
                        "name": "",
                        "mainHeight": "541",
                        "supStorePrice": item.supStorePrice,//现价
                        "mainWidth": "750"
                    }
            DB.getItem(goodsData.supGoodsId, function(ret){
                if (ret.data != 'undefined' && ret.data.length > 0){
                    var item = JSON.parse(ret.data)
                    if (item.count >= goodsData.supGoodsInventory){
                        var event = {
                            result:'fail',
                            data:'库存不足'
                        }
                        callback(event);
                    } else {
                        //存入本地数据库            
                        DB.setItem(goodsData, event=>{
                            callback(event);
                        });
                    }
                } else {
                    if (goodsData.supGoodsInventory > 0) {
                        //存入本地数据库            
                        DB.setItem(goodsData,event=>{
                            callback(event);
                        });
                    } else {
                        var event = {
                            result:'fail',
                            data:'库存不足'
                        }
                        callback(event);
                    }
                }
            })
        },
        wxcMinibarMiddleKeyboardShowOrHide:function (e) {
            console.log('键盘返回值：'+JSON.stringify(e))
            const self = this;
            self.isKeyboardShow = e.isShow
            if (e.isShow) {
                if (self.isAndroid) {
                    var bottomHeight = 150 + 500;
                    if (bottomHeight > navigationSearch.screenHeight() / 2) {
                        bottomHeight = navigationSearch.screenHeight() / 2
                    }
                    self.popupHeight = bottomHeight;
                } else {
                    self.popupHeight = 150 + 500;
                }
            } else {
                self.popupHeight = 150;
            }

            if (self.isAndroid) {
                // modal.alert({message:"keyboard："+JSON.stringify(e)})
                if(e.isShow){
                    //android的weexsdk0.19以下没有keyboardSize参数
                    if (e.keyboardSize) {
                        //self.popupHeight = 300 //+ Number(e.keyboardSize);
                    } else {
                        //self.popupHeight = 300+616
                    }
                } else {}
            } else {
                console.log("keyboard："+JSON.stringify(e))
            }
        },
        loadCommendGoodsData:function () {
            console.log('推荐商品')
            const self = this;
            var param = {};
            Fetch.post(
                "superiorGoodsCommend.json",
                param,
                function(jsonString) {
                    var result = JSON.parse(jsonString);
                    if (result.op_flag === "success") {
                        console.log('推荐商品：',jsonString)
                        
                        self.commendGoodsList = result.goodsList.filter(function(item){
                            if(item.supplier == "淘菜猫优选旗舰店"){
                                // 赋值，因为2个接口字段名有区别
                                item.goodsImgURLs = item.goodsImgURLs; // item.superiorImg.length > 0 ? item.superiorImg[0] : ''
                                item.supGoodsName = item.superiorName
                                item.supStorePrice = item.storePrice
                                item.supGoodsPrice = item.goodsPrice
                                item.supGoodsId = item.id
                                DB.getItem(item.supGoodsId, function(ret) {
                                    if (ret.data != 'undefined' && ret.data.length > 0){
                                        var goodsModel = JSON.parse(ret.data)
                                        if (item.supGoodsId == goodsModel.supGoodsId) {
                                            console.log('找到对应商品：',goodsModel.count)
                                            // item.count = goodsModel.count;
                                            self.$set(item,"count",goodsModel.count)
                                        } 
                                    }
                                });
                                return item
                            }else{}
                        })
                        
                    } else {
                        modal.toast({
                            message: result.info,
                            duration: 1.0
                        });
                    }
                },
                function(err) {
                    modal.toast({
                        message:err,
                        duration:1.0
                    })
                }
            );
        },
        // 增加/减少 改变商品数量
        changeGoodsCountEvent:function(objc, isAdd) {
            const self = this;
           //禁止判断undefined后使用‘或’操作
            let hasSession = weex.config.sessionid == 'undefined' || (weex.config.sessionid != 'undefined'&&weex.config.sessionid.length == 0)
            if (hasSession){
                 // 本地数据
                DB.changeItemCount(objc.supGoodsId, isAdd ? 'add':'sub', event => {
                    DB.getCounts(function(count){
                        self.cartGoodsCount = count;
                    })
                })
                return;
            }
            // 网络请求
            let operationType = isAdd ? 'add':'sub';
            var param = {
               type:operationType,//操作类型
               supGoodsId:objc.supGoodsId,//商品ID
               supSubjectId:objc.supSubjectId,//主题ID
               num:'1',
            }
            var url = 'buyer/addSuperiorGoodsCart.json'
            Fetch.post(url, param, function(respone){
            //    modal.alert({message:"修改："+ JSON.stringify(respone)})
                var result = JSON.parse(respone)
                if(result.op_flag == 'success'){
                    if(isAdd){
                        // modal.toast({message:'成功添加', duration: 0.3})
                        DB.changeItemCount(objc.supGoodsId, isAdd ? 'add':'sub', event => {
                            DB.getCounts(function(count){
                                self.cartGoodsCount = count;
                            })
                        })
                    }else{
                        //如果减少且商品数量为1时，调用删除操作
                        if(!isAdd && result.count < 1){
                            self.deleAGoodsEvent(result.goodsCart_id, isAdd, objc);
                        } else {
                            // modal.toast({message:'成功减去', duration: 0.3})
                            DB.changeItemCount(objc.supGoodsId, isAdd ? 'add':'sub', event => {
                                DB.getCounts(function(count){
                                    self.cartGoodsCount = count;
                                })
                            })
                        }
                    }
                }else{
                    modal.toast({message:result.info})
                    if(isAdd){
                        objc.count = parseInt(objc.count) - 1;
                    }else{
                        objc.count = parseInt(objc.count) + 1;
                    }
                }
            }, function(err){
               modal.toast({message:err})
                if(isAdd){
                    objc.count = parseInt(objc.count) - 1;
                }else{
                    objc.count = parseInt(objc.count) + 1;
                }
                DB.getCounts(function(count){
                    self.cartGoodsCount = count;
                })
            });
        },
        //删除单个商品
        deleAGoodsEvent:function(bgcId, isAdd, objc){
            const self = this;
            var param = {bgcId:bgcId}
            var url = 'buyer/delBuyerGoodsCart.json';
            Fetch.post(url, param, function(respone){
                // console.log('删除：'+respone)
                var result = JSON.parse(respone)
                if(result.op_flag == 'success'){
                    // modal.toast({message:'成功减去',duration: 0.3})
                    DB.changeItemCount(objc.supGoodsId, isAdd ? 'add':'sub', event => {
                        DB.getCounts(function(count){
                            self.cartGoodsCount = count;
                        })
                    })
                }else{
                    modal.toast({message:result.info})
                }
            }, function(err){
               modal.toast({message:err})
            });
        },
        go2floor: function (event) {
            const target = event.target;
            const ref = this.$refs['floor-'+'border-cell'];
            const el = ref ? ref : null;
        
            dom.scrollToElement(target, {offset: 0, animated: false});
            if (el) {
                dom.scrollToElement(el, {offset: 0, animated: false});
            }
        }
    }
}
</script>

<style scoped>
.wrapper { 
    width: 750px;
    /* justify-content: center;
    align-items: center; */
}
.list {
    width: 750px;
    flex: 1;
    background-color: white;
}
.no-result {
    width: 750px;
    height: 510px;
    align-items: center;
    justify-content: center;
    border-bottom-width: 1px;
    border-bottom-color: #f0f0f0;
}
.search-record-bg {
    width: 750px;
    padding: 26px;
    align-items: center;
    border-bottom-width: 1px;
    border-bottom-color: #f0f0f0;
}
.record-top { 
    width:698px;
    flex-direction: row;
    align-items:center;
    justify-content:space-between;
}
.record-label {
    width: 698px;
    flex-direction: row;
    padding-top: 12px;
    flex-wrap:wrap;
}
.record-label-no {
    width: 698px;
    padding-top:20px;
}
.label-text {
    color:#666666; 
    font-size:28px; 
    height: 56px;
    padding-left:20px;
    padding-right: 20px;
    border-width: 1px;
    border-color: #cccccc;
    border-radius: 30px;
    line-height: 56px;
    margin-left: 10px;
    margin-right: 10px;
    margin-top: 12px;
    margin-bottom: 12px;
}
.search-think {
    width: 750px;
    height: 90px;
    border-bottom-width: 1px;
    border-bottom-color: #f0f0f0;
    justify-content:center;
    padding: 26px;
}
.cell-content {
    flex-direction: row;
    align-items: center;
    padding-top: 30px;
    padding-bottom: 30px;
    border-bottom-width: 1px;
    border-bottom-color: #f0f0f0;
    /* height: 188px; */
    /* flex: 1; */
}
.goods-name {
    font-size: 32px;
    color: #333333;
}
.goods-desc {
    flex:1;
    font-size: 24px;
    color: #666666;
    text-overflow: ellipsis;
    lines:1;
    /*width:440px;*/
}
.goods-price {
    font-size: 36px;
    color: #e5354a;
}
.fixedItem {
    position: fixed;
    width: 100px;
    height: 100px;
    background-color: #f0f0f0;
    right: 70px;
    bottom: 150px;
    border-radius: 50px;
    align-items: center;
    justify-content: center;
}
.border-cell {
    background-color: #ffffff;
    width: 750px;
    height: 1px;
    align-items: center;
    justify-content: center;
}
</style>
