<template>
    <div class='wrapper'>
        <navigation :title="title" @wxcMinibarLeftButtonClicked="goBack" :use-default-return='false'/>
        <div class="web">
            <web ref="webview" class="web" :src="url" 
                @pagestart="onPageStart" 
                @pagefinish="onPageFinish" 
                @error="onError"></web>
            <div ref="progress" class="progress"></div>
        </div>
    </div>
</template>

<script>
import navigation from "@/base-superior/components/NavigationBar.vue";

const modal = weex.requireModule('modal');
const storage = weex.requireModule("storage");

export default {
    components: { navigation },
    data() {
        return {
            canGoBack: false,
            url:"",
            title:'隐私权政策'
        }
    },
    created(){

        storage.getItem('web_url', event => {
          console.log('web_url:', event.data)
        //   event.data = {url:'',title:''}
          if(event.data && event.data != 'undefined'){
              var obj = JSON.parse(event.data)
              this.url = obj.url;
              this.title = obj.title;
              storage.removeItem('web_url',event => {})
          }
        });
    },
    methods: {
        //返回刷新
        goBack: function() {
            /*
            if(this.canGoBack == true){
                var webview = weex.requireModule('webview');
                webview.goBack(this.$refs.webview);
            }else{
                navigation.pop({pop:true},event=>{});
            }*/ 
            navigation.pop({pop:true},event=>{});
        },
        
        onPageStart: function(e) {
            console.log(e.url)
            this.progressAnimation(0.7);
        },
        onPageFinish: function(e) {
            this.canGoBack = e.canGoBack;
            this.progressAnimation(1.0);
            if (e.title) {
                this.title = e.title;
                console.log(e.title)
            }
        },
        onError: function(e) {
            console.log(e.url)
            this.progressAnimation(1.0);
        },
        //进度动画
        progressAnimation:function(progress){
            const animation = weex.requireModule('animation')
            var deviceWidth =WXEnvironment.deviceWidth
            if(progress>1){
                progress = 1.0
            }else if(progress<0){
                progress = 0;
            }
            let width = progress * deviceWidth;
            var progressEl = this.$refs.progress;
            animation.transition(progressEl, {
            styles: {
                width: width,
            },
            duration: 500, //ms
            timingFunction: 'ease',
            delay: 0 
            }, function () {
                if(progress == 1.0){
                    animation.transition(progressEl, {
                    styles: { width: 0 },
                    duration: 0, 
                    delay: 0 
                    }, function () {})
                }
                
            })
        },
    }
}
</script>

<style scoped>
.wrapper { 
    flex-direction: column;
    background-color: #ffffff;
    display: flex;
}
.progress {
    position:absolute;
    top: 0;
    left: 0;
    width: 0;
    height: 4px;
    background-color: red;
}
.web {
    width: 750px;
    flex: 1;
}
</style>
