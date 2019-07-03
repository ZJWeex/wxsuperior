/**本地数据库操作函数 */
const storage = weex.requireModule("storage");
var modal = weex.requireModule("modal");
import Define from "@/base-superior/Define.js";
import Fetch from "@/base-superior/Fetch.js";

export default {
    //保存一个数据
    setItem(value, callback) {
        const self = this;
        if (typeof value == 'string') {
            value = JSON.parse(value)
        }
        storage.getItem(Define.kLocal_Cart, event => {
            if (event.data != 'undefined') {
                var result = JSON.parse(event.data)
                var foundInGroup = false;
                var found = false;
                for (let i = 0; i < result.length; i++) {
                    var item = result[i];
                    if (item.subjectId === value.supSubjectId) {
                        foundInGroup = true;
                        for (let j = 0; j < item.supGoodsList.length; j++) {
                            var model = item.supGoodsList[j];
                            if (model.supGoodsId == value.supGoodsId) {
                                model.count = parseInt(model.count) + parseInt(value.count);
                                found = true;
                            }
                        }
                        if (foundInGroup && !found) {
                            //找到主题活动，未找到商品则添加商品
                            item.supGoodsList.splice(0, 0, value);
                        }

                    }
                }

                if (!foundInGroup) {
                    //未找到商品对应的主题活动
                    var item = {
                            subjectId: value.supSubjectId,
                            activityPower: value.activityPower == undefined ? [] : value.activityPower,
                            supGoodsList: [value],
                        }
                        //插入第一个
                    result.splice(0, 0, item);
                }
                //保存
                console.log('保存的数据：' + JSON.stringify(result))
                storage.setItem(Define.kLocal_Cart, JSON.stringify(result), ret => {
                    self.postBadgeNotification();
                    callback(ret)
                });
            } else {
                //此时购物车为空
                var item = {
                    subjectId: value.supSubjectId,
                    activityPower: value.activityPower == undefined ? [] : value.activityPower,
                    supGoodsList: [value],
                }
                var result = [item]
                console.log('保存的数据：' + JSON.stringify(result))
                storage.setItem(Define.kLocal_Cart, JSON.stringify(result), ret => {
                    self.postBadgeNotification();
                    callback(ret)
                });
            }
        })
    },
    //根据商品ID，获得一个商品模型
    getItem(goodsId, callback) {
        storage.getItem(Define.kLocal_Cart, event => {
            if (event.data != 'undefined' && event.data.length > 0) {
                var result = JSON.parse(event.data)
                var found = false;
                for (let i = 0; i < result.length; i++) {
                    var item = result[i];
                    for (let j = 0; j < item.supGoodsList.length; j++) {
                        const cell = item.supGoodsList[j];
                        if (cell.supGoodsId == goodsId) {
                            event.data = JSON.stringify(cell);
                            found = true;
                            callback(event)
                            break;
                        }
                    }
                }
                if (!found) {
                    event.data = '';
                    callback(event)
                }
            } else {
                callback(event);
            }
        })
    },
    //获取购物车商品总数量
    getCounts(callback) {
        storage.getItem(Define.kLocal_Cart, event => {
            var totalCount = 0;
            if (event.data == 'undefined' || event.data.length == 0) {
                totalCount = 0;
            } else {
                var result = JSON.parse(event.data)
                for (let i = 0; i < result.length; i++) {
                    var item = result[i];
                    for (let j = 0; j < item.supGoodsList.length; j++) {
                        const element = item.supGoodsList[j];
                        totalCount = Number(totalCount) + Number(element.count);
                    }
                }
            }
            callback(totalCount);
        })
    },
    //根据goodsId删除一个商品,在提交订单后使用。购物车删除会自动触发！
    removeItemByGoodsId(goodsId, callback) {
        storage.getItem(Define.kLocal_Cart, event => {
            if (event.data != 'undefined' && event.data.length > 0) {
                var result = JSON.parse(event.data)
                for (let i = 0; i < result.length; i++) {
                    var item = result[i];
                    for (let j = 0; j < item.supGoodsList.length; j++) {
                        const cell = item.supGoodsList[j];
                        if (cell.supGoodsId == goodsId) {
                            item.supGoodsList.splice(j, 1);
                            break;
                        }
                    }
                    //若分组中商品数量为0，则删除该分组
                    if (item.supGoodsList.length <= 0) {
                        result.splice(i, 1);
                    }
                    //重新保存
                    storage.setItem(Define.kLocal_Cart, JSON.stringify(result), callback);
                }
            } else {
                callback(event);
            }
        })
    },
    //改变商品的数量type:add为增加;sub为减少
    changeItemCount(goodsId, type, callback) {
        const self = this;
        self.getItem(goodsId, event => {
            if (event.data != 'undefined' && event.data.length > 0) {
                var goodsItem = JSON.parse(event.data);
                if (type == "add") {
                    goodsItem.count = Number(goodsItem.count) + 1;
                    storage.getItem(Define.kLocal_Cart, objc => {
                        if (objc.data != 'undefined' && objc.data.length > 0) {
                            var result = JSON.parse(objc.data)
                            for (let i = 0; i < result.length; i++) {
                                var item = result[i];
                                for (let j = 0; j < item.supGoodsList.length; j++) {
                                    const cell = item.supGoodsList[j];
                                    if (cell.supGoodsId == goodsItem.supGoodsId) {
                                        //数据替换
                                        item.supGoodsList.splice(j, 1, goodsItem);
                                        break;
                                    }
                                }
                            }
                            //重新保存
                            storage.setItem(Define.kLocal_Cart, JSON.stringify(result), callback);
                        }
                    })
                } else {
                    if (goodsItem.count > 1) {
                        goodsItem.count = Number(goodsItem.count) - 1;
                        storage.getItem(Define.kLocal_Cart, element => {
                            if (element.data != 'undefined' && element.data.length > 0) {
                                var result = JSON.parse(element.data)
                                for (let i = 0; i < result.length; i++) {
                                    var item = result[i];
                                    for (let j = 0; j < item.supGoodsList.length; j++) {
                                        const cell = item.supGoodsList[j];
                                        if (cell.supGoodsId == goodsItem.supGoodsId) {
                                            //数据替换
                                            item.supGoodsList.splice(j, 1, goodsItem);
                                            break;
                                        }
                                    }
                                }
                                //重新保存
                                storage.setItem(Define.kLocal_Cart, JSON.stringify(result), callback);
                            }
                        })
                    } else {
                        self.removeItemByGoodsId(goodsItem.supGoodsId, callback)
                    }
                }
            } else {
                callback(event)
            }
        });
    },
    //更新商品数据
    updateItems(cartList, callback) {
        storage.getItem(Define.kLocal_Cart, function(value) {
            if (value.data != 'undefined' && value.data.length > 0) {
                var result = JSON.parse(value.data);
                cartList.forEach(netSection => {
                    result.forEach(localSection => {
                        if (netSection.subjectId == localSection.subjectId) {
                            netSection.selected = localSection.selected;
                            netSection.supGoodsList.forEach(netGoods => {
                                localSection.supGoodsList.forEach(localGoods => {
                                    if (netGoods.supGoodsId == localGoods.supGoodsId) {
                                        netGoods.selected = localGoods.selected;
                                    }
                                });
                            });
                        }
                    });
                });
            }
            value.data = JSON.stringify(cartList);
            value.result = 'success'
            callback(value)
        });
    },

    //游客同步购物车数据
    touristsSynchCartData: function(ret) {
        const self = this;
        storage.getItem(Define.kLocal_Cart, function(e) {
            if (e.data == 'undefined') {
                self.loadCartData()
            } else {
                var cartList = JSON.parse(e.data);
                if (cartList.length == 0) {
                    self.loadCartData(function(block) {
                        if (ret) {
                            ret();
                        }
                    })
                    return;
                }
                var listCount = 0;
                var updataCount = 0;
                for (let i = 0; i < cartList.length; i++) {
                    const element = cartList[i];
                    listCount = Number(listCount) + Number(element.supGoodsList.length);
                    for (let j = 0; j < element.supGoodsList.length; j++) {
                        var objc = element.supGoodsList[j];
                        var param = {
                            type: 'add', //操作类型
                            supGoodsId: objc.supGoodsId, //商品ID
                            supSubjectId: objc.supSubjectId, //主题ID
                            num: objc.count,
                        }
                        var url = 'buyer/addSuperiorGoodsCart.json'
                        Fetch.post(url, param, function(respone) {
                            updataCount = Number(updataCount) + 1;
                            if (updataCount == listCount) {
                                // modal.toast({ message: "上传完成" })
                                self.loadCartData(function(block) {
                                    if (ret) {
                                        ret();
                                    }
                                })
                            }
                            var result = JSON.parse(respone)
                            if (result.op_flag == 'success') {

                            } else {

                            }
                        }, function(err) {
                            updataCount = Number(updataCount) + 1;
                            if (updataCount == listCount) {
                                // modal.toast({ message: "上传完成" })
                                self.loadCartData(function(block) {
                                    if (ret) {
                                        ret();
                                    }
                                })
                            }
                        })
                    }
                }

            }
        })
    },
    //加载购物车数据
    loadCartData(block) {
        const self = this;
        Fetch.post('buyer/superiorwechatGoodsCartList.json', {}, function(respone) {
            var result = JSON.parse(respone)
            if (result.op_flag == 'success') {
                var list = result.bgcs;
                self.updateItems(list, callback => {
                    //保存数据
                    storage.setItem(Define.kLocal_Cart, callback.data, event => {
                        self.postBadgeNotification();
                        if (block) {
                            block(event)
                        }

                        if (event.result != 'success') {
                            storage.setItem(Define.kLocal_Cart, callback.data, function(e) {
                                self.postBadgeNotification();
                            })
                        }
                    });

                })
            } else {
                if (block) {
                    let event = {
                        result: 'fail',
                        data: result.info
                    }
                    block(event)
                }
                //加载失败信息不提示
                console.log(result.info)
            }
        }, function(err) {
            if (block) {
                block(err)
            }
            console.log(err)
        });
    },
    //发送角标通知
    postBadgeNotification: function() {
        const self = this;
        if (WXEnvironment.platform.toLowerCase() != 'web') {
            self.getCounts(count => {
                //发送角标到本地
                if (WXEnvironment.platform.toLowerCase() === 'android') {
                    weex.requireModule('myGlobalEvent').postNotificationName('setTabBarItemBadge', { tabIndex: '2', badge: count.toString() })
                } else {
                    weex.requireModule('globalEvent').postNotificationName('setTabBarItemBadge', { tabIndex: '2', badge: count.toString() })
                }
            });
        }
    },
    //消费者app同步登录通知
    appSynchLoginNotification: function() {
        const self = this;
        if (WXEnvironment.platform.toLowerCase() != 'web') {
            if (weex.config.env.appName != 'superior') {
                //登录通知
                if (WXEnvironment.platform.toLowerCase() === 'android') {
                    weex.requireModule('myGlobalEvent').postNotificationName('appSynchLogin', {})
                } else {
                    weex.requireModule('globalEvent').postNotificationName('appSynchLogin', {})
                }
            }
        }
    },

}