<template>
    <wxc-mask :height="[warn?'410':'620']" width="680" border-radius="10" duration="200" 
              mask-bg-color="#FFFFFF"
              :has-overlay="true" 
              :overlay-can-close='false'  
              :show="showAlert">
        <div>
            <div class="content">
                <div class="demo-title">
                    <text v-if="warn" class="title">隐私保护提示</text>
                    <text v-else class="title">淘菜猫隐私政策</text>
                </div>
                <div v-if="warn">
                    <text class="content-text">淘菜猫坚决保障您的隐私信息安全，您的信息仅用于为您提供服务或改善服务体验，如果您确实无法认同此政策，可点击不同意并退出此应用。
                    </text>
                </div>
                <div v-else>
                    <text class="content-text">欢迎使用“淘菜猫优选”！我们非常重视您的个人信息和隐私保护。在您使用“淘菜猫优选”之前，请仔细阅读</text>
                    <text style="color: #ff0033;font-size: 28px;" @click="onclick">《淘菜猫隐私权政策》</text>
                    <text class="content-text">，我们将严格按照您同意的各项条款使用您的个人信息，以便为您提供更好的服务。
                    </text>
                    <text style="color:#999999;font-size:24px;">如您同意此政策，请点击“同意”并开始使用我们的产品和服务，我们会全力保护您的个人隐私安全。
                    </text>
                </div>
            </div>
            <div style="flex-direction: row;height:100px;border-top-color:#f0f0f0;border-top-width:2px;margin-top:20px;">
                <div class="footer-btn btn-rightborder" @click="cancelBtnClicked">
                    <text v-if="warn" class="cancel-text">不同意退出</text>
                    <text v-else class="cancel-text">不同意</text>
                </div>
                <div class="footer-btn" @click="confirmBtnClicked">
                    <text class="confirm-text">同意</text>
                </div>
            </div>
        </div>
    </wxc-mask>
</template>

<script>
import { WxcMask } from "weex-ui";

const modal = weex.requireModule("modal");
const storage = weex.requireModule("storage");
const navigator = weex.requireModule("navigator");

export default {
    components: { WxcMask },
    data() {
        return {
            showAlert: false,
            warn:false,
        };
    },
    created() {
        const self = this
        storage.getItem("Agree_Privacy",event=>{
            if(event.data == 'Agree_Privacy'){
                self.showAlert = false;
            }else{
                self.showAlert = true;
            }
        })
    },
    methods: {
        cancelBtnClicked: function() {
            const self = this;
            if(self.warn){
                //该方法不可用
                // self.exit(1);
                modal.toast({message:"不可退出"})
            }else{
                this.showAlert = false;
                setTimeout(()=>{
                    self.warn = true;
                    self.showAlert = true;
                },200)
            }
        },
        confirmBtnClicked: function() {
            this.showAlert = false;
            storage.setItem("Agree_Privacy","Agree_Privacy",event=>{})
        },
        onclick:function(){
            var objc = {url:'https://s3.cn-north-1.amazonaws.com.cn/www.taocaimall.com/webResources/tcmApp_page/lawInfo.html',
                            title:'隐私权政策'}
                storage.setItem('web_url',JSON.stringify(objc),event =>{})
                navigator.push({
                        url: "setting_agreementWeb.html",
                        title:'隐私权政策',
                        animated: "true"
                    },event => {
                        console.log("结果回调");
                    }
                );
        }
    }
};
</script>

<style scoped>
.content {
    padding-left: 30px;
    padding-right: 30px;
}
.demo-title {
    align-items: center;
    margin-bottom: 40px;
    margin-top: 40px;
}
.title {
    color: #333333;
    font-size: 36px;
    font-weight: bold;
}
.content-text {
    color: #333333;
    font-size: 28px;
}
.footer-btn {
    justify-content: center;
    align-items: center;
    flex: 1;
}
.btn-rightborder{
    border-right-color: #f0f0f0;
    border-right-width: 2px;
}
.cancel-text {
    font-size: 36px;
    color: #666666;
}
.confirm-text {
    font-size: 36px;
    color: #ff0033;
}
</style>
