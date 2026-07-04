<template>
  <div class="login-wrapper">
    <div class="login-box">
      <div class="login-header">
        <div class="brand-icon-wrapper">
          <Ticket class="brand-icon" :size="36" />
        </div>
        <h2 class="title">欢迎来到校园大麦</h2>
      </div>

      <form @submit.prevent="handleLogin" class="login-form">
        <div class="input-group">
          <Smartphone class="input-icon" :size="20" />
          <input 
            type="text" 
            v-model="loginForm.phone" 
            placeholder="请输入手机号" 
            required 
          />
        </div>

        <div class="input-group">
          <Lock class="input-icon" :size="20" />
          <input 
            type="password" 
            v-model="loginForm.password" 
            placeholder="请输入密码" 
            required 
          />
        </div>

        <div v-if="errorMessage" class="error-msg">
          <AlertCircle :size="16" />
          <span>{{ errorMessage }}</span>
        </div>

        <button type="submit" class="submit-btn" :disabled="isLoading">
          <Loader2 v-if="isLoading" class="spin-icon" :size="20" />
          <span>{{ isLoading ? '登录中...' : '立即登录' }}</span>
        </button>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import axios from 'axios'
// 引入专业线性图标
import { Ticket, Smartphone, Lock, AlertCircle, Loader2 } from 'lucide-vue-next'

const router = useRouter()

// 表单绑定的数据
const loginForm = reactive({
  phone: '',
  password: ''
})

const isLoading = ref(false)
const errorMessage = ref('')

// 点击登录按钮触发
const handleLogin = async () => {
  if (!loginForm.phone || !loginForm.password) return

  isLoading.value = true
  errorMessage.value = ''

  try {
    const response = await axios.post('http://localhost:8080/user/login', {
      phone: loginForm.phone,
      passwordHash: loginForm.password 
    })

    if (response.data.code === 200) {
      const loginResult = response.data.data
      
      localStorage.setItem('token', loginResult.token)
      localStorage.setItem('userName', loginResult.userName)
      localStorage.setItem('userId', loginResult.userId)
      
      router.push('/')
    } else {
      errorMessage.value = response.data.msg
    }
  } catch (error) {
    console.error('登录请求失败:', error)
    errorMessage.value = '服务器连接失败，请检查后端是否启动'
  } finally {
    isLoading.value = false
  }
}
</script>

<style scoped>
/* ================= 全局颜色变量 (大麦官方规范) ================= */
.login-wrapper {
  --primary-red: #FF1268;
  --bg-light: #F5F6F8;
  --text-primary: #1D2129;
  --text-secondary: #666666;
  --text-white: #FFFFFF;
  --border-light: #E5E6EB;

  display: flex;
  justify-content: center;
  align-items: center;
  min-height: calc(100vh - 72px); /* 减去顶部导航栏高度 */
  background-color: var(--bg-light); /* 浅灰底色衬托纯白卡片 */
}

/* ================= 纯白登录卡片 ================= */
.login-box {
  width: 100%;
  max-width: 420px;
  padding: 48px 40px;
  background: var(--text-white);
  border: 1px solid var(--border-light);
  border-radius: 20px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.04); /* 极其克制的阴影 */
}

/* ================= 头部区域 ================= */
.login-header {
  text-align: center;
  margin-bottom: 40px;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.brand-icon-wrapper {
  display: flex;
  justify-content: center;
  align-items: center;
  width: 64px;
  height: 64px;
  background-color: #FFF0F4;
  border-radius: 50%;
  margin-bottom: 16px;
}

.brand-icon {
  color: var(--primary-red);
}

.title {
  color: var(--text-primary);
  margin: 0 0 8px 0;
  font-size: 1.6rem;
  font-weight: bold;
}

.subtitle {
  color: var(--text-secondary);
  font-size: 0.95rem;
  margin: 0;
}

/* ================= 表单区域 ================= */
.login-form {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

/* 输入框组：胶囊态 */
.input-group {
  display: flex;
  align-items: center;
  background: var(--bg-light);
  border: 1px solid transparent;
  border-radius: 999px; /* 极限圆角 */
  padding: 8px 20px;
  transition: all 0.3s ease;
}

/* 焦点状态：边框变红并浮现红色光晕 */
.input-group:focus-within {
  background: var(--text-white);
  border-color: var(--primary-red);
  box-shadow: 0 0 0 3px rgba(255, 18, 104, 0.1);
}

.input-icon {
  color: #999;
  margin-right: 12px;
}

/* 输入框被激活时，图标也跟着变红 */
.input-group:focus-within .input-icon {
  color: var(--primary-red);
}

.input-group input {
  flex: 1;
  border: none;
  background: transparent;
  padding: 10px 0;
  font-size: 1.05rem;
  color: var(--text-primary);
  outline: none;
}

.input-group input::placeholder {
  color: #bbb;
}

/* ================= 错误提示 ================= */
.error-msg {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  color: #ff4d4f;
  font-size: 0.9rem;
  background-color: #fff2f0;
  padding: 10px;
  border-radius: 8px;
  border: 1px solid #ffccc7;
}

/* ================= 大麦红登录按钮 ================= */
.submit-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  background: var(--primary-red);
  color: var(--text-white);
  border: none;
  padding: 14px;
  font-size: 1.15rem;
  font-weight: bold;
  border-radius: 999px;
  cursor: pointer;
  box-shadow: 0 4px 16px rgba(255, 18, 104, 0.25);
  transition: all 0.3s ease;
  margin-top: 10px;
}

.submit-btn:hover:not(:disabled) {
  background: #e00d5a;
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(255, 18, 104, 0.35);
}

.submit-btn:active:not(:disabled) {
  transform: translateY(0);
}

.submit-btn:disabled {
  background: #ffb4c8;
  box-shadow: none;
  cursor: not-allowed;
}

/* 按钮加载动画 */
.spin-icon {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}
</style>