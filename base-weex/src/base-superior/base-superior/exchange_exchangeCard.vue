<template>
    <div class='wrapper'>
        <navigation title="商品兑换"/>
    </div>
</template>

<script>
import navigation from "@/base-superior/components/NavigationBar.vue";

const modal = weex.requireModule('modal');

export default {
    components: {navigation },
    data() {
        return {

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
</style>
