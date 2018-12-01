import { isNullOrUndefined } from "util";

// 配置默认API接口地址
var baseUrl = 'http://app.taocaimall.com/taocaimall/';
// console.log('自定义网络环境'+WXEnvironment.netEnv);
if (WXEnvironment.netEnv) {
    //获取native端网络环境配置
    baseUrl = WXEnvironment.netEnv;
    if (baseUrl.substr(baseUrl.length - 1, 1) != '/') {
        baseUrl += '/'
    }
    // console.log('拼接字符串'+baseUrl);
}
// 引入 弹窗组件
var modal = weex.requireModule('modal');

// 自定义判断元素类型JS
function toType(obj) {
    return ({}).toString.call(obj).match(/\s([a-zA-Z]+)/)[1].toLowerCase()
}
// 参数过滤函数
function filterNull(objc) {
    for (var key in objc) {
        if (objc[key] === null) {
            delete objc[key]
        }
        if (toType(objc[key]) === 'string') {
            objc[key] = objc[key].trim()
        } else if (toType(objc[key]) === 'object') {
            objc[key] = filterNull(objc[key])
        } else if (toType(objc[key]) === 'array') {
            objc[key] = filterNull(objc[key])
        }
    }
    return objc
}

// 工具方法
function toParams(obj) {
    var param = ""
    if (!obj) return param;

    for (const name in obj) {
        if (typeof obj[name] != 'function') {
            param += "&" + name + "=" + encodeURIComponent(obj[name])
        }
    }
    return param.substring(1)
};

function getRequest(url, params, success, failure) {
    // 引入请求数据组件
    var stream = weex.requireModule('stream');
    var resultURL = url;
    if (url.indexOf('http') == -1) {
        resultURL = baseUrl + url;
    }
    var HTTPHeader = {}
    var jsonType = ''
    if (WXEnvironment.platform.toLowerCase() === 'web') {
        HTTPHeader = { 'Content-Type': 'application/json' }
        jsonType = 'jsonp'
    } else {
        if (WXEnvironment.platform.toLowerCase() === 'ios') {
            console.log('This IOS')
            HTTPHeader = { 'Content-Type': 'application/json;charset=utf-8' }
            jsonType = 'text'
        } else if (WXEnvironment.platform.toLowerCase() === 'android') {
            HTTPHeader = { 'Content-Type': 'application/json' }
            jsonType = 'text'
        }
        HTTPHeader.Cookie = 'JSESSIONID=' + params.sessionId;
    }

    if (params) {
        resultURL = resultURL + '?' + toParams(params);
    }
    console.log(resultURL)

    stream.fetch({
        method: 'GET',
        url: resultURL,
        type: jsonType,
        headers: HTTPHeader,
    }, function(ret) {
        console.log(JSON.stringify(ret))
        if (!ret.ok) {
            // modal.toast({
            //     message: 'request failed',
            //     duration: 0.3
            // })
            failure('请求失败' + url);
        } else {
            var result = JSON.stringify(ret.data);
            // console.log('get:'+result);

            if (WXEnvironment.platform === 'android' || WXEnvironment.platform === 'iOS') {
                result = JSON.parse(result)
            }
            success(result)
        }
    }, function(response) {
        console.log('get in progress:' + response.length);
    })

}
//params为对象类型
function postRequest(url, params, success, failure) {
    // 引入请求数据组件
    var stream = weex.requireModule('stream');
    var resultURL = url;
    if (url.indexOf('http') == -1) {
        resultURL = baseUrl + url;
    }

    var HTTPHeader = {}
    var jsonType = ''
    if (WXEnvironment.platform.toLowerCase() === 'web') {
        HTTPHeader = { 'Content-Type': 'application/json' }
        jsonType = 'jsonp'
    } else {
        if (WXEnvironment.platform.toLowerCase() === 'ios') {
            HTTPHeader = { 'Content-Type': 'application/json;charset=utf-8' }
            jsonType = 'text'
        } else if (WXEnvironment.platform.toLowerCase() === 'android') {
            HTTPHeader = { 'Content-Type': 'application/json' }
            jsonType = 'text'
        }
        HTTPHeader.Cookie = 'JSESSIONID=' + params.sessionId;
    }

    // 过滤参数
    if (params) {
        params = filterNull(params)
        resultURL = resultURL + '?' + toParams(params);
    }

    console.log('参数：' + resultURL)
    stream.fetch({
        method: 'POST',
        // timeout: 30000,//30s
        url: resultURL,
        type: jsonType,
        headers: HTTPHeader,
        // body: JSON.stringify(params)
    }, function(ret) {
        if (!ret.ok) {
            console.log('请求失败\n', JSON.stringify(ret))
            if (ret.data.indexOf('offline') != -1) {
                failure('当前网络不可用' + url);
            } else {
                failure('请求失败' + url);
            }
        } else {
            var jsonString = JSON.stringify(ret.data);
            // console.log('post:'+jsonString);
            if (WXEnvironment.platform === 'android' || WXEnvironment.platform === 'iOS') {
                jsonString = JSON.parse(jsonString)
            }
            success(jsonString);

        }
    }, function(response) {
        console.log('post in progress:' + response.length);
    })
}

function setupRequest(method, url, param, success, failure) {
    const storage = weex.requireModule("storage");
    storage.getItem('JESSIONID', event => {
        if (param) {
            if (event.result == 'success') {
                param.sessionId = event.data
            } else {
                param.sessionId = ''
            }
        }
        if (method == 'get') {
            console.log(method + url)
            return getRequest(url, param, success, failure)
        } else {
            console.log(method + url)
            return postRequest(url, param, success, failure)
        }
    })
}

// 返回在vue模板中的调用接口
export default {
    get: function(url, params, success, failure) {
        if (!params) {
            params = {}
        }
        return setupRequest('get', url, params, success, failure)
    },
    getNo: function(url, success, failure) {
        return getRequest(url, null, success, failure)
    },
    post: function(url, params, success, failure) {
        if (!params) {
            params = {}
        } else {
            params = { requestmodel: JSON.stringify(params) }
        }
        return setupRequest('post', url, params, success, failure)
    },
    //post请求，参数自己处理；不包含requestmodel
    request: function(url, params, success, failure) {
        return setupRequest('post', url, params, success, failure)
    },
}

//使用
/*
import Fetch from '@/Fetch.js'
//请求
Fetch.post('uri',{key:'vaule'},function(data){

    },function(err){
      
    })
*/