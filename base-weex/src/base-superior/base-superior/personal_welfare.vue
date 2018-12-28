<template>
    <div class='wrapper' @viewappear="viewappear">
        <navigation title="企业福利"/>
        <web class="web" ref="webview" :src="url" 
             @pagestart="onPageStart" 
             @pagefinish="onPageFinish" 
             @error="onError"></web>
    </div>
</template>

<script>
import navigation from "@/base-superior/components/NavigationBar.vue";
var webview = weex.requireModule('webview');
const modal = weex.requireModule('modal');

export default {
    components: {navigation },
    data() {
        return {
            isAndroid:WXEnvironment.platform === 'android',
            url:'https://s3.cn-north-1.amazonaws.com.cn/h5.taocaimall.net/webResources/welfare/index.html',
        }
    },
    created() {

    },
    methods: {
        viewappear(){
            if(this.isAndroid){
                var webElement = this.$refs.webview;
                webview.goBack(webElement);
            }
        },
        onPageStart (event) {
        // page start load
          if(this.isAndroid){
              if(event.url.substr(0, 4) == "tel:"){
                  let tel = event.url.substring(4,event.url.length);
                  weex.requireModule('myGlobalEvent').telCall(tel)
                  var webElement = this.$refs.webview;
                  this.$set(webElement.attr,'src',this.url)
                  webElement.attr.src = this.url;
              }
          }
        },
        onPageFinish (event) {
        // page finish load
        if(this.isAndroid){
            const self = this;
              if(event.url.substr(0, 4) == "tel:"){
                  var webElement = self.$refs.webview;
                  webview.goBack(webElement);
              }
          }
        },
        onError (event) {
        // page load error
        },
    }
}
</script>

<style scoped>
.wrapper { 
    align-items: center;
}
.web {
    width: 750px;
    flex: 1;
}
</style>
