import Vue from 'vue'
import weex from 'weex-vue-render'

// import drag from 'v-drag.js'
// 全局注册拖拽指令
Vue.directive('drag', {
    inserted: function(el) {
        el.drag()
    }
})
Vue.use(drag)

weex.init(Vue)
    /*
    <template>
  <div>
    <text style="height:100px;font-size:20px;">{{forceValue}}</text>
    <div style="width:600px;height:800px;top:40px;left:40px;background-color:red;">
      <text ref="fixed" style="font-size:20px; border-width:2px;width:100px;height:100px;top:40px;left:40px" 
            ontouchcancel='ontouchcancel' 
            @touchstart="ontouchstart" 
            @touchmove="ontouchmove" 
            @touchend="ontouchend"
            >{{forceValue}}</text>
    </div>
  </div>
</template>

<script>
const animation = weex.requireModule('animation')

   module.exports = {
     data:{
       forceValue:0,
     },
     methods:{
       ontouchstart:function(e) {
         console.log("ontouchStart")
         var changedTouche = e.changedTouches[0];
         console.log("identifier "+changedTouche.identifier)
         console.log("pageX "+changedTouche.pageX)
         console.log("screenX "+changedTouche.screenX)
         var fixed = this.$refs.fixed
         animation.transition(fixed,{
                    styles:{
                        transform:`translate(${changedTouche.pageX-140}px, ${changedTouche.pageY-240}px)`,
                        transformOrigin: 'center center'
                    },
                    duration: 0,
                    needLayout:false,
                    delay: 0
                },function (){});
                
         this.forceValue = "ontouchStart: pageX:"+changedTouche.pageX+",screenX:"+changedTouche.screenX+",pageY:"+changedTouche.pageY+",screenY:"+changedTouche.screenY;
       },
       ontouchmove:function(e) {
          console.log("ontouchMove ")
          var changedTouche = e.changedTouches[0];
         console.log("identifier "+changedTouche.identifier)
         console.log("pageX "+changedTouche.pageX)
         console.log("screenX "+changedTouche.screenX)
         var fixed = this.$refs.fixed
         animation.transition(fixed,{
                    styles:{
                        transform:`translate(${changedTouche.pageX-140}px, ${changedTouche.pageY-240}px)`,
                        transformOrigin: 'center center'
                    },
                    duration: 0,
                    needLayout:false,
                    delay: 0
                },function (){});
         this.forceValue = "ontouchMove: pageX:"+changedTouche.pageX+",screenX:"+changedTouche.screenX+",pageY:"+changedTouche.pageY+",screenY:"+changedTouche.screenY;
       },
       ontouchend:function(e) {
         console.log("ontouchEnd ")
          var changedTouche = e.changedTouches[0];
         console.log("identifier "+changedTouche.identifier)
         console.log("pageX "+changedTouche.pageX)
         console.log("screenX "+changedTouche.screenX)
         this.forceValue = "ontouchEnd: pageX:"+changedTouche.pageX+",screenX:"+changedTouche.screenX+",pageY:"+changedTouche.pageY+",screenY:"+changedTouche.screenY;
       },
       ontouchcancel:function(e) {
           //如电话接入或者弹出信息,触发touchcancel
          console.log("ontouchCancel ")
       }
     }
   }
</script>
     */