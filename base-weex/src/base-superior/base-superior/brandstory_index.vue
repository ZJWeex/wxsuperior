<template>
    <div class='wrapper'>
        <navigation title="品牌故事" left-button=""/>
        <!-- <web class="web" :src="url"></web> -->
        <list class="list">
            <cell v-for="(url, index) in imgList" :key="index">
                <image class="img" :src="url"/>
            </cell>
        </list>
    </div>
</template>

<script>
import navigation from "@/base-superior/components/NavigationBar.vue";

const modal = weex.requireModule('modal');

export default {
    components: {navigation },
    data() {
        return {
            url:'',
            imgList:['https://s3.cn-north-1.amazonaws.com.cn/h5.taocaimall.net/app/banner/2017/images/0307/pic_01.jpg',
                    'https://s3.cn-north-1.amazonaws.com.cn/h5.taocaimall.net/app/banner/2017/images/0307/pic_02.jpg',
                    'https://s3.cn-north-1.amazonaws.com.cn/h5.taocaimall.net/app/banner/2017/images/0307/pic_03.jpg',
                    'https://s3.cn-north-1.amazonaws.com.cn/h5.taocaimall.net/app/banner/2017/images/0307/pic_04.jpg',
                    'https://s3.cn-north-1.amazonaws.com.cn/h5.taocaimall.net/app/banner/2017/images/0307/pic_05.jpg',
                    'https://s3.cn-north-1.amazonaws.com.cn/h5.taocaimall.net/app/banner/2017/images/0307/pic_06.jpg'],
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
    background-color: whitesmoke;
}
.web {
    width: 750px;
    flex: 1;
}
.list {
    width: 750px;
    flex: 1;
}
.img {
    height:630px;
    width: 750px;
    background-color: #f0f0f0;
}
</style>
