<!-- 规格九宫格组件  -->
<template recyclable>
  <div class="content">
    <text style="font-size: 30px; margin: 10px;padding-top: 10px;">规格：</text>
    <div class="wrap">
        <div class="items" v-for="(item, index) in specs" :key="index">
            <!-- 移动端不支持下面的设置方式 -->
            <!--
            <text :class="[item.selfFlag === 'true'? 'item-select':'item-none']" @click="itemClick(item)">{{item.supGoodsAliasName}}</text>
            -->
            <div v-if="item.supGoodsId === selectId">
                <text class="item-select"  @click="itemClick(item)">{{item.supGoodsAliasName}}</text>
            </div>
            <div v-else>
                <text class="item-none"  @click="itemClick(item)">{{item.supGoodsAliasName}}</text>
            </div>
        </div>
    </div>
  </div>
</template>

<script>
const modal = weex.requireModule("modal");

export default {
    //定义属性,移动端不可设置type,且prop定义的属性在当前组件中不可修改
    props: {specs:
                {
                //  type: Array,
                 default:function(){
                       return [{supGoodsAliasName:'默认值', supGoodsId:'780949458800914432'},
                               {supGoodsAliasName:'默认值1', supGoodsId:'764587003762225152'}]
                      } 
                },
            selectId:''
           },

    data() {
        return {
           select_id: '' 
        }
    },
    mounted: function () {
        console.log('selectid'+this.selectId)
    },
    methods: {
        itemClick:function(sender){
            var that = this
            if(sender.supGoodsId === that.select_id){
                console.log('当前选中')
            }else{
                console.log('改变选中' + sender.supGoodsId)
                //若直接使用selectId则会报错
                //[Vue warn]: Avoid mutating a prop directly since the value will be overwritten whenever the parent component re-renders. Instead, use a data or computed property based on the prop's value. Prop being mutated: "selectId"
                that.select_id = sender.supGoodsId;
                //自定义事件
                that.$emit('changeItem', sender.supGoodsId);
            }
        }
    }

}
</script>

<style scoped>
.content{
    flex-direction: row;
}
.wrap{
    width: 630px;
    flex: 1;
    flex-direction: row;
    flex-wrap: wrap;
    justify-content: flex-start;
    align-items: center;
    background-color: white;
}
.items {
    margin: 10px;
    border-radius: 20px;
}
.item {
    background-color: brown;
    font-size: 30px;
    text-align: center;
    color: white;
    margin: 10px;
    padding-top: 10px;
    padding-bottom: 10px;
    padding-left: 10px;
    padding-right: 10px;
    border: 5px;
    border-radius: 5px;
}
.item-select {
    background-color: brown;
    font-size: 30px;
    text-align: center;
    color: white;
    margin: 10px;
    padding-top: 10px;
    padding-bottom: 10px;
    padding-left: 10px;
    padding-right: 10px;
    border: 5px;
    border-radius: 5px;
}
.item-none {
    background-color: #f5f5f5;
    font-size: 30px;
    text-align: center;
    color: #666666;
    margin: 10px;
    padding-top: 10px;
    padding-bottom: 10px;
    padding-left: 10px;
    padding-right: 10px;
    border: 5px;
    border-radius: 5px;
}
</style>
