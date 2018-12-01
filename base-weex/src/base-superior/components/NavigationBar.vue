<template>
  <div v-if="show && isApp" :style="{backgroundColor: backgroundColor, }">
    <div :style="{height: height, }"></div>
    <div class="wxc-minibar" :style="{backgroundColor:backgroundColor, }" v-if="show">
      <div class="left" @click="leftButtonClicked" aria-label="返回" :accessible="true">
        <slot name="left">
          <image :src="leftButton"
                resize='contain'
                v-if="leftButton && !leftText"
                class="left-button" />
          <text v-if="leftText"
                class="icon-text"
                :style="{ color: textColor }">{{leftText}}</text>
        </slot>
      </div>
      <slot name="middle">
        <text v-if="title" class="middle-title" :style="{ color: textColor }">{{title}}</text>
        <text v-else-if="pageName" class="middle-title" :style="{ color: textColor }">{{pageName}}</text>
      </slot>
      <div class="right" @click="rightButtonClicked">
        <slot name="right">
          <image v-if="rightButton && !rightText"
                class="right-button"
                :src="rightButton"
                :aria-hidden="true" />
          <text v-if="rightText"
                class="icon-text"
                :style="{ color: textColor }">{{rightText}}</text>
        </slot>
      </div>
    </div>
    <div v-if="breakLineColor != ''" :style="{ backgroundColor: breakLineColor, height: 1 }"></div>
  </div>
</template>

<script>
var Navigator = weex.requireModule('navigator')
const modal = weex.requireModule('modal')
export default {
    components: {  },
     props: {
      backgroundColor: {
        type: String,
        default: '#009ff0'
      },
      leftButton: {
        type: String,
        default: '/web/assets/back_9x16.png'
      },
      textColor: {
        type: String,
        default: 'white'
      },
      rightButton: {
        type: String,
        default: ''
      },
      title: {
        type: String,
        default: ''
      },
      leftText: {
        type: String,
        default: ''
      },
      rightText: {
        type: String,
        default: ''
      },
      useDefaultReturn: {
        type: Boolean,
        default: true
      },
      show: {
        type: Boolean,
        default: true
      },
      breakLineColor: {
        type: String,
        default: '#f0f0f0',
      },
      barStyle: {
        type: Object,
      }
    },
    computed: {

    },
    data() {
         return {   
           height: 40,
           isApp: true,
           pageName: '',
         }
     },
    created() {
      if (WXEnvironment.platform.toLowerCase() === 'web') {
        // this.isApp = false
        this.pageName = this.getUrlParam('title')
      } else if (WXEnvironment.platform.toLowerCase() === 'ios') {
        //IPHONE-X系列高度变换
        if (WXEnvironment.deviceHeight == 2436 || WXEnvironment.deviceHeight == 2688 ||WXEnvironment.deviceHeight ==1792) {
          this.height = 88 * 1125 / WXEnvironment.deviceWidth
        } else {
        this.height = 40 * 750 / WXEnvironment.deviceWidth

        }
        
        console.log('TCM'+ this.height, WXEnvironment.deviceWidth)
        this.pageName = weex.config.title
      }
    },
    methods:{
      leftButtonClicked () {
        if (this.useDefaultReturn) {
          Navigator.pop({}, e => {
          });
        }
        this.$emit('wxcMinibarLeftButtonClicked', {});
      },
      rightButtonClicked () {
        const hasRightContent = this.rightText || this.rightButton || (this.$slots && this.$slots.right);
        hasRightContent && this.$emit('wxcMinibarRightButtonClicked', {});
      },
      getUrlParam: function (name) {
          var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)");
          var r = window.location.search.substr(1).match(reg);
          if (r != null)
            return decodeURI(r[2]); 
          
          return null;
      },
    },
    push: function (option, callback) {
      if (WXEnvironment.platform.toLowerCase() === 'web') {
        option.url = option.url + '?title=' + option.title
        option.url=encodeURI(option.url);
      }
      Navigator.push(option,callback)
    },
    pop: function (option, callback) {
      Navigator.pop(option,callback)
    },

}
</script>

<style scoped>
  .wxc-minibar {
    width: 750px;
    height: 90px;
    flex-direction: row;
    justify-content: space-between;
    align-items: center;
  }
  .left {
    width: 180px;
    padding-left: 32px;
  }
  .middle-title {
    font-size: 36px;
    color: #ffffff;
    height: 36px;
    line-height: 34px;
    font-weight:bold;
  }
  .right {
    width: 180px;
    padding-right: 32px;
    align-items: flex-end;
  }
  .left-button {
    width: 53px;
    height: 36px;
  }
  .right-button {
    width: 32px;
    height: 32px;
  }
  .icon-text {
    font-size: 28px;
    color: #ffffff;
  }
</style>