<template>
    <div class='wrapper'>
        <navigation title="企业福利"/>
        <web class="web" :src="url"></web>
    </div>
</template>

<script>
import navigation from "@/base-superior/components/NavigationBar.vue";

const modal = weex.requireModule('modal');

export default {
    components: {navigation },
    data() {
        return {
            url:'https://s3.cn-north-1.amazonaws.com.cn/h5.taocaimall.net/webResources/welfare/index.html',
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
}
.web {
    width: 750px;
    flex: 1;
}
</style>
