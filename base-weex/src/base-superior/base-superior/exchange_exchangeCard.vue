<template>
    <div class='wrapper'>
        <navigation title="商品兑换"/>
        <div style="align-items: center;justify-content: center;flex:1;">
            <div class="ui-btn">
                <div class="progressView" :style="progressStyle">
                    <div class="progressInner"></div>
                </div>
            </div>
        </div>
        <wxc-result type="noGoods"
              :show="show"
              :custom-set="customSet"
              :wrap-style="{top:176}"
              padding-top="232">
        </wxc-result>
    </div>
</template>

<script>
import navigation from "@/base-superior/components/NavigationBar.vue";
import { WxcResult } from 'weex-ui';
const modal = weex.requireModule('modal');

export default {
    components: {navigation,  WxcResult },
    data() {
        return {
            show:false,
            customSet:{noGoods: { button: null, content: '没有可兑换商品', desc: '' }},
            progress: 0,
        }
    },
    created() {

    },
    mounted () {
       let timer = setInterval(() => {
            if(this.progress >= 1){
                this.show = true;
                clearInterval(timer);
            }else{
                this.progress += 0.01;
            }
        }, 100);
    },
    computed: {
        progressStyle(){
            let width = 360;
            let progressWidth = this.progress * width;

            if(weex.config.env.platform === 'Web'){
                progressWidth = progressWidth / 2;
            }
            if(this.progress === 0){
                progressWidth  = 0.1
            }
            return {
                width : progressWidth + 'px'
            }
        }
    },
    methods: {

    }
}
</script>

<style scoped>
.wrapper { 
    align-items: center;
    background-color: #F5F5F5;
}
.ui-btn{
        width: 360px;
        height:60px;
        font-size: 24px;
        background-color: #ffffff;
        border-width: 1px;
        border-color: #888899;
        border-style: solid;
        border-radius: 30px;
        align-items: center;
        justify-content: center;
        background-image: none;
        opacity: 1;
    }
    .progressView{
        position: absolute;
        left:-1px;
        top:-1px;
        width: 10px;
        height:60px;
        overflow:hidden;
    }

    .progressInner{
        width: 360px;
        height:60px;
        border-radius: 30px;
        background-image: linear-gradient(to right,#FFD980,#E6BC5C);
    }
</style>
