<script setup lang="ts">
import { ref, watch } from 'vue'
import { RouterView, RouterLink, useRoute, useRouter } from 'vue-router'
// 引入 Lucide 线性图标
import { Ticket, CircleUser, LogOut } from 'lucide-vue-next'

const route = useRoute()
const router = useRouter()

const isLoggedIn = ref(false)
const userName = ref('') 

watch(
  () => route.path,
  () => {
    const token = localStorage.getItem('token')
    isLoggedIn.value = !!token 
    
    if (token) {
      userName.value = localStorage.getItem('userName') || '未知用户'
    }
  },
  { immediate: true } 
)

// 退出登录
const handleLogout = () => {
  if (!confirm('确定要退出登录吗？')) return
  
  localStorage.removeItem('token')
  localStorage.removeItem('userName')
  localStorage.removeItem('userId') // 顺手把 userId 也清掉
  
  isLoggedIn.value = false
  router.push('/login')
}
</script>

<template>
  <div id="app">
    <header class="navbar">
      <div class="logo">
        <Ticket class="logo-icon" :size="28" :stroke-width="2.5" />
        校园大麦 <span class="logo-en">Campus Damai</span>
      </div>
      
      <nav class="nav-links">
        <RouterLink to="/">大厅首页</RouterLink>
        <RouterLink to="/my-tickets">我的票夹</RouterLink>
        <RouterLink to="/admin">发布活动</RouterLink>

        <RouterLink v-if="!isLoggedIn" to="/login" class="login-btn">
          登录 / 注册
        </RouterLink>

        <div v-else class="user-profile">
          <div class="avatar-capsule">
            <CircleUser class="avatar-icon" :size="18" />
            <span class="username">{{ userName }}</span>
          </div>
          <button class="logout-btn" @click="handleLogout">
            <LogOut :size="14" />
            退出
          </button>
        </div>
      </nav>
    </header>

    <main class="main-content">
      <RouterView />
    </main>
  </div>
</template>

<style>
/* 全局样式清除与底色设定 */
body {
  margin: 0;
  padding: 0;
  background-color: #F5F6F8; /* 大麦极简浅灰底色 */
}
</style>

<style scoped>
/* ================= 全局颜色变量 (大麦官方规范) ================= */
#app {
  --primary-red: #FF1268;
  --primary-orange: #FF5400;
  --bg-light: #F5F6F8;
  --text-primary: #1D2129;
  --text-secondary: #666666;
  --text-white: #FFFFFF;
  --border-light: #E5E6EB;
  
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
  color: var(--text-primary);
  min-height: 100vh;
}

/* ================= 导航栏区域 ================= */
.navbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 40px;
  height: 72px; /* 增加导航栏高度，显得更大气 */
  background-color: var(--text-white);
  border-bottom: 1px solid var(--border-light);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.02);
  position: sticky;
  top: 0;
  z-index: 100;
}

.logo {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 1.4rem;
  font-weight: 800;
  color: var(--primary-red); 
}

.logo-en {
  font-size: 1rem;
  font-weight: 600;
  color: var(--text-primary);
  margin-top: 4px;
}

/* ================= 导航链接 ================= */
.nav-links {
  display: flex;
  gap: 30px;
  align-items: center;
}

.nav-links a {
  text-decoration: none;
  color: var(--text-secondary);
  font-weight: 600;
  font-size: 1.05rem;
  transition: color 0.2s;
}

.nav-links a:hover, .nav-links a.router-link-active {
  color: var(--primary-red); /* 悬浮和选中时变为大麦红 */
}

/* ================= 登录与用户状态 ================= */
.login-btn {
  background-color: var(--primary-red);
  color: var(--text-white) !important;
  padding: 8px 24px;
  border-radius: 999px; /* 极限胶囊圆角 */
  font-size: 0.95rem;
  font-weight: bold;
  transition: all 0.2s ease;
}

.login-btn:hover {
  background-color: #e00d5a; /* 稍微深一点的红色 */
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(255, 18, 104, 0.3);
}

.user-profile {
  display: flex;
  align-items: center;
  gap: 16px;
}

/* 用户名胶囊 */
.avatar-capsule {
  display: flex;
  align-items: center;
  background-color: var(--bg-light);
  border: 1px solid var(--border-light);
  padding: 6px 16px 6px 12px;
  border-radius: 999px;
  gap: 8px;
  color: var(--text-primary);
}

.avatar-icon {
  color: var(--text-secondary);
}

.username {
  font-weight: 600;
  font-size: 0.95rem;
}

/* 退出按钮 */
.logout-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  background: transparent;
  border: 1px solid var(--border-light);
  color: var(--text-secondary);
  padding: 6px 16px;
  border-radius: 999px;
  cursor: pointer;
  font-size: 0.9rem;
  font-weight: 600;
  transition: all 0.2s ease;
}

.logout-btn:hover {
  border-color: var(--primary-red);
  color: var(--primary-red);
  background-color: #fff0f4; /* 极浅的红色背景 */
}

/* ================= 主体内容区 ================= */
.main-content {
  padding: 0; /* 留给各个视图组件自行决定内边距 */
}
</style>