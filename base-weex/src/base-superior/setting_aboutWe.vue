<template>
    <div>
        <navigation title="关于我们"/>
        <scroller class="scroller" alwaysScrollableVertical='true' scroll-direction="vertical">
            <div class="content">
                <image class="iconImage" :src=topImg resize="contain" />
                <text style="color:#ff0033 ;font-size: 40px;margin:40px">{{appInfo}}</text>
                <text style="font-size: 34px;padding-bottom:20px">{{appName}} 版权所有</text>
                <text style="text-align: center;margin-left: 20px;margin-right: 20px;">Copyright © 2019-2020 Taocaimall Information Development Inc. All Rights Reserved</text>
            </div>
        </scroller>
    </div>
</template>

<style scoped>

.scroller {
   width: 750px;
   height: 1000px;
}
.content {
    align-items: center;
    padding-top: 50px;
}
.iconImage {
    width: 490px;
    height: 280px;
    /* background-color: #f9f9f9; */
}
</style>

<script>
import navigation from "@/base-superior/components/NavigationBar.vue";

export default {
    components: { navigation },
    data() {
        return {
            topImg:  "/web/assets/sup/sup_setting_aboutUsTopImg.png",
            appInfo: '淘菜猫优选  v'+WXEnvironment.appVersion,
            appName: '淘菜猫优选 ',
        }
    }
}
</script>
