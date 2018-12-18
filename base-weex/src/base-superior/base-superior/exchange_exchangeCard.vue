<template>
    <div class='wrapper'>
        <navigation title="商品兑换"/>
        <wxc-result type="noGoods"
              :show="true"
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
            customSet:{noGoods: { button: null, content: '没有可兑换商品', desc: '' }},
        }
    },
    created() {

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
</style>
