<template>
    <div class='wrapper'>
        <navigation :title="title"/>
        <web class="web" :src="url"></web>
    </div>
</template>

<script>
import navigation from "@/base-superior/components/NavigationBar.vue";

const modal = weex.requireModule('modal');
const storage = weex.requireModule("storage");

export default {
    components: { navigation },
    data() {
        return {
            url:"",
            title:'隐私权政策'
        }
    },
    created(){

        storage.getItem('web_url', event => {
          console.log('web_url:', event.data)
        //   event.data = {url:'',title:''}
          if(event.data && event.data != 'undefined'){
              var obj = JSON.parse(event.data)
              this.url = obj.url;
              this.title = obj.title;
              storage.removeItem('web_url',event => {})
          }
        });
    },
    methods: {

    }
}
</script>

<style scoped>
.wrapper { 
    flex-direction: column;
    background-color: #ffffff;
    display: flex;
}
.web {
    width: 750px;
    flex: 1;
}
</style>
