<template>
  <div>
    <navigation title="设置"/>
     <scroller class="scroller" :style="{height:(rows.length * 100)+'px'}" > 
        <div class="row" v-for="(item, index) in rows" :key="index" @click="onclick(item.custom_index, index)">
          <div class="content">
              <image class="iconImg" :src="item.icon" resize="contain"/>
              <text class="text">{{item.name}}</text>
          </div>
          <div v-if="item.type === 1">
              <div style="padding-right:20px">
                  <switch checked="true" @change="onchange"></switch>
              </div>    
          </div>
          <div v-else-if="item.type === 2">
             <text style="padding-right:20px">0.36M</text>    
          </div>
          <div v-else>
             <image class="arrowImg" :src='arrow' resize="contain"/>    
          </div>
        </div>
     </scroller>
     <text v-if="hidLogout != true" class="loginOut" @click="loginOut">退出登录</text>
  </div>
</template>

<script>
import Define from "@/base-superior/Define.js";
import navigation from "@/base-superior/components/NavigationBar.vue";


const modal = weex.requireModule("modal");
// var navigation = weex.requireModule('navigation')
const storage = weex.requireModule('storage')

export default {
  components: { navigation },
  data() {
    return {
      arrow: "/web/assets/personal/next.png",
      rows: [
        // {
        //   icon: "/web/assets/setting/noticeIcon.png",
        //   name: "推送通知设置",
        //   type: 1,
        //   custom_index: 0 // 所在位置(方便点击调试)
        // },
        // {
        //   icon: "/web/assets/setting/removeIcon.png",
        //   name: "清除缓存",
        //   type: 2,
        //   custom_index: 1
        // },
        {
          icon: "/web/assets/setting/aboutUsIcon.png",
          name: "关于我们",
          type: 0,
          custom_index: 2
        },
        // {
        //   icon: "/web/assets/setting/starIcon.png",
        //   name: "欢迎评分",
        //   type: 0,
        //   custom_index: 3
        // },
        {
          icon: "/web/assets/setting/declareIcon.png",
          name: "特别声明",
          type: 0,
          custom_index: 4
        },
        {
          icon: "/web/assets/setting/privacyIcon.png",
          name: "隐私权政策",
          type: 0,
          custom_index: 5
        }
      ],
      hidLogout: true //是否隐藏退出登录按钮
    };
  },
  created: function() {
      storage.getItem('JESSIONID', event=>{
        if (event.result == 'success') {
          this.hidLogout = false
        } else {
          this.hidLogout = true
        }        
      })
  },
  methods: {
      //点击cell
    onclick: function(custom_index, index) {
      console.log("点击" + index);

      var url = '';
      var title = '';
      switch(custom_index){
          case 0:
             return;
             break;
          case 1:
             modal.confirm({
                 message: '确定清楚本地缓存 ?',
                 okTitle: '确定',
                 cancelTitle: '取消'
             },function(vaule){
                 if(vaule === '确定'){
                     console.log("清楚缓存");
                 }
             })
             return;
             break;
          case 2:
             //相对路径，当前目录
             url = 'setting_aboutWe.html'
             title = '关于我们'
             break;
          case 3:
             let msg = this.rows[index].name;
             console.log(msg+'xxx')
             modal.toast({
                 message: msg,
                 duration: 0.5
               })
             break;
          case 4:
             //相对路径，当前目录
             url = 'setting_specialStatement.html'
             title = '特别声明'
            break;
          case 5:
             //绝对路径，以'/'开始
             url = 'setting_agreementWeb.html'
             title = '隐私权政策'
             var data = {url:"https://s3.cn-north-1.amazonaws.com.cn/www.taocaimall.com/webResources/tcmApp_page/lawInfo.html",
                          title:'隐私权政策'}
             storage.setItem('web_url',JSON.stringify(data),event =>{})
             break;
      }
      if (url.length) {
         navigation.push({url:url, title:title}, event =>{

         });
      }
    },
    //退出登录
    loginOut: function() {
      modal.confirm({
        message: '退出登录?',
        okTitle: '确定',
        cancelTitle: '取消'
      }, function(vaule){
          if(vaule === '确定'){
              console.log("退出登录");
              //删除用户信息token
              storage.removeItem(Define.kToken, event => {

              })
              //置空sessionid, userInfo
              storage.removeItem('JESSIONID', event => {
                if (event.result == 'success') {
                  const logoutChannel = new BroadcastChannel("login");
                  logoutChannel.postMessage("logout");
                }
              })
              weex.config.sessionid = '';
              weex.config.userInfo = {};
              //清空本地购物车数据库
              storage.removeItem(Define.kLocal_Cart, event => {})
              navigation.pop({
                animated:"true"
              }, event => {
                console.log('结果回调')
              })
          } 
      })
    },
    //switch切换
    onchange: function(e) {
        var message;
        if(e.value){
            message = '通知开启'
        }else{
            message = '通知关闭'
        }
        modal.toast({
        message: message
      });
    }
  }
};
</script>

<style scoped>
.scroller {
  width: 750px;
  /* height: 300px; */
}
.row {
  height: 100px;
  flex-direction: row;
  justify-content: space-between;
  align-items: center;
  border-bottom-width: 1px;
  border-bottom-style: solid;
  border-bottom-color: #dddddd;
}
.content {
  height: 100px;
  flex-direction: row;
  justify-content: flex-start;
  align-items: center;
  padding-left: 20px;
}
.iconImg {
  width: 36px;
  height: 36px;
}
.text {
  margin-left: 20px;
  font-size: 32px;
  color: #333333;
}
.arrowImg {
  width: 20px;
  height: 30px;
  margin-right: 20px;
}
.loginOut {
  font-size: 40px;
  /* width: 550px; */
  /* height: 98px;
  line-height: 98px;
  display: flex;
  align-items: center;
  justify-content: center; */
  text-align: center;
  margin-top: 60px;
  margin-bottom: 60px;
  margin-left: 75px;
  margin-right: 75px;
  padding-top: 20px;
  padding-bottom: 20px;
  border-width: 1px;
  border-style: solid;
  color: #ffffff;
  border-color: #dddddd;
  background-color: rgb(226, 35, 35);
  border-radius: 10px;
}
</style>
