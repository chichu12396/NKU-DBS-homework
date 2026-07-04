<template>
  <main class="detail-container">
    <div class="nav-bar">
      <button class="back-btn" @click="goBack">
        <ChevronLeft :size="20" />
        返回大厅
      </button>
    </div>

    <div v-if="!eventData" class="loading-state">
      <Loader2 class="spin-icon" :size="28" />
      <p>正在加载活动详情...</p>
    </div>

    <div v-else class="detail-card">
      <header class="detail-header">
        <div class="tags-row">
          <span class="pill-tag type-tag">
            <BookOpen v-if="eventData.eventType === 'Lecture'" :size="16" />
            <Drama v-else :size="16" />
            {{ eventData.eventType === 'Lecture' ? '学术讲座' : '文艺演出' }}
          </span>
        </div>
        <h1 class="title">{{ eventData.eventTitle }}</h1>
      </header>

      <section class="info-section">
        <div class="info-item">
          <div class="icon-wrapper">
            <Clock class="info-icon" :size="22" />
          </div>
          <div class="text">
            <span class="label">演出时间</span>
            <span class="value">{{ formatTime(eventData.startTime) }}</span>
          </div>
        </div>
        
        <div class="info-item">
          <div class="icon-wrapper">
            <MapPin class="info-icon" :size="22" />
          </div>
          <div class="text">
            <span class="label">举办场馆</span>
            <span class="value">
              {{ eventData.venueName }} 
              <span class="sub-value">({{ eventData.venueLocation }})</span>
            </span>
          </div>
        </div>

        <div class="info-item">
          <div class="icon-wrapper">
            <Building2 class="info-icon" :size="22" />
          </div>
          <div class="text">
            <span class="label">主办方</span>
            <span class="value">{{ eventData.organizerName }}</span>
          </div>
        </div>
      </section>

      <footer class="action-footer">
        <div class="stock-info">
          <p class="stock-label">当前余票</p>
          <h2 class="stock-number" :class="{ 'low-stock': eventData.availTix < 10 }">
            {{ eventData.availTix }} <span class="unit">张</span>
          </h2>
        </div>
        
        <button 
          class="buy-btn" 
          @click="handleBuyTicket"
        >
          <Ticket :size="20" />
          立即抢票 <span class="test-text">(触发器测试)</span>
        </button>
      </footer>
    </div>
  </main>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import axios from 'axios'
// 引入专业线性图标
import { ChevronLeft, Loader2, BookOpen, Drama, Clock, MapPin, Building2, Ticket } from 'lucide-vue-next'

const route = useRoute()
const router = useRouter()
const eventId = route.params.id 
const eventData = ref<any>(null)

// 1. 获取活动详情
const fetchEventDetail = async () => {
  try {
    const response = await axios.get(`http://localhost:8080/event/detail?eventId=${eventId}`)
    eventData.value = response.data.data
  } catch (error) {
    console.error('获取详情失败:', error)
    alert('获取详情失败，请检查后端接口')
  }
}

// 2. 购票核心逻辑 
const handleBuyTicket = async () => {
  const currentUserId = localStorage.getItem('userId')

  if (!currentUserId) {
    alert('请先登录后再进行抢票哦！')
    router.push('/login')
    return
  }

  if (!confirm('确定要购买这张票吗？')) return

  try {
    const response = await axios.post('http://localhost:8080/ticket/buy', null, {
      params: {
        userId: currentUserId,
        eventId: eventId
      }
    })

    if (response.data.code === 200) {
      alert('🎉 抢票成功！去【我的票夹】看看吧。')
      fetchEventDetail() 
    } else {
      alert('❌ 抢票失败：' + response.data.msg) 
    }
  } catch (error) {
    console.error('购票请求报错:', error)
    alert('请求失败，请检查网络或后端状态！')
  }
}

const goBack = () => {
  router.back()
}

const formatTime = (timeStr: string) => {
  if (!timeStr) return ''
  return timeStr.replace('T', ' ').substring(0, 16)
}

onMounted(() => {
  fetchEventDetail()
})
</script>

<style scoped>
/* ================= 全局颜色变量 (大麦官方规范) ================= */
.detail-container {
  --primary-red: #FF1268;
  --primary-orange: #FF5400;
  --bg-light: #F5F6F8;
  --text-primary: #1D2129;
  --text-secondary: #666666;
  --text-white: #FFFFFF;
  --border-light: #E5E6EB;

  max-width: 800px;
  margin: 0 auto;
  padding: 30px 20px;
}

/* ================= 导航条 ================= */
.nav-bar {
  margin-bottom: 24px;
}

.back-btn {
  display: flex;
  align-items: center;
  gap: 4px;
  background: none;
  border: none;
  color: var(--text-secondary);
  font-size: 1rem;
  font-weight: 500;
  cursor: pointer;
  padding: 0;
  transition: color 0.2s;
}

.back-btn:hover {
  color: var(--primary-red);
}

/* ================= 加载状态 ================= */
.loading-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 80px 0;
  color: var(--text-secondary);
}

.spin-icon {
  animation: spin 1s linear infinite;
  color: var(--primary-red);
  margin-bottom: 12px;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

/* ================= 纯白详情卡片 ================= */
.detail-card {
  background: var(--text-white);
  border: 1px solid var(--border-light);
  border-radius: 16px;
  padding: 40px;
  box-shadow: 0 4px 24px rgba(0, 0, 0, 0.04);
}

.detail-header {
  margin-bottom: 30px;
  border-bottom: 1px solid var(--border-light);
  padding-bottom: 24px;
}

.tags-row {
  margin-bottom: 12px;
}

.type-tag {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  background-color: #FFF0F4; /* 极浅的红色背景 */
  color: var(--primary-red);
  padding: 6px 14px;
  border-radius: 999px; /* 胶囊圆角 */
  font-size: 0.85rem;
  font-weight: bold;
}

.title {
  font-size: 2rem;
  color: var(--text-primary);
  margin: 0;
  line-height: 1.4;
  font-weight: 800;
}

/* ================= 核心信息区 ================= */
.info-section {
  display: flex;
  flex-direction: column;
  gap: 20px;
  margin-bottom: 40px;
}

.info-item {
  display: flex;
  align-items: center;
  gap: 16px;
}

.icon-wrapper {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 44px;
  height: 44px;
  background: var(--bg-light);
  border-radius: 50%;
  color: var(--text-secondary);
}

.text {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.label {
  font-size: 0.85rem;
  color: var(--text-secondary);
}

.value {
  font-size: 1.1rem;
  color: var(--text-primary);
  font-weight: 600;
}

.sub-value {
  font-size: 0.9rem;
  color: var(--text-secondary);
  font-weight: normal;
}

/* ================= 底部操作区 ================= */
.action-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: var(--bg-light);
  padding: 24px 32px;
  border-radius: 12px;
  border: 1px solid var(--border-light);
}

.stock-info {
  display: flex;
  flex-direction: column;
}

.stock-label {
  margin: 0 0 4px 0;
  color: var(--text-secondary);
  font-size: 0.9rem;
}

.stock-number {
  margin: 0;
  color: var(--text-primary);
  font-size: 2rem;
  font-weight: 800;
}

.stock-number.low-stock {
  color: var(--primary-orange); /* 余票不足变为活力橙 */
}

.unit {
  font-size: 1rem;
  font-weight: normal;
  color: var(--text-secondary);
}

/* 大麦红购买按钮 */
.buy-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  background: var(--primary-red);
  color: var(--text-white);
  border: none;
  padding: 16px 40px;
  font-size: 1.2rem;
  font-weight: bold;
  border-radius: 999px; /* 胶囊圆角 */
  cursor: pointer;
  transition: all 0.2s ease;
  box-shadow: 0 4px 16px rgba(255, 18, 104, 0.25);
}

.buy-btn:hover {
  background: #e00d5a;
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(255, 18, 104, 0.35);
}

.buy-btn:active {
  transform: translateY(0);
}

.test-text {
  font-size: 0.85rem;
  font-weight: normal;
  opacity: 0.8;
}
</style>