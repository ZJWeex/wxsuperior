<!-- banner组件  -->
<template recyclable>
 <div>
     <div v-if="this.goodsImgURLs.length>1">
         <slider class="slider" auto-play="true" interval="3000">
             <div v-for="(img, index) in goodsImgURLs" :key="index">
                 <image class="img" :src= "img" resize='stretch' @click="onImgClick(index)"/>
             </div>
             <indicator class="Indicator"></indicator>
         </slider>
     </div>
     <div v-else>
         <image class="img" v-for="(img, index) in goodsImgURLs" 
         :key="index" 
         :src= "img" resize='stretch' 
         @click="onImgClick(index)"/>
     </div>
 </div>
</template>

<script>
var modal = weex.requireModule('modal');
export default {
    //定义属性
    props: {
        goodsImgURLs:{
            default:  function(){
                return ['https://gd1.alicdn.com/bao/uploaded/i1/TB1PXJCJFXXXXciXFXXXXXXXXXX_!!0-item_pic.jpg']
            } 
        }
     },
    data() {
        return {
        }
    },
    methods: {
        onImgClick:function(index) {
            console.log('index ='+index)
            this.$emit('sliderSelectIndex',index)
        }
    }
}
</script>

<style scoped>
.slider {
    height: 450px;
  }
  .Indicator {
    width: 730px;
    height: 30px;
    item-color: #808080;
    item-selected-color: #FFFFFF;
    item-size: 15px;
    position: absolute;
    bottom: 30px;
  }
.img {
   width: 750px;
   height: 450px 
}
</style>