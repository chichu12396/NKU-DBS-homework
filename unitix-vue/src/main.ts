import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import axios from 'axios'


axios.interceptors.request.use(config => {
  // 1. 去浏览器的本地钱包里找找有没有 token
  const token = localStorage.getItem('token')
  
  // 2. 如果有 token，就把前端通行证塞进请求头 (Header) 里
  if (token) {
    config.headers['token'] = token
  }
  return config
}, error => {
  return Promise.reject(error)
})
// ---------------------------------

const app = createApp(App)

app.use(router)

app.mount('#app')