import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '../views/HomeView.vue'
import LoginView from '../views/LoginView.vue'
import EventDetailView from '../views/EventDetailView.vue'
import MyTicketsView from '../views/MyTicketsView.vue'
import AdminView from '../views/AdminView.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: HomeView
    },
    {
      path: '/login',
      name: 'login',
      component: LoginView
    },
    {
      // 注意这里的 :id，这是一个动态路由，用来接收不同活动的 ID
      path: '/event/:id', 
      name: 'eventDetail',
      component: EventDetailView
    },
    {
      path: '/my-tickets',
      name: 'myTickets',
      component: MyTicketsView
    },
    {
      path: '/admin',
      name: 'admin',
      component: AdminView
    }
  ]
})

export default router