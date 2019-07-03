<template>
<div class="wrapper">
    <navigationSearch title="搜索商品" :showInput="false"
                        @wxcMinibarMiddleButtonClicked='wxcMinibarMiddleButtonClicked'/>
    <ClassList  v-if="classId" class="classlist"
        :classId="classId"
        :subPage="true"
        :style="{ height: pageHight}"></ClassList>
    <div v-else>
        
    </div>
</div>
</template>

<!-- JS -->
<script>
import ClassList from "@/base-superior/homepage_classList.vue";
import navigationSearch from "@/base-superior/components/NavigationBarSearch.vue";

const modal = weex.requireModule('modal');
const storage = weex.requireModule('storage')

export default {

     //导入组件注册
    components: {ClassList, navigationSearch},
    //变量申明及初始化
    data() {
        return {
            pageHight: navigationSearch.pageHeight(false),
            classId: null,
        };
    },
    //页面创建完成
    created: function() {
        var self = this
        storage.getItem('homepage_subPage', event=>{
            console.log(event)
            if (event.result === 'success') {
                self.classId = JSON.parse(event.data).classId;
            }
        });
    },
    //
    methods: {
        wxcMinibarMiddleButtonClicked () {
            console.log('点击搜索')
            // 搜索界面
            navigationSearch.push({url:'homepage_search.html', title:''}, event =>{});
        },
    }
};
</script>

<!-- Style -->
<style scoped>
.wrapper { 
    width: 750px; 
    align-items: center;
    background-color: #f5f5f9;
}
</style>
