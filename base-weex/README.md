# Introduction

This boilerplate is targeted towards large, serious projects and assumes you are somewhat familiar with Webpack and `weex-loader`. 

## Quickstart

To use this template, scaffold a project with [weexpack v1.1.1+](https://github.com/weexteam/weex-pack).

``` bash
$ npm install -g weex-toolkit
$ weex create my-project # default will create the webpack template
$ cd my-project && npm start
```

## How to use less/sass/pug

Take `sass` for example:

```
$ npm i node-sass sass-loader --save
```

Then, you just need to change the `style` tag as: `<style lang="sass"><style>`.

## How to create your own template

See [How-to-create-your-own-template](https://github.com/weex-templates/How-to-create-your-own-template).

## 运行环境判断

### 开发环境 启动服务器
```
$ npm start 
或
$ npm run serve

process.env.NODE_ENV === 'development'
上传到服务器后,因为并没有上传webpage配置
process.env.NODE_ENV === 'undefined'

```

优化WEEX编译速度
添加html-webpack-plugin-for-multihtml

npm install html-webpack-plugin-for-multihtml
