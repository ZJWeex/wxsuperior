<template>
    <div class='wrapper'>
        <navigation title="特别声明"/>
        <div class="panel">
            <text class="text" lines="0">淘菜猫优选在此声明，您通过本软件参加的商业活动，与Apple Inc. 无关。</text>
        </div>
    </div>
</template>

<script>
const modal = weex.requireModule("modal");
import navigation from "@/base-superior/components/NavigationBar.vue";

export default {
    components: {navigation},
    data() {
        return {};
    },
    created() {},
    methods: {}
};
</script>

<style scoped>
.wrapper {
    justify-content: top;
    /* align-items: center; */
}
.panel {
    /* margin-left: 0px;
    margin-right: 0px;
    border-width: 2px;
    border-style: solid;
    border-color: #BBB; */
    padding-top: 18px;
    padding-bottom: 18px;
    padding-left: 25px;
    padding-right: 25px;
}
.text {
    color: #333333;
    font-size: 28px;
    text-align: center;
}
</style>
